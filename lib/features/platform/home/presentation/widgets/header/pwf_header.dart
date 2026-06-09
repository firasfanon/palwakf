import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pwf_top_bar.dart';
import 'pwf_main_header.dart';
import 'pwf_main_nav.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';

class PwfHeader extends ConsumerWidget {
  const PwfHeader({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);

    // Header visibility can be driven by DB-configured homepage sections.
    // If the list is empty/unavailable, we default to the full header.
    final sections = ref
        .watch(homepageSectionsForUnitProvider(unitSlug))
        .maybeWhen(data: (items) => items, orElse: () => const []);
    final normalizedActive = {
      for (final s in sections)
        if (s.isActive) _normalizeSectionName(s.sectionName): true,
    };
    final showTopBar =
        normalizedActive.isEmpty ||
        normalizedActive[_normalizeSectionName('pwf_top_bar')] == true ||
        normalizedActive[_normalizeSectionName('PwfTopBar')] == true ||
        normalizedActive[_normalizeSectionName('top_bar')] == true;
    final showMainNav =
        normalizedActive.isEmpty ||
        normalizedActive[_normalizeSectionName('pwf_main_nav')] == true ||
        normalizedActive[_normalizeSectionName('PwfMainNav')] == true ||
        normalizedActive[_normalizeSectionName('main_nav')] == true;

    // HTML header is sticky with a gradient background.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: t.headerGradient,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTopBar) PwfTopBar(unitSlug: unitSlug),
          PwfMainHeader(unitSlug: unitSlug),
          if (showMainNav) PwfMainNav(unitSlug: unitSlug),
        ],
      ),
    );
  }
}

String _normalizeSectionName(String raw) {
  final lower = raw.trim().toLowerCase();
  return lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}
