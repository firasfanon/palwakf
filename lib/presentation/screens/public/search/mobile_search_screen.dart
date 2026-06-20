// lib/presentation/screens/public/search/mobile_search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/core/unit/pwf_unit_slug_registry.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_app_bar.dart';

/// Mobile-optimized Search Screen
/// Features: Vertical scrolling, mobile-friendly search interface
class MobileSearchScreen extends StatefulWidget {
  const MobileSearchScreen({
    super.key,
    this.initialQuery = '',
    this.unitSlug = 'home',
  });

  final String initialQuery;
  final String unitSlug;

  @override
  State<MobileSearchScreen> createState() => _MobileSearchScreenState();
}

class _MobileSearchScreenState extends State<MobileSearchScreen> {
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
      appBar: const CustomAppBar(title: 'البحث'),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      color: Colors.grey[50],
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث في جميع الأقسام...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchResults.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _performSearch(value);
            },
            onSubmitted: _performSearch,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(_getCategoryName(category)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        if (_searchQuery.isNotEmpty) {
                          _performSearch(_searchQuery);
                        }
                      });
                    },
                    selectedColor: AppColors.islamicGreen.withValues(
                      alpha: 0.2,
                    ),
                    checkmarkColor: AppColors.islamicGreen,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      children: [
        Text(
          'البحث السريع',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                'المساجد',
                'الخدمات الإلكترونية',
                'الأخبار',
                'الأنشطة',
                'معالي الوزير',
                'اتصل بنا',
              ].map((suggestion) {
                return ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _searchController.text = suggestion;
                    _performSearch(suggestion);
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 32),
        Text(
          'عمليات البحث الأخيرة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._getRecentSearches().map((search) {
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(search),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {},
            ),
            onTap: () {
              _searchController.text = search;
              _performSearch(search);
            },
          );
        }),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: AppTextStyles.titleMedium.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على نتائج لـ "$_searchQuery"',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _searchResults.clear();
              });
            },
            child: const Text('مسح البحث'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(result.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            _getCategoryIcon(result.category),
            color: _getCategoryColor(result.category),
          ),
        ),
        title: Text(
          result.title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  result.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getCategoryName(result.category),
                style: TextStyle(
                  color: _getCategoryColor(result.category),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(result.route),
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
    final searchLower = _normalizeSearch(query);
    final queryTerms = _expandedSearchTerms(searchLower);
    final allResults = _searchIndex();
    final scoped = _selectedCategory == 'all'
        ? allResults
        : allResults.where((result) => result.category == _selectedCategory);
    return scoped.where((result) {
      final haystack = _normalizeSearch(
        [result.title, result.description, ...result.keywords].join(' '),
      );
      return queryTerms.any(haystack.contains);
    }).toList();
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

  List<String> _getRecentSearches() {
    return ['المساجد', 'الخدمات', 'الأنشطة'];
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
