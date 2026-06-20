import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../data/services/supabase_service.dart';
import 'unit_context_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(SupabaseService());
});

final announcementsForUnitProvider =
    FutureProvider.family<List<Announcement>, String>((ref, unitSlug) async {
      final unitId = await ref.watch(unitIdBySlugExactProvider(unitSlug).future);
      if (unitId == null || unitId.isEmpty) return const <Announcement>[];
      return ref
          .read(announcementRepositoryProvider)
          .getAllAnnouncementsForUnit(unitId, unitSlug: unitSlug);
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



class UnitAnnouncementContentIdParam {
  const UnitAnnouncementContentIdParam(this.unitSlug, this.contentId);

  final String unitSlug;
  final String contentId;

  String get normalizedUnitSlug {
    final value = unitSlug.trim().toLowerCase();
    return value.isEmpty ? 'home' : value;
  }

  @override
  bool operator ==(Object other) =>
      other is UnitAnnouncementContentIdParam &&
      other.normalizedUnitSlug == normalizedUnitSlug &&
      other.contentId == contentId;

  @override
  int get hashCode => Object.hash(normalizedUnitSlug, contentId);
}

/// Direct public detail RPC provider; feed/list reconstruction is prohibited.
final announcementContentDetailForUnitProvider =
    FutureProvider.family<Announcement?, UnitAnnouncementContentIdParam>((ref, p) async {
      final unitId = await ref.watch(
        unitIdBySlugExactProvider(p.normalizedUnitSlug).future,
      );
      if (unitId == null || unitId.isEmpty) return null;
      return ref.read(announcementRepositoryProvider).getAnnouncementByContentIdForUnit(
            p.contentId,
            unitId,
            unitSlug: p.normalizedUnitSlug,
          );
    });

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

      if (p.normalizedUnitSlug == 'home') {
        final compat = await repo.getCompatRuntimeAnnouncementById(p.id);
        if (compat != null) return compat;
      }

      final unitId = await ref
          .watch(unitIdBySlugExactProvider(p.normalizedUnitSlug).future)
          .timeout(const Duration(seconds: 6), onTimeout: () => null);
      if (unitId == null || unitId.isEmpty) return null;

      return repo
          .getAnnouncementByIdForUnit(
            p.id,
            unitId,
            unitSlug: p.normalizedUnitSlug,
          )
          .timeout(const Duration(seconds: 8), onTimeout: () => null);
    });
