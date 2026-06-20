// lib/presentation/screens/public/search/web_search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/core/unit/pwf_unit_slug_registry.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_container.dart';
import '../../../widgets/web/web_footer.dart';
import '../../../widgets/common/app_filter_chip.dart';

/// Web-optimized Search Screen
/// Features: Horizontal navbar, multi-column layout, advanced filters
class WebSearchScreen extends StatefulWidget {
  const WebSearchScreen({
    super.key,
    this.initialQuery = '',
    this.unitSlug = 'home',
  });

  final String initialQuery;
  final String unitSlug;

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
  void initState() {
    super.initState();
    final initial = widget.initialQuery.trim();
    if (initial.isNotEmpty) {
      _searchController.text = initial;
      _searchQuery = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _performSearch(initial);
      });
    }
  }

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
      decoration: const BoxDecoration(gradient: AppConstants.islamicGradient),
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
                color: Colors.white.withValues(alpha: 0.95),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 900;
            final sidebar = Column(
              children: [
                _buildPopularSearches(),
                const SizedBox(height: 20),
                _buildQuickLinks(),
              ],
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchResults(),
                  const SizedBox(height: 24),
                  sidebar,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _buildSearchResults()),
                const SizedBox(width: 30),
                Expanded(flex: 3, child: sidebar),
              ],
            );
          },
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
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'نتائج البحث (${_searchResults.length})',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'البحث عن: "$_searchQuery"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        onTap: () => context.go(result.route),
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
                  color: _getCategoryColor(
                    result.category,
                  ).withValues(alpha: 0.1),
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
                        color: _getCategoryColor(
                          result.category,
                        ).withValues(alpha: 0.1),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
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
                      onPressed: () => context.go(result.route),
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
              children:
                  [
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
                      backgroundColor: AppConstants.islamicGreen.withValues(
                        alpha: 0.1,
                      ),
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
              Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                    color: AppConstants.islamicGreen.withValues(alpha: 0.1),
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
    _syncSearchQueryToRoute(query);

    // Use the governed local public-route index until a database-backed
    // public search RPC is approved. Keep a short async boundary so the
    // loading state remains testable without blocking the UI thread.
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _searchResults = _getIndexedResults(query);
        _isSearching = false;
      });
    });
  }


  void _syncSearchQueryToRoute(String query) {
    final trimmed = query.trim();
    final base = '${_unitBasePath()}/search';
    final target = trimmed.isEmpty
        ? base
        : '$base?${Uri(queryParameters: {'q': trimmed}).query}';
    if (GoRouterState.of(context).uri.toString() != target) {
      context.replace(target);
    }
  }

  List<SearchResult> _getIndexedResults(String query) {
    final allResults = _searchIndex();

    var filteredResults = _selectedCategory == 'all'
        ? allResults
        : allResults
              .where((result) => result.category == _selectedCategory)
              .toList();

    final searchLower = _normalizeSearch(query);
    final queryTerms = _expandedSearchTerms(searchLower);
    filteredResults = filteredResults.where((result) {
      final haystack = _normalizeSearch(
        [result.title, result.description, ...result.keywords].join(' '),
      );
      return queryTerms.any(haystack.contains);
    }).toList();

    return filteredResults;
  }

  List<SearchResult> _searchIndex() {
    final base = _unitBasePath();
    return [
      SearchResult(
        title: 'الصفحة الرئيسية',
        description: 'الواجهة الرئيسية للوزارة وأقسام الأخبار والخدمات والمعلومات العامة.',
        category: 'documents',
        route: base,
        keywords: const [
          'الرئيسية',
          'وزارة',
          'الأوقاف',
          'الاوقاف',
          'وقف',
          'وقفي',
          'المنصة',
          'home',
        ],
      ),
      SearchResult(
        title: 'مستكشف الوقف',
        description:
            'مدخل استكشاف الأوقاف والأصول الوقفية والخرائط والمؤشرات العامة ذات العلاقة.',
        category: 'documents',
        route: '/mustakshif',
        keywords: const [
          'وقف',
          'اوقاف',
          'الأوقاف',
          'الاوقاف',
          'وقفي',
          'وقفية',
          'وقفيه',
          'أصل وقفي',
          'اصل وقفي',
          'أصول وقفية',
          'اصول وقفيه',
          'أراضي وقفية',
          'اراضي وقفيه',
          'مستكشف',
          'خريطة',
          'خرائط',
          'تحليل مكاني',
        ],
      ),
      SearchResult(
        title: 'الأخبار',
        description: 'آخر أخبار الوزارة والوحدات والمديريات المنشورة للجمهور.',
        category: 'news',
        route: '$base/news',
        keywords: const ['اخبار', 'خبر', 'إعلام', 'المركز الإعلامي'],
      ),
      SearchResult(
        title: 'الإعلانات',
        description: 'الإعلانات الرسمية والتنبيهات العامة المنشورة على المنصة.',
        category: 'news',
        route: '$base/announcements',
        keywords: const ['اعلانات', 'إعلان', 'تنبيه', 'بلاغ'],
      ),
      SearchResult(
        title: 'الأنشطة والفعاليات',
        description: 'الأنشطة والفعاليات والبرامج العامة الخاصة بالوزارة والوحدات.',
        category: 'activities',
        route: '$base/activities',
        keywords: const ['نشاط', 'فعاليات', 'برامج', 'events'],
      ),
      SearchResult(
        title: 'الخدمات الإلكترونية',
        description: 'بوابة الخدمات الإلكترونية وتتبع طلبات الجمهور.',
        category: 'services',
        route: '$base/services',
        keywords: const ['خدمات', 'خدمة', 'طلب', 'تتبع', 'معاملة'],
      ),
      SearchResult(
        title: 'المركز الإعلامي',
        description: 'مركز الأخبار والبيانات والتصريحات والحملات الإعلامية.',
        category: 'news',
        route: '$base/media-center',
        keywords: const ['إعلام', 'بيانات', 'تصريحات', 'حملات', 'صور', 'فيديو'],
      ),
      SearchResult(
        title: 'المساجد',
        description: 'البحث في المساجد والمعلومات العامة ذات العلاقة.',
        category: 'mosques',
        route: '$base/mosques',
        keywords: const ['مسجد', 'مساجد', 'إمام', 'خطيب'],
      ),
      SearchResult(
        title: 'خطب الجمعة',
        description: 'أرشيف خطب الجمعة والنشرات العامة.',
        category: 'documents',
        route: '$base/friday-sermon',
        keywords: const ['خطبة', 'خطب', 'جمعة', 'خطيب'],
      ),
      SearchResult(
        title: 'الأنظمة والقوانين والتعليمات',
        description: 'مراجع قانونية وتعليمات ونماذج عامة منشورة للجمهور.',
        category: 'documents',
        route: '$base/legal-references',
        keywords: const [
          'قانون',
          'قوانين',
          'تعليمات',
          'نظام',
          'نماذج',
          'وقف',
          'أوقاف',
          'اوقاف',
        ],
      ),
      SearchResult(
        title: 'الشكاوى والبلاغات',
        description: 'تقديم الشكاوى والبلاغات العامة عبر المنصة.',
        category: 'services',
        route: '$base/complaints',
        keywords: const ['شكوى', 'شكاوى', 'بلاغ', 'ملاحظة'],
      ),
      SearchResult(
        title: 'كلمة الوزير',
        description: 'صفحة الوزير والكلمة الرسمية ومعلومات الاتصال المؤسسي.',
        category: 'documents',
        route: '$base/minister',
        keywords: const ['وزير', 'معالي', 'كلمة الوزير'],
      ),
      SearchResult(
        title: 'اتصل بنا',
        description: 'معلومات التواصل الرسمية مع الوزارة والوحدات.',
        category: 'services',
        route: '$base/contact',
        keywords: const ['اتصال', 'تواصل', 'هاتف', 'عنوان'],
      ),
    ];
  }

  String _unitBasePath() {
    final slug = widget.unitSlug.trim().isEmpty
        ? 'home'
        : widget.unitSlug.trim().toLowerCase();
    return PwfUnitSlugRegistry.publicBasePathFor(slug);
  }

  String _normalizeSearch(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('ـ', '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Set<String> _expandedSearchTerms(String normalizedQuery) {
    final terms = <String>{normalizedQuery};
    for (final token in normalizedQuery.split(' ')) {
      final trimmed = token.trim();
      if (trimmed.isEmpty) continue;
      terms.add(trimmed);
      if (trimmed == 'وقف') {
        terms.addAll(const [
          'وقف',
          'وقفي',
          'وقفيه',
          'اوقاف',
          'الاوقاف',
          'اصول وقفيه',
          'اراضي وقفيه',
        ]);
      }
      if (trimmed == 'اوقاف' || trimmed == 'الاوقاف') {
        terms.addAll(const ['وقف', 'وقفي', 'وقفيه']);
      }
    }
    return terms.where((term) => term.isNotEmpty).toSet();
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
  final String route;
  final List<String> keywords;

  SearchResult({
    required this.title,
    required this.description,
    required this.category,
    this.route = '/home',
    this.keywords = const <String>[],
  });
}
