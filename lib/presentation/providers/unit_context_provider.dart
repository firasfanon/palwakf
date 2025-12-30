import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/org_units_repository.dart';

final unitOrgUnitsRepositoryProvider = Provider<OrgUnitsRepository>((ref) {
  return OrgUnitsRepository(Supabase.instance.client);
});

final orgUnitBySlugProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, unitSlug) async {
  return ref.read(unitOrgUnitsRepositoryProvider).fetchUnitBySlug(unitSlug);
});

final unitIdBySlugProvider = FutureProvider.family<String, String>((ref, unitSlug) async {
  // Fail-open to 'home' id if slug not found.
  final repo = ref.read(unitOrgUnitsRepositoryProvider);
  final direct = await repo.fetchUnitIdBySlug(unitSlug);
  if (direct != null && direct.isNotEmpty) return direct;

  final home = await repo.fetchUnitIdBySlug('home');
  if (home != null && home.isNotEmpty) return home;

  throw StateError('org_units: cannot resolve unit id for slug=$unitSlug (and home missing).');
});
