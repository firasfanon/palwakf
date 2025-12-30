import 'dart:developer' as dev;
import '../models/waqf_land.dart';
import '../services/supabase_service.dart';

/// Repository for managing WaqfLand data
/// Provides CRUD operations for waqf land records
class WaqfLandRepository {
  final SupabaseService _supabaseService;

  WaqfLandRepository(this._supabaseService);

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all waqf lands with optional pagination
  Future<List<WaqfLand>> getAllWaqfLands({
    int? limit,
    int? offset,
  }) async {
    try {
      dev.log('Fetching waqf lands', name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);
      if (offset != null) query = query.range(offset, offset + (limit ?? 10) - 1);

      final response = await query;

      dev.log('Successfully fetched ${(response as List).length} waqf lands',
          name: 'WaqfLandRepository');

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf lands',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf lands: $e');
    }
  }

  /// Get waqf land by ID
  Future<WaqfLand?> getWaqfLandById(int id) async {
    try {
      dev.log('Fetching waqf land with ID: $id', name: 'WaqfLandRepository');

      final response = await _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        dev.log('Waqf land not found with ID: $id', name: 'WaqfLandRepository');
        return null;
      }

      return WaqfLand.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf land by ID',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf land: $e');
    }
  }

  /// Get waqf land by reference number
  Future<WaqfLand?> getWaqfLandByReferenceNumber(String referenceNumber) async {
    try {
      dev.log('Fetching waqf land with reference: $referenceNumber',
          name: 'WaqfLandRepository');

      final response = await _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('reference_number', referenceNumber)
          .maybeSingle();

      if (response == null) {
        dev.log('Waqf land not found with reference: $referenceNumber',
            name: 'WaqfLandRepository');
        return null;
      }

      return WaqfLand.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf land by reference',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf land: $e');
    }
  }

  /// Get waqf lands by type
  Future<List<WaqfLand>> getWaqfLandsByType(LandType type, {int? limit}) async {
    try {
      dev.log('Fetching waqf lands of type: ${type.name}',
          name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('type', type.name)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf lands by type',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf lands by type: $e');
    }
  }

  /// Get waqf lands by status
  Future<List<WaqfLand>> getWaqfLandsByStatus(
    LandStatus status, {
    int? limit,
  }) async {
    try {
      dev.log('Fetching waqf lands with status: ${status.name}',
          name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('status', status.name)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf lands by status',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf lands by status: $e');
    }
  }

  /// Get waqf lands by ownership type
  Future<List<WaqfLand>> getWaqfLandsByOwnershipType(
    OwnershipType ownershipType, {
    int? limit,
  }) async {
    try {
      dev.log('Fetching waqf lands with ownership: ${ownershipType.name}',
          name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('ownership_type', ownershipType.name)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf lands by ownership type',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf lands by ownership type: $e');
    }
  }

  /// Get waqf lands by governorate
  Future<List<WaqfLand>> getWaqfLandsByGovernorate(
    String governorate, {
    int? limit,
  }) async {
    try {
      dev.log('Fetching waqf lands for governorate: $governorate',
          name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('governorate', governorate)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching waqf lands by governorate',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load waqf lands by governorate: $e');
    }
  }

  /// Get leased waqf lands
  Future<List<WaqfLand>> getLeasedWaqfLands({int? limit}) async {
    try {
      dev.log('Fetching leased waqf lands', name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('is_leased', true)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching leased waqf lands',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load leased waqf lands: $e');
    }
  }

  /// Get available waqf lands
  Future<List<WaqfLand>> getAvailableWaqfLands({int? limit}) async {
    try {
      dev.log('Fetching available waqf lands', name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('status', 'available')
          .eq('is_leased', false)
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching available waqf lands',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load available waqf lands: $e');
    }
  }

  /// Get disputed waqf lands
  Future<List<WaqfLand>> getDisputedWaqfLands({int? limit}) async {
    try {
      dev.log('Fetching disputed waqf lands', name: 'WaqfLandRepository');

      var query = _supabaseService.client
          .from('waqf_lands')
          .select()
          .eq('status', 'disputed')
          .order('created_at', ascending: false);

      if (limit != null) query = query.limit(limit);

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching disputed waqf lands',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to load disputed waqf lands: $e');
    }
  }

  /// Search waqf lands
  Future<List<WaqfLand>> searchWaqfLands(String query) async {
    try {
      dev.log('Searching waqf lands with query: $query',
          name: 'WaqfLandRepository');

      final response = await _supabaseService.client
          .from('waqf_lands')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%,reference_number.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => WaqfLand.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error searching waqf lands',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to search waqf lands: $e');
    }
  }

  // ============================================
  // CREATE OPERATIONS
  // ============================================

  /// Create a new waqf land record
  Future<WaqfLand> createWaqfLand(WaqfLand waqfLand) async {
    try {
      dev.log('Creating new waqf land: ${waqfLand.referenceNumber}',
          name: 'WaqfLandRepository');

      final response = await _supabaseService.client
          .from('waqf_lands')
          .insert(waqfLand.toJson())
          .select()
          .single();

      dev.log('Waqf land created successfully with ID: ${response['id']}',
          name: 'WaqfLandRepository');

      return WaqfLand.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error creating waqf land',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to create waqf land: $e');
    }
  }

  // ============================================
  // UPDATE OPERATIONS
  // ============================================

  /// Update a waqf land record
  Future<WaqfLand> updateWaqfLand(int id, Map<String, dynamic> updates) async {
    try {
      dev.log('Updating waqf land with ID: $id', name: 'WaqfLandRepository');

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('waqf_lands')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      dev.log('Waqf land updated successfully', name: 'WaqfLandRepository');

      return WaqfLand.fromJson(response);
    } catch (e, stackTrace) {
      dev.log('Error updating waqf land',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to update waqf land: $e');
    }
  }

  /// Update waqf land status
  Future<WaqfLand> updateWaqfLandStatus(int id, LandStatus status) async {
    try {
      dev.log('Updating waqf land status to: ${status.name}',
          name: 'WaqfLandRepository');
      return await updateWaqfLand(id, {'status': status.name});
    } catch (e) {
      throw Exception('Failed to update waqf land status: $e');
    }
  }

  /// Update leasing information
  Future<WaqfLand> updateLeasingInfo(
    int id,
    LeasingInfo leasingInfo,
  ) async {
    try {
      dev.log('Updating leasing info for waqf land: $id',
          name: 'WaqfLandRepository');

      return await updateWaqfLand(id, {
        'is_leased': true,
        'leasing_info': leasingInfo.toJson(),
        'status': 'leased',
      });
    } catch (e, stackTrace) {
      dev.log('Error updating leasing info',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to update leasing info: $e');
    }
  }

  /// Remove leasing information
  Future<WaqfLand> removeLeasingInfo(int id) async {
    try {
      dev.log('Removing leasing info for waqf land: $id',
          name: 'WaqfLandRepository');

      return await updateWaqfLand(id, {
        'is_leased': false,
        'leasing_info': null,
        'status': 'available',
      });
    } catch (e, stackTrace) {
      dev.log('Error removing leasing info',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to remove leasing info: $e');
    }
  }

  /// Update last inspection date
  Future<WaqfLand> updateLastInspection(int id) async {
    try {
      dev.log('Updating last inspection date for waqf land: $id',
          name: 'WaqfLandRepository');

      return await updateWaqfLand(id, {
        'last_inspection_date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update last inspection date: $e');
    }
  }

  // ============================================
  // DELETE OPERATIONS
  // ============================================

  /// Delete a waqf land record
  Future<void> deleteWaqfLand(int id) async {
    try {
      dev.log('Deleting waqf land with ID: $id', name: 'WaqfLandRepository');

      await _supabaseService.client
          .from('waqf_lands')
          .delete()
          .eq('id', id);

      dev.log('Waqf land deleted successfully', name: 'WaqfLandRepository');
    } catch (e, stackTrace) {
      dev.log('Error deleting waqf land',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to delete waqf land: $e');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get waqf land statistics
  Future<Map<String, dynamic>> getWaqfLandStatistics() async {
    try {
      dev.log('Calculating waqf land statistics', name: 'WaqfLandRepository');

      final allLands = await getAllWaqfLands();

      return {
        'total': allLands.length,
        'total_area': allLands.fold<double>(0, (sum, land) => sum + land.area),
        'leased': allLands.where((l) => l.isLeased).length,
        'available': allLands.where((l) => l.status == LandStatus.available).length,
        'disputed': allLands.where((l) => l.status == LandStatus.disputed).length,
        'by_type': {
          for (var type in LandType.values)
            type.name: allLands.where((l) => l.type == type).length,
        },
        'by_status': {
          for (var status in LandStatus.values)
            status.name: allLands.where((l) => l.status == status).length,
        },
        'by_ownership': {
          for (var ownership in OwnershipType.values)
            ownership.name:
                allLands.where((l) => l.ownershipType == ownership).length,
        },
        'total_estimated_value': allLands
            .where((l) => l.estimatedValue != null)
            .fold<double>(0, (sum, land) => sum + (land.estimatedValue ?? 0)),
      };
    } catch (e, stackTrace) {
      dev.log('Error calculating statistics',
          name: 'WaqfLandRepository',
          error: e,
          stackTrace: stackTrace);
      throw Exception('Failed to calculate waqf land statistics: $e');
    }
  }
}
