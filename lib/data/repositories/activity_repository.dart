import 'dart:developer' as dev;
import '../models/activity.dart';
import '../services/supabase_service.dart';

/// Repository for managing Activity data
/// Provides CRUD operations following DRY principles
class ActivityRepository {
  final SupabaseService _supabaseService;

  ActivityRepository(this._supabaseService);

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all activities with optional pagination
  Future<List<Activity>> getAllActivities({
    int? limit,
    int? offset,
  }) async {
    try {
      dev.log('Fetching activities', name: 'ActivityRepository');

      var query = _supabaseService.client
          .from('activities')
          .select()
          .order('start_date', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;

      dev.log('Successfully fetched ${(response as List).length} activities',
          name: 'ActivityRepository');

      return (response as List<dynamic>)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching activities',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load activities: $e');
    }
  }

  /// Get activity by ID
  Future<Activity?> getActivityById(int id) async {
    try {
      dev.log('Fetching activity with ID: $id', name: 'ActivityRepository');

      final response = await _supabaseService.client
          .from('activities')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        dev.log('Activity not found with ID: $id', name: 'ActivityRepository');
        return null;
      }

      return Activity.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error fetching activity by ID',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load activity: $e');
    }
  }

  /// Get activities by category
  Future<List<Activity>> getActivitiesByCategory(
    ActivityCategory category, {
    int? limit,
  }) async {
    try {
      dev.log('Fetching activities for category: ${category.name}',
          name: 'ActivityRepository');

      var query = _supabaseService.client
          .from('activities')
          .select()
          .eq('category', category.name)
          .order('start_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching activities by category',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load activities by category: $e');
    }
  }

  /// Get activities by status
  Future<List<Activity>> getActivitiesByStatus(
    ActivityStatus status, {
    int? limit,
  }) async {
    try {
      dev.log('Fetching activities with status: ${status.name}',
          name: 'ActivityRepository');

      var query = _supabaseService.client
          .from('activities')
          .select()
          .eq('status', status.name)
          .order('start_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching activities by status',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load activities by status: $e');
    }
  }

  /// Get upcoming activities
  Future<List<Activity>> getUpcomingActivities({int limit = 10}) async {
    try {
      dev.log('Fetching upcoming activities', name: 'ActivityRepository');

      final response = await _supabaseService.client
          .from('activities')
          .select()
          .eq('status', 'upcoming')
          .gte('start_date', DateTime.now().toIso8601String())
          .order('start_date', ascending: true)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching upcoming activities',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load upcoming activities: $e');
    }
  }

  /// Get activities by governorate
  Future<List<Activity>> getActivitiesByGovernorate(
    String governorate, {
    int? limit,
  }) async {
    try {
      dev.log('Fetching activities for governorate: $governorate',
          name: 'ActivityRepository');

      var query = _supabaseService.client
          .from('activities')
          .select()
          .eq('governorate', governorate)
          .order('start_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching activities by governorate',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load activities by governorate: $e');
    }
  }

  /// Search activities by title or description
  Future<List<Activity>> searchActivities(String query) async {
    try {
      dev.log('Searching activities with query: $query',
          name: 'ActivityRepository');

      final response = await _supabaseService.client
          .from('activities')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('start_date', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Activity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error searching activities',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to search activities: $e');
    }
  }

  // ============================================
  

  /// Get all activities scoped to a specific unit (org_units)
  Future<List<Activity>> getAllActivitiesForUnit(
    String unitId, {
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabaseService.client
          .from('activities')
          .select()
          .eq('unit_id', unitId)
          .order('start_date', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 50) - 1);

      final response = await query;
      return (response as List).map((e) => Activity.fromJson(e)).toList();
    } catch (e) {
      dev.log('Error fetching unit activities: $e', name: 'ActivityRepository');
      return [];
    }
  }

  Future<List<Activity>> getActivitiesByCategoryForUnit(
    ActivityCategory category,
    String unitId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('activities')
          .select()
          .eq('unit_id', unitId)
          .eq('category', category.name)
          .order('start_date', ascending: false);
      return (response as List).map((e) => Activity.fromJson(e)).toList();
    } catch (e) {
      dev.log('Error fetching unit activities by category: $e', name: 'ActivityRepository');
      return [];
    }
  }

  Future<List<Activity>> getActivitiesByStatusForUnit(
    ActivityStatus status,
    String unitId,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('activities')
          .select()
          .eq('unit_id', unitId)
          .eq('status', status.name)
          .order('start_date', ascending: false);
      return (response as List).map((e) => Activity.fromJson(e)).toList();
    } catch (e) {
      dev.log('Error fetching unit activities by status: $e', name: 'ActivityRepository');
      return [];
    }
  }

// CREATE OPERATIONS
  // ============================================

  /// Create a new activity
  Future<Activity> createActivity(Activity activity) async {
    try {
      dev.log('Creating new activity: ${activity.title}',
          name: 'ActivityRepository');

      final response = await _supabaseService.client
          .from('activities')
          .insert(activity.toJson())
          .select()
          .single();

      dev.log('Activity created successfully with ID: ${response['id']}',
          name: 'ActivityRepository');

      return Activity.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error creating activity',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
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
          .from('activities')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      dev.log('Activity updated successfully', name: 'ActivityRepository');

      return Activity.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error updating activity',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to update activity: $e');
    }
  }

  /// Update activity status
  Future<Activity> updateActivityStatus(int id, ActivityStatus status) async {
    try {
      dev.log('Updating activity status to: ${status.name}',
          name: 'ActivityRepository');

      return await updateActivity(id, {'status': status.name});
    } catch (e) {
      throw Exception('Failed to update activity status: $e');
    }
  }

  /// Increment participant count
  Future<Activity> incrementParticipants(int id) async {
    try {
      dev.log('Incrementing participant count for activity: $id',
          name: 'ActivityRepository');

      final activity = await getActivityById(id);
      if (activity == null) {
        throw Exception('Activity not found');
      }

      return await updateActivity(id, {
        'current_participants': activity.currentParticipants + 1,
      });
    } catch (e, stackTrace) {
      dev.log('Error incrementing participants',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
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
          .from('activities')
          .delete()
          .eq('id', id);

      dev.log('Activity deleted successfully', name: 'ActivityRepository');
    } catch (e, stackTrace) {
      dev.log('Error deleting activity',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
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
        'upcoming': allActivities.where((a) => a.status == ActivityStatus.upcoming).length,
        'ongoing': allActivities.where((a) => a.status == ActivityStatus.ongoing).length,
        'completed': allActivities.where((a) => a.status == ActivityStatus.completed).length,
        'by_category': {
          for (var category in ActivityCategory.values)
            category.name: allActivities.where((a) => a.category == category).length,
        },
        'by_type': {
          for (var type in ActivityType.values)
            type.name: allActivities.where((a) => a.type == type).length,
        },
      };
    } catch (e, stackTrace) {
      dev.log('Error calculating statistics',
          name: 'ActivityRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to calculate activity statistics: $e');
    }
  }
}
