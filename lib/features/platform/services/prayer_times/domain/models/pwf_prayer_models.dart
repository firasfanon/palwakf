import 'package:flutter/material.dart';

enum PwfPrayerKey { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PwfPrayerKeyX on PwfPrayerKey {
  bool get isMainPrayer => this != PwfPrayerKey.sunrise;

  static const List<PwfPrayerKey> displayOrder = <PwfPrayerKey>[
    PwfPrayerKey.fajr,
    PwfPrayerKey.sunrise,
    PwfPrayerKey.dhuhr,
    PwfPrayerKey.asr,
    PwfPrayerKey.maghrib,
    PwfPrayerKey.isha,
  ];

  static const List<PwfPrayerKey> mainOrder = <PwfPrayerKey>[
    PwfPrayerKey.fajr,
    PwfPrayerKey.dhuhr,
    PwfPrayerKey.asr,
    PwfPrayerKey.maghrib,
    PwfPrayerKey.isha,
  ];

  static PwfPrayerKey? tryParse(String raw) {
    switch (raw) {
      case 'fajr':
        return PwfPrayerKey.fajr;
      case 'sunrise':
        return PwfPrayerKey.sunrise;
      case 'dhuhr':
        return PwfPrayerKey.dhuhr;
      case 'asr':
        return PwfPrayerKey.asr;
      case 'maghrib':
        return PwfPrayerKey.maghrib;
      case 'isha':
        return PwfPrayerKey.isha;
    }
    return null;
  }

  String get dbKey {
    switch (this) {
      case PwfPrayerKey.fajr:
        return 'fajr';
      case PwfPrayerKey.sunrise:
        return 'sunrise';
      case PwfPrayerKey.dhuhr:
        return 'dhuhr';
      case PwfPrayerKey.asr:
        return 'asr';
      case PwfPrayerKey.maghrib:
        return 'maghrib';
      case PwfPrayerKey.isha:
        return 'isha';
    }
  }
}

@immutable
class PwfPrayerCity {
  final String id; // uuid as string
  final String key; // slug
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  final String tz;
  final bool isActive;

  const PwfPrayerCity({
    required this.id,
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.tz,
    required this.isActive,
  });

  static PwfPrayerCity fromMap(Map<String, dynamic> m) {
    return PwfPrayerCity(
      id: (m['id'] ?? '').toString(),
      key: (m['key'] ?? '').toString(),
      nameAr: (m['name_ar'] ?? '').toString(),
      nameEn: (m['name_en'] ?? '').toString(),
      lat: (m['lat'] as num?)?.toDouble() ?? 0,
      lng: (m['lng'] as num?)?.toDouble() ?? 0,
      tz: (m['tz'] ?? 'Asia/Hebron').toString(),
      isActive: (m['is_active'] as bool?) ?? true,
    );
  }
}

@immutable
class PwfPrayerCalcMethod {
  final String code;
  final String nameAr;
  final String nameEn;
  final Map<String, dynamic> params;
  final bool isActive;

  const PwfPrayerCalcMethod({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.params,
    required this.isActive,
  });

  static PwfPrayerCalcMethod fromMap(Map<String, dynamic> m) {
    return PwfPrayerCalcMethod(
      code: (m['code'] ?? '').toString(),
      nameAr: (m['name_ar'] ?? '').toString(),
      nameEn: (m['name_en'] ?? '').toString(),
      params:
          (m['params'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      isActive: (m['is_active'] as bool?) ?? true,
    );
  }
}

@immutable
class PwfPrayerTimesDay {
  final DateTime day; // date only
  final Map<PwfPrayerKey, TimeOfDay> times;

  const PwfPrayerTimesDay({required this.day, required this.times});

  TimeOfDay timeOf(PwfPrayerKey key) =>
      times[key] ?? const TimeOfDay(hour: 0, minute: 0);

  static TimeOfDay _parseTime(dynamic raw) {
    // Supabase returns "HH:MM:SS" or "HH:MM:SS+00" sometimes; accept string.
    final s = (raw ?? '').toString();
    final parts = s.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  static PwfPrayerTimesDay fromMap({
    required DateTime day,
    required Map<String, dynamic> m,
  }) {
    return PwfPrayerTimesDay(
      day: DateTime(day.year, day.month, day.day),
      times: <PwfPrayerKey, TimeOfDay>{
        PwfPrayerKey.fajr: _parseTime(m['fajr']),
        PwfPrayerKey.sunrise: _parseTime(m['sunrise']),
        PwfPrayerKey.dhuhr: _parseTime(m['dhuhr']),
        PwfPrayerKey.asr: _parseTime(m['asr']),
        PwfPrayerKey.maghrib: _parseTime(m['maghrib']),
        PwfPrayerKey.isha: _parseTime(m['isha']),
      },
    );
  }
}

@immutable
class PwfUserPrayerSettings {
  final String userId;
  final String? cityId;
  final String? methodCode;
  final bool notificationsEnabled;
  final int remindBeforeMinutes;
  final String tz;

  const PwfUserPrayerSettings({
    required this.userId,
    required this.cityId,
    required this.methodCode,
    required this.notificationsEnabled,
    required this.remindBeforeMinutes,
    required this.tz,
  });

  static PwfUserPrayerSettings fromMap(Map<String, dynamic> m) {
    return PwfUserPrayerSettings(
      userId: (m['user_id'] ?? '').toString(),
      cityId: m['city_id']?.toString(),
      methodCode: m['method_code']?.toString(),
      notificationsEnabled: (m['notifications_enabled'] as bool?) ?? false,
      remindBeforeMinutes: (m['remind_before_minutes'] as num?)?.toInt() ?? 10,
      tz: (m['tz'] ?? 'Asia/Hebron').toString(),
    );
  }
}

class PwfPrayerPalette {
  // PalWakf identity: Blue/Gold + Royal Red
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color primaryBlue2 = Color(0xFF0B3A63);
  static const Color gold = Color(0xFFD4AF37);
  static const Color royalRed = Color(0xFFB22222);

  static const Color bg = Color(0xFFF5F7FA);
  static const Color card = Colors.white;
  static const Color text = Color(0xFF111827);
  static const Color gray = Color(0xFF6B7280);

  static const double radius = 12.0;

  static List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(
      blurRadius: 12,
      offset: const Offset(0, 4),
      color: Colors.black.withValues(alpha: 20),
    ),
  ];

  static List<BoxShadow> shadowHover = <BoxShadow>[
    BoxShadow(
      blurRadius: 20,
      offset: const Offset(0, 8),
      color: Colors.black.withValues(alpha: 28),
    ),
  ];
}

@immutable
class PwfGeoPoint {
  final double lat;
  final double lng;

  const PwfGeoPoint(this.lat, this.lng);
}
