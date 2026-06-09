import '../models/assistant_capability_snapshot.dart';
import '../models/assistant_context.dart';

class AssistantCapabilityService {
  const AssistantCapabilityService();

  AssistantCapabilitySnapshot resolve(AssistantContext context) {
    final permissions = context.permissions.map((e) => e.toLowerCase()).toSet();
    final isSuper = context.roleLabel.toLowerCase() == 'superuser';
    final canManageUsers = isSuper || permissions.contains('manageusers');
    final canManageHome = isSuper || permissions.contains('managehome');
    final canManageSite = isSuper || permissions.contains('managesite');
    final canManageSystems = isSuper || permissions.contains('managesystems');
    final canViewReports = isSuper || permissions.contains('viewreports');
    final canCrud =
        isSuper ||
        permissions.any((e) => e == 'create' || e == 'update' || e == 'delete');
    final canUseDocsAdmin =
        isSuper || canManageHome || canManageSite || canCrud || canViewReports;
    final canUseDocsSystems =
        isSuper || canManageSystems || context.systemKey != 'awqaf_system';
    final canUseVisualIdentityDocs = isSuper || canManageSite || canManageHome;
    final canUseRbacGuidance = isSuper || canManageUsers;

    final accessModeAr = isSuper
        ? 'تشغيلي كامل'
        : (canUseDocsAdmin || canUseDocsSystems || canCrud
              ? 'تشغيلي محكوم'
              : 'إرشادي مقيّد');
    final accessModeEn = isSuper
        ? 'Full operational'
        : (canUseDocsAdmin || canUseDocsSystems || canCrud
              ? 'Governed operational'
              : 'Restricted guidance');

    final roleTierAr = isSuper
        ? 'فئة عليا'
        : (context.roleLabel.toLowerCase().contains('admin')
              ? 'إداري'
              : (context.roleLabel.toLowerCase().contains('user')
                    ? 'تشغيلي'
                    : 'مراجع/مشاهد'));
    final roleTierEn = isSuper
        ? 'Super tier'
        : (context.roleLabel.toLowerCase().contains('admin')
              ? 'Admin'
              : (context.roleLabel.toLowerCase().contains('user')
                    ? 'Operational'
                    : 'Viewer / reviewer'));

    final labelsAr = <String>[
      if (canManageHome) 'إدارة الصفحة الرئيسية',
      if (canManageSite) 'إدارة الموقع',
      if (canManageUsers) 'إدارة المستخدمين',
      if (canManageSystems) 'إدارة الأنظمة',
      if (canViewReports) 'قراءة التقارير',
      if (canCrud) 'إرشاد CRUD محكوم',
      if (canUseRbacGuidance) 'إغلاق نضج المساعد: RAG/Tools/Evals',
      if (context.systemKey == 'awqaf_system' || context.hasAssetContext)
        'نطاق مساعد الأصول الوقفية للقراءة المحكومة',
      if (context.hasUnitContext) 'سياق وحدة نشط',
      if (context.hasAssetContext) 'سياق أصل وقفي نشط',
      if (!canManageHome &&
          !canManageSite &&
          !canManageUsers &&
          !canManageSystems &&
          !canViewReports &&
          !canCrud)
        'إرشاد فقط دون صلاحيات تشغيلية موسعة',
    ];

    final labelsEn = <String>[
      if (canManageHome) 'Home management',
      if (canManageSite) 'Site management',
      if (canManageUsers) 'Users management',
      if (canManageSystems) 'Systems management',
      if (canViewReports) 'Reports access',
      if (canCrud) 'Governed CRUD guidance',
      if (canUseRbacGuidance) 'Assistant maturity: RAG/Tools/Evals',
      if (context.systemKey == 'awqaf_system' || context.hasAssetContext)
        'Governed waqf-assets assistant scope',
      if (context.hasUnitContext) 'Active unit scope',
      if (context.hasAssetContext) 'Active waqf-asset scope',
      if (!canManageHome &&
          !canManageSite &&
          !canManageUsers &&
          !canManageSystems &&
          !canViewReports &&
          !canCrud)
        'Guidance only',
    ];

    return AssistantCapabilitySnapshot(
      accessModeAr: accessModeAr,
      accessModeEn: accessModeEn,
      roleTierAr: roleTierAr,
      roleTierEn: roleTierEn,
      capabilityLabelsAr: List<String>.unmodifiable(labelsAr),
      capabilityLabelsEn: List<String>.unmodifiable(labelsEn),
      canUseDocsAdmin: canUseDocsAdmin,
      canUseDocsSystems: canUseDocsSystems,
      canUseVisualIdentityDocs: canUseVisualIdentityDocs,
      canUseRbacGuidance: canUseRbacGuidance,
    );
  }
}
