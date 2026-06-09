import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pwf_top_bar.dart';
import 'pwf_main_header.dart';
import 'pwf_main_nav.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../../../../../presentation/providers/homepage_settings_provider.dart';

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
        .watch(allHomepageSectionsProvider)
        .maybeWhen(data: (items) => items, orElse: () => const []);

    // Fail-open visibility:
    // - If an explicit row exists for a section name, respect its isActive.
    // - If no row exists (common when unit-aware rows are missing), show by default.
    // - If multiple rows exist (e.g. GLOBAL + unit), any active row wins.
    final statusByKey = <String, bool>{};
    for (final s in sections) {
      final k = _normalizeSectionName(s.sectionName);
      final prev = statusByKey[k];
      if (prev == true) continue; // any active wins
      statusByKey[k] = s.isActive;
    }

    bool isVisibleByDefault(String rawKey) {
      final k = _normalizeSectionName(rawKey);
      if (!statusByKey.containsKey(k)) return true;
      return statusByKey[k] == true;
    }

    final showTopBar =
        isVisibleByDefault('pwf_top_bar') ||
        isVisibleByDefault('PwfTopBar') ||
        isVisibleByDefault('top_bar');

    final showMainNav =
        isVisibleByDefault('pwf_main_nav') ||
        isVisibleByDefault('PwfMainNav') ||
        isVisibleByDefault('main_nav');

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
          if (showTopBar) const PwfTopBar(),
          PwfMainHeader(unitSlug: unitSlug),
          if (showMainNav) const PwfMainNav(),
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
