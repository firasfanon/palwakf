import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/org_units_repository.dart';

final unitOrgUnitsRepositoryProvider = Provider<OrgUnitsRepository>((ref) {
  return OrgUnitsRepository(Supabase.instance.client);
});

final orgUnitBySlugProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, unitSlug) async {
      return ref.read(unitOrgUnitsRepositoryProvider).fetchUnitBySlug(unitSlug);
    });

const _kGlobalUnitId = '11111111-1111-1111-1111-111111111111';

final unitIdBySlugProvider = FutureProvider.family<String, String>((
  ref,
  unitSlug,
) async {
  final repo = ref.read(unitOrgUnitsRepositoryProvider);
  final normalized = unitSlug.trim().isEmpty
      ? 'home'
      : unitSlug.trim().toLowerCase();

  for (final candidate in <String>[
    normalized,
    if (normalized != 'home') 'home',
    'global',
  ]) {
    final id = await repo.fetchUnitIdBySlug(candidate);
    if (id != null && id.isNotEmpty) return id;
  }

  // Final fail-open: use the sovereign GLOBAL unit id so the public home page
  // still renders instead of collapsing into an error state on first load.
  return _kGlobalUnitId;
});
