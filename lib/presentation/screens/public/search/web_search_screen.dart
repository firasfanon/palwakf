// lib/presentation/screens/public/search/web_search_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_container.dart';
import '../../../widgets/web/web_footer.dart';
import '../../../widgets/common/app_filter_chip.dart';

/// Web-optimized Search Screen
/// Features: Horizontal navbar, multi-column layout, advanced filters
class WebSearchScreen extends StatefulWidget {
  const WebSearchScreen({super.key});

  @override
  State<WebSearchScreen> createState() => _WebSearchScreenState();
}

class _WebSearchScreenState extends State<WebSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;

  final List<String> _categories = [
    'all',
    'news',
    'mosques',
    'services',
    'activities',
    'documents',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchHero(),
            _buildSearchContent(),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  // Hero Search Section
  Widget _buildSearchHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: const BoxDecoration(
        gradient: AppConstants.islamicGradient,
      ),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              'البحث في الموقع',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ابحث في جميع الأقسام والخدمات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white.withValues(alpha:0.95),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن المساجد، الخدمات، الأخبار...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          onSubmitted: _performSearch,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ElevatedButton.icon(
                          onPressed: () => _performSearch(_searchQuery),
                          icon: const Icon(Icons.search),
                          label: const Text('بحث'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.islamicGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Category chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _categories.map((category) {
                return AppFilterChip(
                  label: _getCategoryName(category),
                  isSelected: _selectedCategory == category,
                  onSelected: () {
                    setState(() {
                      _selectedCategory = category;
                      if (_searchQuery.isNotEmpty) {
                        _performSearch(_searchQuery);
                      }
                    });
                  },
                  onDarkBackground: true,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Search Content Area (Results + Sidebar)
  Widget _buildSearchContent() {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Results (70%)
            Expanded(
              flex: 7,
              child: _buildSearchResults(),
            ),
            const SizedBox(width: 30),
            // Sidebar (30%)
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildPopularSearches(),
                  const SizedBox(height: 20),
                  _buildQuickLinks(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_isSearching) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نتائج البحث (${_searchResults.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'البحث عن: "$_searchQuery"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ..._searchResults.map((result) => _buildSearchResultCard(result)),
      ],
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _getCategoryColor(result.category).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(result.category),
                  size: 35,
                  color: _getCategoryColor(result.category),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(result.category).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getCategoryName(result.category),
                        style: TextStyle(
                          color: _getCategoryColor(result.category),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('عرض التفاصيل'),
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

  Widget _buildSearchSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppConstants.islamicGreen),
                const SizedBox(width: 12),
                Text(
                  'اقتراحات البحث',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                'المساجد',
                'الخدمات الإلكترونية',
                'الأخبار والإعلانات',
                'الأنشطة والفعاليات',
                'معالي الوزير',
                'اتصل بنا',
                'الهيكل التنظيمي',
                'الرؤية والرسالة',
              ].map((suggestion) {
                return ActionChip(
                  avatar: const Icon(Icons.search, size: 18),
                  label: Text(suggestion),
                  onPressed: () {
                    _searchController.text = suggestion;
                    _performSearch(suggestion);
                  },
                  backgroundColor: AppConstants.islamicGreen.withValues(alpha:0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'لا توجد نتائج',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'لم يتم العثور على نتائج لـ "$_searchQuery"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _searchResults.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('مسح البحث'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppConstants.islamicGreen),
                const SizedBox(width: 12),
                Text(
                  'الأكثر بحثاً',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...[
              'دليل المساجد',
              'الخدمات الإلكترونية',
              'الأنشطة والفعاليات',
              'أوقات الصلاة',
              'التواصل مع الوزارة',
            ].map((search) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.arrow_back, size: 16),
                title: Text(search),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks() {
    final links = [
      {'title': 'دليل المساجد', 'icon': Icons.mosque},
      {'title': 'الخدمات الإلكترونية', 'icon': Icons.computer},
      {'title': 'الأخبار', 'icon': Icons.article},
      {'title': 'اتصل بنا', 'icon': Icons.contact_phone},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: AppConstants.islamicGreen),
                const SizedBox(width: 12),
                Text(
                  'روابط سريعة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...links.map((link) {
              return ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppConstants.islamicGreen.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    link['icon'] as IconData,
                    size: 18,
                    color: AppConstants.islamicGreen,
                  ),
                ),
                title: Text(link['title'] as String),
                trailing: const Icon(Icons.arrow_forward, size: 16),
                onTap: () {},
              );
            }),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _getMockResults(query);
          _isSearching = false;
        });
      }
    });
  }

  List<SearchResult> _getMockResults(String query) {
    // All available results
    final allResults = [
      SearchResult(
        title: 'دليل المساجد في فلسطين',
        description:
        'دليل شامل للمساجد في جميع المحافظات الفلسطينية مع معلومات تفصيلية عن كل مسجد',
        category: 'mosques',
      ),
      SearchResult(
        title: 'مسجد الأقصى المبارك',
        description: 'أولى القبلتين وثالث الحرمين الشريفين في القدس المحتلة',
        category: 'mosques',
      ),
      SearchResult(
        title: 'الخدمات الإلكترونية',
        description:
        'احصل على الخدمات الحكومية بطريقة سهلة وسريعة من خلال البوابة الإلكترونية',
        category: 'services',
      ),
      SearchResult(
        title: 'خدمة حجز موعد',
        description: 'احجز موعدك لمراجعة الوزارة بكل سهولة',
        category: 'services',
      ),
      SearchResult(
        title: 'آخر الأخبار والإعلانات',
        description: 'تابع آخر الأخبار والتحديثات والإعلانات الهامة من الوزارة',
        category: 'news',
      ),
      SearchResult(
        title: 'افتتاح مسجد جديد في رام الله',
        description: 'تم افتتاح مسجد جديد في حي الطيرة بحضور معالي الوزير',
        category: 'news',
      ),
      SearchResult(
        title: 'الأنشطة والفعاليات القادمة',
        description: 'تعرف على الأنشطة والفعاليات التي تنظمها الوزارة',
        category: 'activities',
      ),
      SearchResult(
        title: 'دورة تدريبية لأئمة المساجد',
        description: 'دورة متخصصة في فن الخطابة والإلقاء',
        category: 'activities',
      ),
      SearchResult(
        title: 'وثائق الوزارة',
        description: 'الوثائق والتقارير الرسمية الصادرة عن الوزارة',
        category: 'documents',
      ),
    ];

    // Filter by category if not 'all'
    var filteredResults = _selectedCategory == 'all'
        ? allResults
        : allResults.where((result) => result.category == _selectedCategory).toList();

    // Filter by search query (case insensitive search in title and description)
    filteredResults = filteredResults.where((result) {
      final searchLower = query.toLowerCase();
      return result.title.toLowerCase().contains(searchLower) ||
          result.description.toLowerCase().contains(searchLower);
    }).toList();

    return filteredResults;
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'all':
        return 'الكل';
      case 'news':
        return 'الأخبار';
      case 'mosques':
        return 'المساجد';
      case 'services':
        return 'الخدمات';
      case 'activities':
        return 'الأنشطة';
      case 'documents':
        return 'الوثائق';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'news':
        return AppColors.info;
      case 'mosques':
        return AppColors.islamicGreen;
      case 'services':
        return AppColors.goldenYellow;
      case 'activities':
        return Colors.purple;
      case 'documents':
        return AppColors.sageGreen;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'news':
        return Icons.article;
      case 'mosques':
        return Icons.mosque;
      case 'services':
        return Icons.miscellaneous_services;
      case 'activities':
        return Icons.event;
      case 'documents':
        return Icons.folder;
      default:
        return Icons.search;
    }
  }
}

class SearchResult {
  final String title;
  final String description;
  final String category;

  SearchResult({
    required this.title,
    required this.description,
    required this.category,
  });
}