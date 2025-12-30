import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../../app/routing/unit_routes.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_footer.dart';
import '../../../widgets/web/web_container.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/app_filter_chip.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/unit_news_provider.dart';
import '../../../../data/models/news_article.dart';

class WebNewsScreen extends ConsumerStatefulWidget {
  final String unitSlug;

  const WebNewsScreen({super.key, required this.unitSlug});

  @override
  ConsumerState<WebNewsScreen> createState() => _WebNewsScreenState();
}

class _WebNewsScreenState extends ConsumerState<WebNewsScreen> {
  NewsCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(
        _selectedCategory != null
            ? unitNewsByCategoryProvider(UnitNewsCategoryParam(widget.unitSlug, _selectedCategory!))
            : unitNewsProvider(widget.unitSlug)
    );

    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildContent(newsAsync),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: const BoxDecoration(
        gradient: AppConstants.islamicGradient,
      ),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              'الأخبار والتحديثات',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'آخر الأخبار والمستجدات من وزارة الأوقاف والشؤون الدينية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            _buildCategoryTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // "All" category chip
        AppFilterChip(
          label: 'الكل',
          isSelected: _selectedCategory == null,
          onSelected: () => setState(() => _selectedCategory = null),
          onDarkBackground: true,
        ),
        // Category chips from enum
        ...NewsCategory.values.map((category) {
          return AppFilterChip(
            label: category.displayName,
            isSelected: _selectedCategory == category,
            onSelected: () => setState(() => _selectedCategory = category),
            onDarkBackground: true,
          );
        }),
      ],
    );
  }

  Widget _buildContent(AsyncValue newsAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: newsAsync.when(
          data: (articles) {
            if (articles.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: Text('لا توجد أخبار في هذا التصنيف'),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 0.75,
              ),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _buildNewsCard(article);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              child: LoadingWidget(message: 'جاري تحميل الأخبار...'),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: CustomErrorWidget(
                message: 'فشل تحميل الأخبار',
                onRetry: () => ref.invalidate(newsProvider),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildNewsCard(NewsArticle article) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: InkWell(
        onTap: () {
          context.push(UnitRoutes.newsDetail(widget.unitSlug, article.id), extra: article);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusL),
                  ),
                ),
                child: article.imageUrl != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusL),
                  ),
                  child: Image.network(
                    article.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50),
                  ),
                )
                    : const Center(child: Icon(Icons.article, size: 50)),
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.islamicGreen.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        article.category.displayName,
                        style: const TextStyle(
                          color: AppConstants.islamicGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        article.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${article.publishedAt?.day}/${article.publishedAt?.month}/${article.publishedAt?.year}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}