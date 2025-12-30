import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../providers/unit_news_provider.dart';
import '../../../../data/models/news_article.dart';
import 'news_detail_screen.dart';

class NewsDetailRouteScreen extends ConsumerWidget {
  final String unitSlug;
  final int id;
  final NewsArticle? extraArticle;

  const NewsDetailRouteScreen({
    super.key,
    required this.unitSlug,
    required this.id,
    this.extraArticle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If we came from a list, we may have the article in extra to avoid refetch.
    if (extraArticle != null) {
      return NewsDetailScreen(article: extraArticle);
    }

    final asyncArticle = ref.watch(unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id)));

    return asyncArticle.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => CustomErrorWidget(
        message: 'تعذّر تحميل الخبر. تحقق من الاتصال وحاول مرة أخرى.',
        onRetry: () => ref.invalidate(unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id))),
      ),
      data: (article) {
        if (article == null) {
          return CustomErrorWidget(
            message: 'الخبر غير موجود أو لا يمكن الوصول إليه.',
            onRetry: () => ref.invalidate(unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id))),
          );
        }
        return NewsDetailScreen(article: article);
      },
    );
  }
}
