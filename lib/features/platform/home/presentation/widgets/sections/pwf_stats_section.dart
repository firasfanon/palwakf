import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/core/layout/pwf_global_layout_contract.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';

class PwfStatsSection extends ConsumerWidget {
  const PwfStatsSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedSlug = unitSlug.trim().isEmpty
        ? 'home'
        : unitSlug.trim().toLowerCase();
    final scopedAsync = ref.watch(
      homepageSectionsForUnitProvider(normalizedSlug),
    );
    final legacyAsync = ref.watch(statisticsSectionProvider);
    final unit = ref.watch(orgUnitBySlugProvider(normalizedSlug)).valueOrNull;
    final scopeLabel = _resolveScopeLabel(unitSlug: normalizedSlug, unit: unit);

    final scopedSettings = scopedAsync.maybeWhen(
      data: (sections) => _ScopedStatsSettings.fromSections(sections),
      orElse: () => null,
    );
    final legacySettings = legacyAsync.maybeWhen(
      data: (value) => _ScopedStatsSettings.fromLegacy(value),
      orElse: () => null,
    );
    final effectiveSettings = scopedSettings ?? legacySettings;

    if (effectiveSettings != null && !effectiveSettings.enabled) {
      return const SizedBox.shrink();
    }

    final items = _buildItems(effectiveSettings?.counters ?? const <dynamic>[]);
    final totalValue = _sumItems(items);
    final title = normalizedSlug == 'home'
        ? 'إحصائيات الوزارة'
        : 'إحصائيات $scopeLabel';
    final subtitle = normalizedSlug == 'home'
        ? 'مؤشرات وإحصاءات عامة تعكس أعمال وزارة الأوقاف والشؤون الدينية.'
        : 'مؤشرات تُعرض بحسب الوحدة المختارة داخل نفس الصفحة الديناميكية.';

    return PwfSectionContainer(
      sectionKey: 'PwfStatsSection',
      child: Column(
        children: [
            PwfSectionTitle(title: title, subtitle: subtitle),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _metaChip(
                  label: scopeLabel,
                  icon: normalizedSlug == 'home'
                      ? Icons.public
                      : Icons.account_tree_outlined,
                ),
                _metaChip(
                  label: '${items.length} عدادات',
                  icon: Icons.view_module_outlined,
                ),
                _metaChip(
                  label: 'مجموع القيم: ${_formatInt(totalValue)}',
                  icon: Icons.numbers,
                ),
              ],
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final width =
                    constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width;
                final tileWidth = width < 420
                    ? width.clamp(220.0, 360.0).toDouble()
                    : width < 760
                    ? ((width - 16) / 2).clamp(180.0, 260.0).toDouble()
                    : 210.0;
                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: items
                      .map(
                        (item) => SizedBox(
                          width: tileWidth,
                          child: _PwfStatCard(item: item),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            if (scopedAsync.isLoading || legacyAsync.isLoading) ...[
              const SizedBox(height: 12),
              Text(
                '...جارِ تحميل الإحصائيات من قاعدة البيانات',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: PwfHomePalette.gray,
                ),
              ),
            ],
        ],
      ),
    );
  }
}

Widget _metaChip({required String label, required IconData icon}) {
  return PwfSafePill(
    label: label,
    icon: icon,
    maxWidth: 240,
    foreground: PwfHomePalette.primary,
    borderColor: PwfHomePalette.border,
  );
}

class _PwfStatCard extends StatefulWidget {
  const _PwfStatCard({required this.item});

  final _PwfStatItem item;

  @override
  State<_PwfStatCard> createState() => _PwfStatCardState();
}

class _PwfStatCardState extends State<_PwfStatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hover ? 1.015 : 1,
        child: PwfSafeStatTile(
          icon: widget.item.icon,
          value: widget.item.valueText,
          label: widget.item.label,
          accent: PwfHomePalette.primary,
          background: PwfHomePalette.cardBg,
          minHeight: 148,
        ),
      ),
    );
  }
}

List<_PwfStatItem> _buildItems(List<dynamic> counters) {
  if (counters.isEmpty) return _defaults;

  final mapped = counters
      .map<_PwfStatItem>((c) {
        final map = c is Map<String, dynamic>
            ? c
            : Map<String, dynamic>.from(c as Map);
        return _PwfStatItem(
          icon: _iconFromStringSafe((map['icon'] ?? '').toString()),
          valueText: _formatInt((map['value'] as num?)?.toInt() ?? 0),
          label: (map['label'] ?? map['label_ar'] ?? '').toString(),
        );
      })
      .where((e) => e.label.trim().isNotEmpty)
      .toList(growable: true);

  if (mapped.isEmpty) return _defaults;
  if (mapped.length < 6) {
    final existing = mapped.map((e) => e.label).toSet();
    for (final d in _defaults) {
      if (mapped.length >= 6) break;
      if (existing.contains(d.label)) continue;
      mapped.add(d);
    }
  }
  return mapped;
}

int _sumItems(List<_PwfStatItem> items) {
  var total = 0;
  for (final item in items) {
    total += int.tryParse(item.valueText.replaceAll(',', '')) ?? 0;
  }
  return total;
}

class _ScopedStatsSettings {
  const _ScopedStatsSettings({required this.enabled, required this.counters});

  final bool enabled;
  final List<dynamic> counters;

  static _ScopedStatsSettings? fromSections(List<HomepageSection> sections) {
    for (final section in sections) {
      final key = section.sectionName.trim().toLowerCase();
      if (key == 'pwf_stats_grid' || key == 'statistics') {
        final settings = Map<String, dynamic>.from(section.settings);
        return _ScopedStatsSettings(
          enabled: settings['enabled'] is bool
              ? settings['enabled'] as bool
              : true,
          counters: settings['counters'] is List
              ? List<dynamic>.from(settings['counters'] as List)
              : const <dynamic>[],
        );
      }
    }
    return null;
  }

  static _ScopedStatsSettings? fromLegacy(dynamic value) {
    if (value == null) return null;
    final enabled = _tryRead(value, 'enabled');
    final counters = _tryRead(value, 'counters');
    return _ScopedStatsSettings(
      enabled: enabled is bool ? enabled : true,
      counters: counters is List
          ? List<dynamic>.from(counters)
          : const <dynamic>[],
    );
  }
}

dynamic _tryRead(dynamic source, String key) {
  try {
    return (source as dynamic).toJson()[key];
  } catch (_) {}
  try {
    return (source as dynamic)[key];
  } catch (_) {}
  try {
    if (key == 'enabled') return (source as dynamic).enabled;
    if (key == 'counters') return (source as dynamic).counters;
  } catch (_) {}
  return null;
}

class _PwfStatItem {
  const _PwfStatItem({
    required this.icon,
    required this.valueText,
    required this.label,
  });

  final IconData icon;
  final String valueText;
  final String label;
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

String _formatInt(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return buf.toString();
}

IconData _iconFromStringSafe(String raw) {
  final k = raw.trim().toLowerCase();
  switch (k) {
    case 'mosque':
    case 'masjid':
      return Icons.account_balance;
    case 'user':
    case 'users':
    case 'user-friends':
    case 'people':
      return Icons.groups;
    case 'school':
      return Icons.school;
    case 'quran':
      return Icons.menu_book;
    case 'landmark':
      return Icons.account_balance;
    case 'hands-helping':
    case 'help':
      return Icons.volunteer_activism;
    default:
      return Icons.bar_chart;
  }
}

final List<_PwfStatItem> _defaults = <_PwfStatItem>[
  _PwfStatItem(
    icon: Icons.account_balance,
    valueText: '1,850',
    label: 'مسجد تحت الإشراف',
  ),
  _PwfStatItem(
    icon: Icons.groups,
    valueText: '3,200',
    label: 'إمام وخطيب وداعية',
  ),
  _PwfStatItem(icon: Icons.school, valueText: '45', label: 'معهد ديني ومدرسة'),
  _PwfStatItem(
    icon: Icons.menu_book,
    valueText: '12,500',
    label: 'حافظ وحافظة للقرآن',
  ),
  _PwfStatItem(
    icon: Icons.account_balance,
    valueText: '650',
    label: 'وقف إسلامي مسجل',
  ),
  _PwfStatItem(
    icon: Icons.volunteer_activism,
    valueText: '120',
    label: 'مشروع ترميم وصيانة',
  ),
];
