/// Shared text/contract constants for the platform password recovery flow.
///
/// Systems must not create independent recovery flows. The concrete runtime
/// pages live under `features/platform/access/presentation/pages`.
class PwfPasswordRecoveryController {
  const PwfPasswordRecoveryController._();

  static const emailRequired = 'البريد الإلكتروني مطلوب';
  static const invalidEmail = 'أدخل بريدًا إلكترونيًا صحيحًا';
  static const nonEnumeratingSent =
      'إذا كان البريد مسجلاً فسيصلك رابط استعادة كلمة المرور خلال دقائق.';
  static const missingCode =
      'رابط الاستعادة لا يحتوي رمز Supabase صالحًا. أرسل رابطًا جديدًا وافتحه فورًا من نفس منفذ التطبيق.';
  static const expiredOrInactive =
      'رابط الاستعادة غير نشط أو انتهت صلاحيته. أرسل رابطًا جديدًا ثم افتحه من نفس المتصفح.';
  static const pkceVerifierMissing =
      'لم يتم العثور على جلسة التحقق المحلية الخاصة برابط الاستعادة. اطلب رابطًا جديدًا من نفس المتصفح ونفس منفذ التطبيق ثم افتحه دون إعادة تشغيل التطبيق أو تغيير المنفذ.';
  static const passwordRequired = 'كلمة المرور مطلوبة';
  static const passwordTooShort = 'كلمة المرور قصيرة جدًا';
  static const passwordMismatch = 'تأكيد كلمة المرور غير مطابق';
  static const passwordPolicyFailed = 'كلمة المرور لا تطابق سياسة الأمان';
  static const passwordMustBeDifferent =
      'كلمة المرور الجديدة يجب أن تكون مختلفة عن كلمة المرور السابقة.';
  static const passwordUpdatedFreshLogin =
      'تم تحديث كلمة المرور. يرجى تسجيل الدخول من جديد.';
  static const exchangingCode =
      'جارٍ اعتماد رمز الاستعادة من رابط Supabase وتحويله إلى جلسة recovery مؤقتة...';
  static const freshLoginRequired =
      'يجب تسجيل الدخول من جديد بعد تغيير كلمة المرور.';

  static bool looksLikeEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  static String? validateEmail(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return emailRequired;
    if (!looksLikeEmail(trimmed)) return invalidEmail;
    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return passwordRequired;
    if (password.length < 8) return passwordTooShort;
    final hasLetter = RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasNumber) return passwordPolicyFailed;
    return null;
  }

  static String? validateConfirmation(String? value, String password) {
    if ((value ?? '').isEmpty) return passwordRequired;
    if (value != password) return passwordMismatch;
    return null;
  }
}
