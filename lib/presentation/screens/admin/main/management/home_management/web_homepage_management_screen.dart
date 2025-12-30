import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/providers/header_settings_provider.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/widgets/home/announcements_section.dart';
import 'package:waqf/presentation/widgets/home/services_section.dart';
import 'package:waqf/presentation/widgets/web/web_sidebar.dart';
import 'widgets/common/page_header.dart';
import 'widgets/common/unsaved_changes_banner.dart';
import 'widgets/sections/breaking_news_section.dart';
import 'widgets/sections/footer_settings_section.dart';
import 'widgets/sections/header_settings_section.dart';
import 'widgets/sections/hero_slider_section.dart';
import 'widgets/sections/minister_section.dart';
import 'widgets/sections/statistics_section.dart';

class WebHomePageManagementScreen extends ConsumerStatefulWidget {
  const WebHomePageManagementScreen({super.key});

  @override
  ConsumerState<WebHomePageManagementScreen> createState() =>
      _WebHomePageManagementScreenState();
}

class _WebHomePageManagementScreenState
    extends ConsumerState<WebHomePageManagementScreen> {
  String _activeTab = 'general_settings';
  String _activeSection = 'header';
  String _previewMode = 'desktop';

  @override
  Widget build(BuildContext context) {
    final headerState = ref.watch(headerSettingsProvider);
    final footerState = ref.watch(footerSettingsProvider);
    final ministerState = ref.watch(ministerSectionNotifierProvider);
    final statsState = ref.watch(statisticsSectionNotifierProvider);
    final newsState = ref.watch(newsSectionNotifierProvider);
    final annState = ref.watch(announcementsSectionNotifierProvider);
    final breakingNewsState = ref.watch(breakingNewsSectionNotifierProvider);


    final hasUnsavedChanges = headerState.hasChanges ||
        footerState.hasChanges ||
        ministerState.hasUnsavedChanges ||
        statsState.hasUnsavedChanges ||
        newsState.hasUnsavedChanges ||
        annState.hasUnsavedChanges ||
        breakingNewsState.hasUnsavedChanges;

    return Scaffold(
      body: Row(
        children: [
          const WebSidebar(currentRoute: '/admin/home-management'),
          Expanded(
            child: Column(
              children: [
                PageHeader(
                  previewMode: _previewMode,
                  hasUnsavedChanges: hasUnsavedChanges,
                  onPreviewModeChanged: (mode) =>
                      setState(() => _previewMode = mode),
                  onSave: _handleSave,
                  onPreview: _handlePreview,
                ),
                if (hasUnsavedChanges)
                  UnsavedChangesBanner(
                    onSave: _handleSave,
                    onReset: _handleReset,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainTabs(),
                        const SizedBox(height: 24),
                        if (_activeTab == 'general_settings')
                          _buildGeneralSettingsSectionNav(),
                        if (_activeTab == 'content_management')
                          _buildContentManagementSectionNav(),
                        const SizedBox(height: 32),
                        _buildActiveSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabs() {
    final tabs = [
      {
        'id': 'general_settings',
        'name': 'الإعدادات الرئيسية',
        'icon': Icons.settings
      },
      {
        'id': 'content_management',
        'name': 'إدارة المحتوى',
        'icon': Icons.article
      },
      {'id': 'pages', 'name': 'إدارة الصفحات', 'icon': Icons.description},
      {'id': 'services', 'name': 'إدارة الخدمات', 'icon': Icons.settings},
      {'id': 'navigation', 'name': 'القوائم والتنقل', 'icon': Icons.menu},
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab['id'];
          return Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _activeTab = tab['id'] as String;
                if (_activeTab == 'general_settings') {
                  _activeSection = 'header';
                } else if (_activeTab == 'content_management') {
                  _activeSection = 'minister';
                }
              }),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppConstants.islamicGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color:
                      AppConstants.islamicGreen.withValues(alpha:0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isActive
                          ? Colors.white
                          : AppConstants.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['name'] as String,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : AppConstants.textSecondary,
                        fontWeight:
                        isActive ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGeneralSettingsSectionNav() {
    final sections = [
      {
        'id': 'header',
        'name': 'إعدادات الهيدر',
        'icon': Icons.web,
        'color': Colors.blue
      },

      {
        'id': 'hero',
        'name': 'الشرائح',
        'icon': Icons.slideshow,
        'color': Colors.purple
      },

      {'id': 'breaking_news',
        'name': 'الأخبار العاجلة',
        'icon': Icons.campaign,
        'color': Colors.red
      },

      {
        'id': 'footer',
        'name': 'إعدادات الفوتر',
        'icon': Icons.layers,
        'color': Colors.teal
      },

    ];

    return _buildSectionNav(sections);
  }

  Widget _buildContentManagementSectionNav() {
    final sections = [
      {
        'id': 'minister',
        'name': 'كلمة الوزير',
        'icon': Icons.person,
        'color': Colors.blue
      },
      {
        'id': 'statistics',
        'name': 'الإحصائيات',
        'icon': Icons.bar_chart,
        'color': Colors.green
      },
      {
        'id': 'news',
        'name': 'الأخبار',
        'icon': Icons.article,
        'color': Colors.orange
      },
      {
        'id': 'announcements',
        'name': 'الإعلانات',
        'icon': Icons.campaign,
        'color': Colors.red
      },
      {
        'id': 'services',
        'name': 'الخدمات',
        'icon': Icons.miscellaneous_services,
        'color': Colors.teal
      },
    ];

    return _buildSectionNav(sections);
  }

  Widget _buildSectionNav(List<Map<String, dynamic>> sections) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: sections.map((section) {
          final isActive = _activeSection == section['id'];
          return InkWell(
            onTap: () => setState(() => _activeSection = section['id'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isActive ? AppConstants.islamicGreen : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppConstants.islamicGreen : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    section['icon'] as IconData,
                    color: isActive ? Colors.white : section['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section['name'] as String,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppConstants.textPrimary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveSection() {
    if (_activeTab == 'general_settings') {
      switch (_activeSection) {
        case 'header':
          return const HeaderSettingsSection();

        case 'hero':
          return const HeroSliderSection();

        case 'breaking_news':
          return const BreakingNewsSection();

        case 'footer':
          return const FooterSettingsSection();

        default:
          return _buildPlaceholder('قسم $_activeSection');
      }
    } else if (_activeTab == 'content_management') {
      switch (_activeSection) {
        case 'minister':
          return const MinisterSection();
        case 'statistics':
          return const StatisticsSection();
        case 'news':
          return const NewsSection();
        case 'announcements':
          return const AnnouncementsSection();
        default:
          return _buildPlaceholder('قسم $_activeSection');
      }
    }

    return _buildPlaceholder('قسم $_activeTab');
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'إعدادات هذا القسم متاحة الآن',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    bool allSuccess = true;

    if (ref.read(headerSettingsProvider).hasChanges) {
      final success = await ref.read(headerSettingsProvider.notifier).saveSettings();
      allSuccess = allSuccess && success;
    }

    if (ref.read(footerSettingsProvider).hasChanges) {
      final success = await ref.read(footerSettingsProvider.notifier).saveSettings();
      allSuccess = allSuccess && success;
    }

    if (ref.read(breakingNewsSectionNotifierProvider).hasUnsavedChanges) {
      final success = await ref
          .read(breakingNewsSectionNotifierProvider.notifier)
          .saveSettings();
      allSuccess = allSuccess && success;
    }

    if (_activeTab == 'content_management') {
      switch (_activeSection) {
        case 'minister':
          final success = await ref
              .read(ministerSectionNotifierProvider.notifier)
              .saveSettings();
          allSuccess = allSuccess && success;
          break;
        case 'statistics':
          final success = await ref
              .read(statisticsSectionNotifierProvider.notifier)
              .saveSettings();
          allSuccess = allSuccess && success;
          break;
        case 'news':
          final success =
          await ref.read(newsSectionNotifierProvider.notifier).saveSettings();
          allSuccess = allSuccess && success;
          break;
        case 'announcements':
          final success = await ref
              .read(announcementsSectionNotifierProvider.notifier)
              .saveSettings();
          allSuccess = allSuccess && success;
          break;

      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            allSuccess ? 'تم حفظ التغييرات بنجاح' : 'فشل الحفظ، حاول مجدداً',
          ),
          backgroundColor: allSuccess ? AppConstants.success : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleReset() {
    if (_activeTab == 'general_settings') {
      switch (_activeSection) {
        case 'header':
          ref.read(headerSettingsProvider.notifier).resetChanges();
          break;


        case 'breaking_news':
          ref.read(breakingNewsSectionNotifierProvider.notifier).resetChanges();
          break;

        case 'footer':
          ref.read(footerSettingsProvider.notifier).resetChanges();
          break;
      }
    } else if (_activeTab == 'content_management') {
      switch (_activeSection) {
        case 'minister':
          ref.read(ministerSectionNotifierProvider.notifier).resetChanges();
          break;
        case 'statistics':
          ref.read(statisticsSectionNotifierProvider.notifier).resetChanges();
          break;
        case 'news':
          ref.read(newsSectionNotifierProvider.notifier).resetChanges();
          break;
        case 'announcements':
          ref.read(announcementsSectionNotifierProvider.notifier).resetChanges();
          break;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء التغييرات'),
          backgroundColor: AppConstants.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فتح المعاينة في نافذة جديدة'),
        backgroundColor: AppConstants.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}