import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../pwf_web_container.dart';
import '../shared/pwf_section_title.dart';
import '../../theme/pwf_home_palette.dart';

class PwfMiniMapTeaser extends ConsumerWidget {
  const PwfMiniMapTeaser({super.key, required this.unitSlug});

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
          _MiniMapSettings.fromSections(sections) ?? const _MiniMapSettings(),
      orElse: () => const _MiniMapSettings(),
    );

    if (!settings.enabled) return const SizedBox.shrink();

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
              _metaChip('مدخل تمهيدي للخريطة', Icons.map_outlined),
              _metaChip(
                settings.openMapRoute.trim().startsWith('/')
                    ? 'فتح الخريطة جاهز'
                    : 'فتح الخريطة قيد الإعداد',
                settings.openMapRoute.trim().startsWith('/')
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
              ),
              _metaChip(
                settings.layersRoute.trim().startsWith('/')
                    ? 'الطبقات جاهزة'
                    : 'الطبقات قيد الإعداد',
                settings.layersRoute.trim().startsWith('/')
                    ? Icons.layers_outlined
                    : Icons.pending_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final isNarrow = c.maxWidth < 900;
              final visual = _buildVisualCard(isNarrow, settings);
              final details = _buildDetailsCard(context, settings);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: PwfHomePalette.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [visual, const SizedBox(height: 16), details],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: visual),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: details),
                        ],
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisualCard(bool isNarrow, _MiniMapSettings settings) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: isNarrow ? 220 : 260,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PwfHomePalette.primary.withValues(alpha: 0.10),
              PwfHomePalette.gold.withValues(alpha: 0.14),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 44, color: PwfHomePalette.primary),
              const SizedBox(height: 8),
              Text(
                settings.visualTitle,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PwfHomePalette.dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                settings.visualSubtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: PwfHomePalette.gray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, _MiniMapSettings settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          settings.headline,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: PwfHomePalette.dark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          settings.description,
          style: GoogleFonts.cairo(
            fontSize: 13,
            height: 1.45,
            color: PwfHomePalette.gray,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openRoute(context, settings.openMapRoute),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(
                settings.openMapLabel,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PwfHomePalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _openRoute(context, settings.layersRoute),
              icon: const Icon(Icons.layers_outlined, size: 18),
              label: Text(
                settings.layersLabel,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: PwfHomePalette.primary,
                side: BorderSide(color: PwfHomePalette.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openRoute(BuildContext context, String route) {
    if (route.isEmpty || route == '#') {
      context.go(AppRoutes.mustakshif);
      return;
    }
    if (route.startsWith('/')) {
      context.go(route);
      return;
    }
    context.go(route.startsWith('/') ? route : '/$route');
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

class _MiniMapSettings {
  const _MiniMapSettings({
    this.enabled = true,
    this.title = 'الخريطة التفاعلية للأوقاف',
    this.subtitle = 'استكشاف المواقع والطبقات الجغرافية ذات الصلة',
    this.visualTitle = 'معاينة الخريطة',
    this.visualSubtitle = 'مرتبطة بمستكشف الوقف والطبقات الجغرافية العامة',
    this.headline = 'استكشف على الخريطة',
    this.description =
        'اعرض طبقات إدارية وتاريخية، وارتباطات مكانية للمحتوى والخدمات.',
    this.openMapLabel = 'فتح الخريطة',
    this.openMapRoute = AppRoutes.mustakshif,
    this.layersLabel = 'استعراض الطبقات',
    this.layersRoute = AppRoutes.mustakshif,
  });

  final bool enabled;
  final String title;
  final String subtitle;
  final String visualTitle;
  final String visualSubtitle;
  final String headline;
  final String description;
  final String openMapLabel;
  final String openMapRoute;
  final String layersLabel;
  final String layersRoute;

  static _MiniMapSettings? fromSections(List<HomepageSection> sections) {
    for (final section in sections) {
      final key = section.sectionName.trim().toLowerCase();
      if (key == 'pwf_mini_map_teaser') {
        final settings = Map<String, dynamic>.from(section.settings);
        return _MiniMapSettings(
          enabled: settings['enabled'] is bool
              ? settings['enabled'] as bool
              : true,
          title: (settings['title'] ?? 'الخريطة التفاعلية للأوقاف').toString(),
          subtitle:
              (settings['subtitle'] ??
                      'استكشاف المواقع والطبقات الجغرافية ذات الصلة')
                  .toString(),
          visualTitle: (settings['visual_title'] ?? 'معاينة الخريطة')
              .toString(),
          visualSubtitle:
              (settings['visual_subtitle'] ??
                      'مرتبطة بمستكشف الوقف والطبقات الجغرافية العامة')
                  .toString(),
          headline: (settings['headline'] ?? 'استكشف على الخريطة').toString(),
          description:
              (settings['description'] ??
                      'اعرض طبقات إدارية وتاريخية، وارتباطات مكانية للمحتوى والخدمات.')
                  .toString(),
          openMapLabel: (settings['open_map_label'] ?? 'فتح الخريطة')
              .toString(),
          openMapRoute: (settings['open_map_route'] ?? AppRoutes.mustakshif)
              .toString(),
          layersLabel: (settings['layers_label'] ?? 'استعراض الطبقات')
              .toString(),
          layersRoute: (settings['layers_route'] ?? AppRoutes.mustakshif)
              .toString(),
        );
      }
    }
    return null;
  }
}
