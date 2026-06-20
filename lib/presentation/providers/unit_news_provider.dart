import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/news_article.dart';
import '../../data/services/news_service.dart';
import 'unit_context_provider.dart';

final unitNewsServiceProvider = Provider<NewsService>((ref) => NewsService());

class UnitNewsCategoryParam {
  final String unitSlug;
  final NewsCategory category;
  const UnitNewsCategoryParam(this.unitSlug, this.category);
}

class UnitNewsIdParam {
  final String unitSlug;
  final int id;
  const UnitNewsIdParam(this.unitSlug, this.id);
}

final unitNewsProvider = FutureProvider.family<List<NewsArticle>, String>((
  ref,
  unitSlug,
) async {
  final unitId = await ref.watch(unitIdBySlugExactProvider(unitSlug).future);
  if (unitId == null || unitId.isEmpty) return const <NewsArticle>[];
  return ref
      .read(unitNewsServiceProvider)
      .getAllNewsForUnit(unitId, unitSlug: unitSlug);
});

final unitNewsByCategoryProvider =
    FutureProvider.family<List<NewsArticle>, UnitNewsCategoryParam>((
      ref,
      param,
    ) async {
      final unitId = await ref.watch(
        unitIdBySlugExactProvider(param.unitSlug).future,
      );
      if (unitId == null || unitId.isEmpty) return const <NewsArticle>[];
      return ref
          .read(unitNewsServiceProvider)
          .getNewsByCategoryForUnit(
            param.category,
            unitId,
            unitSlug: param.unitSlug,
          );
    });



/// Opaque public media detail identity. `contentId` is the server-issued
/// content_id passed through the URL; it is not a lossy legacy integer hash.
class UnitNewsContentIdParam {
  const UnitNewsContentIdParam(this.unitSlug, this.contentId);

  final String unitSlug;
  final String contentId;

  String get normalizedUnitSlug {
    final value = unitSlug.trim().toLowerCase();
    return value.isEmpty ? 'home' : value;
  }

  @override
  bool operator ==(Object other) =>
      other is UnitNewsContentIdParam &&
      other.normalizedUnitSlug == normalizedUnitSlug &&
      other.contentId == contentId;

  @override
  int get hashCode => Object.hash(normalizedUnitSlug, contentId);
}

/// Fresh public detail loader. This invokes rpc_public_media_detail_v2 only;
/// it does not reconstruct a detail item from a feed/list result.
final unitNewsContentDetailProvider =
    FutureProvider.family<NewsArticle?, UnitNewsContentIdParam>((ref, param) async {
      final unitId = await ref.watch(
        unitIdBySlugExactProvider(param.normalizedUnitSlug).future,
      );
      if (unitId == null || unitId.isEmpty) return null;
      return ref.read(unitNewsServiceProvider).getNewsByContentIdForUnit(
            param.contentId,
            unitId,
            unitSlug: param.normalizedUnitSlug,
          );
    });

final unitNewsArticleProvider =
    FutureProvider.family<NewsArticle?, UnitNewsIdParam>((ref, param) async {
      final unitId = await ref.watch(
        unitIdBySlugExactProvider(param.unitSlug).future,
      );
      if (unitId == null || unitId.isEmpty) return null;
      return ref
          .read(unitNewsServiceProvider)
          .getNewsByIdForUnit(
            param.id,
            unitId,
            unitSlug: param.unitSlug,
          );
    });
