// lib/presentation/screens/public/search/mobile_search_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_app_bar.dart';

/// Mobile-optimized Search Screen
/// Features: Vertical scrolling, mobile-friendly search interface
class MobileSearchScreen extends StatefulWidget {
  const MobileSearchScreen({super.key});

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
          Expanded(
            child: _buildSearchResults(),
          ),
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
                    selectedColor: AppColors.islamicGreen.withValues(alpha:0.2),
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
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على نتائج لـ "$_searchQuery"',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
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
            color: _getCategoryColor(result.category).withValues(alpha:0.1),
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
                color: _getCategoryColor(result.category).withValues(alpha:0.1),
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
        onTap: () {
          // Navigate to result
        },
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
    return [
      SearchResult(
        title: 'دليل المساجد في فلسطين',
        description: 'دليل شامل للمساجد في جميع المحافظات الفلسطينية',
        category: 'mosques',
      ),
      SearchResult(
        title: 'الخدمات الإلكترونية',
        description: 'احصل على الخدمات الحكومية بطريقة سهلة وسريعة',
        category: 'services',
      ),
      SearchResult(
        title: 'آخر الأخبار',
        description: 'تابع آخر الأخبار والتحديثات من الوزارة',
        category: 'news',
      ),
    ];
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

  SearchResult({
    required this.title,
    required this.description,
    required this.category,
  });
}