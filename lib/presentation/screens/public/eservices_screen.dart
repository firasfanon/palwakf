// ignore_for_file: unused_element
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';

class EServicesScreen extends ConsumerStatefulWidget {
  const EServicesScreen({super.key});

  @override
  ConsumerState<EServicesScreen> createState() => _EServicesScreenState();
}

class _EServicesScreenState extends ConsumerState<EServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSections = ref.watch(homepageSectionsForUnitProvider('home'));
    return asyncSections.when(
      loading: () => _buildScaffold(
        context,
        const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _buildScaffold(
        context,
        Center(child: Text('تعذر تحميل بيانات الخدمات الإلكترونية: $error')),
      ),
      data: (sections) {
        final settings =
            _PortalSettings.fromSections(sections) ?? const _PortalSettings();
        final items = settings.items.isEmpty ? _defaultItems : settings.items;
        final query = _searchController.text.trim().toLowerCase();
        final visible = query.isEmpty
            ? items
            : items
                  .where((item) {
                    final haystack =
                        '${item.title} ${item.description} ${item.linkLabel} ${item.link}'
                            .toLowerCase();
                    return haystack.contains(query);
                  })
                  .toList(growable: false);
        final linkedCount = items
            .where(
              (item) => item.link.trim().isNotEmpty && item.link.trim() != '#',
            )
            .length;

        final content = Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'ابحث داخل الخدمات الإلكترونية',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => setState(_searchController.clear),
                            icon: const Icon(Icons.close),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoChip(label: 'الوزارة', icon: Icons.public),
                    _InfoChip(
                      label: '${items.length} خدمات',
                      icon: Icons.apps_outlined,
                    ),
                    _InfoChip(
                      label: '${visible.length} نتيجة',
                      icon: Icons.filter_alt_outlined,
                    ),
                    _InfoChip(
                      label: '${linkedCount} مرتبطة',
                      icon: Icons.link_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (visible.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('لا توجد خدمات تطابق البحث الحالي.'),
                    ),
                  )
                else if (kIsWeb)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final cardWidth = width < 760 ? width : (width - 16) / 2;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: visible
                            .map(
                              (item) => SizedBox(
                                width: cardWidth,
                                child: _ServiceCard(
                                  item: item,
                                  onOpen: () => _openRoute(context, item.link),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  )
                else
                  ...visible.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceCard(
                        item: item,
                        onOpen: () => _openRoute(context, item.link),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
        return _buildScaffold(
          context,
          content,
          title: settings.title,
          subtitle: settings.subtitle,
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    Widget child, {
    String? title,
    String? subtitle,
  }) {
    final effectiveTitle = title ?? 'الخدمات الإلكترونية';
    final effectiveSubtitle =
        subtitle ?? 'خدمات الوزارة الإلكترونية وروابط النماذج والمعاملات';
    if (kIsWeb) {
      return WebPublicPage(
        pageSpecKey: 'eservices',
        unitSlug: 'home',
        title: effectiveTitle,
        subtitle: effectiveSubtitle,
        child: child,
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: effectiveTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [child],
      ),
    );
  }

  void _openRoute(BuildContext context, String route) {
    final value = route.trim();
    if (value.isEmpty || value == '#') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم ربط هذه الخدمة في مرحلة لاحقة.')),
      );
      return;
    }
    if (value.startsWith('/')) {
      context.go(value);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الرابط الخارجي وسيُفعّل لاحقًا.')),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.title,
    required this.subtitle,
    required this.totalCount,
    required this.linkedCount,
  });

  final String title;
  final String subtitle;
  final int totalCount;
  final int linkedCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatMiniCard(
                  label: 'إجمالي الخدمات',
                  value: '$totalCount',
                  icon: Icons.apps_outlined,
                ),
                _StatMiniCard(
                  label: 'الخدمات المرتبطة',
                  value: '$linkedCount',
                  icon: Icons.link_outlined,
                ),
                const _StatMiniCard(
                  label: 'النطاق',
                  value: 'الوزارة',
                  icon: Icons.public,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.islamicGreen),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 16), label: Text(label));
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.onOpen});

  final _PortalItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.islamicGreen.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(item.icon, color: AppColors.islamicGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(item.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.open_in_new, size: 18),
                  label: Text(
                    item.linkLabel.isEmpty ? 'فتح الخدمة' : item.linkLabel,
                  ),
                  onPressed: onOpen,
                ),
                if (item.link.trim().isNotEmpty)
                  Chip(
                    avatar: Icon(
                      item.link.trim().startsWith('/')
                          ? Icons.alt_route_outlined
                          : Icons.public_outlined,
                      size: 18,
                    ),
                    label: Text(item.link.trim()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalSettings {
  const _PortalSettings({
    this.title = 'الخدمات الإلكترونية',
    this.subtitle = 'خدمات الوزارة الإلكترونية وروابط النماذج والمعاملات',
    this.items = const <_PortalItem>[],
  });

  final String title;
  final String subtitle;
  final List<_PortalItem> items;

  static _PortalSettings? fromSections(List<HomepageSection> sections) {
    for (final section in sections) {
      if (section.sectionName.trim().toLowerCase() == 'pwf_eservices_portal') {
        final settings = Map<String, dynamic>.from(section.settings);
        final rawItems = settings['items'] is List
            ? List<dynamic>.from(settings['items'] as List)
            : const <dynamic>[];
        return _PortalSettings(
          title: (settings['title'] ?? 'الخدمات الإلكترونية').toString(),
          subtitle:
              (settings['subtitle'] ??
                      'خدمات الوزارة الإلكترونية وروابط النماذج والمعاملات')
                  .toString(),
          items: rawItems
              .map(_PortalItem.fromMap)
              .whereType<_PortalItem>()
              .toList(growable: false),
        );
      }
    }
    return null;
  }
}

class _PortalItem {
  const _PortalItem({
    required this.title,
    required this.description,
    required this.linkLabel,
    required this.link,
    required this.icon,
  });

  final String title;
  final String description;
  final String linkLabel;
  final String link;
  final IconData icon;

  static _PortalItem? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    if (map['enabled'] == false) return null;
    final title = (map['title'] ?? '').toString().trim();
    final description = (map['description'] ?? '').toString().trim();
    if (title.isEmpty && description.isEmpty) return null;
    return _PortalItem(
      title: title,
      description: description,
      linkLabel: (map['link_label'] ?? 'فتح الخدمة').toString(),
      link: (map['route'] ?? AppRoutes.underConstruction).toString(),
      icon: _iconFromKey((map['icon'] ?? '').toString()),
    );
  }
}

IconData _iconFromKey(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'credit_card':
      return Icons.credit_card_outlined;
    case 'building':
      return Icons.apartment_outlined;
    case 'file_signature':
      return Icons.description_outlined;
    case 'dashboard':
      return Icons.dashboard_outlined;
    case 'search':
      return Icons.search_outlined;
    case 'verified':
      return Icons.verified_outlined;
    case 'mosque':
      return Icons.mosque_outlined;
    default:
      return Icons.widgets_outlined;
  }
}

const List<_PortalItem> _defaultItems = <_PortalItem>[
  _PortalItem(
    title: 'خدمات المساجد',
    description: 'إدارة بيانات المساجد والمشاريع والخدمات ذات الصلة.',
    linkLabel: 'فتح الخدمة',
    link: AppRoutes.underConstruction,
    icon: Icons.mosque_outlined,
  ),
  _PortalItem(
    title: 'خدمات الأوقاف',
    description: 'خدمات متعلقة بالأراضي الوقفية والإدارة والاستثمار.',
    linkLabel: 'فتح الخدمة',
    link: AppRoutes.underConstruction,
    icon: Icons.account_balance_outlined,
  ),
  _PortalItem(
    title: 'خدمات الزكاة',
    description: 'التقديم للاستفادة، والاستعلام، والخدمات المرتبطة.',
    linkLabel: 'فتح الخدمة',
    link: AppRoutes.underConstruction,
    icon: Icons.volunteer_activism_outlined,
  ),
  _PortalItem(
    title: 'خدمات الحج والعمرة',
    description: 'متابعة التسجيلات، والإرشادات، والمعلومات الرسمية.',
    linkLabel: 'فتح الخدمة',
    link: AppRoutes.underConstruction,
    icon: Icons.flight_takeoff_outlined,
  ),
];
