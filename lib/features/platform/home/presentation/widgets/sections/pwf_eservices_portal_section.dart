import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_inline_link.dart';
import '../shared/pwf_section_title.dart';

class PwfEServicesPortalSection extends ConsumerWidget {
  const PwfEServicesPortalSection({super.key, this.unitSlug = 'home'});

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
          _EServicesSettings.fromSections(sections) ??
          const _EServicesSettings(),
      orElse: () => const _EServicesSettings(),
    );

    if (!settings.enabled) return const SizedBox.shrink();
    final items = settings.items.isEmpty ? _defaultItems : settings.items;

    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return PwfSectionContainer(
      sectionKey: 'PwfEServicesPortalSection',
      child: Column(
          children: [
            PwfSectionTitle(title: settings.title, subtitle: settings.subtitle),
            const SizedBox(height: 8),
            _GovernanceMetaRow(
              chips: [
                _metaChip(
                  label: scopeLabel,
                  icon: normalizedSlug == 'home'
                      ? Icons.public
                      : Icons.account_tree_outlined,
                ),
                _metaChip(
                  label: '${items.length} خدمات',
                  icon: Icons.apps_outlined,
                ),
                _metaChip(
                  label: 'ربط موحد مع الصفحة الديناميكية',
                  icon: Icons.hub_outlined,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 28),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isMobile ? 360 : 420,
                mainAxisSpacing: isMobile ? 14 : 25,
                crossAxisSpacing: isMobile ? 14 : 25,
                mainAxisExtent: isMobile ? 244 : 282,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _PwfEServiceCard(item: items[i]),
            ),
        ],
      ),
    );
  }
}

class _GovernanceMetaRow extends StatelessWidget {
  const _GovernanceMetaRow({required this.chips});

  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < chips.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            chips[i],
          ],
        ],
      ),
    );
  }
}

Widget _metaChip({required String label, required IconData icon}) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

class _PwfEServiceCard extends StatefulWidget {
  const _PwfEServiceCard({required this.item});

  final _PwfEServiceItem item;

  @override
  State<_PwfEServiceCard> createState() => _PwfEServiceCardState();
}

class _PwfEServiceCardState extends State<_PwfEServiceCard>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _setHover(bool v) {
    if (_hover == v) return;
    setState(() => _hover = v);
    if (v) {
      _ctl.forward(from: 0);
    } else {
      _ctl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hover ? (Matrix4.identity()..translate(0.0, -10.0)) : null,
        decoration: BoxDecoration(
          color: PwfHomePalette.cardBg,
          borderRadius: PwfHomeRadii.br8,
          boxShadow: _hover ? PwfHomeShadows.cardHover : PwfHomeShadows.card,
          border: Border(top: BorderSide(color: accentColor, width: 4)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ctl,
                builder: (_, __) {
                  if (!_hover) return const SizedBox.shrink();
                  final t = _ctl.value;
                  return ClipRRect(
                    borderRadius: PwfHomeRadii.br8,
                    child: Transform.translate(
                      offset: Offset((t * 2 - 1) * 600, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 22,
                isMobile ? 16 : 22,
                isMobile ? 16 : 22,
                isMobile ? 14 : 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    widget.item.icon,
                    size: isMobile ? 30 : 38,
                    color: accentColor,
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Text(
                    widget.item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 14.5 : 15.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Expanded(
                    child: Text(
                      widget.item.description,
                      maxLines: isMobile ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 12.5 : 13.5,
                        color: PwfHomePalette.gray,
                        height: 1.45,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  SizedBox(
                    width: double.infinity,
                    child: PwfInlineLink(
                    label: widget.item.linkLabel,
                    icon: Icons.arrow_back,
                    onTap: () {
                      final link = widget.item.link.trim();
                      if (link.isEmpty) {
                        context.go(AppRoutes.eservices);
                        return;
                      }
                      if (link.startsWith('http://') ||
                          link.startsWith('https://')) {
                        launchUrlString(link);
                        return;
                      }
                      if (link.startsWith('#')) {
                        context.go(AppRoutes.eservices);
                        return;
                      }
                      context.go(link.startsWith('/') ? link : '/$link');
                    },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EServicesSettings {
  const _EServicesSettings({
    this.enabled = true,
    this.title = 'بوابة الخدمات الإلكترونية',
    this.subtitle =
        'وصول مباشر إلى الخدمات الإلكترونية والنماذج والإجراءات العامة المتاحة',
    this.items = const <_PwfEServiceItem>[],
  });

  final bool enabled;
  final String title;
  final String subtitle;
  final List<_PwfEServiceItem> items;

  static _EServicesSettings? fromSections(List<HomepageSection> sections) {
    for (final section in sections) {
      final key = section.sectionName.trim().toLowerCase();
      if (key == 'pwf_eservices_portal') {
        final settings = Map<String, dynamic>.from(section.settings);
        final rawItems = settings['items'] is List
            ? List<dynamic>.from(settings['items'] as List)
            : const <dynamic>[];
        return _EServicesSettings(
          enabled: settings['enabled'] is bool
              ? settings['enabled'] as bool
              : true,
          title: (settings['title'] ?? 'بوابة الخدمات الإلكترونية').toString(),
          subtitle:
              (settings['subtitle'] ??
                      'وصول مباشر إلى الخدمات الإلكترونية والنماذج والإجراءات العامة المتاحة')
                  .toString(),
          items: rawItems
              .map(_PwfEServiceItem.fromMap)
              .whereType<_PwfEServiceItem>()
              .toList(growable: false),
        );
      }
    }
    return null;
  }
}

class _PwfEServiceItem {
  const _PwfEServiceItem({
    required this.icon,
    required this.iconKey,
    required this.title,
    required this.description,
    required this.linkLabel,
    required this.link,
    this.enabled = true,
  });

  final IconData icon;
  final String iconKey;
  final String title;
  final String description;
  final String linkLabel;
  final String link;
  final bool enabled;

  static _PwfEServiceItem? fromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    if (map['enabled'] == false) return null;
    return _PwfEServiceItem(
      icon: _iconFromKey((map['icon'] ?? '').toString()),
      iconKey: (map['icon'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      linkLabel: (map['link_label'] ?? 'فتح الخدمة').toString(),
      link: (map['route'] ?? AppRoutes.eservices).toString(),
      enabled: map['enabled'] is bool ? map['enabled'] as bool : true,
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
    case 'credit_card':
      return Icons.credit_card;
    case 'building':
      return Icons.account_balance;
    case 'file_signature':
      return Icons.description;
    case 'mosque':
      return Icons.account_balance;
    case 'chart':
      return Icons.bar_chart;
    default:
      return Icons.bolt;
  }
}

final List<_PwfEServiceItem> _defaultItems = <_PwfEServiceItem>[
  _PwfEServiceItem(
    icon: Icons.forum,
    iconKey: 'file_signature',
    title: 'الشكاوى والمتابعة',
    description: 'تقديم الشكاوى العامة ومتابعة حالتها ضمن واجهة المنصة العامة.',
    linkLabel: 'فتح الخدمة',
    link: AppRoutes.complaints,
  ),
  _PwfEServiceItem(
    icon: Icons.volunteer_activism,
    iconKey: 'credit_card',
    title: 'حاسبة الزكاة',
    description:
        'احتساب الزكاة لأنواع الأموال المختلفة وفق الضوابط الشرعية المعتمدة.',
    linkLabel: 'الانتقال للخدمة',
    link: AppRoutes.zakat,
  ),
  _PwfEServiceItem(
    icon: Icons.event,
    iconKey: 'clock',
    title: 'مواقيت الصلاة',
    description:
        'مواقيت الصلاة واتجاه القبلة وفق المدينة وطريقة الاحتساب المعتمدة.',
    linkLabel: 'عرض المواقيت',
    link: AppRoutes.prayerTimes,
  ),
  _PwfEServiceItem(
    icon: Icons.menu_book,
    iconKey: 'mosque',
    title: 'القرآن الكريم',
    description: 'قراءة السور والآيات ضمن واجهة منسجمة مع بوابة وزارة الأوقاف.',
    linkLabel: 'فتح الصفحة',
    link: AppRoutes.quran,
  ),
];
