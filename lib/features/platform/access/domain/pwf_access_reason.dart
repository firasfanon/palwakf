/// Canonical platform access-denial reasons.
///
/// Systems must pass a reason code only; the platform renders the user-facing
/// Arabic message and keeps technical/auth backend messages out of the UI.
enum PwfAccessReason {
  inactiveProfile('inactive_profile'),
  missingAccessProfile('missing_access_profile'),
  awqafOperationsDenied('awqaf_operations_denied'),
  awqafScopeDenied('awqaf_scope_denied'),
  adminAccessDenied('admin_access_denied'),
  systemRoleDenied('system_role_denied'),
  unauthorizedProtectedRoute('unauthorized_protected_route'),
  manualForbiddenOpen('manual_forbidden_open'),
  unknown('unknown');

  const PwfAccessReason(this.code);

  final String code;

  static PwfAccessReason fromCode(String? code) {
    final normalized = (code ?? '').trim();
    if (normalized.isEmpty) return PwfAccessReason.manualForbiddenOpen;
    for (final reason in PwfAccessReason.values) {
      if (reason.code == normalized) return reason;
    }
    return PwfAccessReason.unknown;
  }

  String get arabicMessage {
    switch (this) {
      case PwfAccessReason.inactiveProfile:
        return 'تم رفض الوصول لأن ملف المستخدم غير نشط.';
      case PwfAccessReason.missingAccessProfile:
        return 'تم رفض الوصول لأن ملف الصلاحيات غير موجود أو لم يتم تحميله.';
      case PwfAccessReason.awqafOperationsDenied:
        return 'تم رفض الوصول لأن المستخدم لا يملك صلاحية تشغيل أوقاف سيستم.';
      case PwfAccessReason.awqafScopeDenied:
        return 'تم رفض الوصول لأن نطاق الوحدة التنظيمية لا يطابق صلاحيات المستخدم.';
      case PwfAccessReason.adminAccessDenied:
        return 'تم رفض الوصول لأن صلاحيات الإدارة العامة غير متوفرة لهذا المستخدم.';
      case PwfAccessReason.systemRoleDenied:
        return 'تم رفض الوصول لأن دور المستخدم لا يسمح بفتح هذا النظام.';
      case PwfAccessReason.unauthorizedProtectedRoute:
        return 'تم رفض الوصول لأن المسار محمي ويتطلب مصادقة وصلاحية صريحة.';
      case PwfAccessReason.manualForbiddenOpen:
        return 'تم فتح صفحة الرفض مباشرة أو بدون سبب موجّه من بوابة الصلاحيات.';
      case PwfAccessReason.unknown:
        return 'تم رفض الوصول وفق سياسة الصلاحيات ونطاق الوحدة التنظيمية.';
    }
  }
}
