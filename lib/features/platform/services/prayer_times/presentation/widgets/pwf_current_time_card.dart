import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/pwf_prayer_models.dart';
import '../../domain/services/pwf_hijri_converter.dart';
import 'pwf_prayer_i18n.dart';

class PwfCurrentTimeCard extends StatelessWidget {
  final DateTime now;

  const PwfCurrentTimeCard({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    final t = context.pwfPrayerI18n;
    final locale = Localizations.localeOf(context).toLanguageTag();

    final timeStr = DateFormat.Hms(locale).format(now);
    final gregStr = DateFormat.yMMMMEEEEd(locale).format(now);

    final hijri = PwfHijriConverter.fromGregorian(now);
    final hijriMonth = _hijriMonthName(hijri.month, isArabic: t.isArabic);
    final hijriStr = t.isArabic
        ? '${hijri.day} $hijriMonth ${hijri.year} هـ'
        : '${hijri.day} $hijriMonth ${hijri.year} AH';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PwfPrayerPalette.primaryBlue, PwfPrayerPalette.primaryBlue2],
        ),
        boxShadow: PwfPrayerPalette.shadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                color: PwfPrayerPalette.gold.withValues(alpha: 240),
              ),
              const SizedBox(width: 10),
              Text(
                hijriStr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 235),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            timeStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gregStr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 235),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _hijriMonthName(int m, {required bool isArabic}) {
    const ar = <String>[
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
    const en = <String>[
      'Muharram',
      'Safar',
      'Rabi I',
      'Rabi II',
      'Jumada I',
      'Jumada II',
      'Rajab',
      'Shaaban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qadah',
      'Dhu al-Hijjah',
    ];
    if (m < 1 || m > 12) return '—';
    return isArabic ? ar[m - 1] : en[m - 1];
  }
}
