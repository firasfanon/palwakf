import 'package:flutter/material.dart';

/// Dynamic registry contract for systems, services, sections, and platform modules.
///
/// N2.10 keeps existing custom Flutter modules intact, but lets Superuser / Platform
/// Admin onboard generic, external, or registered custom modules without editing
/// Sidebar/Dashboard/RBAC code every time.
enum PwfDynamicModuleType { generic, custom, external, service, sectionGroup }

PwfDynamicModuleType parsePwfDynamicModuleType(String? value) {
  switch ((value ?? '').trim()) {
    case 'custom':
      return PwfDynamicModuleType.custom;
    case 'external':
      return PwfDynamicModuleType.external;
    case 'service':
      return PwfDynamicModuleType.service;
    case 'section_group':
    case 'sectionGroup':
      return PwfDynamicModuleType.sectionGroup;
    case 'generic':
    default:
      return PwfDynamicModuleType.generic;
  }
}

extension PwfDynamicModuleTypeX on PwfDynamicModuleType {
  String get value => switch (this) {
    PwfDynamicModuleType.generic => 'generic',
    PwfDynamicModuleType.custom => 'custom',
    PwfDynamicModuleType.external => 'external',
    PwfDynamicModuleType.service => 'service',
    PwfDynamicModuleType.sectionGroup => 'section_group',
  };

  String get labelAr => switch (this) {
    PwfDynamicModuleType.generic => 'قالب عام',
    PwfDynamicModuleType.custom => 'موديول مخصص',
    PwfDynamicModuleType.external => 'رابط خارجي',
    PwfDynamicModuleType.service => 'خدمة منصة',
    PwfDynamicModuleType.sectionGroup => 'مجموعة أقسام',
  };
}

class PwfDynamicSystemModule {
  const PwfDynamicSystemModule({
    required this.systemKey,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.categoryKey,
    required this.moduleType,
    required this.adminRoutePath,
    required this.publicRoutePath,
    required this.externalUrl,
    required this.iconKey,
    required this.displayOrder,
    required this.isActive,
    required this.showInDashboard,
    required this.showInSidebar,
    required this.requiresPermission,
    required this.isSovereign,
    required this.metadata,
    required this.sections,
  });

  final String systemKey;
  final String nameAr;
  final String? nameEn;
  final String descriptionAr;
  final String categoryKey;
  final PwfDynamicModuleType moduleType;
  final String adminRoutePath;
  final String? publicRoutePath;
  final String? externalUrl;
  final String iconKey;
  final int displayOrder;
  final bool isActive;
  final bool showInDashboard;
  final bool showInSidebar;
  final bool requiresPermission;
  final bool isSovereign;
  final Map<String, dynamic> metadata;
  final List<PwfDynamicSystemSection> sections;

  bool get isExternal => moduleType == PwfDynamicModuleType.external;
  bool get hasSections => sections.isNotEmpty;

  IconData get icon => PwfDynamicIconCatalog.resolve(iconKey);

  String routeForShell() {
    if (adminRoutePath.trim().isNotEmpty) return adminRoutePath.trim();
    return '/admin/systems/$systemKey';
  }

  PwfDynamicSystemModule copyWith({List<PwfDynamicSystemSection>? sections}) {
    return PwfDynamicSystemModule(
      systemKey: systemKey,
      nameAr: nameAr,
      nameEn: nameEn,
      descriptionAr: descriptionAr,
      categoryKey: categoryKey,
      moduleType: moduleType,
      adminRoutePath: adminRoutePath,
      publicRoutePath: publicRoutePath,
      externalUrl: externalUrl,
      iconKey: iconKey,
      displayOrder: displayOrder,
      isActive: isActive,
      showInDashboard: showInDashboard,
      showInSidebar: showInSidebar,
      requiresPermission: requiresPermission,
      isSovereign: isSovereign,
      metadata: metadata,
      sections: sections ?? this.sections,
    );
  }

  factory PwfDynamicSystemModule.fromMap(Map<String, dynamic> map) {
    final rawSections = map['sections'];
    final sections = rawSections is List
        ? rawSections
              .whereType<Map>()
              .map(
                (item) => PwfDynamicSystemSection.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
        : const <PwfDynamicSystemSection>[];

    return PwfDynamicSystemModule(
      systemKey: (map['system_key'] ?? '').toString(),
      nameAr: (map['name_ar'] ?? map['title_ar'] ?? 'نظام بدون اسم').toString(),
      nameEn: map['name_en']?.toString(),
      descriptionAr: (map['description_ar'] ?? '').toString(),
      categoryKey: (map['category_key'] ?? 'systems').toString(),
      moduleType: parsePwfDynamicModuleType(map['module_type']?.toString()),
      adminRoutePath: (map['admin_route_path'] ?? '').toString().trim().isEmpty
          ? '/admin/systems/${(map['system_key'] ?? '').toString()}'
          : map['admin_route_path'].toString(),
      publicRoutePath: map['public_route_path']?.toString(),
      externalUrl: map['external_url']?.toString(),
      iconKey: (map['icon_key'] ?? 'widgets').toString(),
      displayOrder: _asInt(map['display_order']),
      isActive: _asBool(map['is_active'], fallback: true),
      showInDashboard: _asBool(map['show_in_dashboard'], fallback: true),
      showInSidebar: _asBool(map['show_in_sidebar'], fallback: true),
      requiresPermission: _asBool(map['requires_permission'], fallback: true),
      isSovereign: _asBool(map['is_sovereign']),
      metadata: _asMap(map['metadata']),
      sections: sections,
    );
  }

  Map<String, dynamic> toUpsertParams() {
    return {
      'p_system_key': systemKey,
      'p_name_ar': nameAr,
      'p_name_en': nameEn,
      'p_description_ar': descriptionAr,
      'p_category_key': categoryKey,
      'p_module_type': moduleType.value,
      'p_admin_route_path': adminRoutePath,
      'p_public_route_path': publicRoutePath,
      'p_external_url': externalUrl,
      'p_icon_key': iconKey,
      'p_display_order': displayOrder,
      'p_is_active': isActive,
      'p_show_in_dashboard': showInDashboard,
      'p_show_in_sidebar': showInSidebar,
      'p_requires_permission': requiresPermission,
      'p_is_sovereign': isSovereign,
      'p_metadata': metadata,
    };
  }
}

class PwfDynamicSystemSection {
  const PwfDynamicSystemSection({
    required this.systemKey,
    required this.sectionKey,
    required this.titleAr,
    required this.descriptionAr,
    required this.routePath,
    required this.sectionType,
    required this.iconKey,
    required this.displayOrder,
    required this.isActive,
    required this.showInDashboard,
    required this.showInSidebar,
    required this.requiredPermissionKey,
    required this.metadata,
  });

  final String systemKey;
  final String sectionKey;
  final String titleAr;
  final String descriptionAr;
  final String routePath;
  final String sectionType;
  final String iconKey;
  final int displayOrder;
  final bool isActive;
  final bool showInDashboard;
  final bool showInSidebar;
  final String requiredPermissionKey;
  final Map<String, dynamic> metadata;

  IconData get icon => PwfDynamicIconCatalog.resolve(iconKey);

  factory PwfDynamicSystemSection.fromMap(Map<String, dynamic> map) {
    final systemKey = (map['system_key'] ?? '').toString();
    final sectionKey = (map['section_key'] ?? '').toString();
    return PwfDynamicSystemSection(
      systemKey: systemKey,
      sectionKey: sectionKey,
      titleAr: (map['title_ar'] ?? map['name_ar'] ?? 'قسم بدون اسم').toString(),
      descriptionAr: (map['description_ar'] ?? '').toString(),
      routePath: (map['route_path'] ?? '').toString().trim().isEmpty
          ? '/admin/systems/$systemKey/sections/$sectionKey'
          : map['route_path'].toString(),
      sectionType: (map['section_type'] ?? 'generic').toString(),
      iconKey: (map['icon_key'] ?? 'article').toString(),
      displayOrder: _asInt(map['display_order']),
      isActive: _asBool(map['is_active'], fallback: true),
      showInDashboard: _asBool(map['show_in_dashboard'], fallback: true),
      showInSidebar: _asBool(map['show_in_sidebar'], fallback: true),
      requiredPermissionKey: (map['required_permission_key'] ?? 'read')
          .toString(),
      metadata: _asMap(map['metadata']),
    );
  }

  Map<String, dynamic> toUpsertParams() {
    return {
      'p_system_key': systemKey,
      'p_section_key': sectionKey,
      'p_title_ar': titleAr,
      'p_description_ar': descriptionAr,
      'p_route_path': routePath,
      'p_section_type': sectionType,
      'p_icon_key': iconKey,
      'p_display_order': displayOrder,
      'p_is_active': isActive,
      'p_show_in_dashboard': showInDashboard,
      'p_show_in_sidebar': showInSidebar,
      'p_required_permission_key': requiredPermissionKey,
      'p_metadata': metadata,
    };
  }
}

class PwfDynamicIconCatalog {
  const PwfDynamicIconCatalog._();

  static IconData resolve(String? key) {
    switch ((key ?? '').trim()) {
      case 'service':
      case 'services':
        return Icons.design_services_rounded;
      case 'media':
        return Icons.perm_media_rounded;
      case 'map':
      case 'explorer':
        return Icons.map_rounded;
      case 'finance':
      case 'billing':
        return Icons.receipt_long_rounded;
      case 'tasks':
        return Icons.task_alt_rounded;
      case 'cases':
        return Icons.gavel_rounded;
      case 'document':
      case 'documents':
        return Icons.folder_rounded;
      case 'users':
        return Icons.people_alt_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'audit':
      case 'governance':
        return Icons.verified_user_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'external':
        return Icons.open_in_new_rounded;
      case 'section':
        return Icons.view_module_rounded;
      case 'widgets':
      default:
        return Icons.widgets_rounded;
    }
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value == null) return fallback;
  final text = value.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return fallback;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
