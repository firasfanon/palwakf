import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/unit/pwf_unit_slug_registry.dart';
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
      final normalized = PwfUnitSlugRegistry.internalSlugFor(unitSlug);
      String? unitId;
      String? homeUnitId;

      try {
        unitId = await ref.watch(unitIdBySlugExactProvider(normalized).future);
      } catch (_) {
        unitId = null;
      }

      try {
        homeUnitId = normalized == 'home'
            ? await ref.watch(unitIdBySlugExactProvider('home').future)
            : null;
      } catch (_) {
        homeUnitId = null;
      }

      return repo.fetchForScopes(
        unitId: unitId,
        homeUnitId: normalized == 'home' ? homeUnitId : null,
        strictUnitOnly: normalized != 'home',
      );
    });

final editablePwfFormerMinistersProvider =
    FutureProvider.family<List<PwfFormerMinister>, String>((
      ref,
      unitSlug,
    ) async {
      final repo = ref.watch(pwfFormerMinistersRepositoryProvider);
      final normalized = PwfUnitSlugRegistry.internalSlugFor(unitSlug);
      String? unitId;
      String? homeUnitId;

      try {
        unitId = await ref.watch(unitIdBySlugExactProvider(normalized).future);
      } catch (_) {
        unitId = null;
      }

      try {
        homeUnitId = normalized == 'home'
            ? await ref.watch(unitIdBySlugExactProvider('home').future)
            : null;
      } catch (_) {
        homeUnitId = null;
      }

      return repo.fetchForEdit(
        unitId: unitId,
        homeUnitId: normalized == 'home' ? homeUnitId : null,
        strictUnitOnly: normalized != 'home',
      );
    });
