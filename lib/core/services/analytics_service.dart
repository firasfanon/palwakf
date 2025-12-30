// lib/core/services/analytics_service.dart
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// خدمة تحليلات لتتبع استخدام التطبيق
class AnalyticsService {
  /// تسجيل حدث في التحليلات
  static void logEvent(String eventName, Map<String, dynamic>? parameters) {
    try {
      // يمكن استبدال هذا بـ Firebase Analytics أو أي خدمة تحليلات أخرى
      final logMessage = '📊 Analytics Event: $eventName';
      if (parameters != null && parameters.isNotEmpty) {
        developer.log(logMessage, name: 'Analytics', error: parameters);
      } else {
        developer.log(logMessage, name: 'Analytics');
      }

      // هنا يمكن إضافة تكامل مع Firebase Analytics أو Google Analytics
      // await FirebaseAnalytics.instance.logEvent(
      //   name: eventName,
      //   parameters: parameters,
      // );
    } catch (e) {
      debugPrint('⚠️ Error logging analytics event: $e');
    }
  }

  /// تسجيل شاشة تم عرضها
  static void logScreenView(String screenName) {
    try {
      developer.log('📱 Screen View: $screenName', name: 'Analytics');

      // للاستخدام مع Firebase Analytics:
      // await FirebaseAnalytics.instance.setCurrentScreen(
      //   screenName: screenName,
      //   screenClassOverride: screenName,
      // );
    } catch (e) {
      debugPrint('⚠️ Error logging screen view: $e');
    }
  }

  /// تسجيل مستخدم
  static void logUserProperties({
    String? userId,
    String? userRole,
    String? userEmail,
  }) {
    try {
      final properties = {
        if (userId != null) 'user_id': userId,
        if (userRole != null) 'user_role': userRole,
        if (userEmail != null) 'user_email': userEmail,
      };

      developer.log('👤 User Properties: $properties', name: 'Analytics');

      // للاستخدام مع Firebase Analytics:
      // if (userId != null) {
      //   await FirebaseAnalytics.instance.setUserId(id: userId);
      // }
      // for (final entry in properties.entries) {
      //   await FirebaseAnalytics.instance.setUserProperty(
      //     name: entry.key,
      //     value: entry.value,
      //   );
      // }
    } catch (e) {
      debugPrint('⚠️ Error logging user properties: $e');
    }
  }

  /// تتبع الأخطاء
  static void logError(String errorName, String errorDetails) {
    try {
      developer.log(
        '❌ App Error: $errorName',
        name: 'Analytics',
        error: errorDetails,
      );

      logEvent('app_error', {
        'error_name': errorName,
        'error_details': errorDetails,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('⚠️ Error logging app error: $e');
    }
  }

  /// تتبع الأداء
  static void logPerformance(String action, Duration duration) {
    try {
      developer.log(
        '⚡ Performance: $action - ${duration.inMilliseconds}ms',
        name: 'Analytics',
      );

      logEvent('performance', {
        'action': action,
        'duration_ms': duration.inMilliseconds,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('⚠️ Error logging performance: $e');
    }
  }
}