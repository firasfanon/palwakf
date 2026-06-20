import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../providers/unit_news_provider.dart';
import '../../../providers/news_provider.dart';
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
    this.contentId,
  });

  /// Direct public content identity. When present, this route must call the
  /// scoped detail RPC; it must not trust `extraArticle` or a feed cache.
  final String? contentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directContentId = contentId?.trim();
    if (directContentId != null && directContentId.isNotEmpty) {
      final directAsync = ref.watch(
        unitNewsContentDetailProvider(
          UnitNewsContentIdParam(unitSlug, directContentId),
        ),
      );
      return directAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(
          message: 'تعذّر تحميل الخبر. تحقق من الاتصال وحاول مرة أخرى.',
          onRetry: () => ref.invalidate(
            unitNewsContentDetailProvider(
              UnitNewsContentIdParam(unitSlug, directContentId),
            ),
          ),
        ),
        data: (article) => article == null
            ? CustomErrorWidget(
                message: 'الخبر غير موجود أو لا يمكن الوصول إليه.',
                onRetry: () => ref.invalidate(
                  unitNewsContentDetailProvider(
                    UnitNewsContentIdParam(unitSlug, directContentId),
                  ),
                ),
              )
            : NewsDetailScreen(article: article),
      );
    }

    // Legacy system routes which only expose a historical integer id remain
    // isolated here. Public routes above always provide `contentId`.
    if (extraArticle != null) {
      return NewsDetailScreen(article: extraArticle);
    }

    final normalizedSlug = unitSlug.trim().toLowerCase();
    final scopedAsync = ref.watch(
      unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id)),
    );
    final globalAsync = ref.watch(newsArticleProvider(id));

    if (normalizedSlug == 'home') {
      return globalAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => CustomErrorWidget(
          message: 'تعذّر تحميل الخبر. تحقق من الاتصال وحاول مرة أخرى.',
          onRetry: () => ref.invalidate(newsArticleProvider(id)),
        ),
        data: (article) {
          if (article == null) {
            return CustomErrorWidget(
              message: 'الخبر غير موجود أو لا يمكن الوصول إليه.',
              onRetry: () => ref.invalidate(newsArticleProvider(id)),
            );
          }
          return NewsDetailScreen(article: article);
        },
      );
    }

    return scopedAsync.when(
      loading: () => globalAsync.maybeWhen(
        data: (article) => article == null
            ? const LoadingWidget()
            : NewsDetailScreen(article: article),
        orElse: () => const LoadingWidget(),
      ),
      error: (e, _) => globalAsync.when(
        loading: () => const LoadingWidget(),
        error: (_, __) => CustomErrorWidget(
          message: 'تعذّر تحميل الخبر. تحقق من الاتصال وحاول مرة أخرى.',
          onRetry: () {
            ref.invalidate(
              unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id)),
            );
            ref.invalidate(newsArticleProvider(id));
          },
        ),
        data: (article) {
          if (article == null) {
            return CustomErrorWidget(
              message: 'الخبر غير موجود أو لا يمكن الوصول إليه.',
              onRetry: () {
                ref.invalidate(
                  unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id)),
                );
                ref.invalidate(newsArticleProvider(id));
              },
            );
          }
          return NewsDetailScreen(article: article);
        },
      ),
      data: (article) {
        if (article != null) return NewsDetailScreen(article: article);
        return globalAsync.when(
          loading: () => const LoadingWidget(),
          error: (_, __) => CustomErrorWidget(
            message: 'الخبر غير موجود أو لا يمكن الوصول إليه.',
            onRetry: () {
              ref.invalidate(
                unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id)),
              );
              ref.invalidate(newsArticleProvider(id));
            },
          ),
          data: (fallbackArticle) {
            if (fallbackArticle == null) {
              return CustomErrorWidget(
                message: 'الخبر غير موجود أو لا يمكن الوصول إليه.',
                onRetry: () {
                  ref.invalidate(
                    unitNewsArticleProvider(UnitNewsIdParam(unitSlug, id)),
                  );
                  ref.invalidate(newsArticleProvider(id));
                },
              );
            }
            return NewsDetailScreen(article: fallbackArticle);
          },
        );
      },
    );
  }
}
