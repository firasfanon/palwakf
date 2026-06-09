import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../pwf_web_container.dart';
import '../shared/pwf_section_title.dart';
import '../../theme/pwf_home_palette.dart';

class PwfFeatureHighlights extends ConsumerWidget {
  const PwfFeatureHighlights({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final sectionsAsync = ref.watch(
      homepageSectionsForUnitProvider(normalizedSlug),
    );
    final unit = ref.watch(orgUnitBySlugProvider(normalizedSlug)).valueOrNull;
    final scopeLabel = _resolveScopeLabel(unitSlug: normalizedSlug, unit: unit);
    final settings = sectionsAsync.maybeWhen(
      data: (sections) =>
          _FeatureHighlightsSettings.fromSections(sections) ??
          const _FeatureHighlightsSettings(),
      orElse: () => const _FeatureHighlightsSettings(),
    );

    if (!settings.enabled) return const SizedBox.shrink();
    final items = settings.items.isEmpty ? _defaultItems : settings.items;

    return PwfWebContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfSectionTitle(title: settings.title, subtitle: settings.subtitle),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metaChip(
                scopeLabel,
                normalizedSlug == 'home'
                    ? Icons.public
                    : Icons.account_tree_outlined,
              ),
              _metaChip('${items.length} بطاقات', Icons.auto_awesome_outlined),
              _metaChip('واجهة عامة أغنى', Icons.dashboard_customize_outlined),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final isTight = c.maxWidth < 900;
              final itemWidth = isTight ? c.maxWidth : (c.maxWidth - 24) / 3;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items
                    .map((item) => _HighlightCard(width: itemWidth, item: item))
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _metaChip(String label, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: PwfHomePalette.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: PwfHomePalette.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: PwfHomePalette.dark,
          ),
        ),
      ],
    ),
  );
}

class _HighlightCard extends StatefulWidget {
  const _HighlightCard({required this.width, required this.item});

  final double width;
  final _HighlightItem item;

  @override
  State<_HighlightCard> createState() => _HighlightCardState();
}

class _HighlightCardState extends State<_HighlightCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: widget.width,
        transform: _hover ? (Matrix4.identity()..translate(0.0, -8.0)) : null,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: PwfHomePalette.border),
          boxShadow: _hover ? PwfHomeShadows.cardHover : PwfHomeShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: PwfHomePalette.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.item.icon, color: PwfHomePalette.primary),
            ),
            const SizedBox(height: 14),
            Text(
              widget.item.title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: PwfHomePalette.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.text,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                color: PwfHomePalette.gray,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureHighlightsSettings {
  const _FeatureHighlightsSettings({
    this.enabled = true,
    this.title = 'بوابة الوزارة الرقمية',
    this.subtitle =
        'استكشف أبرز الخدمات العامة والمحتوى الرقمي والروابط الرسمية',
    this.items = const <_HighlightItem>[],
  });

  final bool enabled;
  final String title;
  final String subtitle;
  final List<_HighlightItem> items;

  static _FeatureHighlightsSettings? fromSections(
    List<HomepageSection> sections,
  ) {
    for (final section in sections) {
      final key = section.sectionName.trim().toLowerCase();
      if (key == 'pwf_feature_highlights') {
        final settings = Map<String, dynamic>.from(section.settings);
        final rawItems = settings['items'] is List
            ? List<dynamic>.from(settings['items'] as List)
            : const <dynamic>[];
        return _FeatureHighlightsSettings(
          enabled: settings['enabled'] is bool
              ? settings['enabled'] as bool
              : true,
          title: (settings['title'] ?? 'بوابة الوزارة الرقمية').toString(),
          subtitle:
              (settings['subtitle'] ??
                      'استكشف أبرز الخدمات العامة والمحتوى الرقمي والروابط الرسمية')
                  .toString(),
          items: rawItems
              .map(_HighlightItem.fromMap)
              .whereType<_HighlightItem>()
              .toList(growable: false),
        );
      }
    }
    return null;
  }
}

class _HighlightItem {
  const _HighlightItem({
    required this.icon,
    required this.iconKey,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String iconKey;
  final String title;
  final String text;

  static _HighlightItem? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    if (map['enabled'] == false) return null;
    final title = (map['title'] ?? '').toString();
    final text = (map['description'] ?? map['text'] ?? '').toString();
    if (title.trim().isEmpty || text.trim().isEmpty) return null;
    final iconKey = (map['icon'] ?? '').toString();
    return _HighlightItem(
      icon: _iconFromKey(iconKey),
      iconKey: iconKey,
      title: title,
      text: text,
    );
  }
}

String _resolveScopeLabel({
  required String unitSlug,
  Map<String, dynamic>? unit,
}) {
  final normalizedSlug = unitSlug.trim().isEmpty
      ? 'home'
      : unitSlug.trim().toLowerCase();
  if (normalizedSlug == 'home') return 'الوزارة';
  final candidates = [
    unit?['name_ar'],
    unit?['title_ar'],
    unit?['name'],
    unit?['name_en'],
  ];
  for (final candidate in candidates) {
    final value = (candidate ?? '').toString().trim();
    if (value.isNotEmpty) return value;
  }
  return 'الوحدة الحالية';
}

IconData _iconFromKey(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'dashboard':
      return Icons.dashboard_outlined;
    case 'search':
      return Icons.search_outlined;
    case 'verified':
      return Icons.verified_outlined;
    case 'link':
      return Icons.link_outlined;
    case 'widgets':
      return Icons.widgets_outlined;
    default:
      return Icons.auto_awesome_outlined;
  }
}

const List<_HighlightItem> _defaultItems = <_HighlightItem>[
  _HighlightItem(
    icon: Icons.dashboard_outlined,
    iconKey: 'dashboard',
    title: 'واجهة موحدة',
    text: 'الوصول إلى الأخبار والخدمات والروابط والمحتوى العام من مكان واحد.',
  ),
  _HighlightItem(
    icon: Icons.search_outlined,
    iconKey: 'search',
    title: 'وصول سريع',
    text:
        'الوصول السريع إلى الخدمات الإلكترونية والمحتوى العام الأكثر استخداماً.',
  ),
  _HighlightItem(
    icon: Icons.verified_outlined,
    iconKey: 'verified',
    title: 'محتوى موثوق',
    text: 'محتوى عام ورسمي صادر عن الوزارة ويجري تحديثه عبر المنصة.',
  ),
];
