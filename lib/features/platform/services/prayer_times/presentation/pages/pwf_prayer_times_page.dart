import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/pwf_http_client.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';

class PwfPrayerTimesPage extends StatefulWidget {
  const PwfPrayerTimesPage({
    super.key,
    this.embedInPublicShell = false,
    this.unitSlug = 'home',
  });

  final bool embedInPublicShell;
  final String unitSlug;

  @override
  State<PwfPrayerTimesPage> createState() => _PwfPrayerTimesPageState();
}

class _PwfPrayerTimesPageState extends State<PwfPrayerTimesPage> {
  final _http = createPwfHttpClient();

  static const _meccaLat = 21.4225;
  static const _meccaLng = 39.8262;

  final _cities = const <_City>[
    _City(
      key: 'heb',
      nameAr: 'الخليل',
      nameEn: 'Hebron',
      lat: 31.5326,
      lng: 35.0998,
      tz: 'Asia/Hebron',
    ),
    _City(
      key: 'jer',
      nameAr: 'القدس',
      nameEn: 'Jerusalem',
      lat: 31.7683,
      lng: 35.2137,
      tz: 'Asia/Jerusalem',
    ),
    _City(
      key: 'nbs',
      nameAr: 'نابلس',
      nameEn: 'Nablus',
      lat: 32.2211,
      lng: 35.2544,
      tz: 'Asia/Hebron',
    ),
    _City(
      key: 'ram',
      nameAr: 'رام الله',
      nameEn: 'Ramallah',
      lat: 31.9074,
      lng: 35.2053,
      tz: 'Asia/Hebron',
    ),
    _City(
      key: 'gza',
      nameAr: 'غزة',
      nameEn: 'Gaza',
      lat: 31.5017,
      lng: 34.4668,
      tz: 'Asia/Gaza',
    ),
    _City(
      key: 'jen',
      nameAr: 'جنين',
      nameEn: 'Jenin',
      lat: 32.4600,
      lng: 35.3000,
      tz: 'Asia/Hebron',
    ),
    _City(
      key: 'bth',
      nameAr: 'بيت لحم',
      nameEn: 'Bethlehem',
      lat: 31.7054,
      lng: 35.2024,
      tz: 'Asia/Hebron',
    ),
  ];

  final _methods = const <_Method>[
    _Method(
      code: 'MWL',
      nameAr: 'رابطة العالم الإسلامي',
      nameEn: 'Muslim World League',
      aladhanMethod: 3,
    ),
    _Method(
      code: 'EGYPT',
      nameAr: 'الهيئة المصرية العامة',
      nameEn: 'Egyptian General Authority',
      aladhanMethod: 5,
    ),
    _Method(
      code: 'UMM',
      nameAr: 'أم القرى (مكة)',
      nameEn: 'Umm Al-Qura (Makkah)',
      aladhanMethod: 4,
    ),
    _Method(
      code: 'KARACHI',
      nameAr: 'جامعة كراتشي',
      nameEn: 'University of Karachi',
      aladhanMethod: 1,
    ),
  ];

  _City? _city;
  _Method? _method;
  DateTime _day = DateTime.now();
  _DayTimes? _times;
  String? _hijri;
  bool _loading = false;
  String? _error;
  bool _usingCachedTimes = false;
  String? _resilienceNote;

  @override
  void initState() {
    super.initState();
    _city = _cities.first;
    _method = _methods.first;
    _fetch();
  }

  Future<void> _fetch({bool forceRefresh = false}) async {
    final city = _city;
    final method = _method;
    if (city == null || method == null) return;

    setState(() {
      _loading = true;
      _error = null;
      _resilienceNote = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKey(city, method, _day);
    final cached = _CachedDayTimes.fromJsonString(prefs.getString(cacheKey));

    if (!forceRefresh && _isFreshCache(cached)) {
      if (!mounted) return;
      setState(() {
        _times = cached!.times;
        _hijri = cached.hijri;
        _usingCachedTimes = true;
        _loading = false;
        _resilienceNote =
            'تم عرض مواقيت محفوظة محليًا لتقليل الاعتماد على الاتصال الخارجي.';
      });
      _debugResilience('prayer_times_page', 'fresh_cache', city.nameEn);
      return;
    }

    if (!forceRefresh && _isCircuitOpen(prefs, city, method, _day)) {
      if (!mounted) return;
      setState(() {
        _times = cached?.times;
        _hijri = cached?.hijri;
        _usingCachedTimes = cached != null;
        _loading = false;
        _error = cached == null
            ? 'تعذر الاتصال بمصدر المواقيت الخارجي مؤقتًا. حاول لاحقًا.'
            : null;
        _resilienceNote = cached == null
            ? null
            : 'تم إيقاف المحاولة الخارجية مؤقتًا بعد فشل سابق، وعرض آخر نسخة محفوظة.';
      });
      _debugResilience(
        'prayer_times_page',
        'circuit_open_cache_fallback',
        city.nameEn,
      );
      return;
    }

    try {
      final dateStr = _formatAladhanDate(_day);
      final url = Uri.https(
        'api.aladhan.com',
        '/v1/timings/$dateStr',
        <String, String>{
          'latitude': city.lat.toString(),
          'longitude': city.lng.toString(),
          'method': method.aladhanMethod.toString(),
          'school': '0', // 0 Shafi, 1 Hanafi (can be extended later)
          'timezonestring': city.tz,
        },
      ).toString();

      final body = await _http.get(url, timeout: const Duration(seconds: 8));
      final j = jsonDecode(body) as Map<String, dynamic>;
      final data = (j['data'] ?? const {}) as Map<String, dynamic>;
      final timings = (data['timings'] ?? const {}) as Map<String, dynamic>;

      final t = _DayTimes(
        fajr: _cleanTime(timings['Fajr']),
        sunrise: _cleanTime(timings['Sunrise']),
        dhuhr: _cleanTime(timings['Dhuhr']),
        asr: _cleanTime(timings['Asr']),
        maghrib: _cleanTime(timings['Maghrib']),
        isha: _cleanTime(timings['Isha']),
      );

      if (!_hasValidCoreTimes(t)) {
        throw const FormatException('Incomplete prayer timings');
      }

      final hijri =
          (((data['date'] ?? const {}) as Map<String, dynamic>)['hijri'] ??
                  const {})
              as Map<String, dynamic>;
      final hijriDate = (hijri['date'] ?? '').toString();

      final snapshot = _CachedDayTimes(
        times: t,
        hijri: hijriDate.isEmpty ? null : hijriDate,
        fetchedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setString(cacheKey, snapshot.toJsonString());
      await prefs.remove(_failureKey(city, method, _day));

      if (!mounted) return;
      setState(() {
        _times = t;
        _hijri = hijriDate.isEmpty ? null : hijriDate;
        _usingCachedTimes = false;
        _loading = false;
      });
      _debugResilience('prayer_times_page', 'live_success', city.nameEn);
    } catch (_) {
      await prefs.setString(
        _failureKey(city, method, _day),
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      if (!mounted) return;
      setState(() {
        _times = cached?.times;
        _hijri = cached?.hijri;
        _usingCachedTimes = cached != null;
        _error = cached == null
            ? 'تعذر الاتصال بمصدر المواقيت الخارجي مؤقتًا. حاول لاحقًا.'
            : null;
        _resilienceNote = cached == null
            ? null
            : 'تعذر تحديث المصدر الخارجي؛ تم عرض آخر نسخة محفوظة بدل إيقاف الصفحة.';
        _loading = false;
      });
      _debugResilience(
        'prayer_times_page',
        cached == null ? 'live_failed_no_cache' : 'live_failed_cache_fallback',
        city.nameEn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ar');

    final content = <Widget>[
      if (widget.embedInPublicShell)
        PwfInternalPublicPageIntro(
          specKey: 'prayer_times',
          unitSlug: widget.unitSlug,
          verticalPadding: 0,
        ),
      PwfInternalPublicPageBodySection(
        specKey: 'prayer_times',
        sectionKey: 'PwfPrayerTimesContent',
        verticalPadding: widget.embedInPublicShell ? 18 : 24,
        child: Container(
          color: const Color(0xFFF7F8FA),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              _headerCard(isAr),
              const SizedBox(height: 12),
              _controlsCard(isAr),
              const SizedBox(height: 12),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_error != null) _errorCard(_error!),
              if (_resilienceNote != null)
                _resilienceNoteCard(_resilienceNote!),
              if (!_loading && _error == null) ...[
                _timesCard(isAr),
                const SizedBox(height: 12),
                _qiblaCard(isAr),
                const SizedBox(height: 12),
                _noteCard(isAr),
              ],
            ],
          ),
        ),
      ),
    ];

    final embeddedBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: content,
    );

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: widget.embedInPublicShell
          ? embeddedBody
          : Scaffold(
              appBar: AppBar(
                title: Text(isAr ? 'مواقيت الصلاة' : 'Prayer Times'),
              ),
              body: ListView(padding: EdgeInsets.zero, children: content),
            ),
    );
  }

  Widget _headerCard(bool isAr) {
    final city = _city;
    final method = _method;
    final title = isAr ? 'اليوم' : 'Today';
    final dayStr =
        '${_day.year}-${_day.month.toString().padLeft(2, '0')}-${_day.day.toString().padLeft(2, '0')}';
    final sub = [
      if (city != null) (isAr ? city.nameAr : city.nameEn),
      if (method != null) (isAr ? method.nameAr : method.nameEn),
      if (_hijri != null) (isAr ? 'هجري: $_hijri' : 'Hijri: $_hijri'),
      if (_usingCachedTimes) (isAr ? 'نسخة محفوظة' : 'Cached copy'),
    ].join(' • ');

    return _card(
      child: Row(
        children: [
          const Icon(Icons.access_time),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dayStr${sub.isEmpty ? '' : '\n$sub'}',
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlsCard(bool isAr) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'الإعدادات' : 'Settings',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            runSpacing: 10,
            spacing: 12,
            children: [
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<_City>(
                  value: _city,
                  items: _cities
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(isAr ? c.nameAr : c.nameEn),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (v) {
                    setState(() => _city = v);
                    _fetch();
                  },
                  decoration: InputDecoration(
                    labelText: isAr ? 'المدينة' : 'City',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 340,
                child: DropdownButtonFormField<_Method>(
                  value: _method,
                  items: _methods
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(isAr ? m.nameAr : m.nameEn),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (v) {
                    setState(() => _method = v);
                    _fetch();
                  },
                  decoration: InputDecoration(
                    labelText: isAr ? 'طريقة الاحتساب' : 'Method',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.today),
                  label: Text(isAr ? 'تغيير التاريخ' : 'Change date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _day,
                      firstDate: DateTime(_day.year - 1),
                      lastDate: DateTime(_day.year + 1),
                    );
                    if (picked == null) return;
                    setState(() => _day = picked);
                    _fetch();
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(isAr ? 'تحديث' : 'Refresh'),
                  onPressed: () => _fetch(forceRefresh: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timesCard(bool isAr) {
    final t = _times;
    if (t == null) {
      return _card(child: Text(isAr ? 'لا توجد بيانات' : 'No data'));
    }

    Widget row(String label, String value, IconData icon) {
      return Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFeatures: [ui.FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'مواقيت اليوم' : 'Today Times',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          row(isAr ? 'الفجر' : 'Fajr', t.fajr, Icons.nightlight_round),
          const Divider(height: 16),
          row(isAr ? 'الشروق' : 'Sunrise', t.sunrise, Icons.wb_sunny_outlined),
          const Divider(height: 16),
          row(isAr ? 'الظهر' : 'Dhuhr', t.dhuhr, Icons.wb_sunny),
          const Divider(height: 16),
          row(isAr ? 'العصر' : 'Asr', t.asr, Icons.sunny_snowing),
          const Divider(height: 16),
          row(isAr ? 'المغرب' : 'Maghrib', t.maghrib, Icons.sunny_snowing),
          const Divider(height: 16),
          row(isAr ? 'العشاء' : 'Isha', t.isha, Icons.dark_mode),
        ],
      ),
    );
  }

  Widget _qiblaCard(bool isAr) {
    final city = _city;
    if (city == null) return const SizedBox.shrink();
    final bearing = _bearing(city.lat, city.lng, _meccaLat, _meccaLng);

    return _card(
      child: Row(
        children: [
          const Icon(Icons.explore),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'اتجاه القبلة: ${bearing.toStringAsFixed(1)}°'
                  : 'Qibla direction: ${bearing.toStringAsFixed(1)}°',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Transform.rotate(
            angle: bearing * math.pi / 180.0,
            child: const Icon(Icons.navigation, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _noteCard(bool isAr) {
    return _card(
      child: Text(
        isAr
            ? 'ملاحظة: هذه نسخة MVP تعتمد على مصدر حساب مواقيت خارجي لعرض مواقيت حقيقية فورًا. سنستبدلها لاحقًا بحساب سيادي داخل المنصة + تخزين يومي في قاعدة البيانات.'
            : 'Note: This MVP fetches computed prayer times from an external calculator to show real times immediately. Later we will replace it with a sovereign in-platform calculator + daily DB cache.',
        style: const TextStyle(height: 1.4),
      ),
    );
  }

  Widget _resilienceNoteCard(String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Row(
          children: [
            const Icon(Icons.cloud_done_outlined, color: Color(0xFF0D47A1)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                note,
                style: const TextStyle(
                  color: Color(0xFF0B3A63),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String err) {
    return _card(
      child: Text(
        err,
        style: const TextStyle(
          color: Color(0xFFB22222),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }

  static const int _cacheTtlHours = 6;
  static const int _circuitBreakerMinutes = 20;

  String _cacheKey(_City city, _Method method, DateTime day) {
    return 'pwf_prayer_page__${city.key}__${method.code}__${_formatIsoDate(day)}';
  }

  String _failureKey(_City city, _Method method, DateTime day) {
    return 'pwf_prayer_page__external_failure__${city.key}__${method.code}__${_formatIsoDate(day)}';
  }

  bool _isFreshCache(_CachedDayTimes? cached) {
    if (cached == null) return false;
    final ageMs = DateTime.now().millisecondsSinceEpoch - cached.fetchedAtMs;
    return ageMs >= 0 && ageMs < _cacheTtlHours * 60 * 60 * 1000;
  }

  bool _isCircuitOpen(
    SharedPreferences prefs,
    _City city,
    _Method method,
    DateTime day,
  ) {
    final raw = prefs.getString(_failureKey(city, method, day));
    final failedAtMs = int.tryParse(raw ?? '');
    if (failedAtMs == null || failedAtMs <= 0) return false;
    final ageMs = DateTime.now().millisecondsSinceEpoch - failedAtMs;
    return ageMs >= 0 && ageMs < _circuitBreakerMinutes * 60 * 1000;
  }

  String _formatIsoDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  bool _hasValidCoreTimes(_DayTimes t) {
    return _isTime(t.fajr) &&
        _isTime(t.dhuhr) &&
        _isTime(t.asr) &&
        _isTime(t.maghrib) &&
        _isTime(t.isha);
  }

  bool _isTime(String value) => RegExp(r'^\d{2}:\d{2}$').hasMatch(value);

  void _debugResilience(String operation, String outcome, String city) {
    assert(() {
      // ignore: avoid_print
      print(
        'PWF_EXTERNAL_SERVICE_RESILIENCE '
        'service=prayer_times operation=$operation outcome=$outcome city=$city',
      );
      return true;
    }());
  }

  String _formatAladhanDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
  }

  String _cleanTime(dynamic raw) {
    final s = (raw ?? '').toString().trim();
    // Example: "05:11 (EET)" -> "05:11"
    final m = RegExp(r'(\d{1,2}:\d{2})').firstMatch(s);
    if (m == null) return s;
    final t = m.group(1)!;
    return t.length == 4 ? '0$t' : t;
  }

  double _bearing(double lat1, double lon1, double lat2, double lon2) {
    // Great-circle initial bearing
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final deltaLambda = _degToRad(lon2 - lon1);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x =
        math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    var theta = math.atan2(y, x);
    var brng = (_radToDeg(theta) + 360.0) % 360.0;
    return brng;
  }

  double _degToRad(double d) => d * math.pi / 180.0;
  double _radToDeg(double r) => r * 180.0 / math.pi;
}

@immutable
class _CachedDayTimes {
  const _CachedDayTimes({
    required this.times,
    required this.hijri,
    required this.fetchedAtMs,
  });

  final _DayTimes times;
  final String? hijri;
  final int fetchedAtMs;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'times': times.toJson(),
    'hijri': hijri,
    'fetchedAtMs': fetchedAtMs,
  };

  String toJsonString() => jsonEncode(toJson());

  static _CachedDayTimes? fromJsonString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final timesRaw = decoded['times'];
      if (timesRaw is! Map) return null;
      return _CachedDayTimes(
        times: _DayTimes.fromJson(Map<String, dynamic>.from(timesRaw)),
        hijri: decoded['hijri']?.toString(),
        fetchedAtMs: (decoded['fetchedAtMs'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}

@immutable
class _City {
  const _City({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.tz,
  });

  final String key;
  final String nameAr;
  final String nameEn;
  final double lat;
  final double lng;
  final String tz;
}

@immutable
class _Method {
  const _Method({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.aladhanMethod,
  });

  final String code;
  final String nameAr;
  final String nameEn;
  final int aladhanMethod;
}

@immutable
class _DayTimes {
  const _DayTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'fajr': fajr,
    'sunrise': sunrise,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
  };

  static _DayTimes fromJson(Map<String, dynamic> json) {
    return _DayTimes(
      fajr: (json['fajr'] ?? '--:--').toString(),
      sunrise: (json['sunrise'] ?? '--:--').toString(),
      dhuhr: (json['dhuhr'] ?? '--:--').toString(),
      asr: (json['asr'] ?? '--:--').toString(),
      maghrib: (json['maghrib'] ?? '--:--').toString(),
      isha: (json['isha'] ?? '--:--').toString(),
    );
  }
}
