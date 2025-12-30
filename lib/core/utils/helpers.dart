import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class Helpers {
  // Show snackbar with custom styling
  static void showSnackBar(
      BuildContext context,
      String message, {
        Color? backgroundColor,
        Color? textColor,
        IconData? icon,
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor ?? Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show success message
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  // Show error message
  static void showError(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  // Show warning message
  static void showWarning(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  // Show info message
  static void showInfo(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(
              child: Text(message ?? 'جاري التحميل...'),
            ),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'تأكيد',
        String cancelText = 'إلغاء',
        Color? confirmColor,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Launch URL
  static Future<void> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // Make phone call
  static Future<void> makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    await launchURL(url);
  }

  // Send SMS
  static Future<void> sendSMS(String phoneNumber, {String? message}) async {
    final url = 'sms:$phoneNumber${message != null ? '?body=$message' : ''}';
    await launchURL(url);
  }

  // Send email
  static Future<void> sendEmail(
      String email, {
        String? subject,
        String? body,
      }) async {
    final url = 'mailto:$email'
        '${subject != null ? '?subject=${Uri.encodeComponent(subject)}' : ''}'
        '${body != null ? '${subject != null ? '&' : '?'}body=${Uri.encodeComponent(body)}' : ''}';
    await launchURL(url);
  }

  // Share text
  static Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      debugPrint('Error sharing text: $e');
    }
  }

  // Share with files
  static Future<void> shareFiles(
      List<String> filePaths, {
        String? text,
        String? subject,
      }) async {
    try {
      await Share.shareXFiles(
        filePaths.map((path) => XFile(path)).toList(),
        text: text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing files: $e');
    }
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showSuccess(context, 'تم النسخ إلى الحافظة');
      }
    } catch (e) {
      if (context.mounted) {
        showError(context, 'فشل في النسخ');
      }
    }
  }

  // Get clipboard data
  static Future<String?> getClipboardData() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('Error getting clipboard data: $e');
      return null;
    }
  }

  // Vibrate device
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error vibrating device: $e');
    }
  }

  // Light vibration
  static Future<void> lightVibrate() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error vibrating device: $e');
    }
  }

  // Heavy vibration
  static Future<void> heavyVibrate() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error vibrating device: $e');
    }
  }

  // Format file size
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Format number with Arabic digits
  static String formatNumberArabic(num number) {
    final formatted = number.toString();
    return arabicNumbers(formatted);
  }

  // Convert to Arabic numbers
  static String arabicNumbers(String input) {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  // Convert to English numbers
  static String englishNumbers(String input) {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';

    String result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  // Check if string contains Arabic
  static bool containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  // Check if string is all Arabic
  static bool isArabic(String text) {
    return RegExp(r'^[\u0600-\u06FF\s\u060C\u061B\u061F\u0640]+$').hasMatch(text);
  }

  // Format currency (Palestinian/Jordanian)
  static String formatCurrency(double amount, {String currency = 'شيكل'}) {
    final formatted = amount.toStringAsFixed(2);
    return '$formatted $currency';
  }

  // Get initials from name
  static String getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.isEmpty) return '';

    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }

    return (names.first.substring(0, 1) + names.last.substring(0, 1)).toUpperCase();
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Remove HTML tags
  static String removeHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Calculate reading time (words per minute)
  static int calculateReadingTime(String text, {int wordsPerMinute = 200}) {
    final wordCount = text.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  // Generate random color
  static Color generateColorFromString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;

    return Color.fromRGBO(r, g, b, 1.0);
  }

  // Validate network connection
  static Future<bool> hasNetworkConnection() async {
    try {
      // This is a simple check - in a real app, you'd use connectivity_plus
      return true; // Placeholder
    } catch (e) {
      return false;
    }
  }

  // Show network error dialog
  static void showNetworkError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لا يوجد اتصال بالإنترنت'),
        content: const Text('يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  // Format phone number for display
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Palestinian phone number formatting
    if (cleaned.startsWith('+970')) {
      cleaned = cleaned.substring(4);
    } else if (cleaned.startsWith('970')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    if (cleaned.length == 8) {
      return '+970 ${cleaned.substring(0, 1)} ${cleaned.substring(1, 4)} ${cleaned.substring(4)}';
    }

    return phoneNumber; // Return original if formatting fails
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // Check if URL is valid
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if file is image
  static bool isImageFile(String fileName) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(getFileExtension(fileName));
  }

  // Check if file is video
  static bool isVideoFile(String fileName) {
    const videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm'];
    return videoExtensions.contains(getFileExtension(fileName));
  }

  // Check if file is document
  static bool isDocumentFile(String fileName) {
    const docExtensions = ['pdf', 'doc', 'docx', 'txt', 'rtf'];
    return docExtensions.contains(getFileExtension(fileName));
  }

  // Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Throttle function calls
  static DateTime? _lastThrottleTime;
  static void throttle(VoidCallback callback, {Duration delay = const Duration(milliseconds: 1000)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= delay) {
      _lastThrottleTime = now;
      callback();
    }
  }

  // Show bottom sheet with custom content
  static Future<T?> showCustomBottomSheet<T>(
      BuildContext context, {
        required Widget child,
        bool isScrollControlled = true,
        bool isDismissible = true,
        Color? backgroundColor,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor ?? Colors.transparent,
      builder: (context) => child,
    );
  }

  // Show image picker options
  static Future<void> showImagePickerOptions(
      BuildContext context, {
        required VoidCallback onCamera,
        required VoidCallback onGallery,
      }) async {
    showCustomBottomSheet(
      context,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                Navigator.pop(context);
                onCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                Navigator.pop(context);
                onGallery();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Generate placeholder avatar
  static Widget generateAvatarPlaceholder(String name, {double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: generateColorFromString(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          getInitials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Show progress dialog
  static void showProgressDialog(
      BuildContext context, {
        required String title,
        required double progress,
        String? message,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 16),
            Text('${(progress * 100).toInt()}%'),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  // Calculate distance between two points (in kilometers)
  static double calculateDistance(
      double lat1, double lon1,
      double lat2, double lon2,
      ) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}