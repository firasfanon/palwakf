import 'dart:convert';

/// Minimal model for prayer timings used by the HTML-exact Home section.
///
/// Stored in cache as a JSON string (see [toJsonString]/[fromJsonString]).
class PwfPrayerTimes {
  final String cityAr;
  final String cityEn;
  final String countryEn;
  final String dateIso; // yyyy-MM-dd (local)

  /// 24h format HH:mm
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  final String source;
  final int fetchedAtMs;

  const PwfPrayerTimes({
    required this.cityAr,
    required this.cityEn,
    required this.countryEn,
    required this.dateIso,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.source,
    required this.fetchedAtMs,
  });

  Map<String, dynamic> toJson() => {
    'cityAr': cityAr,
    'cityEn': cityEn,
    'countryEn': countryEn,
    'dateIso': dateIso,
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
    'source': source,
    'fetchedAtMs': fetchedAtMs,
  };

  static PwfPrayerTimes fromJson(Map<String, dynamic> json) {
    return PwfPrayerTimes(
      cityAr: (json['cityAr'] ?? '') as String,
      cityEn: (json['cityEn'] ?? '') as String,
      countryEn: (json['countryEn'] ?? '') as String,
      dateIso: (json['dateIso'] ?? '') as String,
      fajr: (json['fajr'] ?? '--:--') as String,
      sunrise: (json['sunrise'] ?? '--:--') as String,
      dhuhr: (json['dhuhr'] ?? '--:--') as String,
      asr: (json['asr'] ?? '--:--') as String,
      maghrib: (json['maghrib'] ?? '--:--') as String,
      isha: (json['isha'] ?? '--:--') as String,
      source: (json['source'] ?? 'AlAdhan') as String,
      fetchedAtMs: (json['fetchedAtMs'] ?? 0) as int,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static PwfPrayerTimes? fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>)
        return PwfPrayerTimes.fromJson(decoded);
      if (decoded is Map)
        return PwfPrayerTimes.fromJson(decoded.cast<String, dynamic>());
      return null;
    } catch (_) {
      return null;
    }
  }
}
