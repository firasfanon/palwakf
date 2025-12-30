import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../../app/routing/unit_routes.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/bottom_nav_bar.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/news/news_card.dart';
import '../../../widgets/news/category_filter.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/unit_news_provider.dart';

class MobileNewsScreen extends ConsumerStatefulWidget {
  final String unitSlug;

  const MobileNewsScreen({super.key, required this.unitSlug});

  @override
  ConsumerState<MobileNewsScreen> createState() => _MobileNewsScreenState();
}

class _MobileNewsScreenState extends ConsumerState<MobileNewsScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(filteredNewsProvider);
    final filter = ref.watch(newsFilterProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الأخبار',
        showSearchButton: true,
      ),
      body: Column(
        children: [
          // Category Filter
          CategoryFilter(
            selectedCategory: filter.category,
            onCategorySelected: (category) {
              ref.read(newsFilterProvider.notifier).setCategory(category);
            },
          ),

          // News List
          Expanded(
            child: newsAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return const Center(
                    child: Text('لا توجد أخبار'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredNewsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return NewsCard(
                        article: article,
                        onTap: () {
                          // GoRouter: pass the article through `extra`
                          context.push(UnitRoutes.newsDetail(widget.unitSlug, article.id), extra: article);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(message: 'جاري تحميل الأخبار...'),
              error: (error, stack) => CustomErrorWidget(
                message: 'فشل تحميل الأخبار',
                onRetry: () => ref.invalidate(filteredNewsProvider),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _handleNavigation(index);
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: context.go(AppRoutes.home); break;
      case 1: break; // Already on news
      case 2: context.go(AppRoutes.services); break;
      case 3: context.go(AppRoutes.mosques); break;
      case 4: context.go(AppRoutes.about); break;
    }
  }
}
