import 'dart:developer' as dev;
import '../models/announcement.dart';
import '../services/supabase_service.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

/// Repository for managing Announcement data
/// Provides CRUD operations for announcements
class AnnouncementRepository {
  final SupabaseService _supabaseService;

  AnnouncementRepository(this._supabaseService);

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all announcements with optional pagination
  Future<List<Announcement>> getAllAnnouncements({
    int? limit,
    int? offset,
  }) async {
    try {
      dev.log('Fetching announcements', name: 'AnnouncementRepository');

      var query = _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null)
        query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;

      dev.log(
        'Successfully fetched ${(response as List).length} announcements',
        name: 'AnnouncementRepository',
      );

      return (response as List<dynamic>)
          .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching announcements',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load announcements: $e');
    }
  }

  /// Get active announcements
  Future<List<Announcement>> getActiveAnnouncements({int? limit}) async {
    try {
      dev.log('Fetching active announcements', name: 'AnnouncementRepository');

      var query = _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('is_active', true)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      // Filter by validUntil if present
      final announcements = (response as List<dynamic>)
          .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
          .where((announcement) {
            if (announcement.validUntil == null) return true;
            return announcement.validUntil!.isAfter(DateTime.now());
          })
          .toList();

      dev.log(
        'Found ${announcements.length} active announcements',
        name: 'AnnouncementRepository',
      );

      return announcements;
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching active announcements',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load active announcements: $e');
    }
  }

  /// Get announcement by ID
  Future<Announcement?> getAnnouncementById(int id) async {
    try {
      dev.log(
        'Fetching announcement with ID: $id',
        name: 'AnnouncementRepository',
      );

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        dev.log(
          'Announcement not found with ID: $id',
          name: 'AnnouncementRepository',
        );
        return null;
      }

      return Announcement.fromDb(response);
    } catch (e, stackTrace) {
      dev.log(
        'Error fetching announcement by ID',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to load announcement: $e');
    }
  }

  /// Get announcement by ID scoped to a specific unit.
  ///
  /// Fail-open: if unit scoping is not available (e.g., missing column) or
  /// any error happens, this falls back to global getAnnouncementById.
  Future<Announcement?> getAnnouncementByIdForUnit(
    int id,
    String unitId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('id', id)
          .eq('unit_id', unitId)
          .maybeSingle();

      if (response == null) return null;
      return Announcement.fromDb(response);
    } catch (e) {
      dev.log(
        'Fail-open: getAnnouncementByIdForUnit fallback: $e',
        name: 'AnnouncementRepository',
      );
      return getAnnouncementById(id);
    }
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

  /// Search announcements
  Future<List<Announcement>> searchAnnouncements(String query) async {
    try {
      dev.log(
        'Searching announcements with query: $query',
        name: 'AnnouncementRepository',
      );

      final response = await _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Announcement.fromDb(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log(
        'Error searching announcements',
        name: 'AnnouncementRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Failed to search announcements: $e');
    }
  }

  // ============================================

  /// Get all announcements scoped to a specific unit (org_units)
  Future<List<Announcement>> getAllAnnouncementsForUnit(
    String unitId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabaseService.client
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .select()
          .eq('unit_id', unitId)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null)
        query = query.range(offset, offset + (limit ?? 50) - 1);

      final response = await query;
      return (response as List)
          .map((e) => Announcement.fromDb(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log(
        'Error fetching unit announcements: $e',
        name: 'AnnouncementRepository',
      );
      return [];
    }
  }

  /// Get active announcements scoped to a specific unit (org_units)
  ///
  /// Active means: is_active = true and (valid_until is null OR valid_until > now)
  ///
  /// Fail-open: if unit scoping is not yet available (e.g., missing column) or
  /// any error happens, this returns an empty list.
  Future<List<Announcement>> getActiveAnnouncementsForUnit(
    String unitId, {
    int limit = 5,
  }) async {
    try {
      // NOTE: valid_until is often DATE. Use YYYY-MM-DD to avoid PostgREST 400.
      final now = DateTime.now();
      final nowIsoDate =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Try unit-scoped query first. If unit_id is missing, fall back to global.
      dynamic response;
      try {
        response = await _supabaseService.client
            .from(PwfDatabaseOwnerSurfaces.announcements)
            .select()
            .eq('unit_id', unitId)
            .eq('is_active', true)
            .or('valid_until.is.null,valid_until.gt.$nowIsoDate')
            .order('created_at', ascending: false)
            .limit(limit);
      } catch (e) {
        response = await _supabaseService.client
            .from(PwfDatabaseOwnerSurfaces.announcements)
            .select()
            .eq('is_active', true)
            .or('valid_until.is.null,valid_until.gt.$nowIsoDate')
            .order('created_at', ascending: false)
            .limit(limit);
      }

      return (response as List)
          .map((e) => Announcement.fromDb(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log(
        'Error fetching active unit announcements: $e',
        name: 'AnnouncementRepository',
      );
      return [];
    }
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
