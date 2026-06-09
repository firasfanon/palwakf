import 'pwf_password_recovery_controller.dart';

/// Converts technical auth/backend errors into safe Arabic user messages.
///
/// UI code should never render raw Supabase or exception messages directly.
class PwfAuthErrorNormalizer {
  const PwfAuthErrorNormalizer._();

  static String normalize(Object? error) {
    final raw = (error ?? '').toString().toLowerCase();
    if (raw.trim().isEmpty) {
      return 'تعذر تسجيل الدخول. تحقق من البيانات والصلاحيات ثم أعد المحاولة.';
    }
    if (raw.contains('invalid login') ||
        raw.contains('invalid credentials') ||
        raw.contains('invalid_grant') ||
        raw.contains('email or password')) {
      return 'بيانات الدخول غير صحيحة أو الحساب غير مخول.';
    }
    if (raw.contains('inactive') || raw.contains('غير نشط')) {
      return 'هذا الحساب غير نشط. راجع مسؤول النظام.';
    }
    if (_isNetwork(raw)) {
      return 'تعذر الاتصال بخدمة المصادقة. تحقق من الاتصال ثم أعد المحاولة.';
    }
    if (raw.contains('email not confirmed') || raw.contains('not confirmed')) {
      return 'البريد الإلكتروني غير مؤكد بعد.';
    }
    if (_isExpiredOrInvalidRecovery(raw)) {
      return 'رابط الاستعادة غير نشط أو انتهت صلاحيته. أرسل رابطًا جديدًا ثم افتحه من نفس المتصفح.';
    }
    return 'تعذر تسجيل الدخول. تحقق من البيانات والصلاحيات ثم أعد المحاولة.';
  }

  static String normalizeRecovery(Object? error) {
    final raw = (error ?? '').toString().toLowerCase();
    if (raw.trim().isEmpty) return 'تعذر إتمام إجراء الاستعادة. حاول لاحقًا.';
    if (_isNetwork(raw)) {
      return 'تعذر الاتصال بالخادم. تحقق من الاتصال وحاول مجددًا.';
    }
    if (raw.contains('rate') || raw.contains('too many')) {
      return 'تم إرسال عدة طلبات. حاول بعد قليل.';
    }
    if (_isPkceVerifierMissing(raw)) {
      return PwfPasswordRecoveryController.pkceVerifierMissing;
    }
    if (_isSamePassword(raw)) {
      return PwfPasswordRecoveryController.passwordMustBeDifferent;
    }
    if (_isSessionMissing(raw)) {
      return PwfPasswordRecoveryController.pkceVerifierMissing;
    }
    if (raw.contains('expired')) {
      return 'رابط الاستعادة منتهي الصلاحية. اطلب رابطًا جديدًا.';
    }
    if (_isExpiredOrInvalidRecovery(raw)) {
      return 'رابط الاستعادة غير صالح أو تم استخدامه سابقًا.';
    }
    if (raw.contains('password') && raw.contains('short')) {
      return 'كلمة المرور قصيرة جدًا.';
    }
    if (raw.contains('password') && raw.contains('policy')) {
      return 'كلمة المرور لا تطابق سياسة الأمان.';
    }
    return 'تعذر إتمام إجراء الاستعادة. حاول لاحقًا.';
  }

  static bool _isNetwork(String raw) {
    return raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('timeout') ||
        raw.contains('connection') ||
        raw.contains('xmlhttprequest');
  }

  static bool _isSamePassword(String raw) {
    return raw.contains('same password') ||
        raw.contains('different from the old') ||
        raw.contains('different from old') ||
        raw.contains('should be different');
  }

  static bool _isSessionMissing(String raw) {
    return raw.contains('auth session missing') ||
        raw.contains('session missing') ||
        raw.contains('not logged in') ||
        raw.contains('no current session') ||
        raw.contains('current session is null');
  }

  static bool _isPkceVerifierMissing(String raw) {
    return raw.contains('code verifier') ||
        raw.contains('verifier could not be found') ||
        raw.contains('pkce') && raw.contains('storage');
  }

  static bool _isExpiredOrInvalidRecovery(String raw) {
    return raw.contains('expired') ||
        raw.contains('otp') ||
        raw.contains('code') ||
        raw.contains('token') ||
        raw.contains('recovery');
  }
}
