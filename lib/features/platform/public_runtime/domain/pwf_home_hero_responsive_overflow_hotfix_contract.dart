/// Contract marker for the public home hero responsive overflow hotfix.
///
/// Scope:
/// - Fixes the Chrome runtime RenderFlex overflow observed on `#/home` when
///   DevTools or a constrained viewport reduces the hero text width.
/// - Keeps the Font Awesome 11 migration baseline intact.
/// - Does not change data sources, routes, SQL, RBAC, RLS, or platform service
///   center runtime contracts.
class PwfHomeHeroResponsiveOverflowHotfixContract {
  const PwfHomeHeroResponsiveOverflowHotfixContract._();

  static const String batchKey =
      'home_hero_responsive_overflow_hotfix_2026_05_31';

  static const String decision =
      'HOME_HERO_RESPONSIVE_OVERFLOW_HOTFIX_APPLIED_RETEST_REQUIRED';

  static const String evidenceSource =
      'browser_screenshot_home_renderflex_overflow_2026_05_31';

  static const String affectedRoute = '#/home';

  static const String affectedWidget = '_HeroText';

  static const String affectedFile =
      'lib/features/platform/home/presentation/widgets/sections/pwf_hero_slider_section.dart';

  static const String rootCause =
      'Hero text kept desktop horizontal padding and font scale under a constrained width, causing a vertical RenderFlex overflow.';

  static const List<String> appliedFixes = [
    'responsive_horizontal_padding',
    'responsive_title_and_subtitle_font_sizes',
    'bounded_title_and_subtitle_lines_with_ellipsis',
    'compact_cta_button_when_very_narrow',
    'loading_note_ellipsis_guard',
  ];

  static const List<String> unchangedBoundaries = [
    'no_sql_production',
    'no_ddl_dml_grant_drop',
    'no_service_role',
    'no_platform_services_contract_change',
    'no_media_center_contract_change',
    'no_public_services_contract_change',
    'no_waqf_waqf_assets_awqaf_system_gis_mutation',
    'production_not_approved',
  ];

  static const List<String> requiredRetest = [
    'dart format affected files',
    'flutter analyze',
    'flutter run -d chrome',
    'open #/home with DevTools docked',
    'confirm no RenderFlex overflow in Console',
    'retry Service Center Browser UAT',
  ];
}
