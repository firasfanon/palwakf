import '../enums/enums.dart';
import 'access_profile.dart';

/// Platform-wide route authorization contract for PalWakf admin surfaces.
///
/// This is deliberately broader than media/services. PalWakf is a sovereign
/// multi-system platform; every protected admin route should eventually be
/// mapped to a system, action, and scope policy. N1.1 introduces the central
/// contract and fail-closed enforcement for known sensitive routes while
/// leaving common shell routes accessible to active admin identities.
class AdminRouteAccessContract {
  const AdminRouteAccessContract({
    required this.routePrefix,
    required this.systemKey,
    required this.minRole,
    required this.readPermission,
    required this.writePermissions,
    required this.labelAr,
    required this.scopePolicyAr,
    this.readOnly = false,
    this.governanceRoute = false,
  });

  final String routePrefix;
  final SystemKey systemKey;
  final UserRole minRole;
  final Permission readPermission;
  final Set<Permission> writePermissions;
  final String labelAr;
  final String scopePolicyAr;
  final bool readOnly;
  final bool governanceRoute;

  bool matches(String location) {
    final path = _normalize(location);
    final prefix = _normalize(routePrefix);
    return path == prefix || path.startsWith('$prefix/');
  }

  bool allows(AccessProfile profile) {
    if (!profile.isActive) return false;
    if (profile.isSuperuser) return true;
    if (profile.canManagePlatformAdmin()) return true;
    if (profile.hasRoleAtLeast(systemKey, minRole)) return true;
    if (profile.can(systemKey, readPermission)) return true;
    for (final permission in writePermissions) {
      if (profile.can(systemKey, permission)) return true;
    }
    return false;
  }

  static String _normalize(String value) {
    final path = value.split('?').first.trim();
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }
}

class AdminRouteAccessDecision {
  const AdminRouteAccessDecision({
    required this.allowed,
    required this.reasonAr,
    this.contract,
  });

  final bool allowed;
  final String reasonAr;
  final AdminRouteAccessContract? contract;
}

class AdminRouteAccessContracts {
  const AdminRouteAccessContracts._();

  static const commonActiveAdminRoutes = <String>{
    '/admin/dashboard',
    '/admin/profile',
    '/admin/my-activity',
    '/admin/assistant',
    '/admin/chatbot',
    '/admin/usage-guide',
  };

  static const contracts = <AdminRouteAccessContract>[
    AdminRouteAccessContract(
      routePrefix: '/admin/users',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageUsers,
      writePermissions: {Permission.manageUsers},
      labelAr: 'إدارة المستخدمين والصلاحيات',
      scopePolicyAr: 'منصة/وحدة/نظام حسب صلاحيات المستخدم الحالية.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/org-units',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'إدارة الوحدات والمؤسسات',
      scopePolicyAr: 'منصة مركزية مع إمكانية تقييد وحدوي.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/settings',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems, Permission.manageSite},
      labelAr: 'إعدادات المنصة والأنظمة',
      scopePolicyAr: 'منصة مركزية فقط.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/home-management',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageHome,
      writePermissions: {Permission.manageHome, Permission.manageSite},
      labelAr: 'إدارة الصفحة الرئيسية',
      scopePolicyAr: 'مركزي/وحدوي حسب homepage_sections وunit scope.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/unit-surfaces-management',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageHome,
      writePermissions: {Permission.manageHome, Permission.manageSite},
      labelAr: 'إدارة واجهات الوحدات',
      scopePolicyAr: 'وحدات إدارية مرتبطة بنطاق المستخدم.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/system-surfaces-management',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems, Permission.manageSite},
      labelAr: 'إدارة واجهات الأنظمة',
      scopePolicyAr: 'حسب النظام المسجل داخل المنصة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/media-center',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.delete,
        Permission.manageSite,
      },
      labelAr: 'المركز الإعلامي',
      scopePolicyAr: 'مركزي/وحدوي حسب المحتوى والنشر.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/hero-slider',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.update, Permission.manageSite},
      labelAr: 'السلايدر العام',
      scopePolicyAr: 'مركزي أو وحدة حسب الصفحة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/breaking-news',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.manageSite,
      },
      labelAr: 'الأخبار العاجلة',
      scopePolicyAr: 'نطاق إعلامي مركزي/وحدوي.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/activities-management',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.manageSite,
      },
      labelAr: 'إدارة الأنشطة',
      scopePolicyAr: 'نطاق إعلامي/وحدوي.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/friday-sermons',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.manageSite,
      },
      labelAr: 'خطب الجمعة',
      scopePolicyAr: 'نطاق محتوى عام/وحدوي.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/public-pages',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.manageSite,
      },
      labelAr: 'إدارة الصفحات العامة',
      scopePolicyAr: 'الموقع العام ومراكز الواجهة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/shared-content',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.update, Permission.manageSite},
      labelAr: 'المحتوى المشترك',
      scopePolicyAr: 'المنصة العامة دون خلط بأنظمة سيادية.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/surfaces-services',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.manageSite,
      },
      labelAr: 'مركز الخدمات',
      scopePolicyAr: 'خدمة/نموذج/وحدة حسب نوع الطلب.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/complaints',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.update, Permission.manageSite},
      labelAr: 'الشكاوى والملاحظات',
      scopePolicyAr: 'خدمة عامة مع قنوات متابعة داخلية.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/zakat',
      systemKey: SystemKey.zakat,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.manageZakat, Permission.update},
      labelAr: 'خدمة الزكاة',
      scopePolicyAr: 'خدمة تخصصية مرتبطة بالمنصة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/prayer-times',
      systemKey: SystemKey.prayerTimes,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.managePrayerTimes, Permission.update},
      labelAr: 'مواقيت الصلاة',
      scopePolicyAr: 'خدمة تخصصية مرتبطة بالمنصة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/quran',
      systemKey: SystemKey.quran,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.manageQuran, Permission.update},
      labelAr: 'القرآن الكريم',
      scopePolicyAr: 'خدمة تخصصية مرتبطة بالمنصة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/tasks',
      systemKey: SystemKey.tasks,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.delete,
      },
      labelAr: 'نظام المهام',
      scopePolicyAr: 'حسب النظام والوحدة والمكلف.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/cases',
      systemKey: SystemKey.cases,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.delete,
      },
      labelAr: 'نظام القضايا',
      scopePolicyAr: 'حسب القضية/الوحدة/الدور القانوني.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/mosques',
      systemKey: SystemKey.mosques,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.create, Permission.update},
      labelAr: 'نظام المساجد',
      scopePolicyAr: 'حسب المسجد/الوحدة/الصلاحية.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/waqf-lands',
      systemKey: SystemKey.lands,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.manageLandsCrud, Permission.update},
      labelAr: 'الأراضي الوقفية',
      scopePolicyAr: 'قراءة/إدارة حسب النظام دون تعديل waqf_assets.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/documents',
      systemKey: SystemKey.site,
      minRole: UserRole.user,
      readPermission: Permission.read,
      writePermissions: {Permission.create, Permission.update},
      labelAr: 'مركز الوثائق',
      scopePolicyAr: 'وثائق عامة/داخلية حسب السياسة.',
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/document-intelligence',
      systemKey: SystemKey.site,
      minRole: UserRole.admin,
      readPermission: Permission.read,
      writePermissions: {
        Permission.create,
        Permission.update,
        Permission.manageSite,
      },
      labelAr: 'ذكاء الوثائق',
      scopePolicyAr: 'معالجة وثائق دون كتابة في مصادر سيادية.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/reports',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.user,
      readPermission: Permission.viewReports,
      writePermissions: {Permission.viewReports},
      labelAr: 'التقارير',
      scopePolicyAr: 'حسب نطاق المستخدم والنظام.',
      readOnly: true,
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/platform/system-registry',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'سجل الأنظمة والأقسام الديناميكي',
      scopePolicyAr: 'منصة مركزية؛ Superuser أو Platform Admin فقط.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/platform/system-operations',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'مركز تشغيل الأنظمة المندمجة',
      scopePolicyAr:
          'منصة مركزية لمراقبة الأنظمة شبه المستقلة دون تعديل منطقها الداخلي.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/platform/database-migration',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'برنامج نقل ملكية الجداول',
      scopePolicyAr:
          'منصة مركزية؛ SQL/UAT/rollback فقط دون تعديل مصادر سيادية.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/database-migration',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'اختصار برنامج نقل ملكية الجداول',
      scopePolicyAr:
          'Alias legacy-only يوجّه إلى /admin/platform/database-migration دون SQL أو تغيير ملكية.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/platform/design-system',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'نظام الواجهات السيادي PWF-SIS',
      scopePolicyAr:
          'منصة مركزية؛ معرض مكونات وجسر هوية بصرية وPilot مرئي دون تغيير بيانات الأنظمة.',
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/platform/cross-system-contracts',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.user,
      readPermission: Permission.viewReports,
      writePermissions: {Permission.manageSystems},
      labelAr: 'عقود الربط بين الأنظمة',
      scopePolicyAr: 'قراءة حوكمة مركزية فقط.',
      readOnly: true,
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/awqaf-system/waqf-assets-intake',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.user,
      readPermission: Permission.viewReports,
      writePermissions: {Permission.manageSystems},
      labelAr: 'استلام waqf_assets من awqaf_system',
      scopePolicyAr: 'قراءة intake فقط؛ لا تطوير waqf_assets داخل المنصة.',
      readOnly: true,
      governanceRoute: true,
    ),
    AdminRouteAccessContract(
      routePrefix: '/admin/developer',
      systemKey: SystemKey.platformAdmin,
      minRole: UserRole.admin,
      readPermission: Permission.manageSystems,
      writePermissions: {Permission.manageSystems},
      labelAr: 'أدوات المطور',
      scopePolicyAr: 'منصة مركزية / مطور.',
      governanceRoute: true,
    ),
  ];

  static AdminRouteAccessContract? contractFor(String location) {
    final matches =
        contracts.where((contract) => contract.matches(location)).toList()
          ..sort(
            (a, b) => b.routePrefix.length.compareTo(a.routePrefix.length),
          );
    return matches.isEmpty ? null : matches.first;
  }

  static bool isCommonActiveAdminRoute(String location) {
    final path = AdminRouteAccessContract._normalize(location);
    return commonActiveAdminRoutes.contains(path);
  }

  static String? _dynamicSystemKeyFromLocation(String location) {
    final segments = Uri.parse(location).pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'admin' &&
        segments[1] == 'systems') {
      return Uri.decodeComponent(segments[2]);
    }
    return null;
  }

  static AdminRouteAccessDecision decide(
    String location,
    AccessProfile profile,
  ) {
    if (isCommonActiveAdminRoute(location)) {
      return const AdminRouteAccessDecision(
        allowed: true,
        reasonAr: 'مسار لوحة مشترك متاح لأي حساب إداري نشط.',
      );
    }

    final dynamicSystemKey = _dynamicSystemKeyFromLocation(location);
    if (dynamicSystemKey != null) {
      if (!profile.isActive) {
        return const AdminRouteAccessDecision(
          allowed: false,
          reasonAr: 'غير مصرح: الحساب غير فعال.',
        );
      }
      if (profile.hasPlatformRootAuthority) {
        return AdminRouteAccessDecision(
          allowed: true,
          reasonAr:
              'السماح وفق صلاحية منصة عليا: Superuser يتجاوز فحص النظام الديناميكي $dynamicSystemKey.',
        );
      }
      final allowed = profile.canAccessDynamicSystem(dynamicSystemKey);
      return AdminRouteAccessDecision(
        allowed: allowed,
        reasonAr: allowed
            ? 'السماح وفق سجل الأنظمة الديناميكي: $dynamicSystemKey'
            : 'غير مصرح: النظام الديناميكي $dynamicSystemKey غير ممنوح لهذا المستخدم.',
      );
    }

    final contract = contractFor(location);
    if (contract == null) {
      return const AdminRouteAccessDecision(
        allowed: true,
        reasonAr:
            'مسار إداري غير مصنف بعد؛ يسمح موقتًا للحساب الإداري النشط ويجب إضافته إلى Route Access Contract.',
      );
    }

    final allowed = contract.allows(profile);
    return AdminRouteAccessDecision(
      allowed: allowed,
      contract: contract,
      reasonAr: allowed
          ? 'السماح وفق عقد الوصول: ${contract.labelAr}'
          : 'غير مصرح: ${contract.labelAr} يتطلب صلاحية/دورًا ضمن ${contract.systemKey.name}.',
    );
  }
}
