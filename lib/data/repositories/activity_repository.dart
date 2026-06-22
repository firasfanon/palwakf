import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:waqf/core/content/pwf_temporal_ordering.dart';
import '../models/activity.dart';
import '../services/media_compat_mapper.dart';
import '../services/supabase_service.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/public_runtime/pwf_public_media_runtime_gateway.dart';

/// Repository for managing Activity data
/// Provides CRUD operations following DRY principles
class ActivityRepository {
  final SupabaseService _supabaseService;

  ActivityRepository(this._supabaseService);

  static const bool _forceLegacyPublicMedia = bool.fromEnvironment(
    'PWF_FORCE_LEGACY_PUBLIC_MEDIA',
    defaultValue: false,
  );
  static const bool _mediaOwnerReadDefault = !_forceLegacyPublicMedia;
  static const Duration _mediaOwnerRuntimeTimeout = Duration(seconds: 8);

  Future<List<Activity>> _getCompatActivities({
    int? limit,
    int? offset,
    String? unitSlug,
    String? ownerOrgUnitId,
    Set<String>? unitScopeKeys,
    ActivityCategory? category,
    ActivityStatus? status,
    String? searchQuery,
  }) async {
    if (!_mediaOwnerReadDefault) {
      _logMediaRuntimeFallback(
        family: 'activities',
        reason: 'forced-legacy-public-media',
      );
      return const <Activity>[];
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
        familyKey: 'activities',
        limit: (limit ?? 50).clamp(1, 50).toInt(),
        offset: 0,
      ).timeout(_mediaOwnerRuntimeTimeout);

      var items = rows
          .map(MediaCompatMapper.activityFromCompatRow)
          .where((activity) => activity.status != ActivityStatus.cancelled)
          .toList();

      if (category != null) {
        items = items.where((item) => item.category == category).toList();
      }
      if (status != null) {
        items = items.where((item) => item.status == status).toList();
      }

      final q = searchQuery?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        items = items.where((activity) {
          return activity.title.toLowerCase().contains(q) ||
              activity.description.toLowerCase().contains(q) ||
              activity.location.toLowerCase().contains(q);
        }).toList();
      }
      _sortActivityOwnerRows(items);
      final windowed = _window(items, limit: limit, offset: offset);
      _logMediaRuntimeSource(
        family: 'activities',
        surface: PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2,
        rows: windowed.length,
      );
      return windowed;
    } on TimeoutException {
      _logMediaRuntimeFallback(family: 'activities', reason: 'public-rpc-timeout');
      return const <Activity>[];
    } catch (_) {
      if (kDebugMode) {
        debugPrint(
          'PWF_MEDIA_CENTER_PUBLIC_RPC_UNAVAILABLE '
          'family=activities '
          'rpc=${PwfDatabaseOwnerSurfaces.publicMediaRuntimeFeedRpcV2} '
          'fallback=false',
        );
      }
      _logMediaRuntimeFallback(family: 'activities', reason: 'public-rpc-failure');
      return const <Activity>[];
    }
  }

  void _sortActivityOwnerRows(List<Activity> items) {
    items.sort(
      (a, b) => PwfTemporalOrdering.newestFirst(
        a.startDate,
        b.startDate,
        leftStableKey: a.id.toString(),
        rightStableKey: b.id.toString(),
      ),
    );
  }

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
      'ordering=newest-first-client-enforced '
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

  Future<Activity?> _getCompatActivityById(
    int id, {
    String? unitSlug,
    String? ownerOrgUnitId,
    Set<String>? unitScopeKeys,
  }) async {
    final items = await _getCompatActivities(
      limit: 500,
      unitSlug: unitSlug,
      ownerOrgUnitId: ownerOrgUnitId,
      unitScopeKeys: unitScopeKeys,
    );
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all activities with optional pagination.
  Future<List<Activity>> getAllActivities({int? limit, int? offset}) {
    return _getCompatActivities(limit: limit, offset: offset);
  }

  /// Get activity by ID.
  Future<Activity?> getActivityById(int id) {
    return _getCompatActivityById(id);
  }

  /// Get activity by ID scoped to a specific unit.
  ///
  /// Unit-scoped detail lookup.
  ///
  /// If the item is not owned by the requested unit, return null instead of
  /// falling back to global/ministry content.
  Future<Activity?> getActivityByIdForUnit(
    int id,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatActivityById(
      id,
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
    );
    return compat;
  }


  /// Resolves a public activity detail by opaque server-issued content_id.
  ///
  /// The public RPC receives both the unit reference and family key. It returns
  /// null when the content is not published for that unit. No bounded feed,
  /// cache, legacy table, or ministry fallback is used for this route.
  Future<Activity?> getActivityByContentIdForUnit(
    String contentId,
    String unitId, {
    String? unitSlug,
  }) async {
    if (!_mediaOwnerReadDefault) return null;

    final safeContentId = contentId.trim();
    final safeUnitId = unitId.trim();
    if (safeContentId.isEmpty || safeUnitId.isEmpty) return null;

    final unitRef = unitSlug?.trim().isNotEmpty == true
        ? unitSlug!.trim()
        : safeUnitId;

    try {
      final rows = await PwfPublicMediaRuntimeGateway(
        _supabaseService.client,
      ).fetchDetail(
        unitRef: unitRef,
        contentId: safeContentId,
        familyKey: 'activities',
      ).timeout(_mediaOwnerRuntimeTimeout);

      if (rows.isEmpty) return null;
      return MediaCompatMapper.activityFromCompatRow(rows.first);
    } on TimeoutException {
      _logMediaRuntimeFallback(
        family: 'activities',
        reason: 'public-detail-rpc-timeout',
      );
      return null;
    } catch (error, stackTrace) {
      dev.log(
        'Media Center public activity detail resolver failed',
        name: 'ActivityRepository',
        error: error,
        stackTrace: stackTrace,
      );
      _logMediaRuntimeFallback(
        family: 'activities',
        reason: 'public-detail-rpc-failure',
      );
      return null;
    }
  }

  /// Get activities by category.
  Future<List<Activity>> getActivitiesByCategory(
    ActivityCategory category, {
    int? limit,
  }) {
    return _getCompatActivities(limit: limit, category: category);
  }

  /// Get activities by status.
  Future<List<Activity>> getActivitiesByStatus(
    ActivityStatus status, {
    int? limit,
  }) {
    return _getCompatActivities(limit: limit, status: status);
  }

  /// Get upcoming activities.
  Future<List<Activity>> getUpcomingActivities({int limit = 10}) {
    return _getCompatActivities(
      limit: limit,
      status: ActivityStatus.upcoming,
    );
  }

  /// Get upcoming activities scoped to a specific unit (org_units)
  ///
  /// Upcoming means: status = 'upcoming' and start_date >= now
  /// Ordered ascending by start_date.
  ///
  /// Fail-open: returns empty list if unit scoping isn't available yet or on error.
  Future<List<Activity>> getUpcomingActivitiesForUnit(
    String unitId, {
    String? unitSlug,
    int limit = 6,
  }) async {
    final compat = await _getCompatActivities(
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
      limit: limit,
      status: ActivityStatus.upcoming,
    );
    return compat;
  }

  /// Get activities by governorate
  Future<List<Activity>> getActivitiesByGovernorate(
    String governorate, {
    int? limit,
  }) async {
    try {
      dev.log(
        'Fetching activities for governorate: $governorate',
        name: 'ActivityRepository',
      );

      var query = _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.activities)
          .select()
          .eq('governorate', governorate)
          .order('start_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Activity.fromDb(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching activities by governorate',
        name: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load activities by governorate: $e');
    }
  }

  /// Search activities by title or description.
  Future<List<Activity>> searchActivities(String query) {
    return _getCompatActivities(searchQuery: query, limit: 50);
  }

  // ============================================

  /// Get all activities scoped to a specific unit (org_units)
  Future<List<Activity>> getAllActivitiesForUnit(
    String unitId, {
    String? unitSlug,
    int? limit,
    int? offset,
  }) async {
    final compat = await _getCompatActivities(
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
      limit: limit,
      offset: offset,
    );
    return compat;
  }

  Future<List<Activity>> getActivitiesByCategoryForUnit(
    ActivityCategory category,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatActivities(
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
      category: category,
    );
    return compat;
  }

  Future<List<Activity>> getActivitiesByStatusForUnit(
    ActivityStatus status,
    String unitId, {
    String? unitSlug,
  }) async {
    final compat = await _getCompatActivities(
      unitSlug: unitSlug ?? unitId,
      ownerOrgUnitId: unitId,
      status: status,
    );
    return compat;
  }

  // CREATE OPERATIONS
  // ============================================

  /// Create a new activity
  Future<Activity> createActivity(Activity activity) async {
    try {
      dev.log(
        'Creating new activity: ${activity.title}',
        name: 'ActivityRepository',
      );

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.activities)
          .insert(activity.toDb())
          .select()
          .single();

      dev.log(
        'Activity created successfully with ID: ${response['id']}',
        name: 'ActivityRepository',
      );

      return Activity.fromDb(response);
    } catch (e, stackTrace) {
      dev.log(
        'Error creating activity',
        name: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to create activity: $e');
    }
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update an existing activity
  Future<Activity> updateActivity(int id, Map<String, dynamic> updates) async {
    try {
      dev.log('Updating activity with ID: $id', name: 'ActivityRepository');

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.activities)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      dev.log('Activity updated successfully', name: 'ActivityRepository');

      return Activity.fromDb(response);
    } catch (e, stackTrace) {
      dev.log(
        'Error updating activity',
        name: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to update activity: $e');
    }
  }

  /// Update activity status
  Future<Activity> updateActivityStatus(int id, ActivityStatus status) async {
    try {
      dev.log(
        'Updating activity status to: ${status.name}',
        name: 'ActivityRepository',
      );

      return await updateActivity(id, {'status': status.name});
    } catch (e) {
      throw Exception('Failed to update activity status: $e');
    }
  }

  /// Increment participant count
  Future<Activity> incrementParticipants(int id) async {
    try {
      dev.log(
        'Incrementing participant count for activity: $id',
        name: 'ActivityRepository',
      );

      final activity = await getActivityById(id);
      if (activity == null) {
        throw Exception('Activity not found');
      }

      return await updateActivity(id, {
        'current_participants': activity.currentParticipants + 1,
      });
    } catch (e, stackTrace) {
      dev.log(
        'Error incrementing participants',
        name: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to increment participants: $e');
    }
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Delete an activity
  Future<void> deleteActivity(int id) async {
    try {
      dev.log('Deleting activity with ID: $id', name: 'ActivityRepository');

      await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.activities)
          .delete()
          .eq('id', id);

      dev.log('Activity deleted successfully', name: 'ActivityRepository');
    } catch (e, stackTrace) {
      dev.log(
        'Error deleting activity',
        name: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to delete activity: $e');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get activity statistics
  Future<Map<String, dynamic>> getActivityStatistics() async {
    try {
      dev.log('Calculating activity statistics', name: 'ActivityRepository');

      final allActivities = await getAllActivities();

      return {
        'total': allActivities.length,
        'upcoming': allActivities
            .where((a) => a.status == ActivityStatus.upcoming)
            .length,
        'ongoing': allActivities
            .where((a) => a.status == ActivityStatus.ongoing)
            .length,
        'completed': allActivities
            .where((a) => a.status == ActivityStatus.completed)
            .length,
        'by_category': {
          for (var category in ActivityCategory.values)
            category.name: allActivities
                .where((a) => a.category == category)
                .length,
        },
        'by_type': {
          for (var type in ActivityType.values)
            type.name: allActivities.where((a) => a.type == type).length,
        },
      };
    } catch (e, stackTrace) {
      dev.log(
        'Error calculating statistics',
        name: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to calculate activity statistics: $e');
    }
  }
}
