import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/pwf_home_palette.dart';
import '../../theme/pwf_theme_tokens.dart';
import '../../providers/pwf_ui_prefs_provider.dart';
// Intentionally no maxWidth container here: Prayer Times should span full page width.
import '../../providers/pwf_prayer_times_provider.dart';

/// HTML-exact: Prayer times widget (Jerusalem by default), DB independent.
///
/// Requirements:
/// - Same visual structure as the provided HTML.
/// - Real API (AlAdhan) + caching (SharedPreferences).
/// - No additional visual controls.
class PwfPrayerTimesWidget extends ConsumerStatefulWidget {
  const PwfPrayerTimesWidget({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  ConsumerState<PwfPrayerTimesWidget> createState() =>
      _PwfPrayerTimesWidgetState();
}

class _PwfPrayerTimesWidgetState extends ConsumerState<PwfPrayerTimesWidget> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider).themeKey;
    final t = PwfThemeTokens.forKey(themeKey);
    final cityAr = _resolveCityAr(widget.unitSlug);
    final async = ref.watch(pwfPrayerTimesProvider(cityAr));

    final data = async.maybeWhen(data: (v) => v, orElse: () => null);

    final times = _PrayerTimesViewModel.from(data);
    final active = times.activePrayerKey(_now);

    // Full-width section: stretch across the viewport (with HTML-like side padding).
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w >= 768 ? 20.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 40),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: t.prayerGradient,
            ),
            borderRadius: PwfHomeRadii.br8,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مواقيت الصلاة',
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: t.secondary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'مدينة ${times.cityAr}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  int count = 6;
                  if (w < 520)
                    count = 2;
                  else if (w < 860)
                    count = 3;
                  else if (w < 1100)
                    count = 4;

                  final items = <_PrayerItemData>[
                    _PrayerItemData('fajr', 'الفجر', times.fajr),
                    _PrayerItemData('sunrise', 'الشروق', times.sunrise),
                    _PrayerItemData('dhuhr', 'الظهر', times.dhuhr),
                    _PrayerItemData('asr', 'العصر', times.asr),
                    _PrayerItemData('maghrib', 'المغرب', times.maghrib),
                    _PrayerItemData('isha', 'العشاء', times.isha),
                  ];

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 2.9,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final isActive = it.key == active;
                      return _PrayerItemCard(
                        label: it.label,
                        time: it.time,
                        active: isActive,
                      );
                    },
                  );
                },
              ),
              if (async.hasError) ...[
                const SizedBox(height: 10),
                Text(
                  'تعذر تحديث المواقيت — سيتم عرض آخر القيم المتاحة.',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerItemData {
  final String key;
  final String label;
  final String time;
  const _PrayerItemData(this.key, this.label, this.time);
}

class _PrayerItemCard extends StatelessWidget {
  const _PrayerItemCard({
    required this.label,
    required this.time,
    required this.active,
  });

  final String label;
  final String time;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: active
            ? const Color.fromRGBO(193, 154, 80, 0.30)
            : Colors.white.withValues(alpha: 0.10),
        borderRadius: PwfHomeRadii.br8,
        border: active
            ? Border.all(color: PwfHomePalette.secondary, width: 2)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            time,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimesViewModel {
  final String cityAr;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const _PrayerTimesViewModel({
    required this.cityAr,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  static _PrayerTimesViewModel from(dynamic model) {
    // If API not ready yet, keep the exact HTML fallback values.
    if (model == null) {
      return const _PrayerTimesViewModel(
        cityAr: 'القدس',
        fajr: '4:15 ص',
        sunrise: '5:45 ص',
        dhuhr: '12:30 م',
        asr: '3:45 م',
        maghrib: '6:15 م',
        isha: '7:45 م',
      );
    }

    // Model is PwfPrayerTimes.
    final m = model as dynamic;
    return _PrayerTimesViewModel(
      cityAr: m.cityAr as String,
      fajr: _fmtAr(m.fajr as String),
      sunrise: _fmtAr(m.sunrise as String),
      dhuhr: _fmtAr(m.dhuhr as String),
      asr: _fmtAr(m.asr as String),
      maghrib: _fmtAr(m.maghrib as String),
      isha: _fmtAr(m.isha as String),
    );
  }

  String activePrayerKey(DateTime now) {
    final currentMinutes = now.hour * 60 + now.minute;

    final schedule = <String, int>{
      'fajr': _toMinutes24(fajr),
      'sunrise': _toMinutes24(sunrise),
      'dhuhr': _toMinutes24(dhuhr),
      'asr': _toMinutes24(asr),
      'maghrib': _toMinutes24(maghrib),
      'isha': _toMinutes24(isha),
    };

    // HTML behavior: find last prayer time <= now.
    String active = 'fajr';
    for (final e in schedule.entries) {
      if (e.value <= currentMinutes) active = e.key;
    }
    return active;
  }
}

String _resolveCityAr(String unitSlug) {
  const map = <String, String>{
    'home': 'القدس',
    'jer': 'القدس',
    'bth': 'بيت لحم',
    'rml': 'رام الله',
    'hbr': 'الخليل',
    'nbs': 'نابلس',
    'jen': 'جنين',
    'tkr': 'طولكرم',
    'qly': 'قلقيلية',
    'slt': 'سلفيت',
    'tub': 'طوباس',
    'jericho': 'أريحا',
    'gza': 'غزة',
  };
  return map[unitSlug] ?? 'القدس';
}

String _fmtAr(String hhmm24) {
  final parts = hhmm24.split(':');
  if (parts.length != 2) return hhmm24;
  int h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1].padLeft(2, '0');
  final isPm = h >= 12;
  int h12 = h % 12;
  if (h12 == 0) h12 = 12;
  final suffix = isPm ? 'م' : 'ص';
  return '$h12:$m $suffix';
}

int _toMinutes24(String display) {
  // Accept both: "HH:mm" and "h:mm ص/م".
  final raw = display.trim();
  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
  if (match == null) return 0;
  final h = int.tryParse(match.group(1)!) ?? 0;
  final m = int.tryParse(match.group(2)!) ?? 0;
  final isPm = raw.contains('م');
  final isAm = raw.contains('ص');

  int hour = h;
  if (isPm && h < 12) hour = h + 12;
  if (isAm && h == 12) hour = 0;
  return hour * 60 + m;
}
