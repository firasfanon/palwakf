import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/org_units_repository.dart';

final orgUnitsRepositoryProvider = Provider<OrgUnitsRepository>((ref) {
  return OrgUnitsRepository(Supabase.instance.client);
});

final orgUnitsSearchProvider = StateProvider<String>((ref) => '');

final orgUnitsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(orgUnitsRepositoryProvider).fetchUnitsWithProfiles();
});

final filteredOrgUnitsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final q = ref.watch(orgUnitsSearchProvider).trim().toLowerCase();
  final listAsync = ref.watch(orgUnitsListProvider);

  return listAsync.whenData((rows) {
    if (q.isEmpty) return rows;
    return rows.where((r) {
      final nameAr = (r['name_ar'] ?? '').toString().toLowerCase();
      final nameEn = (r['name_en'] ?? '').toString().toLowerCase();
      final code = (r['code'] ?? '').toString().toLowerCase();
      final slug = (r['slug'] ?? '').toString().toLowerCase();
      return nameAr.contains(q) || nameEn.contains(q) || code.contains(q) || slug.contains(q);
    }).toList();
  });
});
