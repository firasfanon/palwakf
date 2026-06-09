import 'package:flutter/material.dart';

import '../../features/platform/home/presentation/theme/pwf_theme_tokens.dart';
import 'visual_identity_contract.dart';

class PwfVisualIdentityRegistry {
  const PwfVisualIdentityRegistry._();

  static const String docsPath =
      'docs/visual_identity/PALWAKF_VISUAL_IDENTITY_MASTER_MERGED_V1_1_AR.md';

  static final Map<PwfVisualContext, PwfVisualPreset>
  _runtimePublishedOverrides = <PwfVisualContext, PwfVisualPreset>{};

  static const PwfVisualPalette sovereignBluePalette = PwfVisualPalette(
    primary: Color(0xFF0F4C81),
    primaryHover: Color(0xFF0C3E6A),
    secondary: Color(0xFFC9A227),
    royalRed: Color(0xFFB22222),
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE3EAF6),
    textPrimary: Color(0xFF102A43),
    textSecondary: Color(0xFF486581),
  );

  static const PwfVisualPalette waqfGreenPalette = PwfVisualPalette(
    primary: Color(0xFF1F6B45),
    primaryHover: Color(0xFF175437),
    secondary: Color(0xFFC8A44D),
    royalRed: Color(0xFFB22222),
    background: Color(0xFFF8FAF7),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFD8E4DD),
    textPrimary: Color(0xFF163126),
    textSecondary: Color(0xFF567164),
  );

  static const PwfVisualPalette heritageStonePalette = PwfVisualPalette(
    primary: Color(0xFF7A1F2B),
    primaryHover: Color(0xFF641923),
    secondary: Color(0xFFB9923F),
    royalRed: Color(0xFFB22222),
    background: Color(0xFFF4EFE8),
    surface: Color(0xFFFFFDFC),
    border: Color(0xFFD8CFC2),
    textPrimary: Color(0xFF2E2A26),
    textSecondary: Color(0xFF6B6258),
  );

  static PwfVisualPreset? presetById(String id) {
    for (final preset in defaults) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  static void applyPublishedMappings(Map<String, String> mappings) {
    _runtimePublishedOverrides.clear();
    for (final entry in mappings.entries) {
      PwfVisualContext? context;
      for (final item in PwfVisualContext.values) {
        if (item.key == entry.key) {
          context = item;
          break;
        }
      }
      final preset = presetById(entry.value);
      if (context != null && preset != null && preset.context == context) {
        _runtimePublishedOverrides[context] = preset;
      }
    }
  }

  static void publishRuntimeOverride(PwfVisualPreset preset) {
    _runtimePublishedOverrides[preset.context] = preset;
  }

  static void rollbackRuntimeContext(
    PwfVisualContext context, {
    PwfVisualPreset? preset,
  }) {
    if (preset == null) {
      _runtimePublishedOverrides.remove(context);
      return;
    }
    _runtimePublishedOverrides[context] = preset;
  }

  static const List<PwfVisualPreset> defaults = [
    PwfVisualPreset(
      family: PwfVisualFamily.sovereignBlue,
      context: PwfVisualContext.platformHome,
      palette: sovereignBluePalette,
      descriptionAr: 'الافتراضي الوزاري العام للواجهة والمنصة.',
    ),
    PwfVisualPreset(
      family: PwfVisualFamily.sovereignBlue,
      context: PwfVisualContext.unitPages,
      palette: sovereignBluePalette,
      descriptionAr: 'نمط الوحدات والمديريات داخل الهوية السيادية نفسها.',
    ),
    PwfVisualPreset(
      family: PwfVisualFamily.waqfGreen,
      context: PwfVisualContext.systemPages,
      palette: waqfGreenPalette,
      descriptionAr:
          'أساس بصري للأنظمة الوظيفية أو الاستكشافية المرتبطة بالمنصة.',
    ),
    PwfVisualPreset(
      family: PwfVisualFamily.heritageStone,
      context: PwfVisualContext.adminInternal,
      palette: heritageStonePalette,
      density: PwfVisualDensity.standard,
      descriptionAr:
          'أساس أكثر وقارًا للبيئة الإدارية الداخلية مع بقاء الوظيفة هي الأصل.',
    ),
  ];

  static PwfVisualPreset resolvePublishedPreset({
    required PwfVisualContext context,
    required Map<String, String> publishedByContext,
  }) {
    final presetId = publishedByContext[context.key];
    final preset = presetId == null ? null : presetById(presetId);
    if (preset != null && preset.context == context) return preset;
    return defaultForContext(context);
  }

  static PwfVisualPreset defaultForContext(PwfVisualContext context) {
    final override = _runtimePublishedOverrides[context];
    if (override != null) return override;
    return defaults.firstWhere(
      (preset) => preset.context == context,
      orElse: () => defaults.first,
    );
  }
}

extension PwfVisualPresetTokens on PwfVisualPreset {
  PwfThemeTokensData toHomeTokens() {
    return PwfThemeTokensData(
      primary: palette.primary,
      secondary: palette.secondary,
      onPrimary: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      muted: palette.textSecondary,
      topBarBg: palette.primary,
      navBg: palette.primary,
      headerGradient: [palette.primary, palette.primaryHover],
      prayerGradient: [palette.primary, palette.primaryHover],
      footerBg: palette.primaryHover,
      cardBg: palette.surface,
      cardBorder: palette.border,
      cardShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
      inputBg: palette.background,
      inputBorder: palette.border,
      primaryButtonBg: palette.royalRed,
      primaryButtonFg: Colors.white,
      primaryButtonBgHover: palette.royalRed.withValues(alpha: 0.92),
      primaryButtonBgPressed: palette.royalRed.withValues(alpha: 0.82),
      outlinedBorder: palette.border,
      outlinedFg: palette.textPrimary,
      outlinedHoverBg: palette.background,
      chipBg: palette.background,
      chipFg: palette.textPrimary,
      chipBorder: palette.border,
      chipHoverBg: palette.border.withValues(alpha: 0.35),
    );
  }
}
