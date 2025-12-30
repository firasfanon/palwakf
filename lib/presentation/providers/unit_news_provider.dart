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

final unitNewsProvider = FutureProvider.family<List<NewsArticle>, String>((ref, unitSlug) async {
  final unitId = await ref.watch(unitIdBySlugProvider(unitSlug).future);
  return ref.read(unitNewsServiceProvider).getAllNewsForUnit(unitId);
});

final unitNewsByCategoryProvider =
    FutureProvider.family<List<NewsArticle>, UnitNewsCategoryParam>((ref, param) async {
  final unitId = await ref.watch(unitIdBySlugProvider(param.unitSlug).future);
  return ref.read(unitNewsServiceProvider).getNewsByCategoryForUnit(param.category, unitId);
});

final unitNewsArticleProvider =
    FutureProvider.family<NewsArticle?, UnitNewsIdParam>((ref, param) async {
  final unitId = await ref.watch(unitIdBySlugProvider(param.unitSlug).future);
  return ref.read(unitNewsServiceProvider).getNewsByIdForUnit(param.id, unitId);
});
