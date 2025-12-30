import '../models/mosque.dart';
import '../services/supabase_service.dart';
import 'dart:math' as math;
import 'dart:developer' as dev;

class MosqueRepository {
  final SupabaseService _supabaseService;

  MosqueRepository(this._supabaseService);

  // Get all mosques
  Future<List<Mosque>> getAllMosques() async {
    try {
      // Add debug logging
      dev.log('Attempting to fetch mosques from Supabase...', name: 'MosqueRepository');
      dev.log('Supabase client initialized: ${_supabaseService.client}', name: 'MosqueRepository');

      final response = await _supabaseService.client
          .from('mosques')
          .select()
          .order('name');

      dev.log('Successfully fetched ${(response as List).length} mosques from Supabase', name: 'MosqueRepository');

      return (response as List<dynamic>)
          .map((json) => _mapToMosque(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      // IMPORTANT: Log the actual error instead of hiding it
      dev.log('Error fetching mosques from Supabase', name: 'MosqueRepository', error: e, stackTrace: stackTrace);

      // Check if it's a configuration issue
      if (e.toString().contains('Invalid API key') ||
          e.toString().contains('Invalid URL')) {
        dev.log('Supabase configuration error - check your API keys and URL', name: 'MosqueRepository', error: e);
      }

      dev.log('Falling back to sample data', name: 'MosqueRepository');
      return _getSampleMosques();
    }
  }

  // Get mosque by ID
  Future<Mosque?> getMosqueById(int id) async {
    try {
      dev.log('Fetching mosque with ID: $id', name: 'MosqueRepository');

      final response = await _supabaseService.client
          .from('mosques')
          .select()
          .eq('id', id)
          .single();

      dev.log('Successfully fetched mosque: ${response['name']}', name: 'MosqueRepository');
      return _mapToMosque(response);
    } catch (e, stackTrace) {
      dev.log('Error fetching mosque by ID $id', name: 'MosqueRepository', error: e, stackTrace: stackTrace);

      final samples = _getSampleMosques();
      try {
        return samples.firstWhere((m) => m.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  // Get mosques by governorate
  Future<List<Mosque>> getMosquesByGovernorate(String governorate) async {
    try {
      dev.log('Fetching mosques for governorate: $governorate', name: 'MosqueRepository');

      final response = await _supabaseService.client
          .from('mosques')
          .select()
          .eq('governorate', governorate)
          .order('name');

      dev.log('Found ${(response as List).length} mosques in $governorate', name: 'MosqueRepository');

      return (response as List<dynamic>)
          .map((json) => _mapToMosque(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching mosques by governorate', name: 'MosqueRepository', error: e, stackTrace: stackTrace);

      return _getSampleMosques()
          .where((m) => m.governorate == governorate)
          .toList();
    }
  }

  // Get mosques by type
  Future<List<Mosque>> getMosquesByType(MosqueType type) async {
    try {
      dev.log('Fetching mosques of type: ${type.name}', name: 'MosqueRepository');

      final response = await _supabaseService.client
          .from('mosques')
          .select()
          .eq('type', type.name)
          .order('name');

      dev.log('Found ${(response as List).length} mosques of type ${type.name}', name: 'MosqueRepository');

      return (response as List<dynamic>)
          .map((json) => _mapToMosque(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error fetching mosques by type', name: 'MosqueRepository', error: e, stackTrace: stackTrace);

      return _getSampleMosques().where((m) => m.type == type).toList();
    }
  }

  // Search mosques
  Future<List<Mosque>> searchMosques(String query) async {
    try {
      dev.log('Searching mosques with query: $query', name: 'MosqueRepository');

      final response = await _supabaseService.client
          .from('mosques')
          .select()
          .or('name.ilike.%$query%,name_en.ilike.%$query%,imam.ilike.%$query%')
          .order('name');

      dev.log('Found ${(response as List).length} mosques matching "$query"', name: 'MosqueRepository');

      return (response as List<dynamic>)
          .map((json) => _mapToMosque(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      dev.log('Error searching mosques', name: 'MosqueRepository', error: e, stackTrace: stackTrace);

      return _getSampleMosques()
          .where((m) =>
      m.name.toLowerCase().contains(query.toLowerCase()) ||
          m.imam.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // Get nearby mosques
  Future<List<Mosque>> getNearbyMosques(
      double latitude,
      double longitude, {
        double radiusKm = 5.0,
      }) async {
    try {
      dev.log('Fetching mosques near ($latitude, $longitude) within ${radiusKm}km', name: 'MosqueRepository');

      final allMosques = await getAllMosques();

      final nearbyMosques = allMosques.where((mosque) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          mosque.location.latitude,
          mosque.location.longitude,
        );
        return distance <= radiusKm;
      }).toList();

      dev.log('Found ${nearbyMosques.length} mosques within radius', name: 'MosqueRepository');

      return nearbyMosques;
    } catch (e, stackTrace) {
      dev.log('Error fetching nearby mosques', name: 'MosqueRepository', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load nearby mosques: $e');
    }
  }

  // Get mosque statistics
  Future<Map<String, dynamic>> getMosqueStatistics() async {
    try {
      dev.log('Calculating mosque statistics...', name: 'MosqueRepository');

      final allMosques = await getAllMosques();

      final stats = {
        'total': allMosques.length,
        'active': allMosques.where((m) => m.status == MosqueStatus.active).length,
        'by_type': {
          for (var type in MosqueType.values)
            type.name: allMosques.where((m) => m.type == type).length,
        },
        'by_governorate': {
          for (var gov in allMosques.map((m) => m.governorate).toSet())
            gov: allMosques.where((m) => m.governorate == gov).length,
        },
      };

      dev.log('Statistics calculated successfully', name: 'MosqueRepository');

      return stats;
    } catch (e, stackTrace) {
      dev.log('Error calculating statistics', name: 'MosqueRepository', error: e, stackTrace: stackTrace);
      throw Exception('Failed to load mosque statistics: $e');
    }
  }

  /// Maps Supabase JSON to Mosque object
  /// Handles null values gracefully to prevent type casting errors
  Mosque _mapToMosque(Map<String, dynamic> json) {
    try {
      // Debug: Log raw JSON to identify issues
      dev.log('Mapping mosque: ${json['name']}', name: 'MosqueRepository');

      return Mosque(
        // Required numeric fields (Supabase always returns these)
        id: (json['id'] as num).toInt(),

        // String fields that might be null in database
        name: json['name'] as String? ?? 'غير معروف',
        nameEn: json['name_en'] as String? ?? '',  // ← FIX: Allow null
        description: json['description'] as String? ?? '',  // ← FIX: Allow null

        // Enum fields with safe parsing
        type: _parseEnumFromString(
          json['type'] as String?,
          MosqueType.values,
          MosqueType.masjid,
        ),
        status: _parseEnumFromString(
          json['status'] as String?,
          MosqueStatus.values,
          MosqueStatus.active,
        ),

        // Location (assuming fields are flat in your table)
        location: MosqueLocation(
          address: json['address'] as String? ?? 'غير محدد',
          addressEn: json['address_en'] as String? ?? '',  // ← FIX: Allow null
          latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
          nearbyLandmarks: json['nearby_landmarks'] as String?,
        ),

        // Imam information
        imam: json['imam'] as String? ?? 'غير محدد',
        imamPhone: json['imam_phone'] as String?,  // Already nullable in model

        // Numeric fields
        capacity: (json['capacity'] as num?)?.toInt() ?? 0,
        area: (json['area'] as num?)?.toDouble(),

        // Boolean fields with sensible defaults
        hasParkingSpace: json['has_parking_space'] as bool? ?? false,
        hasWheelchairAccess: json['has_wheelchair_access'] as bool? ?? false,
        hasAirConditioning: json['has_air_conditioning'] as bool? ?? false,
        hasWuduArea: json['has_wudu_area'] as bool? ?? true,
        hasFemaleSection: json['has_female_section'] as bool? ?? false,
        hasLibrary: json['has_library'] as bool? ?? false,
        hasEducationCenter: json['has_education_center'] as bool? ?? false,

        // Array fields (handle PostgreSQL arrays and null)
        services: _parseStringList(json['services']),
        programs: _parseStringList(json['programs']),
        gallery: _parseStringList(json['gallery']),

        // Optional fields
        imageUrl: json['image_url'] as String?,
        establishedDate: json['established_date'] != null
            ? DateTime.tryParse(json['established_date'] as String)
            : null,
        architect: json['architect'] as String?,

        // Location metadata
        governorate: json['governorate'] as String? ?? 'غير محدد',
        district: json['district'] as String? ?? 'غير محدد',

        // Timestamps (Supabase always provides these)
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (e, stackTrace) {
      dev.log('Error mapping mosque', name: 'MosqueRepository', error: e, stackTrace: stackTrace);
      dev.log('Problematic JSON: $json', name: 'MosqueRepository');
      rethrow;  // Re-throw to see the error in the logs
    }
  }

  // Calculate distance using Haversine formula
  double _calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  // Sample data for fallback
  List<Mosque> _getSampleMosques() {
    return [
      Mosque(
        id: 1,
        name: 'المسجد الأقصى المبارك',
        nameEn: 'Al-Aqsa Mosque',
        description: 'المسجد الأقصى المبارك أولى القبلتين وثالث الحرمين الشريفين',
        type: MosqueType.jamia,
        status: MosqueStatus.active,
        location: const MosqueLocation(
          address: 'البلدة القديمة، القدس',
          latitude: 31.7782778,
          longitude: 35.2361111,
        ),
        imam: 'الشيخ عكرمة صبري',
        capacity: 5000,
        hasWheelchairAccess: true,
        hasAirConditioning: true,
        hasFemaleSection: true,
        governorate: 'القدس',
        district: 'البلدة القديمة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Mosque(
        id: 2,
        name: 'مسجد عمر بن الخطاب',
        nameEn: 'Omar Ibn Al-Khattab Mosque',
        description: 'مسجد كبير في وسط مدينة رام الله',
        type: MosqueType.jamia,
        status: MosqueStatus.active,
        location: const MosqueLocation(
          address: 'وسط البلد، رام الله',
          latitude: 31.9037,
          longitude: 35.2034,
        ),
        imam: 'الشيخ محمد أحمد',
        capacity: 1000,
        hasWheelchairAccess: true,
        hasAirConditioning: true,
        hasFemaleSection: true,
        governorate: 'رام الله والبيرة',
        district: 'وسط البلد',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Mosque(
        id: 3,
        name: 'مسجد صلاح الدين',
        nameEn: 'Salah Al-Din Mosque',
        description: 'مسجد تاريخي في مدينة نابلس',
        type: MosqueType.jamia,
        status: MosqueStatus.active,
        location: const MosqueLocation(
          address: 'البلدة القديمة، نابلس',
          latitude: 32.2211,
          longitude: 35.2544,
        ),
        imam: 'الشيخ خالد يوسف',
        capacity: 800,
        hasWheelchairAccess: false,
        hasAirConditioning: true,
        hasFemaleSection: true,
        governorate: 'نابلس',
        district: 'البلدة القديمة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Helper: Safely parse enum from string value
  /// Returns default value if parsing fails or value is null
  T _parseEnumFromString<T extends Enum>(
      String? value,
      List<T> enumValues,
      T defaultValue,
      ) {
    if (value == null || value.isEmpty) {
      return defaultValue;
    }

    try {
      return enumValues.firstWhere(
            (e) => e.name == value,
        orElse: () => defaultValue,
      );
    } catch (e) {
      dev.log('Unknown enum value "$value", using default: ${defaultValue.name}', name: 'MosqueRepository', error: e);
      return defaultValue;
    }
  }

  /// Helper: Safely parse string lists from various JSON formats
  /// Handles: null, List<dynamic>, List<String>, PostgreSQL arrays
  List<String> _parseStringList(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is List) {
      // Handle JSON array: ["item1", "item2"]
      return value
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (value is String) {
      // Handle PostgreSQL array format: {item1,item2,item3}
      if (value.isEmpty) return const [];

      if (value.startsWith('{') && value.endsWith('}')) {
        final content = value.substring(1, value.length - 1);
        if (content.isEmpty) return const [];

        return content
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      // Single string value
      return [value];
    }

    return const [];
  }



}