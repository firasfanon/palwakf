import 'package:flutter/material.dart';

import '../access/access_profile.dart';
import '../enums/enums.dart';

/// Internal execution contract for page managers, unit pages closure,
/// and audit verification. This is intentionally UI-friendly so the
/// governance state can be surfaced directly inside admin screens.

enum PwfGovernanceStatus { complete, inProgress, pending }

extension PwfGovernanceStatusX on PwfGovernanceStatus {
  String get labelAr {
    switch (this) {
      case PwfGovernanceStatus.complete:
        return 'منجز';
      case PwfGovernanceStatus.inProgress:
        return 'جارٍ';
      case PwfGovernanceStatus.pending:
        return 'مؤجل';
    }
  }

  Color get color {
    switch (this) {
      case PwfGovernanceStatus.complete:
        return const Color(0xFF1D7A46);
      case PwfGovernanceStatus.inProgress:
        return const Color(0xFF0F4C81);
      case PwfGovernanceStatus.pending:
        return const Color(0xFFB45309);
    }
  }
}

enum PwfPageManagerRole {
  viewer,
  contentEditor,
  reviewer,
  contentManager,
  superuser,
}

extension PwfPageManagerRoleX on PwfPageManagerRole {
  String get labelAr {
    switch (this) {
      case PwfPageManagerRole.viewer:
        return 'مشاهد';
      case PwfPageManagerRole.contentEditor:
        return 'محرر محتوى';
      case PwfPageManagerRole.reviewer:
        return 'مراجع / ناشر';
      case PwfPageManagerRole.contentManager:
        return 'مدير صفحة / محتوى';
      case PwfPageManagerRole.superuser:
        return 'سوبر يوزر سيادي';
    }
  }

  String get summaryAr {
    switch (this) {
      case PwfPageManagerRole.viewer:
        return 'يطلع على الصفحة والسجلات دون تعديل.';
      case PwfPageManagerRole.contentEditor:
        return 'ينشئ ويعدل ضمن نطاقه دون نشر نهائي.';
      case PwfPageManagerRole.reviewer:
        return 'يراجع ويعتمد النشر ويعيد المسودات.';
      case PwfPageManagerRole.contentManager:
        return 'يدير الصفحة ونطاق المحتوى والحذف المنضبط.';
      case PwfPageManagerRole.superuser:
        return 'تفويض منصة كامل، وإجراءات إدارية مباشرة موثقة، وحوكمة عليا عبر كل النطاقات.';
    }
  }
}

class PwfPageManagerPermissionProfile {
  const PwfPageManagerPermissionProfile({
    required this.role,
    required this.scopeAr,
    required this.canView,
    required this.canEdit,
    required this.canPublish,
    required this.canDelete,
    required this.canAudit,
  });

  final PwfPageManagerRole role;
  final String scopeAr;
  final bool canView;
  final bool canEdit;
  final bool canPublish;
  final bool canDelete;
  final bool canAudit;
}

class PwfUnitPagesClosureItem {
  const PwfUnitPagesClosureItem({
    required this.title,
    required this.description,
    required this.status,
  });

  final String title;
  final String description;
  final PwfGovernanceStatus status;
}

class PwfAuditVerificationItem {
  const PwfAuditVerificationItem({
    required this.domain,
    required this.requiredFields,
    required this.status,
    required this.notes,
  });

  final String domain;
  final List<String> requiredFields;
  final PwfGovernanceStatus status;
  final String notes;
}

class PwfResolvedPageManagerAccess {
  const PwfResolvedPageManagerAccess({
    required this.role,
    required this.profile,
    required this.scopeAr,
  });

  final PwfPageManagerRole role;
  final PwfPageManagerPermissionProfile profile;
  final String scopeAr;
}

class PwfAdminGovernanceContract {
  const PwfAdminGovernanceContract._();

  static const mergedDocPath =
      'docs/admin/PALWAKF_ADMIN_PAGE_MANAGERS_USERS_MASTER_MERGED_v2.md';
  static const visualIdentityDocPath =
      'docs/admin/VISUAL_IDENTITY_EXECUTION_GOVERNANCE.md';

  static PwfResolvedPageManagerAccess resolveAccessProfile(
    AccessProfile? accessProfile, {
    String scopeAr = 'المنصة / الصفحة الحالية',
  }) {
    final role = resolveRole(accessProfile);
    final base = pageManagerProfiles.firstWhere(
      (item) => item.role == role,
      orElse: () => pageManagerProfiles.first,
    );
    return PwfResolvedPageManagerAccess(
      role: role,
      scopeAr: scopeAr,
      profile: PwfPageManagerPermissionProfile(
        role: base.role,
        scopeAr: scopeAr,
        canView: base.canView,
        canEdit: base.canEdit,
        canPublish: base.canPublish,
        canDelete: base.canDelete,
        canAudit: base.canAudit,
      ),
    );
  }

  static PwfPageManagerRole resolveRole(AccessProfile? accessProfile) {
    if (accessProfile == null || !accessProfile.isActive) {
      return PwfPageManagerRole.viewer;
    }
    if (accessProfile.isSuperuser ||
        accessProfile.roleFor(SystemKey.platformAdmin) == UserRole.superuser) {
      return PwfPageManagerRole.superuser;
    }
    final canManageUsers = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.manageUsers,
    );
    final canManageHome = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.manageHome,
    );
    final canManageSite = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.manageSite,
    );
    final canDelete = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.delete,
    );
    final canUpdate = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.update,
    );
    final canCreate = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.create,
    );
    final canAudit = accessProfile.can(
      SystemKey.platformAdmin,
      Permission.viewReports,
    );

    if (canManageUsers || (canManageHome && canManageSite && canDelete)) {
      return PwfPageManagerRole.contentManager;
    }
    if (canManageHome &&
        (canAudit ||
            accessProfile.hasRoleAtLeast(
              SystemKey.platformAdmin,
              UserRole.admin,
            ))) {
      return PwfPageManagerRole.reviewer;
    }
    if (canManageHome || canUpdate || canCreate) {
      return PwfPageManagerRole.contentEditor;
    }
    return PwfPageManagerRole.viewer;
  }

  static const pageManagerProfiles = <PwfPageManagerPermissionProfile>[
    PwfPageManagerPermissionProfile(
      role: PwfPageManagerRole.viewer,
      scopeAr: 'وزارة/وحدة وفق التخصيص',
      canView: true,
      canEdit: false,
      canPublish: false,
      canDelete: false,
      canAudit: false,
    ),
    PwfPageManagerPermissionProfile(
      role: PwfPageManagerRole.contentEditor,
      scopeAr: 'صفحة وزارة أو وحدة محددة',
      canView: true,
      canEdit: true,
      canPublish: false,
      canDelete: false,
      canAudit: false,
    ),
    PwfPageManagerPermissionProfile(
      role: PwfPageManagerRole.reviewer,
      scopeAr: 'مراجعة ونشر ضمن النوع/النطاق',
      canView: true,
      canEdit: true,
      canPublish: true,
      canDelete: false,
      canAudit: true,
    ),
    PwfPageManagerPermissionProfile(
      role: PwfPageManagerRole.contentManager,
      scopeAr: 'إدارة الصفحة والمحتوى ضمن scope واضح',
      canView: true,
      canEdit: true,
      canPublish: true,
      canDelete: true,
      canAudit: true,
    ),
    PwfPageManagerPermissionProfile(
      role: PwfPageManagerRole.superuser,
      scopeAr: 'كل النطاقات + الحوكمة العليا',
      canView: true,
      canEdit: true,
      canPublish: true,
      canDelete: true,
      canAudit: true,
    ),
  ];

  static const unitPagesClosureChecklist = <PwfUnitPagesClosureItem>[
    PwfUnitPagesClosureItem(
      title: 'منع التكرار',
      description:
          'اعتماد منطق upsert by unit_id وعدم إنشاء سجل جديد لصفحة الوحدة نفسها.',
      status: PwfGovernanceStatus.complete,
    ),
    PwfUnitPagesClosureItem(
      title: 'إغلاق allowedSections',
      description:
          'يجب أن تُحفظ الأقسام المسموح بها فعليًا وتنعكس على الصفحة الديناميكية.',
      status: PwfGovernanceStatus.inProgress,
    ),
    PwfUnitPagesClosureItem(
      title: 'أدوات CRUD الظاهرة',
      description:
          'إظهار الإجراءات الأساسية بوضوح داخل واجهة الإدارة بدل إبقائها ضمنية.',
      status: PwfGovernanceStatus.complete,
    ),
    PwfUnitPagesClosureItem(
      title: 'التصدير الموحّد',
      description:
          'الالتزام بحوار اختيار النطاق + PDF متعدد الصفحات عند تفعيل التصدير.',
      status: PwfGovernanceStatus.pending,
    ),
  ];

  static const auditVerificationItems = <PwfAuditVerificationItem>[
    PwfAuditVerificationItem(
      domain: 'المحتوى',
      requiredFields: [
        'entity_type',
        'entity_id',
        'action',
        'actor_user_id',
        'acted_at',
      ],
      status: PwfGovernanceStatus.inProgress,
      notes:
          'يركز على إنشاء/تعديل/نشر/أرشفة الأخبار والإعلانات والأنشطة والخطب.',
    ),
    PwfAuditVerificationItem(
      domain: 'الصفحات',
      requiredFields: [
        'old_values',
        'new_values',
        'scope_type',
        'source_system',
      ],
      status: PwfGovernanceStatus.pending,
      notes: 'ضروري لتتبع تغييرات page title وallowedSections وحالة النشر.',
    ),
    PwfAuditVerificationItem(
      domain: 'المستخدمون والصلاحيات',
      requiredFields: [
        'role',
        'permission_key',
        'scope_unit_id',
        'scope_page_id',
      ],
      status: PwfGovernanceStatus.pending,
      notes:
          'مطلوب للتحقق من فصل edit/publish/delete/audit على مستوى مدير الصفحة.',
    ),
  ];
}
