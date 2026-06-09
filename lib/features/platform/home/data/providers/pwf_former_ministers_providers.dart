import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../models/pwf_former_minister.dart';
import '../repositories/pwf_former_ministers_repository.dart';

final pwfFormerMinistersRepositoryProvider =
    Provider<PwfFormerMinistersRepository>((ref) {
      return PwfFormerMinistersRepository(Supabase.instance.client);
    });

final pwfFormerMinistersProvider =
    FutureProvider.family<List<PwfFormerMinister>, String>((
      ref,
      unitSlug,
    ) async {
      final repo = ref.watch(pwfFormerMinistersRepositoryProvider);
      final normalized = unitSlug.trim().isEmpty
          ? 'home'
          : unitSlug.trim().toLowerCase();
      String? unitId;
      String? homeUnitId;

      try {
        unitId = await ref.watch(unitIdBySlugProvider(normalized).future);
      } catch (_) {
        unitId = null;
      }

      try {
        homeUnitId = await ref.watch(unitIdBySlugProvider('home').future);
      } catch (_) {
        homeUnitId = null;
      }

      return repo.fetchForScopes(unitId: unitId, homeUnitId: homeUnitId);
    });

final editablePwfFormerMinistersProvider =
    FutureProvider.family<List<PwfFormerMinister>, String>((
      ref,
      unitSlug,
    ) async {
      final repo = ref.watch(pwfFormerMinistersRepositoryProvider);
      final normalized = unitSlug.trim().isEmpty
          ? 'home'
          : unitSlug.trim().toLowerCase();
      String? unitId;
      String? homeUnitId;

      try {
        unitId = await ref.watch(unitIdBySlugProvider(normalized).future);
      } catch (_) {
        unitId = null;
      }

      try {
        homeUnitId = await ref.watch(unitIdBySlugProvider('home').future);
      } catch (_) {
        homeUnitId = null;
      }

      return repo.fetchForEdit(unitId: unitId, homeUnitId: homeUnitId);
    });
