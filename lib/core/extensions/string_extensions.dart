extension StringExtensions on String {
  // Check if string is empty or null
  bool get isEmptyOrNull => trim().isEmpty;

  // Check if string is not empty
  bool get isNotEmptyOrNull => trim().isNotEmpty;

  // Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Capitalize first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  // Remove extra spaces
  String removeExtraSpaces() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // Check if string contains only Arabic characters
  bool get isArabic {
    return RegExp(r'^[\u0600-\u06FF\s\u060C\u061B\u061F\u0640]+$').hasMatch(this);
  }

  // Check if string contains only English characters
  bool get isEnglish {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(this);
  }

  // Check if string contains Arabic characters
  bool get containsArabic {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(this);
  }

  // Check if string contains English characters
  bool get containsEnglish {
    return RegExp(r'[a-zA-Z]').hasMatch(this);
  }

  // Validate email
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  // Validate phone number (Palestinian format)
  bool get isValidPhone {
    return RegExp(
      r'^(\+970|970|0)?[2-9]\d{7,8}$',
    ).hasMatch(this);
  }

  // Validate URL
  bool get isValidUrl {
    return RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    ).hasMatch(this);
  }

  // Convert to Arabic numerals
  String toArabicNumerals() {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    String result = this;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // Convert to English numerals
  String toEnglishNumerals() {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    String result = this;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  // Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // Remove HTML tags
  String removeHtmlTags() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Extract numbers from string
  String extractNumbers() {
    return replaceAll(RegExp(r'[^\d]'), '');
  }

  // Extract letters from string
  String extractLetters() {
    return replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF]'), '');
  }

  // Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  // Convert string to int safely
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  // Convert string to double safely
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }

  // Reverse string
  String reverse() {
    return split('').reversed.join();
  }

  // Count words
  int get wordCount {
    return trim().split(RegExp(r'\s+')).length;
  }

  // Count characters (excluding spaces)
  int get characterCount {
    return replaceAll(RegExp(r'\s'), '').length;
  }

  // Check if palindrome
  bool get isPalindrome {
    final cleaned = toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]'), '');
    return cleaned == cleaned.split('').reversed.join();
  }

  // Convert to snake_case
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'^_'), '');
  }

  // Convert to camelCase
  String toCamelCase() {
    return replaceAllMapped(
      RegExp(r'_([a-z])'),
          (match) => match.group(1)!.toUpperCase(),
    );
  }

  // Convert to Title Case
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  // Mask string (for sensitive data)
  String mask({int visibleStart = 0, int visibleEnd = 0, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;

    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final masked = maskChar * (length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }

  // Format phone number for display
  String formatPhoneNumber() {
    String cleaned = extractNumbers();

    // Remove country code if present
    if (cleaned.startsWith('970')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    if (cleaned.length == 8) {
      return '+970 ${cleaned.substring(0, 1)} ${cleaned.substring(1, 4)} ${cleaned.substring(4)}';
    } else if (cleaned.length == 9) {
      return '+970 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
    }

    return this;
  }

  // Check if contains any of the strings
  bool containsAny(List<String> strings) {
    return strings.any((s) => contains(s));
  }

  // Check if contains all of the strings
  bool containsAll(List<String> strings) {
    return strings.every((s) => contains(s));
  }

  // Replace Arabic characters with their equivalents
  String normalizeArabic() {
    return replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
  }

  // Generate initials from name
  String getInitials({int maxInitials = 2}) {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';

    return words
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  // Convert to safe filename
  String toSafeFilename() {
    return replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[-\s]+'), '-')
        .toLowerCase();
  }

  // Check if string matches pattern
  bool matchesPattern(String pattern) {
    return RegExp(pattern).hasMatch(this);
  }

  // Highlight search term
  String highlightSearch(String searchTerm, {String startTag = '<mark>', String endTag = '</mark>'}) {
    if (searchTerm.isEmpty) return this;
    return replaceAllMapped(
      RegExp(searchTerm, caseSensitive: false),
          (match) => '$startTag${match.group(0)}$endTag',
    );
  }

  // Convert line breaks to HTML br tags
  String nl2br() {
    return replaceAll('\n', '<br>');
  }

  // Convert HTML br tags to line breaks
  String br2nl() {
    return replaceAll(RegExp(r'<br\s*/?>'), '\n');
  }

  // Encode for URL
  String urlEncode() {
    return Uri.encodeComponent(this);
  }

  // Decode from URL
  String urlDecode() {
    return Uri.decodeComponent(this);
  }

  // Check if string is a valid ID number (Palestinian)
  bool get isValidPalestinianId {
    if (length != 9) return false;
    return isNumeric;
  }

  // Format file size from bytes string
  String formatAsFileSize() {
    final bytes = toIntOrNull();
    if (bytes == null) return this;

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

// Extension for nullable strings
extension NullableStringExtensions on String? {
  // Check if null or empty
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  // Get value or default
  String orDefault([String defaultValue = '']) => this ?? defaultValue;

  // Get value or execute callback
  String orElse(String Function() callback) => this ?? callback();

  // Safe length
  int get safeLength => this?.length ?? 0;

  // Safe trim
  String safeTrim() => this?.trim() ?? '';

  // Safe operations
  bool safeContains(String other) => this?.contains(other) ?? false;
  bool safeStartsWith(String prefix) => this?.startsWith(prefix) ?? false;
  bool safeEndsWith(String suffix) => this?.endsWith(suffix) ?? false;
}