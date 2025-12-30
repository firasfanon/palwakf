class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // Phone number validation (Palestinian format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    final phoneRegex = RegExp(r'^(\+970|970|0)?[2-9]\d{7,8}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  // Minimum length validation
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < min) {
      return fieldName != null
          ? '$fieldName يجب أن يكون $min أحرف على الأقل'
          : 'يجب أن يكون $min أحرف على الأقل';
    }

    return null;
  }

  // Maximum length validation
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > max) {
      return fieldName != null
          ? '$fieldName يجب ألا يتجاوز $max حرف'
          : 'يجب ألا يتجاوز $max حرف';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }

    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }

    return null;
  }

  // Numeric validation
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName يجب أن يكون رقماً'
          : 'يجب أن يكون رقماً';
    }

    return null;
  }

  // Integer validation
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (int.tryParse(value) == null) {
      return fieldName != null
          ? '$fieldName يجب أن يكون رقماً صحيحاً'
          : 'يجب أن يكون رقماً صحيحاً';
    }

    return null;
  }

  // Range validation
  static String? range(String? value, num min, num max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final number = num.tryParse(value);
    if (number == null) {
      return 'يجب أن يكون رقماً';
    }

    if (number < min || number > max) {
      return fieldName != null
          ? '$fieldName يجب أن يكون بين $min و $max'
          : 'يجب أن يكون بين $min و $max';
    }

    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  // Arabic text validation
  static String? arabicText(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final arabicRegex = RegExp(r'^[\u0600-\u06FF\s\u060C\u061B\u061F\u0640]+$');

    if (!arabicRegex.hasMatch(value)) {
      return fieldName != null
          ? '$fieldName يجب أن يحتوي على نص عربي فقط'
          : 'يجب أن يحتوي على نص عربي فقط';
    }

    return null;
  }

  // Palestinian ID validation
  static String? palestinianId(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهوية مطلوب';
    }

    if (value.length != 9) {
      return 'رقم الهوية يجب أن يكون 9 أرقام';
    }

    if (int.tryParse(value) == null) {
      return 'رقم الهوية يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  // Date validation
  static String? date(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return fieldName != null
          ? '$fieldName تاريخ غير صحيح'
          : 'تاريخ غير صحيح';
    }
  }

  // Future date validation
  static String? futureDate(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return fieldName != null
            ? '$fieldName يجب أن يكون في المستقبل'
            : 'يجب أن يكون تاريخاً في المستقبل';
      }
      return null;
    } catch (e) {
      return 'تاريخ غير صحيح';
    }
  }

  // Past date validation
  static String? pastDate(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return fieldName != null
            ? '$fieldName يجب أن يكون في الماضي'
            : 'يجب أن يكون تاريخاً في الماضي';
      }
      return null;
    } catch (e) {
      return 'تاريخ غير صحيح';
    }
  }

  // File size validation
  static String? fileSize(int? bytes, int maxSizeInMB) {
    if (bytes == null) {
      return null;
    }

    final maxBytes = maxSizeInMB * 1024 * 1024;
    if (bytes > maxBytes) {
      return 'حجم الملف يجب ألا يتجاوز $maxSizeInMB ميجابايت';
    }

    return null;
  }

  // File extension validation
  static String? fileExtension(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return null;
    }

    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'صيغة الملف غير مدعومة. الصيغ المدعومة: ${allowedExtensions.join(', ')}';
    }

    return null;
  }

  // Combine multiple validators
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  // Custom regex validation
  static String? regex(String? value, String pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!RegExp(pattern).hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  // Match validation (for matching two fields)
  static String? match(String? value, String? otherValue, String errorMessage) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value != otherValue) {
      return errorMessage;
    }

    return null;
  }

  // Whitelist validation
  static String? whitelist(String? value, List<String> allowedValues, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!allowedValues.contains(value)) {
      return fieldName != null
          ? '$fieldName قيمة غير صالحة'
          : 'قيمة غير صالحة';
    }

    return null;
  }

  // Blacklist validation
  static String? blacklist(String? value, List<String> forbiddenValues, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (forbiddenValues.contains(value)) {
      return fieldName != null
          ? '$fieldName قيمة غير مسموحة'
          : 'قيمة غير مسموحة';
    }

    return null;
  }
}