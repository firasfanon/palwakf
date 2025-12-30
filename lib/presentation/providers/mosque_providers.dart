import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import '../../data/repositories/mosque_repository.dart';
import '../../data/models/mosque.dart';

// ============ Repository Providers ============

/// Provider for MosqueRepository
/// Uses the shared supabaseServiceProvider from common_providers.dart
final mosqueRepositoryProvider = Provider<MosqueRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return MosqueRepository(supabaseService);
});

// ============ Data Providers ============

/// Provider for all mosques
/// Returns a Future<List<Mosque>> that automatically refreshes when invalidated
final allMosquesProvider = FutureProvider<List<Mosque>>((ref) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getAllMosques();
});

/// Provider for a single mosque by ID
/// This is a "family" provider - it takes a parameter (the ID)
/// Usage: ref.watch(mosqueByIdProvider(1))
final mosqueByIdProvider = FutureProvider.family<Mosque?, int>((ref, id) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getMosqueById(id);
});

/// Provider for mosques filtered by governorate
/// Usage: ref.watch(mosquesByGovernorateProvider('القدس'))
final mosquesByGovernorateProvider =
FutureProvider.family<List<Mosque>, String>((ref, governorate) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getMosquesByGovernorate(governorate);
});

/// Provider for mosques filtered by type
/// Usage: ref.watch(mosquesByTypeProvider(MosqueType.jamia))
final mosquesByTypeProvider =
FutureProvider.family<List<Mosque>, MosqueType>((ref, type) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getMosquesByType(type);
});

/// Provider for mosque search
/// Usage: ref.watch(mosquesSearchProvider('الأقصى'))
final mosquesSearchProvider =
FutureProvider.family<List<Mosque>, String>((ref, query) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.searchMosques(query);
});

/// Provider for nearby mosques
/// Takes a custom object with latitude, longitude, and radius
class NearbyMosquesParams {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const NearbyMosquesParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 5.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NearbyMosquesParams &&
              runtimeType == other.runtimeType &&
              latitude == other.latitude &&
              longitude == other.longitude &&
              radiusKm == other.radiusKm;

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ radiusKm.hashCode;
}

/// Provider for nearby mosques
/// Usage: ref.watch(nearbyMosquesProvider(NearbyMosquesParams(latitude: 31.9, longitude: 35.2)))
final nearbyMosquesProvider =
FutureProvider.family<List<Mosque>, NearbyMosquesParams>((ref, params) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getNearbyMosques(
    params.latitude,
    params.longitude,
    radiusKm: params.radiusKm,
  );
});

/// Provider for mosque statistics
final mosqueStatisticsProvider =
FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getMosqueStatistics();
});