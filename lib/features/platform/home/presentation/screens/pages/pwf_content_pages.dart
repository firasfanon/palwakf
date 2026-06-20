import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/unit/pwf_unit_slug_registry.dart';
import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../pwf_web_page_scaffold.dart';
import '../../widgets/pwf_section_container.dart';
import 'package:waqf/features/platform/home/presentation/widgets/shared/pwf_home_visual_contract.dart';
import '../../theme/pwf_home_palette.dart';
import '../../widgets/pwf_important_links_section.dart';
import '../../widgets/sections/pwf_eservices_portal_section.dart';
import '../../widgets/sections/pwf_quick_services_section.dart';
import '../../widgets/sections/pwf_public_services_catalog_section.dart';
import 'pwf_public_content_shared.dart';
import '../../../data/providers/pwf_site_pages_providers.dart';
import '../../../data/providers/pwf_former_ministers_providers.dart';
import '../../../data/models/pwf_former_minister.dart';

part 'pwf_content_pages_primary.part.dart';
part 'pwf_content_pages_legal.part.dart';
part 'pwf_content_pages_shared.part.dart';

/// Real content pages for public site (Web identity).
///
/// These pages replace the temporary placeholders created earlier and keep the
/// new HTML identity via [PwfWebPageScaffold].
///
/// Notes:
/// - Web-only in current phase; mobile keeps legacy screens.
/// - Bilingual: picks Arabic when locale is `ar`, else English.

String _pickLocalized(
  BuildContext context, {
  required String? ar,
  required String? en,
  required String fallbackAr,
  required String fallbackEn,
}) {
  final isAr =
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
  final arValue = (ar ?? '').trim();
  final enValue = (en ?? '').trim();
  if (isAr) {
    if (arValue.isNotEmpty) return arValue;
    if (enValue.isNotEmpty) return enValue;
    return fallbackAr;
  }
  if (enValue.isNotEmpty) return enValue;
  if (arValue.isNotEmpty) return arValue;
  return fallbackEn;
}
