import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Information
  static const String appName = 'وزارة الأوقاف والشؤون الدينية';
  static const String appNameEn = 'Palestinian Ministry of Endowments';
  static const String appVersion = '1.0.0';
  static const String appLogo = 'assets/icons/appLogo.png';

  // Supabase Storage
  // Bucket used for Media Gallery uploads (photos/videos/thumbnails).
  static const String mediaGalleryBucket = 'media-gallery';

  // Spacing Constants
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius Constants
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Colors - Added here for direct access via AppConstants
  static const Color islamicGreen = Color(0xFF0F4C81);
  static const Color goldenYellow = Color(0xFFEAB308);
  static const Color sageGreen = Color(0xFF1E3A8A);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xAB000000);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFF6B7280);
  static const Color royalRed = Color(0xFFB22222);

  // Gradient - Added here for direct access via AppConstants
  static const Gradient islamicGradient = LinearGradient(
    colors: [Color(0xFF0F4C81), Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ENVIRONMENT VARIABLES - NO HARDCODED FALLBACKS
  static String get baseUrl => _getRequiredEnv('SUPABASE_URL');
  static String get apiKey => _getRequiredEnv('SUPABASE_ANON_KEY');
  static String get googleMapsApiKey => _getRequiredEnv('GOOGLE_MAPS_API_KEY');
  static String get firebaseProjectId => _getRequiredEnv('FIREBASE_PROJECT_ID');

  // Optional environment variables with safe defaults
  static String get environment => _getEnv('ENVIRONMENT', 'development');
  static String get prayerTimesApiUrl =>
      _getEnv('PRAYER_TIMES_API_URL', 'https://api.aladhan.com/v1/timings');

  // Helper: Get required environment variable or throw
  static String _getRequiredEnv(String key) {
    // Try dotenv first (for local development)
    try {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (e) {
      // dotenv not initialized, that's ok
    }

    // Note: String.fromEnvironment doesn't work at runtime in Flutter web
    // Only dotenv variables are supported

    // If not found, throw exception
    throw EnvironmentException(
      'Required environment variable "$key" is not set. Please check your .env file.',
    );
  }

  // Helper: Get optional environment variable with default
  static String _getEnv(String key, String defaultValue) {
    // Try dotenv first
    try {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    } catch (e) {
      // dotenv not initialized, that's ok
    }

    // Note: String.fromEnvironment doesn't work at runtime in Flutter web

    // Return default
    return defaultValue;
  }

  // Service Categories
  static const List<String> serviceCategories = [
    'خدمات المساجد',
    'الأوقاف الإسلامية',
    'الشؤون الدينية',
    'التعليم الديني',
    'الحج والعمرة',
    'الفتاوى والإرشاد',
    'خدمات إدارية',
  ];

  // Palestinian Governorates
  static const List<String> governorates = [
    'القدس',
    'رام الله والبيرة',
    'نابلس',
    'الخليل',
    'بيت لحم',
    'أريحا والأغوار',
    'قلقيلية',
    'سلفيت',
    'طولكرم',
    'جنين',
    'طوباس والأغوار الشمالية',
    'غزة',
    'خان يونس',
    'دير البلح',
    'رفح',
    'شمال غزة',
  ];

  // Contact Information
  static const String phoneNumber = '+970-2-2406340';
  static const String email = 'info@awqaf.ps';
  static const String website = 'https://www.awqaf.ps';
  static const String address =
      'رام الله - فلسطين\nشارع الإرسال - مجمع الوزارات';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/awqaf.ps';
  static const String twitterUrl = 'https://twitter.com/awqaf_ps';
  static const String youtubeUrl = 'https://youtube.com/awqafps';
  static const String instagramUrl = 'https://instagram.com/awqaf.ps';

  // Default Values
  static const int defaultPageSize = 20;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> supportedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'txt',
  ];

  // Cache Keys
  static const String cacheKeyNews = 'cached_news';
  static const String cacheKeyMosques = 'cached_mosques';
  static const String cacheKeyAnnouncements = 'cached_announcements';
  static const String cacheKeyActivities = 'cached_activities';

  // Shared Preferences Keys
  static const String keyLanguage = 'selected_language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyUserPreferences = 'user_preferences';
  static const String keyLastSync = 'last_sync';

  // Error Messages
  static const String errorNetworkConnection = 'لا يوجد اتصال بالإنترنت';
  static const String errorGeneral = 'حدث خطأ غير متوقع';
  static const String errorDataNotFound = 'لم يتم العثور على البيانات';
  static const String errorTimeout = 'انتهت مهلة الاتصال';
  static const String errorServerError = 'خطأ في الخادم';

  // Success Messages
  static const String successDataLoaded = 'تم تحميل البيانات بنجاح';
  static const String successDataSaved = 'تم حفظ البيانات بنجاح';
  static const String successMessageSent = 'تم إرسال الرسالة بنجاح';

  // Map Configuration
  static const double defaultLatitude = 31.9522;
  static const double defaultLongitude = 35.2332;
  static const double defaultZoom = 8.0;

  // Notification Channels
  static const String notificationChannelGeneral = 'general';
  static const String notificationChannelAnnouncements = 'announcements';
  static const String notificationChannelNews = 'news';
  static const String notificationChannelActivities = 'activities';

  // File Upload Limits
  static const int maxImagesPerUpload = 5;
  static const int maxDocumentsPerUpload = 3;
  static const double maxImageSizeMB = 5.0;
  static const double maxDocumentSizeMB = 10.0;

  // Islamic Calendar
  static const List<String> islamicMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  // News Categories
  static const Map<String, IconData> newsCategoryIcons = {
    'عامة': Icons.article,
    'مساجد': Icons.mosque,
    'فعاليات': Icons.event,
    'تعليم': Icons.school,
    'اجتماعية': Icons.group,
    'دينية': Icons.menu_book,
    'دولية': Icons.public,
    'إدارية': Icons.business,
  };

  // Quick Actions
  static const List<Map<String, dynamic>> quickActions = [
    {
      'title': 'دليل المساجد',
      'icon': Icons.mosque,
      'route': '/mosques',
      'color': Colors.green,
    },
    {
      'title': 'الخدمات الإلكترونية',
      'icon': Icons.computer,
      'route': '/eservices',
      'color': Colors.blue,
    },
    {
      'title': 'الأخبار',
      'icon': Icons.article,
      'route': '/news',
      'color': Colors.orange,
    },
    {
      'title': 'اتصل بنا',
      'icon': Icons.contact_phone,
      'route': '/contact',
      'color': Colors.purple,
    },
  ];

  // Statistics Labels
  static const Map<String, String> statsLabels = {
    'mosques': 'مسجد',
    'activities': 'نشاط',
    'news': 'خبر',
    'services': 'خدمة',
    'users': 'مستخدم',
    'waqf_lands': 'أرض وقف',
    'cases': 'قضية',
    'documents': 'وثيقة',
  };

  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(r'^(\+970|970|0)?[2-9]\d{7}$');

  static final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');

  // App Store URLs
  static const String appStoreUrl = 'https://apps.apple.com/app/your-app-id';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.yourapp.id';

  // Deep Links
  static const String deepLinkScheme = 'awqaf';
  static const String deepLinkHost = 'ps';

  // Backup and Restore
  static const String backupFileName = 'awqaf_backup';
  static const String backupFileExtension = '.json';
  static const int maxBackupFiles = 5;

  // Security
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
}

// Custom Exception for Environment Variables
class EnvironmentException implements Exception {
  final String message;

  EnvironmentException(this.message);

  @override
  String toString() => 'EnvironmentException: $message';
}

// Shared dimensions used by the legacy app theme and public frontend widgets.
class AppDimensions {
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
}

// Color Scheme
class AppColors {
  // Primary Islamic Colors (also accessible via AppConstants)
  static const Color islamicGreen = AppConstants.islamicGreen;
  static const Color goldenYellow = AppConstants.goldenYellow;
  static const Color sageGreen = AppConstants.sageGreen;
  static const Color royalRed = AppConstants.royalRed;

  // Status Colors (also accessible via AppConstants)
  static const Color success = AppConstants.success;
  static const Color warning = AppConstants.warning;
  static const Color error = AppConstants.error;
  static const Color info = AppConstants.info;

  // Gradients (also accessible via AppConstants)
  static const Gradient islamicGradient = AppConstants.islamicGradient;

  static const Gradient goldenGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = AppConstants.onSurface;
  static const Color surfaceVariant = AppConstants.surfaceVariant;
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Palestinian Flag Colors
  static const Color palestineRed = Color(0xFFCE1126);
  static const Color palestineWhite = Color(0xFFFFFFFF);
  static const Color palestineBlack = Color(0xFF000000);
  static const Color palestineGreen = Color(0xFF007A3D);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
}

// Text Styles
class AppTextStyles {
  // Arabic Fonts
  static const String arabicDisplay = 'Amiri';
  static const String arabicBody = 'NotoSansArabic';

  // English Fonts
  static const String englishFont = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: arabicDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: arabicDisplay,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: arabicDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: arabicDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: arabicDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: arabicDisplay,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: arabicBody,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.45,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: arabicBody,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: arabicBody,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: arabicBody,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: arabicBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: arabicBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  // Compatibility aliases for older screens
  static const TextStyle labelLarge = titleSmall;
  static const TextStyle labelMedium = bodySmall;
  static const TextStyle labelSmall = bodySmall;
}
