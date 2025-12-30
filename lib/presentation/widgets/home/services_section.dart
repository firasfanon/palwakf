import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/news_article.dart';
import '../../../app/routing/app_routes.dart';
import '../../../core/extensions/datetime_extensions.dart';

class NewsSection extends ConsumerWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, we'll use sample data
    // Later you can replace this with ref.watch(latestNewsProvider)
    final articles = _getSampleArticles();

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر الأخبار',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.news),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...articles.take(3).map((article) => _buildNewsCard(context, article)),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, NewsArticle article) {
    final publishDate = article.publishedAt ?? article.createdAt;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.newsDetail, extra: article);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceVariant,
                    child: Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image, size: 32);
                      },
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.excerpt,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.islamicGreen.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.category.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.islamicGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          publishDate.timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NewsArticle> _getSampleArticles() {
    return [
      NewsArticle(
        id: 1,
        title: 'افتتاح مسجد جديد في مدينة رام الله',
        excerpt: 'تم افتتاح مسجد جديد في حي الطيرة برام الله بحضور معالي الوزير',
        content: 'محتوى الخبر الكامل...',
        imageUrl: null,
        author: 'أحمد محمد',
        category: NewsCategory.mosques,
        status: PublishStatus.published,
        viewCount: 150,
        isFeatured: true,
        tags: const ['مساجد', 'رام الله'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsArticle(
        id: 2,
        title: 'ندوة حول الوسطية في الإسلام',
        excerpt: 'تنظم الوزارة ندوة علمية حول موضوع الوسطية في الإسلام',
        content: 'محتوى الخبر الكامل...',
        imageUrl: null,
        author: 'فاطمة أحمد',
        category: NewsCategory.religious,
        status: PublishStatus.published,
        viewCount: 89,
        isFeatured: false,
        tags: const ['ندوة', 'وسطية'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NewsArticle(
        id: 3,
        title: 'دورة تدريبية لأئمة المساجد',
        excerpt: 'تنطلق غداً دورة تدريبية متخصصة لأئمة المساجد',
        content: 'محتوى الخبر الكامل...',
        imageUrl: null,
        author: 'محمد خالد',
        category: NewsCategory.education,
        status: PublishStatus.published,
        viewCount: 67,
        isFeatured: true,
        tags: const ['تدريب', 'أئمة'],
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
}