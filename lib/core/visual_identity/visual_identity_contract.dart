import 'package:flutter/material.dart';

@immutable
class PwfVisualPalette {
  const PwfVisualPalette({
    required this.primary,
    required this.primaryHover,
    required this.secondary,
    required this.royalRed,
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color primary;
  final Color primaryHover;
  final Color secondary;
  final Color royalRed;
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
}

enum PwfVisualFamily { sovereignBlue, waqfGreen, heritageStone }

extension PwfVisualFamilyX on PwfVisualFamily {
  String get key => switch (this) {
    PwfVisualFamily.sovereignBlue => 'sovereign_blue',
    PwfVisualFamily.waqfGreen => 'waqf_green',
    PwfVisualFamily.heritageStone => 'heritage_stone',
  };

  String get labelAr => switch (this) {
    PwfVisualFamily.sovereignBlue => 'الأزرق السيادي',
    PwfVisualFamily.waqfGreen => 'الأخضر الوقفي الإسلامي',
    PwfVisualFamily.heritageStone => 'الحجري الملكي الحكومي',
  };
}

enum PwfVisualContext { platformHome, unitPages, systemPages, adminInternal }

extension PwfVisualContextX on PwfVisualContext {
  String get key => switch (this) {
    PwfVisualContext.platformHome => 'platform_home',
    PwfVisualContext.unitPages => 'unit_pages',
    PwfVisualContext.systemPages => 'system_pages',
    PwfVisualContext.adminInternal => 'admin_internal',
  };

  String get labelAr => switch (this) {
    PwfVisualContext.platformHome => 'الصفحة الوزارية الأم',
    PwfVisualContext.unitPages => 'صفحات الوحدات',
    PwfVisualContext.systemPages => 'صفحات الأنظمة',
    PwfVisualContext.adminInternal => 'لوحة التحكم الداخلية',
  };
}

enum PwfVisualDensity { comfortable, standard, dense }

extension PwfVisualDensityX on PwfVisualDensity {
  String get labelAr => switch (this) {
    PwfVisualDensity.comfortable => 'مريح',
    PwfVisualDensity.standard => 'قياسي',
    PwfVisualDensity.dense => 'كثيف',
  };
}

@immutable
class PwfVisualPreset {
  const PwfVisualPreset({
    required this.family,
    required this.context,
    required this.palette,
    required this.descriptionAr,
    this.density = PwfVisualDensity.standard,
  });

  final PwfVisualFamily family;
  final PwfVisualContext context;
  final PwfVisualPalette palette;
  final PwfVisualDensity density;
  final String descriptionAr;

  String get id => '${family.key}.${context.key}';
}
