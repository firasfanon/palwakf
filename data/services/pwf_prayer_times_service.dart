import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pwf_prayer_times.dart';

/// Fetches prayer times from AlAdhan public API and caches daily results locally.
///
/// Resilience contract:
/// - cache-first for fresh daily values;
/// - coordinate endpoint first, city endpoint as secondary fallback;
/// - stale latest-cache fallback when the external service fails;
/// - short circuit breaker after failures to avoid repeated browser console noise;
/// - no production SQL, no platform-navigation coupling, and no sovereign data mutation.
class PwfPrayerTimesService {
  static const _baseHost = 'api.aladhan.com';
  static const _cityPath = '/v1/timingsByCity';
  static const _timingsPath = '/v1/timings';

  /// AlAdhan method id (3 = Muslim World League) — widely used.
  static const int calculationMethod = 3;

  /// Cache TTL (hours). Even if the date is the same, we refresh after TTL
  /// when forced by UI or provider refresh.
  static const int cacheTtlHours = 6;

  /// External service timeout. Keep short because this is a public homepage
  /// helper, not a blocking sovereign workflow.
  static const int externalTimeoutSeconds = 8;

  /// Browser-side failure suppression window. This prevents repeated failed
  /// external requests from polluting Console on every public route rebuild.
  static const int externalCircuitBreakerMinutes = 20;

  /// Default remains live-enabled. It can be disabled for UAT/offline runs with:
  /// --dart-define=PWF_ENABLE_PRAYER_EXTERNAL_LIVE=false
  static const bool externalLiveEnabled = bool.fromEnvironment(
    'PWF_ENABLE_PRAYER_EXTERNAL_LIVE',
    defaultValue: true,
  );

  const PwfPrayerTimesService();

  Future<PwfPrayerTimes?> getToday({
    required String cityAr,
    bool forceRefresh = false,
  }) async {
    final mapping = _resolveCity(cityAr);
    final now = DateTime.now();
    final dateIso = _dateIso(now);

    final cacheKey = _cacheKey(mapping.cityEn, mapping.countryEn, dateIso);
    final prefs = await SharedPreferences.getInstance();

    final cached = PwfPrayerTimes.fromJsonString(prefs.getString(cacheKey));
    final latestCached = _readLatestCached(prefs, mapping);

    if (!forceRefresh && _isFresh(now, cached)) {
      _debugResilience(
        operation: 'prayer_times_home_widget',
        outcome: 'fresh_cache',
        city: mapping.cityEn,
      );
      return cached;
    }

    if (!externalLiveEnabled) {
      _debugResilience(
        operation: 'prayer_times_home_widget',
        outcome: 'external_live_disabled_cache_fallback',
        city: mapping.cityEn,
      );
      return cached ?? latestCached;
    }

    if (!forceRefresh && _isCircuitOpen(prefs, mapping, now)) {
      _debugResilience(
        operation: 'prayer_times_home_widget',
        outcome: 'circuit_open_cache_fallback',
        city: mapping.cityEn,
      );
      return cached ?? latestCached;
    }

    try {
      final model = await _fetchLive(
        cityAr: cityAr,
        mapping: mapping,
        date: now,
        dateIso: dateIso,
      );

      await prefs.setString(cacheKey, model.toJsonString());
      await prefs.setString(
        _latestPointerKey(mapping.cityEn, mapping.countryEn),
        cacheKey,
      );
      await prefs.remove(_failureKey(mapping));

      _debugResilience(
        operation: 'prayer_times_home_widget',
        outcome: 'live_success',
        city: mapping.cityEn,
      );
      return model;
    } catch (e) {
      await prefs.setString(
        _failureKey(mapping),
        now.millisecondsSinceEpoch.toString(),
      );

      final fallback = cached ?? latestCached;
      _debugResilience(
        operation: 'prayer_times_home_widget',
        outcome: fallback == null
            ? 'live_failed_no_cache'
            : 'live_failed_cache_fallback',
        city: mapping.cityEn,
      );
      return fallback;
    }
  }

  Future<PwfPrayerTimes> _fetchLive({
    required String cityAr,
    required _CityMapping mapping,
    required DateTime date,
    required String dateIso,
  }) async {
    final endpoints = <Uri>[_coordinatesUri(mapping, date), _cityUri(mapping)];

    Object? lastError;
    for (final uri in endpoints) {
      try {
        final res = await http
            .get(uri)
            .timeout(const Duration(seconds: externalTimeoutSeconds));
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw StateError('Prayer external HTTP ${res.statusCode}');
        }
        return _parseAladhanResponse(
          body: res.body,
          cityAr: cityAr,
          mapping: mapping,
          dateIso: dateIso,
          fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
        );
      } catch (e) {
        lastError = e;
      }
    }

    throw StateError(
      'Prayer external service unavailable: ${lastError.runtimeType}',
    );
  }

  static PwfPrayerTimes _parseAladhanResponse({
    required String body,
    required String cityAr,
    required _CityMapping mapping,
    required String dateIso,
    required int fetchedAtMs,
  }) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const FormatException('Prayer external response is not an object');
    }

    final data = decoded['data'];
    if (data is! Map) {
      throw const FormatException('Prayer external response missing data');
    }

    final timings = data['timings'];
    if (timings is! Map) {
      throw const FormatException('Prayer external response missing timings');
    }

    String readTiming(String key) => _cleanTime(timings[key]?.toString() ?? '');

    final model = PwfPrayerTimes(
      cityAr: cityAr,
      cityEn: mapping.cityEn,
      countryEn: mapping.countryEn,
      dateIso: dateIso,
      fajr: readTiming('Fajr'),
      sunrise: readTiming('Sunrise'),
      dhuhr: readTiming('Dhuhr'),
      asr: readTiming('Asr'),
      maghrib: readTiming('Maghrib'),
      isha: readTiming('Isha'),
      source: 'AlAdhan live',
      fetchedAtMs: fetchedAtMs,
    );

    if (!_hasValidCoreTimes(model)) {
      throw const FormatException(
        'Prayer external response has incomplete timings',
      );
    }

    return model;
  }

  static PwfPrayerTimes? _readLatestCached(
    SharedPreferences prefs,
    _CityMapping mapping,
  ) {
    final latestKey = prefs.getString(
      _latestPointerKey(mapping.cityEn, mapping.countryEn),
    );
    if (latestKey == null || latestKey.trim().isEmpty) return null;
    return PwfPrayerTimes.fromJsonString(prefs.getString(latestKey));
  }

  static bool _isFresh(DateTime now, PwfPrayerTimes? cached) {
    if (cached == null) return false;
    final ageMs = now.millisecondsSinceEpoch - cached.fetchedAtMs;
    final maxAgeMs = cacheTtlHours * 60 * 60 * 1000;
    return ageMs >= 0 && ageMs < maxAgeMs;
  }

  static bool _isCircuitOpen(
    SharedPreferences prefs,
    _CityMapping mapping,
    DateTime now,
  ) {
    final raw = prefs.getString(_failureKey(mapping));
    final failedAtMs = int.tryParse(raw ?? '');
    if (failedAtMs == null || failedAtMs <= 0) return false;
    final ageMs = now.millisecondsSinceEpoch - failedAtMs;
    final maxAgeMs = externalCircuitBreakerMinutes * 60 * 1000;
    return ageMs >= 0 && ageMs < maxAgeMs;
  }

  static Uri _coordinatesUri(_CityMapping mapping, DateTime date) {
    return Uri.https(_baseHost, '$_timingsPath/${_aladhanDate(date)}', {
      'latitude': mapping.lat.toString(),
      'longitude': mapping.lng.toString(),
      'method': calculationMethod.toString(),
      'school': '0',
      'timezonestring': mapping.tz,
    });
  }

  static Uri _cityUri(_CityMapping mapping) {
    return Uri.https(_baseHost, _cityPath, {
      'city': mapping.cityEn,
      'country': mapping.countryEn,
      'method': calculationMethod.toString(),
      'school': '0',
      'timezonestring': mapping.tz,
    });
  }

  static _CityMapping _resolveCity(String cityAr) {
    const map = <String, _CityMapping>{
      'القدس': _CityMapping(
        'Jerusalem',
        'Palestine',
        31.7683,
        35.2137,
        'Asia/Jerusalem',
      ),
      'رام الله': _CityMapping(
        'Ramallah',
        'Palestine',
        31.9074,
        35.2053,
        'Asia/Hebron',
      ),
      'الخليل': _CityMapping(
        'Hebron',
        'Palestine',
        31.5326,
        35.0998,
        'Asia/Hebron',
      ),
      'نابلس': _CityMapping(
        'Nablus',
        'Palestine',
        32.2211,
        35.2544,
        'Asia/Hebron',
      ),
      'بيت لحم': _CityMapping(
        'Bethlehem',
        'Palestine',
        31.7054,
        35.2024,
        'Asia/Hebron',
      ),
      'جنين': _CityMapping(
        'Jenin',
        'Palestine',
        32.4600,
        35.3000,
        'Asia/Hebron',
      ),
      'طولكرم': _CityMapping(
        'Tulkarm',
        'Palestine',
        32.3104,
        35.0286,
        'Asia/Hebron',
      ),
      'قلقيلية': _CityMapping(
        'Qalqilya',
        'Palestine',
        32.1965,
        34.9688,
        'Asia/Hebron',
      ),
      'سلفيت': _CityMapping(
        'Salfit',
        'Palestine',
        32.0837,
        35.1808,
        'Asia/Hebron',
      ),
      'طوباس': _CityMapping(
        'Tubas',
        'Palestine',
        32.3209,
        35.3699,
        'Asia/Hebron',
      ),
      'أريحا': _CityMapping(
        'Jericho',
        'Palestine',
        31.8556,
        35.4597,
        'Asia/Hebron',
      ),
      'غزة': _CityMapping('Gaza', 'Palestine', 31.5017, 34.4668, 'Asia/Gaza'),
    };

    final exact = map[cityAr.trim()];
    if (exact != null) return exact;
    for (final e in map.entries) {
      if (cityAr.contains(e.key)) return e.value;
    }
    return const _CityMapping(
      'Jerusalem',
      'Palestine',
      31.7683,
      35.2137,
      'Asia/Jerusalem',
    );
  }

  static String _dateIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String _aladhanDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString().padLeft(4, '0');
    return '$day-$month-$year';
  }

  static String _cacheKey(String cityEn, String countryEn, String dateIso) =>
      'pwf_prayer_times__${cityEn.toLowerCase()}__${countryEn.toLowerCase()}__$dateIso';

  static String _latestPointerKey(String cityEn, String countryEn) =>
      'pwf_prayer_times__latest__${cityEn.toLowerCase()}__${countryEn.toLowerCase()}';

  static String _failureKey(_CityMapping mapping) =>
      'pwf_prayer_times__external_failure__${mapping.cityEn.toLowerCase()}__${mapping.countryEn.toLowerCase()}';

  static String _cleanTime(String raw) {
    final match = RegExp(r'(\d{1,2}:\d{2})').firstMatch(raw);
    final time = match?.group(1) ?? '--:--';
    final parts = time.split(':');
    if (parts.length != 2) return '--:--';
    final h = parts[0].padLeft(2, '0');
    final min = parts[1].padLeft(2, '0');
    return '$h:$min';
  }

  static bool _hasValidCoreTimes(PwfPrayerTimes model) {
    return _isTime(model.fajr) &&
        _isTime(model.dhuhr) &&
        _isTime(model.asr) &&
        _isTime(model.maghrib) &&
        _isTime(model.isha);
  }

  static bool _isTime(String value) {
    return RegExp(r'^\d{2}:\d{2}$').hasMatch(value);
  }

  static void _debugResilience({
    required String operation,
    required String outcome,
    required String city,
  }) {
    assert(() {
      // ignore: avoid_print
      print(
        'PWF_EXTERNAL_SERVICE_RESILIENCE '
        'service=prayer_times operation=$operation outcome=$outcome city=$city',
      );
      return true;
    }());
  }
}

class _CityMapping {
  final String cityEn;
  final String countryEn;
  final double lat;
  final double lng;
  final String tz;

  const _CityMapping(this.cityEn, this.countryEn, this.lat, this.lng, this.tz);
}
