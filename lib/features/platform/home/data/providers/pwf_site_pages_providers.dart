import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/presentation/providers/unit_context_provider.dart';
import '../models/pwf_site_page.dart';
import '../repositories/pwf_site_pages_repository.dart';

class PwfSitePageParam {
  const PwfSitePageParam({required this.unitSlug, required this.slug});

  final String unitSlug;
  final String slug;

  @override
  bool operator ==(Object other) {
    return other is PwfSitePageParam &&
        other.unitSlug == unitSlug &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(unitSlug, slug);
}

final pwfSitePagesRepositoryProvider = Provider<PwfSitePagesRepository>((ref) {
  return const PwfSitePagesRepository();
});

final pwfGlobalSitePageProvider = FutureProvider.family<PwfSitePage?, String>((
  ref,
  slug,
) async {
  final repo = ref.watch(pwfSitePagesRepositoryProvider);
  try {
    return await repo.getGlobalPageBySlug(slug: slug);
  } on PostgrestException catch (e) {
    final msg = (e.message).toLowerCase();
    if (msg.contains('does not exist') ||
        msg.contains('column') ||
        msg.contains('relation')) {
      return null;
    }
    rethrow;
  } catch (_) {
    return null;
  }
});

/// Returns a CMS page if available, otherwise null.
///
/// Fail-open:
/// - If table/column doesn't exist, returns null (fallback to local content).
final pwfSitePageProvider =
    FutureProvider.family<PwfSitePage?, PwfSitePageParam>((ref, p) async {
      final repo = ref.watch(pwfSitePagesRepositoryProvider);
      try {
        final normalizedSlug = p.slug.trim();
        final normalizedUnitSlug = p.unitSlug.trim().toLowerCase();
        if (normalizedUnitSlug.isEmpty ||
            normalizedUnitSlug == 'home' ||
            normalizedUnitSlug == 'global') {
          return await repo.getGlobalPageBySlug(slug: normalizedSlug);
        }

        final unitId = await ref.watch(unitIdBySlugProvider(p.unitSlug).future);
        return await repo.getPageBySlugForUnit(
          slug: normalizedSlug,
          unitId: unitId,
        );
      } on PostgrestException catch (e) {
        final msg = (e.message).toLowerCase();
        if (msg.contains('does not exist') ||
            msg.contains('column') ||
            msg.contains('relation')) {
          return null;
        }
        rethrow;
      } catch (_) {
        return null;
      }
    });
