import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../data/services/supabase_service.dart';
import 'unit_context_provider.dart';

const _fallbackGlobalUnitId = '11111111-1111-1111-1111-111111111111';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(SupabaseService());
});

final announcementsForUnitProvider =
    FutureProvider.family<List<Announcement>, String>((ref, unitSlug) async {
      final unitId = await ref.watch(unitIdBySlugProvider(unitSlug).future);
      return ref
          .read(announcementRepositoryProvider)
          .getAllAnnouncementsForUnit(unitId);
    });

class UnitAnnouncementIdParam {
  final String unitSlug;
  final int id;

  const UnitAnnouncementIdParam(this.unitSlug, this.id);

  String get normalizedUnitSlug {
    final normalized = unitSlug.trim().toLowerCase();
    return normalized.isEmpty ? 'home' : normalized;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UnitAnnouncementIdParam &&
            other.id == id &&
            other.normalizedUnitSlug == normalizedUnitSlug;
  }

  @override
  int get hashCode => Object.hash(normalizedUnitSlug, id);
}

/// Announcement detail for unit.
///
/// Database Wave B-1A media runtime bridge rule:
/// - Resolve compatibility media announcements before legacy unit scoping.
/// - Keep a bounded unit-id lookup for legacy fallback only.
/// - Fail open to the global unit id instead of leaving the public detail page
///   in a perpetual loading state.
final announcementForUnitByIdProvider =
    FutureProvider.family<Announcement?, UnitAnnouncementIdParam>((
      ref,
      p,
    ) async {
      final repo = ref.read(announcementRepositoryProvider);

      final compat = await repo.getCompatRuntimeAnnouncementById(p.id);
      if (compat != null) return compat;

      final unitId = await ref
          .watch(unitIdBySlugProvider(p.normalizedUnitSlug).future)
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () => _fallbackGlobalUnitId,
          );

      return repo
          .getAnnouncementByIdForUnit(p.id, unitId)
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
    });
