import '../../app/routing/app_routes.dart';
import '../../data/models/admin_user.dart';
import '../enums/permission.dart';
import '../enums/system_key.dart';
import '../enums/user_role.dart' as platform_role;
import 'access_profile.dart';

class UserDashboardContract {
  final String userId;
  final String displayName;
  final String email;
  final String username;
  final bool isActive;
  final bool isSuperuser;
  final String scopeLabel;
  final String roleLabelAr;
  final String policyRoleKey;
  final String policyRoleLabelAr;
  final String governanceScopeDescription;
  final List<String> governanceBadges;
  final List<String> managedSystems;
  final String? unitNameAr;
  final String? unitSlug;
  final List<UserDashboardSystemAccess> systems;
  final List<UserDashboardQuickAction> quickActions;
  final List<UserDashboardAdminTool> adminTools;
  final bool canViewOwnActivityLog;
  final bool canViewOwnSessionLog;

  const UserDashboardContract({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.username,
    required this.isActive,
    required this.isSuperuser,
    required this.scopeLabel,
    required this.roleLabelAr,
    required this.policyRoleKey,
    required this.policyRoleLabelAr,
    required this.governanceScopeDescription,
    required this.governanceBadges,
    required this.managedSystems,
    required this.unitNameAr,
    required this.unitSlug,
    required this.systems,
    required this.quickActions,
    required this.adminTools,
    required this.canViewOwnActivityLog,
    required this.canViewOwnSessionLog,
  });

  int get visibleSystemsCount => systems.where((e) => e.isVisible).length;
  int get writableSystemsCount =>
      systems.where((e) => e.isVisible && e.canWrite).length;
  int get grantedPermissionsCount =>
      systems.fold<int>(0, (sum, s) => sum + s.grantedPermissions.length);
  bool get isCentral => unitNameAr == null && unitSlug == null;
}

class UserDashboardSystemAccess {
  final SystemKey systemKey;
  final String title;
  final String route;
  final platform_role.UserRole role;
  final bool isVisible;
  final bool canRead;
  final bool canWrite;
  final bool isOversight;
  final List<Permission> grantedPermissions;

  const UserDashboardSystemAccess({
    required this.systemKey,
    required this.title,
    required this.route,
    required this.role,
    required this.isVisible,
    required this.canRead,
    required this.canWrite,
    required this.isOversight,
    required this.grantedPermissions,
  });
}

class UserDashboardQuickAction {
  final String title;
  final String subtitle;
  final String route;

  const UserDashboardQuickAction({
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class UserDashboardAdminTool {
  final String title;
  final String subtitle;
  final String route;
  final SystemKey? systemKey;

  const UserDashboardAdminTool({
    required this.title,
    required this.subtitle,
    required this.route,
    this.systemKey,
  });
}

class UserDashboardContractBuilder {
  const UserDashboardContractBuilder._();

  static UserDashboardContract build({
    required AdminUser user,
    required AccessProfile? profile,
  }) {
    final hasPlatformRootAuthority = _hasPlatformRootAuthority(user, profile);
    final visibleSystems = SystemKey.values
        .map((key) => _systemAccessFor(
              key,
              user,
              profile,
              hasPlatformRootAuthority: hasPlatformRootAuthority,
            ))
        .where((entry) => entry.isVisible)
        .toList();

    final managedSystemTitles = <String>{
      ...visibleSystems
          .where((entry) =>
              entry.isOversight && entry.systemKey != SystemKey.platformAdmin)
          .map((entry) => entry.title),
      if (!hasPlatformRootAuthority)
        ...user.assignedSystemKeys
            .map((key) => _labelForSystemKeyName(key))
            .where((title) => title.trim().isNotEmpty),
    }.toList();

    final policyRoleKey = _policyRoleKey(user, profile, managedSystemTitles);
    final policyRoleLabel = _policyRoleLabel(policyRoleKey);
    final governanceDescription =
        _policyDescription(policyRoleKey, user, managedSystemTitles);
    final governanceBadges =
        _policyBadges(policyRoleKey, user, managedSystemTitles);

    final quickActions = <UserDashboardQuickAction>[
      UserDashboardQuickAction(
        title: 'الملف الشخصي',
        subtitle: 'مراجعة بياناتك الأساسية ونطاقك الحالي داخل PalWakf.',
        route: AppRoutes.adminProfile,
      ),
      UserDashboardQuickAction(
        title: 'سجل نشاطي',
        subtitle: 'مراجعة جلساتك وحركاتك الخاصة ضمن السجل الشخصي.',
        route: AppRoutes.adminMyActivity,
      ),
      UserDashboardQuickAction(
        title: 'المساعد الداخلي',
        subtitle: 'مساعد إرشادي مقيّد بسياق حسابك والأنظمة المصرح لك بها فقط.',
        route: AppRoutes.adminAssistant,
      ),
      if (visibleSystems.isNotEmpty)
        UserDashboardQuickAction(
          title: 'أول نظام متاح',
          subtitle: 'الدخول السريع إلى أول نظام مصرح لك به وفق النطاق الحالي.',
          route: visibleSystems.first.route,
        ),
      if (policyRoleKey == 'unit_admin')
        const UserDashboardQuickAction(
          title: 'إدارة صفحات الوحدة',
          subtitle:
              'الوصول إلى صفحات الوحدة والخدمات والمحتوى العام الخاص بها.',
          route: AppRoutes.adminHomeManagement,
        ),
      if (managedSystemTitles.isNotEmpty)
        UserDashboardQuickAction(
          title: 'متابعة أنظمتي',
          subtitle: 'أنت مسؤول عن: ${managedSystemTitles.join('، ')}',
          route: _routeFor(
              _primaryManagedSystem(visibleSystems) ?? SystemKey.platformAdmin),
        ),
    ];

    final adminTools = <UserDashboardAdminTool>[];
    switch (policyRoleKey) {
      case 'superuser':
        adminTools.addAll(const [
          UserDashboardAdminTool(
            title: 'إدارة المستخدمين',
            subtitle: 'إدارة كل المستخدمين والوحدات والأنظمة على مستوى المنصة.',
            route: AppRoutes.adminUsers,
            systemKey: SystemKey.platformAdmin,
          ),
          UserDashboardAdminTool(
            title: 'الأنظمة والحوكمة',
            subtitle:
                'مراجعة الحوكمة والسياسات وأدوات المطور على مستوى المنصة.',
            route: AppRoutes.adminDeveloper,
            systemKey: SystemKey.platformAdmin,
          ),
          UserDashboardAdminTool(
            title: 'التقارير المركزية',
            subtitle: 'تقارير المنصة والمؤشرات الشاملة لكل الوحدات والأنظمة.',
            route: AppRoutes.adminReports,
            systemKey: SystemKey.platformAdmin,
          ),
        ]);
        break;
      case 'power_admin':
        for (final system in visibleSystems.where(
            (e) => e.isOversight && e.systemKey != SystemKey.platformAdmin)) {
          adminTools.add(
            UserDashboardAdminTool(
              title: 'متابعة ${system.title}',
              subtitle:
                  'أنت Power Admin لهذا النظام عبر كل الوحدات التي تعمل عليه.',
              route: system.route,
              systemKey: system.systemKey,
            ),
          );
        }
        break;
      case 'unit_admin':
        adminTools.addAll(const [
          UserDashboardAdminTool(
            title: 'مستخدمو الوحدة',
            subtitle: 'إدارة مستخدمي الوحدة الإدارية التابعة لك فقط.',
            route: AppRoutes.adminUsers,
            systemKey: SystemKey.platformAdmin,
          ),
          UserDashboardAdminTool(
            title: 'صفحات الوحدة',
            subtitle: 'إدارة صفحات الوحدة ومحتواها وخدماتها.',
            route: AppRoutes.adminHomeManagement,
            systemKey: SystemKey.platformAdmin,
          ),
        ]);
        break;
      case 'system_super_user':
        for (final system in visibleSystems.where(
            (e) => e.isOversight && e.systemKey != SystemKey.platformAdmin)) {
          adminTools.add(
            UserDashboardAdminTool(
              title: 'فريق ${system.title}',
              subtitle: 'أنت مشرف هذا النظام داخل وحدتك وتتابع العاملين عليه.',
              route: system.route,
              systemKey: system.systemKey,
            ),
          );
        }
        break;
      case 'delegate_lawyer':
        adminTools.add(const UserDashboardAdminTool(
          title: 'القضايا الموكلة',
          subtitle: 'متابعة القضايا في الوحدات الموكلة إليك فقط.',
          route: AppRoutes.adminCases,
          systemKey: SystemKey.cases,
        ));
        break;
      case 'employee':
      case 'viewer_experimental':
        break;
    }

    return UserDashboardContract(
      userId: user.id,
      displayName: user.displayName,
      email: user.email,
      username: (user.username ?? '').trim(),
      isActive: user.isActive,
      isSuperuser: hasPlatformRootAuthority,
      scopeLabel: hasPlatformRootAuthority ? 'مركزي — كل الوحدات' : user.scopeLabel,
      roleLabelAr: policyRoleLabel,
      policyRoleKey: policyRoleKey,
      policyRoleLabelAr: policyRoleLabel,
      governanceScopeDescription: governanceDescription,
      governanceBadges: governanceBadges,
      managedSystems: managedSystemTitles,
      unitNameAr: hasPlatformRootAuthority ? null : user.unitNameAr,
      unitSlug: hasPlatformRootAuthority ? null : user.unitSlug,
      systems: visibleSystems,
      quickActions: quickActions,
      adminTools: adminTools,
      canViewOwnActivityLog: user.isActive,
      canViewOwnSessionLog: user.isActive,
    );
  }

  static bool _hasPlatformRootAuthority(
      AdminUser user, AccessProfile? profile) {
    if (user.isSuperuser) return true;
    if (profile?.isSuperuser == true) return true;
    final platformRole = (profile?.dynamicRoles['platformAdmin'] ??
            profile?.dynamicRoles['platform_admin'] ??
            profile?.dynamicRoles['admin'] ??
            '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_');
    return platformRole == 'superuser' ||
        platformRole == 'super_user' ||
        platformRole == 'super_admin' ||
        platformRole == 'platform_super_admin' ||
        platformRole == 'platform_root' ||
        platformRole == 'root' ||
        platformRole == 'owner';
  }

  static String _policyRoleKey(
      AdminUser user, AccessProfile? profile, List<String> managedSystems) {
    if (_hasPlatformRootAuthority(user, profile)) return 'superuser';
    if (_isDelegateLawyer(user, profile)) return 'delegate_lawyer';
    if (user.isPowerAdmin || (user.isCentral && managedSystems.isNotEmpty))
      return 'power_admin';
    if (user.isUnitAdmin) return 'unit_admin';
    if (user.isSystemSuperUser || managedSystems.isNotEmpty)
      return 'system_super_user';
    if (user.normalizedRole == 'employee') return 'employee';
    return 'viewer_experimental';
  }

  static String _policyRoleLabel(String key) {
    switch (key) {
      case 'superuser':
        return 'سوبر يوزر';
      case 'power_admin':
        return 'Power Admin';
      case 'unit_admin':
        return 'مدير وحدة';
      case 'system_super_user':
        return 'مشرف نظام الوحدة';
      case 'delegate_lawyer':
        return 'وكيل قانوني مفوض';
      case 'employee':
        return 'موظف';
      default:
        return 'مشاهد (تجريبي)';
    }
  }

  static String _policyDescription(
      String key, AdminUser user, List<String> managedSystems) {
    switch (key) {
      case 'superuser':
        return 'مسؤول عن كل وحدات المنصة وكل الأنظمة.';
      case 'power_admin':
        return managedSystems.isEmpty
            ? 'مسؤول عن نظام واحد عبر جميع الوحدات التي تعمل عليه.'
            : 'مسؤول عن ${managedSystems.join('، ')} عبر جميع الوحدات التي تعمل على هذه الأنظمة.';
      case 'unit_admin':
        return 'مسؤول عن جميع الصفحات والخدمات والمستخدمين والأنظمة المرتبطة بوحدته الإدارية فقط.';
      case 'system_super_user':
        return managedSystems.isEmpty
            ? 'صلاحياته أعلى من الموظف العادي ويتابع نظامًا محددًا داخل وحدته.'
            : 'يتابع ${managedSystems.join('، ')} داخل وحدته، وصلاحياته أعلى من الموظف وأقل من Power Admin.';
      case 'delegate_lawyer':
        return 'وكيل/محامٍ غير موظف، يعمل على نظام القضايا أو نظام مماثل في وحدات محددة موكلة إليه فقط.';
      case 'employee':
        return 'صلاحيات تشغيلية عادية مثل الإضافة والتعديل ضمن النطاق والوحدة والأنظمة المسموحة له.';
      default:
        return 'هذا الدور تجريبي فقط نتيجة حسابات الاختبار الحالية، وسيُزال من المسار التشغيلي النهائي.';
    }
  }

  static List<String> _policyBadges(
      String key, AdminUser user, List<String> managedSystems) {
    final badges = <String>[];
    switch (key) {
      case 'superuser':
        badges.addAll(['كل الوحدات', 'كل الأنظمة']);
        break;
      case 'power_admin':
        badges.addAll(['نطاق نظامي', 'عبر الوحدات']);
        break;
      case 'unit_admin':
        badges.addAll(['كل خدمات الوحدة', user.scopeLabel]);
        break;
      case 'system_super_user':
        badges.addAll([
          'داخل الوحدة',
          if (managedSystems.isNotEmpty) managedSystems.first
        ]);
        break;
      case 'delegate_lawyer':
        badges.addAll(['تكليف خاص', 'متعدد الوحدات']);
        break;
      case 'employee':
        badges.addAll(['تشغيلي', user.scopeLabel]);
        break;
      default:
        badges.addAll(['تجريبي', 'قراءة فقط']);
        break;
    }
    if (user.unitNameAr?.trim().isNotEmpty == true &&
        !badges.contains(user.unitNameAr!.trim())) {
      badges.add(user.unitNameAr!.trim());
    }
    return badges;
  }

  static bool _isDelegateLawyer(AdminUser user, AccessProfile? profile) {
    if (user.hasDelegateHint) return true;
    final casesRole = profile?.roles[SystemKey.cases];
    final hasCases = casesRole != null ||
        ((profile?.permissions[SystemKey.cases]?.isNotEmpty ?? false));
    if (!hasCases) return false;
    final source =
        '${user.displayName.toLowerCase()} ${(user.department ?? '').toLowerCase()} ${(user.username ?? '').toLowerCase()}';
    return source.contains('محامي') ||
        source.contains('lawyer') ||
        source.contains('وكيل') ||
        source.contains('delegate');
  }

  static UserDashboardSystemAccess _systemAccessFor(
    SystemKey key,
    AdminUser user,
    AccessProfile? profile, {
    required bool hasPlatformRootAuthority,
  }) {
    final hasAnyPermission = (profile?.permissions[key]?.isNotEmpty ?? false);
    final explicitSystemAssigned = user.effectiveSystemKeys.contains(key.name);
    final inferredRole =
        _inferredRoleForSystem(user, key, explicitSystemAssigned);
    final profileRole = profile?.roleFor(key) ?? platform_role.UserRole.viewer;
    final role = hasPlatformRootAuthority
        ? platform_role.UserRole.superuser
        : (profileRole.index >= inferredRole.index ? profileRole : inferredRole);

    final platformVisibility =
        (profile?.can(SystemKey.platformAdmin, Permission.manageUsers) ??
                false) ||
            (profile?.can(SystemKey.platformAdmin, Permission.manageHome) ??
                false) ||
            (profile?.can(SystemKey.platformAdmin, Permission.manageSite) ??
                false) ||
            (profile?.can(SystemKey.platformAdmin, Permission.viewReports) ??
                false) ||
            (profile?.isSuperuser ?? false);

    final derivedVisibility = user.isProtectedSuperuser ||
        (user.isUnitAdmin && key != SystemKey.platformAdmin) ||
        (user.isPowerAdmin &&
            key != SystemKey.platformAdmin &&
            (user.effectiveSystemKeys.isEmpty || explicitSystemAssigned)) ||
        (user.isSystemSuperUser && explicitSystemAssigned) ||
        (user.isDelegateLawyer &&
            ((user.effectiveSystemKeys.isEmpty && key == SystemKey.cases) ||
                explicitSystemAssigned)) ||
        (user.normalizedRole == 'employee' && explicitSystemAssigned);

    final isVisible = hasPlatformRootAuthority ||
        (key == SystemKey.platformAdmin
            ? platformVisibility
            : (profile?.hasRoleAtLeast(key, platform_role.UserRole.viewer) ??
                    false) ||
                hasAnyPermission ||
                derivedVisibility);

    final permissions = (hasPlatformRootAuthority
            ? Permission.values.toSet()
            : (profile?.permissions[key] ?? const <Permission>{}))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final isOversight = hasPlatformRootAuthority ||
        (key != SystemKey.platformAdmin &&
            ((profile?.isSuperuser ?? false) ||
                role == platform_role.UserRole.superuser ||
                role == platform_role.UserRole.admin ||
                user.isPowerAdmin ||
                user.isUnitAdmin ||
                user.isSystemSuperUser));

    return UserDashboardSystemAccess(
      systemKey: key,
      title: key.nameAr,
      route: _routeFor(key),
      role: role,
      isVisible: isVisible,
      canRead: isVisible,
      canWrite: hasPlatformRootAuthority ||
          role.canWrite ||
          (profile?.isSuperuser ?? false) ||
          user.isUnitAdmin ||
          user.isPowerAdmin ||
          user.isSystemSuperUser ||
          (user.normalizedRole == 'employee' && explicitSystemAssigned),
      isOversight: isOversight,
      grantedPermissions: permissions,
    );
  }

  static platform_role.UserRole _inferredRoleForSystem(
      AdminUser user, SystemKey key, bool explicitSystemAssigned) {
    if (user.isProtectedSuperuser) return platform_role.UserRole.superuser;
    if (key == SystemKey.platformAdmin) {
      return user.canAccessUsersManagement
          ? platform_role.UserRole.admin
          : platform_role.UserRole.viewer;
    }
    if (user.isPowerAdmin &&
        (user.effectiveSystemKeys.isEmpty || explicitSystemAssigned)) {
      return platform_role.UserRole.admin;
    }
    if (user.isUnitAdmin) {
      return platform_role.UserRole.admin;
    }
    if (user.isSystemSuperUser && explicitSystemAssigned) {
      return platform_role.UserRole.admin;
    }
    if (user.isDelegateLawyer &&
        ((user.effectiveSystemKeys.isEmpty && key == SystemKey.cases) ||
            explicitSystemAssigned)) {
      return platform_role.UserRole.user;
    }
    if (user.normalizedRole == 'employee' && explicitSystemAssigned) {
      return platform_role.UserRole.user;
    }
    return platform_role.UserRole.viewer;
  }

  static String _labelForSystemKeyName(String raw) {
    final key = raw.trim();
    for (final item in SystemKey.values) {
      if (item.name == key) return item.nameAr;
    }
    return key;
  }

  static SystemKey? _primaryManagedSystem(
      List<UserDashboardSystemAccess> systems) {
    final filtered = systems
        .where((s) => s.isOversight && s.systemKey != SystemKey.platformAdmin)
        .toList();
    return filtered.isEmpty ? null : filtered.first.systemKey;
  }

  static String _routeFor(SystemKey key) {
    switch (key) {
      case SystemKey.platformAdmin:
        return AppRoutes.adminDashboard;
      case SystemKey.awqafSystem:
        return AppRoutes.adminDynamicSystem('awqaf_system');
      case SystemKey.site:
        return AppRoutes.home;
      case SystemKey.mustakshif:
        return AppRoutes.mustakshif;
      case SystemKey.adminData:
        return AppRoutes.adminData;
      case SystemKey.zakat:
        return AppRoutes.adminZakat;
      case SystemKey.prayerTimes:
        return AppRoutes.adminPrayerTimes;
      case SystemKey.quran:
        return AppRoutes.adminQuran;
      case SystemKey.lands:
        return AppRoutes.adminWaqfLands;
      case SystemKey.properties:
        return AppRoutes.properties;
      case SystemKey.cases:
        return AppRoutes.adminCases;
      case SystemKey.tasks:
        return AppRoutes.tasks;
      case SystemKey.mosques:
        return AppRoutes.adminMosques;
      case SystemKey.billing:
        return AppRoutes.billing;
    }
  }
}
