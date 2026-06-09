import 'package:flutter/widgets.dart';

import '../../domain/models/pwf_prayer_models.dart';
import '../../domain/services/pwf_qibla_service.dart';

class PwfPrayerI18n {
  final Locale locale;

  const PwfPrayerI18n(this.locale);

  bool get isArabic => locale.languageCode.toLowerCase().startsWith('ar');

  String get pageTitle => isArabic ? 'مواقيت الصلاة' : 'Prayer Times';
  String get pageSubtitle => isArabic
      ? 'مواقيت الصلاة اليومية حسب مدن فلسطين مع اتجاه القبلة'
      : 'Daily prayer times for Palestine cities with Qibla direction';

  String get currentTimeTitle => isArabic ? 'الوقت الحالي' : 'Current Time';
  String get prayerTimesToday =>
      isArabic ? 'مواقيت الصلاة اليوم' : 'Today Prayer Times';

  String get cityLabel => isArabic ? 'اختر المدينة' : 'Select City';
  String get dateLabel => isArabic ? 'التاريخ' : 'Date';
  String get methodLabel => isArabic ? 'طريقة الاحتساب' : 'Calculation Method';

  String get updateTimes => isArabic ? 'تحديث المواقيت' : 'Update Times';
  String get autoLocation =>
      isArabic ? 'تحديد موقعي تلقائياً' : 'Auto-detect Location';
  String get enableNotifications =>
      isArabic ? 'تفعيل الإشعارات' : 'Enable Notifications';
  String get disableNotifications =>
      isArabic ? 'تعطيل الإشعارات' : 'Disable Notifications';
  String get monthlyCalendar =>
      isArabic ? 'التقويم الشهري' : 'Monthly Calendar';

  String get qiblaTitle => isArabic ? 'اتجاه القبلة' : 'Qibla Direction';
  String get findQibla => isArabic ? 'العثور على القبلة' : 'Find Qibla';

  String get qiblaHowTitle =>
      isArabic ? 'كيفية تحديد اتجاه القبلة' : 'How to determine Qibla';
  String get qiblaHowBody => isArabic
      ? 'اتجاه القبلة هو اتجاه الكعبة المشرفة في مكة المكرمة.'
      : 'Qibla is the direction of the Kaaba in Makkah.';

  String get tipsTitle => isArabic ? 'نصائح لتحديد القبلة' : 'Tips';
  List<String> get tips => isArabic
      ? const <String>[
          'استخدام تطبيقات تحديد القبلة',
          'يمكن استخدام البوصلة التقليدية',
          'الاعتماد على المعالم الجغرافية عند الحاجة',
        ]
      : const <String>[
          'Use Qibla direction apps',
          'Use a traditional compass',
          'Use landmarks when needed',
        ];

  String qiblaLabel(double deg) {
    final cardinal = PwfQiblaService.cardinalLabel(deg, isArabic: isArabic);
    return isArabic
        ? 'اتجاه القبلة: $cardinal (${deg.toStringAsFixed(0)}°)'
        : 'Qibla: $cardinal (${deg.toStringAsFixed(0)}°)';
  }

  String locationLine(String cityName) =>
      isArabic ? '$cityName - فلسطين' : '$cityName - Palestine';

  String methodName(PwfPrayerCalcMethod m) => isArabic ? m.nameAr : m.nameEn;

  String prayerName(PwfPrayerKey k) {
    if (isArabic) {
      switch (k) {
        case PwfPrayerKey.fajr:
          return 'الفجر';
        case PwfPrayerKey.sunrise:
          return 'الشروق';
        case PwfPrayerKey.dhuhr:
          return 'الظهر';
        case PwfPrayerKey.asr:
          return 'العصر';
        case PwfPrayerKey.maghrib:
          return 'المغرب';
        case PwfPrayerKey.isha:
          return 'العشاء';
      }
    } else {
      switch (k) {
        case PwfPrayerKey.fajr:
          return 'Fajr';
        case PwfPrayerKey.sunrise:
          return 'Sunrise';
        case PwfPrayerKey.dhuhr:
          return 'Dhuhr';
        case PwfPrayerKey.asr:
          return 'Asr';
        case PwfPrayerKey.maghrib:
          return 'Maghrib';
        case PwfPrayerKey.isha:
          return 'Isha';
      }
    }
  }

  String remainingToNext(int h, int m) => isArabic
      ? 'متبقي للصلاة التالية: ${h}س ${m}د'
      : 'Time to next: ${h}h ${m}m';

  String get toastUpdated =>
      isArabic ? 'تم تحديث مواقيت الصلاة' : 'Prayer times updated';
  String get toastAutoLocationFail =>
      isArabic ? 'تعذر تحديد الموقع' : 'Unable to detect location';
  String get toastAutoLocationOk =>
      isArabic ? 'تم تحديد أقرب مدينة تلقائياً' : 'Nearest city selected';
  String get toastNotificationsEnabled =>
      isArabic ? 'تم تفعيل الإشعارات' : 'Notifications enabled';
  String get toastNotificationsDisabled =>
      isArabic ? 'تم تعطيل الإشعارات' : 'Notifications disabled';

  String get calendarTitle => isArabic ? 'التقويم الشهري' : 'Monthly Calendar';
}

extension PwfPrayerI18nX on BuildContext {
  PwfPrayerI18n get pwfPrayerI18n =>
      PwfPrayerI18n(Localizations.localeOf(this));
}
