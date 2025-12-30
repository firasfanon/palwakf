import '../../../core/utils/validators.dart';

class FormValidators {
  // Reusable form field validators that return FormFieldValidator functions

  static String? Function(String?) required({String? fieldName}) {
    return (value) => Validators.required(value, fieldName: fieldName);
  }

  static String? Function(String?) email() {
    return (value) => Validators.email(value);
  }

  static String? Function(String?) phone() {
    return (value) => Validators.phoneNumber(value);
  }

  static String? Function(String?) minLength(int min, {String? fieldName}) {
    return (value) => Validators.minLength(value, min, fieldName: fieldName);
  }

  static String? Function(String?) maxLength(int max, {String? fieldName}) {
    return (value) => Validators.maxLength(value, max, fieldName: fieldName);
  }

  static String? Function(String?) password() {
    return (value) => Validators.password(value);
  }

  static String? Function(String?) confirmPassword(String password) {
    return (value) => Validators.confirmPassword(value, password);
  }

  static String? Function(String?) numeric({String? fieldName}) {
    return (value) => Validators.numeric(value, fieldName: fieldName);
  }

  static String? Function(String?) range(num min, num max, {String? fieldName}) {
    return (value) => Validators.range(value, min, max, fieldName: fieldName);
  }

  static String? Function(String?) url() {
    return (value) => Validators.url(value);
  }

  static String? Function(String?) arabicText({String? fieldName}) {
    return (value) => Validators.arabicText(value, fieldName: fieldName);
  }

  static String? Function(String?) palestinianId() {
    return (value) => Validators.palestinianId(value);
  }

  // Combine multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators,
      ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  // Common validation combinations
  static String? Function(String?) requiredEmail() {
    return combine([required(fieldName: 'البريد الإلكتروني'), email()]);
  }

  static String? Function(String?) requiredPhone() {
    return combine([required(fieldName: 'رقم الهاتف'), phone()]);
  }

  static String? Function(String?) requiredPassword() {
    return combine([required(fieldName: 'كلمة المرور'), password()]);
  }

  static String? Function(String?) requiredArabicText({String? fieldName}) {
    return combine([
      required(fieldName: fieldName),
      arabicText(fieldName: fieldName),
    ]);
  }
}