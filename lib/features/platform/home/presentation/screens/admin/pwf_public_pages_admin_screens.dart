import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/home/data/models/pwf_site_page.dart';
import 'package:waqf/features/platform/home/data/providers/pwf_site_pages_providers.dart';
import 'package:waqf/features/platform/services/shared/presentation/widgets/pwf_platform_service_admin_screen.dart';
import 'package:waqf/features/platform/home/data/providers/pwf_former_ministers_providers.dart';
import 'package:waqf/features/platform/home/data/models/pwf_former_minister.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/presentation/screens/admin/main/management/shared_content/widgets/scoped_footer_links_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/shared_content/widgets/scoped_cards_section_management_section.dart';

part 'pwf_public_pages_admin_configs.part.dart';
part 'pwf_public_pages_admin_screen.part.dart';
part 'pwf_public_pages_admin_editor.part.dart';
part 'pwf_public_pages_admin_shared.part.dart';
