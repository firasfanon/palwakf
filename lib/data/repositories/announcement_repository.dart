import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import '../models/announcement.dart';
import '../services/media_compat_mapper.dart';
import '../services/supabase_service.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/public_runtime/pwf_public_media_runtime_gateway.dart';

/// Repository for managing Announcement data
/// Provides CRUD operations for announcements
class AnnouncementRepository {
  final SupabaseService _supabaseService;

  static const bool _forceLegacyPublicMedia = bool.fromEnvironment(
    'PWF_FORCE_LEGACY_PUBLIC_MEDIA',
    defaultValue: false,
  );
  static const bool _mediaOwnerReadDefault = !_forceLegacyPublicMedia;
  static const Duration _mediaOwnerRuntimeTimeout = Duration(seconds: 8);

  AnnouncementRepository(this._supabaseService);

  Future<List<Announcement>> _getCompatAnnouncements({
    int? limit,
    int? offset,
    String? unitSlug,
    String? ownerOrgUnitId,
    Set<String>? unitScopeKeys,
    String? searchQuery,
  }) async {
    if (!_mediaOwnerReadDefault) {
      _logMediaRuntimeFallback(
        family: 'announcements',
        reason: 'forced-legacy-public-media',
      );
      return const <Announcement>[];
    }

    try {
      final unitRef = unitSlug?.trim().isNotEmpty == true
          ? unitSlug!.trim()
          : (ownerOrgUnitId?.trim().isNotEmpty == true
              ? ownerOrgUnitId!.trim()
              : 'home');
      final rows = await PwfPublicMediaRuntimeGateway(
        _supabaseService.client,
      ).fetchFeed(
        unitRef: unitRef,
        familyKey: 'announcements',
        limit: (limit ?? 50).clamp(1, 50).toInt(),
        offset: 0,
      ).timeout(_mediaOwnerRuntimeTimeout);

      var items = rows
          .map(MediaCompatMapper.announcementFromCompatRow)
          .where((announcement) => announcement.isActive)
          .toList();

      final q = searchQuery?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        items = items.where((announcement) {
          return announcement.title.toLowerCase().contains(q) ||
              announcement.content.toLowerCase().contains(q) ||
              announcement.targetAudience.toLowerCase().contains(q);
        }).toList();
      }

      final now = DateTime.now();
      items = items
          .where(
            (announcement) =>
                announcement.validUntil == null ||
                announcement.validUntil!.isAfter(now),
          )
          .toList();
      _sortAnnouncementOwnerRows(items);
      final windowed = _window(items, limit: limit, offset: offset);
      _logMediaRuntimeSource(
        family: 'announcements',
        surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2,
        rows: windowed.length,
      );
      return windowed;
    } on TimeoutException {
      _logMediaRuntimeFallback(family: 'announcements', reason: 'public-rpc-timeout');
      return const <Announcement>[];
    } catch (_) {
      if (kDebugMode) {
        debugPrint(
          'PWF_MEDIA_CENTER_PUBLIC_RPC_UNAVAILABLE '
          'family=announcements '
          'rpc=${PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2} '
          'fallback=false',
        );
      }
      _logMediaRuntimeFallback(family: 'announcements', reason: 'public-rpc-failure');
      return const <Announcement>[];
    }
  }

  void _sortAnnouncementOwnerRows(List<Announcement> items) {
    items.sort((a, b) {
      final pinned = _boolDesc(a.isPinned, b.isPinned);
      if (pinned != 0) return pinned;
      final order = a.sortOrder.compareTo(b.sortOrder);
      if (order != 0) return order;
      final priority = b.priority.index.compareTo(a.priority.index);
      if (priority != 0) return priority;
      final aDate = a.publishAt ?? a.createdAt;
      final bDate = b.publishAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
  }

  int _boolDesc(bool a, bool b) => a == b ? 0 : (a ? -1 : 1);

  List<T> _window<T>(List<T> items, {int? limit, int? offset}) {
    final start = offset == null || offset < 0 ? 0 : offset;
    if (start >= items.length) return <T>[];
    final end = limit == null
        ? items.length
        : (start + limit).clamp(0, items.length).toInt();
    return items.sublist(start, end);
  }

  void _logMediaRuntimeSource({
    required String family,
    required String surface,
    required int rows,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_ROOT_CUTOVER '
      'family=$family '
      'public_rpc=true '
      'surface=$surface '
      'projection=allow-listed '
      'filtering=server-resolved-unit '
      'ordering=server-side '
      'rows=$rows '
      'decision=media-center-owner-read-default-root-cutover',
    );
  }

  void _logMediaRuntimeFallback({
    required String family,
    required String reason,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_LEGACY_FALLBACK_ONLY '
      'family=$family '
      'legacy_public_fallback=false '
      'reason=$reason '
      'decision=media-center-owner-read-no-public-fallback',
    );
  }

  Future<Announcement?> _getCompatAnnouncementByContentId(
    String contentId, {
    String? unitSlug,
    String? ownerOrgUnitId,
  }) async {
    if (!_mediaOwnerReadDefault) return null;
    final safeContentId = contentId.trim();
    if (safeContentId.isEmpty) return null;
    final unitRef = unitSlug?.trim().isNotEmpty == true
        ? unitSlug!.trim()
        : (ownerOrgUnitId?.trim().isNotEmpty == true
            ? ownerOrgUnitId!.trim()
            : 'home');
    try {
      final rows = await PwfPublicMediaRuntimeGateway(_supabaseService.client)
          .fetchDetail(
            unitRef: unitRef,
            contentId: safeContentId,
            familyKey: 'announcements',
          )
          .timeout(_mediaOwnerRuntimeTimeout);
      if (rows.isEmpty) return null;
      final item = MediaCompatMapper.announcementFromCompatRow(rows.first);
      if (!item.isActive) return null;
      if (item != null) {
        _logMediaRuntimeSource(
          family: 'announcements',
          surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeDetailRpcV2,
          rows: 1,
        );
      }
      return item;
    } on TimeoutException {
      _logMediaRuntimeFallback(
        family: 'announcements',
        reason: 'public-detail-rpc-timeout',
      );
      return null;
    } catch (e, stackTrace) {
      dev.log(
        'Media Center public announcement detail RPC failed without feed fallback',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      _logMediaRuntimeFallback(
        family: 'announcements',
        reason: 'public-detail-rpc-failure',
      );
      return null;
    }
  }


  /// Public runtime resolver for B-1A media compatibility announcement details.
  ///
  /// This intentionally checks the compatibility view before unit lookup so the
  /// public detail page cannot remain in a loading state when legacy unit
  /// scoping is slow or unavailable. Legacy fallback remains unchanged.
  Future<Announcement?> getCompatRuntimeAnnouncementById(int id) {
    return _getCompatAnnouncementByContentId(id.toString());
  }

  Future<Announcement?> getAnnouncementByContentIdForUnit(
    String contentId,
    String unitId, {
    String? unitSlug,
  }) {
    return _getCompatAnnouncementByContentId(
      contentId,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
  }

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all announcements with optional pagination.
  /// Public runtime reads only the owner-schema view; it does not fall back to
  /// public.announcements when the view is unavailable or legitimately empty.
  Future<List<Announcement>> getAllAnnouncements({
    int? limit,
    int? offset,
  }) {
    return _getCompatAnnouncements(limit: limit, offset: offset);
  }

  /// Get active announcements.
  Future<List<Announcement>> getActiveAnnouncements({int? limit}) {
    return _getCompatAnnouncements(limit: limit);
  }

  /// Get announcement by ID.
  Future<Announcement?> getAnnouncementById(int id) {
    return _getCompatAnnouncementByContentId(id.toString());
  }

  /// Get announcement by ID scoped to a specific unit.
  ///
  /// Unit-scoped detail lookup.
  ///
  /// If the item is not owned by the requested unit, return null instead of
  /// falling back to global/ministry content.
  Future<Announcement?> getAnnouncementByIdForUnit(
    int id,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatAnnouncementByContentId(
      id.toString(),
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }

  /// Get announcements by priority
  Future<List<Announcement>> getAnnouncementsByPriority(
    Priority priority, {
    int? limit,
  }) async {
    try {
      dev.log(
        'Fetching announcements with priority: ${priority.name}',
        name: 'AnnouncementRepository',
      );

      var query = _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('priority', priority.name)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching announcements by priority',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load announcements by priority: $e');
    }
  }

  /// Get announcements by target audience
  Future<List<Announcement>> getAnnouncementsByAudience(
    String targetAudience, {
    int? limit,
  }) async {
    try {
      dev.log(
        'Fetching announcements for audience: $targetAudience',
        name: 'AnnouncementRepository',
      );

      var query = _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('target_audience', targetAudience)
          .eq('is_active', true)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching announcements by audience',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load announcements by audience: $e');
    }
  }

  /// Get urgent announcements
  Future<List<Announcement>> getUrgentAnnouncements() async {
    try {
      dev.log('Fetching urgent announcements', name: 'AnnouncementRepository');

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('is_active', true)
          .or('priority.eq.urgent,priority.eq.critical')
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching urgent announcements',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load urgent announcements: $e');
    }
  }

  /// Search announcements.
  Future<List<Announcement>> searchAnnouncements(String query) {
    return _getCompatAnnouncements(searchQuery: query);
  }

  // ============================================

  /// Get all announcements scoped to a specific unit (org_units)
  Future<List<Announcement>> getAllAnnouncementsForUnit(
    String unitId, {
    String? unitSlug,
    int? limit,
    int? offset,
  }) async {
    final compat = await _getCompatAnnouncements(
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
      limit: limit,
      offset: offset,
    );
    return compat;
  }

  /// Get active announcements scoped to a specific unit (org_units)
  ///
  /// Active means: is_active = true and (valid_until is null OR valid_until > now)
  ///
  /// Fail-open: if unit scoping is not yet available (e.g., missing column) or
  /// any error happens, this returns an empty list.
  Future<List<Announcement>> getActiveAnnouncementsForUnit(
    String unitId, {
    String? unitSlug,
    int limit = 5,
  }) async {
    final compat = await _getCompatAnnouncements(
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
      limit: limit,
    );
    return compat;
  }

  // CREATE OPERATIONS
  // ============================================

  /// Create a new announcement
  Future<Announcement> createAnnouncement(Announcement announcement) async {
    try {
      dev.log(
        'Creating new announcement: ${announcement.title}',
        name: 'AnnouncementRepository',
      );

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .insert(announcement.toDb())
          .select()
          .single();

      dev.log(
        'Announcement created successfully with ID: ${response['id']}',
        name: 'AnnouncementRepository',
      );

      return Announcement.fromDb(response);
    } catch (e, stackTrace) {
      dev.log(
        'Error creating announcement',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to create announcement: $e');
    }
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update an announcement
  Future<Announcement> updateAnnouncement(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      dev.log(
        'Updating announcement with ID: $id',
        name: 'AnnouncementRepository',
      );

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      dev.log(
        'Announcement updated successfully',
        name: 'AnnouncementRepository',
      );

      return Announcement.fromDb(response);
    } catch (e, stackTrace) {
      dev.log(
        'Error updating announcement',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update announcement: $e');
    }
  }

  /// Activate an announcement
  Future<Announcement> activateAnnouncement(int id) async {
    try {
      dev.log('Activating announcement: $id', name: 'AnnouncementRepository');
      return await updateAnnouncement(id, {'is_active': true});
    } catch (e) {
      throw Exception('Failed to activate announcement: $e');
    }
  }

  /// Deactivate an announcement
  Future<Announcement> deactivateAnnouncement(int id) async {
    try {
      dev.log('Deactivating announcement: $id', name: 'AnnouncementRepository');
      return await updateAnnouncement(id, {'is_active': false});
    } catch (e) {
      throw Exception('Failed to deactivate announcement: $e');
    }
  }

  /// Update announcement priority
  Future<Announcement> updateAnnouncementPriority(
    int id,
    Priority priority,
  ) async {
    try {
      dev.log(
        'Updating announcement priority to: ${priority.name}',
        name: 'AnnouncementRepository',
      );
      return await updateAnnouncement(id, {'priority': priority.name});
    } catch (e) {
      throw Exception('Failed to update announcement priority: $e');
    }
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Delete an announcement
  Future<void> deleteAnnouncement(int id) async {
    try {
      dev.log(
        'Deleting announcement with ID: $id',
        name: 'AnnouncementRepository',
      );

      await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .delete()
          .eq('id', id);

      dev.log(
        'Announcement deleted successfully',
        name: 'AnnouncementRepository',
      );
    } catch (e, stackTrace) {
      dev.log(
        'Error deleting announcement',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to delete announcement: $e');
    }
  }

  /// Deactivate expired announcements
  Future<int> deactivateExpiredAnnouncements() async {
    try {
      dev.log(
        'Deactivating expired announcements',
        name: 'AnnouncementRepository',
      );

      final allAnnouncements = await getAllAnnouncements();
      final now = DateTime.now();
      int count = 0;

      for (var announcement in allAnnouncements) {
        if (announcement.isActive &&
            announcement.validUntil != null &&
            announcement.validUntil!.isBefore(now)) {
          await deactivateAnnouncement(announcement.id);
          count++;
        }
      }

      dev.log(
        'Deactivated $count expired announcements',
        name: 'AnnouncementRepository',
      );

      return count;
    } catch (e, stackTrace) {
      dev.log(
        'Error deactivating expired announcements',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to deactivate expired announcements: $e');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get announcement statistics
  Future<Map<String, dynamic>> getAnnouncementStatistics() async {
    try {
      dev.log(
        'Calculating announcement statistics',
        name: 'AnnouncementRepository',
      );

      final allAnnouncements = await getAllAnnouncements();
      final activeAnnouncements = await getActiveAnnouncements();

      return {
        'total': allAnnouncements.length,
        'active': activeAnnouncements.length,
        'inactive': allAnnouncements.length - activeAnnouncements.length,
        'by_priority': {
          for (var priority in Priority.values)
            priority.name: allAnnouncements
                .where((a) => a.priority == priority)
                .length,
        },
        'urgent_active': activeAnnouncements
            .where(
              (a) =>
                  a.priority == Priority.urgent ||
                  a.priority == Priority.critical,
            )
            .length,
      };
    } catch (e, stackTrace) {
      dev.log(
        'Error calculating statistics',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to calculate announcement statistics: $e');
    }
  }
}
