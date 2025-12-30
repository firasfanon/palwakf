import 'dart:developer' as dev;
import '../models/case.dart';
import '../services/supabase_service.dart';

/// Repository for managing Case data
/// Provides CRUD operations for legal cases
class CaseRepository {
  final SupabaseService _supabaseService;

  CaseRepository(this._supabaseService);

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all cases with optional pagination
  Future<List<Case>> getAllCases({
    int? limit,
    int? offset,
  }) async {
    try {
      dev.log('Fetching cases', name: 'CaseRepository');

      var query = _supabaseService.client
          .from('cases')
          .select()
          .order('filing_date', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;

      dev.log('Successfully fetched ${(response as List).length} cases',
          name: 'CaseRepository');

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching cases',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load cases: $e');
    }
  }

  /// Get case by ID
  Future<Case?> getCaseById(int id) async {
    try {
      dev.log('Fetching case with ID: $id', name: 'CaseRepository');

      final response = await _supabaseService.client
          .from('cases')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        dev.log('Case not found with ID: $id', name: 'CaseRepository');
        return null;
      }

      return Case.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error fetching case by ID',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load case: $e');
    }
  }

  /// Get case by case number
  Future<Case?> getCaseByCaseNumber(String caseNumber) async {
    try {
      dev.log('Fetching case with number: $caseNumber', name: 'CaseRepository');

      final response = await _supabaseService.client
          .from('cases')
          .select()
          .eq('case_number', caseNumber)
          .maybeSingle();

      if (response == null) {
        dev.log('Case not found with number: $caseNumber', name: 'CaseRepository');
        return null;
      }

      return Case.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error fetching case by number',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load case: $e');
    }
  }

  /// Get cases by type
  Future<List<Case>> getCasesByType(CaseType type, {int? limit}) async {
    try {
      dev.log('Fetching cases of type: ${type.name}', name: 'CaseRepository');

      var query = _supabaseService.client
          .from('cases')
          .select()
          .eq('type', type.name)
          .order('filing_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching cases by type',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load cases by type: $e');
    }
  }

  /// Get cases by status
  Future<List<Case>> getCasesByStatus(CaseStatus status, {int? limit}) async {
    try {
      dev.log('Fetching cases with status: ${status.name}', name: 'CaseRepository');

      var query = _supabaseService.client
          .from('cases')
          .select()
          .eq('status', status.name)
          .order('filing_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching cases by status',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load cases by status: $e');
    }
  }

  /// Get cases by priority
  Future<List<Case>> getCasesByPriority(CasePriority priority, {int? limit}) async {
    try {
      dev.log('Fetching cases with priority: ${priority.name}',
          name: 'CaseRepository');

      var query = _supabaseService.client
          .from('cases')
          .select()
          .eq('priority', priority.name)
          .order('filing_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching cases by priority',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load cases by priority: $e');
    }
  }

  /// Get cases by governorate
  Future<List<Case>> getCasesByGovernorate(String governorate, {int? limit}) async {
    try {
      dev.log('Fetching cases for governorate: $governorate',
          name: 'CaseRepository');

      var query = _supabaseService.client
          .from('cases')
          .select()
          .eq('governorate', governorate)
          .order('filing_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching cases by governorate',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load cases by governorate: $e');
    }
  }

  /// Get cases assigned to a specific user
  Future<List<Case>> getCasesAssignedTo(String assignee, {int? limit}) async {
    try {
      dev.log('Fetching cases assigned to: $assignee', name: 'CaseRepository');

      var query = _supabaseService.client
          .from('cases')
          .select()
          .eq('assigned_to', assignee)
          .order('filing_date', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching assigned cases',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load assigned cases: $e');
    }
  }

  /// Search cases
  Future<List<Case>> searchCases(String query) async {
    try {
      dev.log('Searching cases with query: $query', name: 'CaseRepository');

      final response = await _supabaseService.client
          .from('cases')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%,case_number.ilike.%$query%')
          .order('filing_date', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Case.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error searching cases',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to search cases: $e');
    }
  }

  // ============================================
  // CREATE OPERATIONS
  // ============================================

  /// Create a new case
  Future<Case> createCase(Case caseData) async {
    try {
      dev.log('Creating new case: ${caseData.caseNumber}',
          name: 'CaseRepository');

      final response = await _supabaseService.client
          .from('cases')
          .insert(caseData.toJson())
          .select()
          .single();

      dev.log('Case created successfully with ID: ${response['id']}',
          name: 'CaseRepository');

      return Case.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error creating case',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to create case: $e');
    }
  }

  /// Add note to case
  Future<Case> addCaseNote(int caseId, CaseNote note) async {
    try {
      dev.log('Adding note to case: $caseId', name: 'CaseRepository');

      final caseData = await getCaseById(caseId);
      if (caseData == null) {
        throw Exception('Case not found');
      }

      final updatedNotes = [...caseData.notes, note];

      return await updateCase(caseId, {
        'notes': updatedNotes.map((n) => n.toJson()).toList(),
      });
    } catch (e, stackTrace) {
      dev.log('Error adding case note',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to add case note: $e');
    }
  }

  /// Add activity to case
  Future<Case> addCaseActivity(int caseId, CaseActivity activity) async {
    try {
      dev.log('Adding activity to case: $caseId', name: 'CaseRepository');

      final caseData = await getCaseById(caseId);
      if (caseData == null) {
        throw Exception('Case not found');
      }

      final updatedActivities = [...caseData.activities, activity];

      return await updateCase(caseId, {
        'activities': updatedActivities.map((a) => a.toJson()).toList(),
      });
    } catch (e, stackTrace) {
      dev.log('Error adding case activity',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to add case activity: $e');
    }
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update a case
  Future<Case> updateCase(int id, Map<String, dynamic> updates) async {
    try {
      dev.log('Updating case with ID: $id', name: 'CaseRepository');

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('cases')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      dev.log('Case updated successfully', name: 'CaseRepository');

      return Case.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error updating case',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to update case: $e');
    }
  }

  /// Update case status
  Future<Case> updateCaseStatus(int id, CaseStatus status) async {
    try {
      dev.log('Updating case status to: ${status.name}', name: 'CaseRepository');
      return await updateCase(id, {'status': status.name});
    } catch (e) {
      throw Exception('Failed to update case status: $e');
    }
  }

  /// Assign case to user
  Future<Case> assignCase(int id, String assignee) async {
    try {
      dev.log('Assigning case to: $assignee', name: 'CaseRepository');
      return await updateCase(id, {'assigned_to': assignee});
    } catch (e) {
      throw Exception('Failed to assign case: $e');
    }
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Delete a case
  Future<void> deleteCase(int id) async {
    try {
      dev.log('Deleting case with ID: $id', name: 'CaseRepository');

      await _supabaseService.client
          .from('cases')
          .delete()
          .eq('id', id);

      dev.log('Case deleted successfully', name: 'CaseRepository');
    } catch (e, stackTrace) {
      dev.log('Error deleting case',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to delete case: $e');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get case statistics
  Future<Map<String, dynamic>> getCaseStatistics() async {
    try {
      dev.log('Calculating case statistics', name: 'CaseRepository');

      final allCases = await getAllCases();

      return {
        'total': allCases.length,
        'by_status': {
          for (var status in CaseStatus.values)
            status.name: allCases.where((c) => c.status == status).length,
        },
        'by_type': {
          for (var type in CaseType.values)
            type.name: allCases.where((c) => c.type == type).length,
        },
        'by_priority': {
          for (var priority in CasePriority.values)
            priority.name: allCases.where((c) => c.priority == priority).length,
        },
        'resolved': allCases.where((c) => c.status == CaseStatus.resolved).length,
        'pending': allCases
            .where((c) =>
                c.status != CaseStatus.resolved && c.status != CaseStatus.closed)
            .length,
      };
    } catch (e, stackTrace) {
      dev.log('Error calculating statistics',
          name: 'CaseRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to calculate case statistics: $e');
    }
  }
}
