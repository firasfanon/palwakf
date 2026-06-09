import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../presentation/providers/unit_context_provider.dart';
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

/// Returns a CMS page if available, otherwise null.
///
/// Fail-open:
/// - If table/column doesn't exist, returns null (fallback to local content).
final pwfSitePageProvider =
    FutureProvider.family<PwfSitePage?, PwfSitePageParam>((ref, p) async {
      final repo = ref.watch(pwfSitePagesRepositoryProvider);
      try {
        final unitId = await ref.watch(unitIdBySlugProvider(p.unitSlug).future);
        return await repo.getPageBySlugForUnit(slug: p.slug, unitId: unitId);
      } on PostgrestException catch (e) {
        // Fail-open for missing table/column.
        final msg = (e.message).toLowerCase();
        if (msg.contains('does not exist') ||
            msg.contains('column') ||
            msg.contains('relation')) {
          return null;
        }
        rethrow;
      } catch (_) {
        // Any unexpected errors -> fail-open (don't crash public pages).
        return null;
      }
    });
