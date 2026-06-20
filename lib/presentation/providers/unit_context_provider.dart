import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/unit/pwf_unit_slug_registry.dart';
import '../../data/repositories/org_units_repository.dart';

final unitOrgUnitsRepositoryProvider = Provider<OrgUnitsRepository>((ref) {
  return OrgUnitsRepository(Supabase.instance.client);
});

final orgUnitBySlugProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, unitSlug) async {
      final internalSlug = PwfUnitSlugRegistry.internalSlugFor(unitSlug);
      return ref
          .read(unitOrgUnitsRepositoryProvider)
          .fetchUnitBySlug(internalSlug);
    });

const kPwfGlobalUnitId = '11111111-1111-1111-1111-111111111111';
const _kGlobalUnitId = kPwfGlobalUnitId;


/// Resolve only the requested slug without silently substituting `home`.
///
/// Public unit pages use this when they must preserve the selected unit scope.
/// The broader [unitIdBySlugProvider] remains fail-open for legacy callers that
/// explicitly need a home/global fallback.
final unitIdBySlugExactProvider = FutureProvider.family<String?, String>((
  ref,
  unitSlug,
) async {
  final repo = ref.read(unitOrgUnitsRepositoryProvider);
  final normalized = PwfUnitSlugRegistry.internalSlugFor(unitSlug);
  return repo.fetchUnitIdBySlug(normalized);
});

final unitIdBySlugProvider = FutureProvider.family<String, String>((
  ref,
  unitSlug,
) async {
  final repo = ref.read(unitOrgUnitsRepositoryProvider);
  final normalized = PwfUnitSlugRegistry.internalSlugFor(unitSlug);

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
