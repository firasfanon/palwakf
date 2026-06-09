import 'package:flutter/material.dart';

import '../../domain/models/pwf_prayer_models.dart';
import 'pwf_prayer_i18n.dart';

class PwfPrayerTimesGrid extends StatelessWidget {
  final PwfPrayerTimesDay day;
  final DateTime now;

  const PwfPrayerTimesGrid({super.key, required this.day, required this.now});

  @override
  Widget build(BuildContext context) {
    final t = context.pwfPrayerI18n;

    final nowMin = (now.hour * 60) + now.minute;
    final active = _activePrayer(nowMin, day);
    final remaining = _remainingToNext(nowMin, day, active);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final count = w >= 1100 ? 6 : (w >= 800 ? 3 : (w >= 600 ? 2 : 1));

        return GridView.builder(
          itemCount: PwfPrayerKeyX.displayOrder.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: count >= 3 ? 1.25 : 1.15,
          ),
          itemBuilder: (context, idx) {
            final k = PwfPrayerKeyX.displayOrder[idx];
            final isActive = (k == active);
            final tod = day.timeOf(k);
            final time = _fmtTime(tod);

            return _PrayerCard(
              name: t.prayerName(k),
              time: time,
              icon: _iconFor(k),
              isActive: isActive,
              remainingText: isActive && remaining != null
                  ? t.remainingToNext(remaining.$1, remaining.$2)
                  : null,
            );
          },
        );
      },
    );
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  PwfPrayerKey _activePrayer(int nowMin, PwfPrayerTimesDay day) {
    var current = PwfPrayerKey.fajr;

    final times = <PwfPrayerKey, int>{
      for (final k in PwfPrayerKeyX.mainOrder) k: _toMin(day.timeOf(k)),
    };

    for (final k in PwfPrayerKeyX.mainOrder) {
      if (nowMin >= (times[k] ?? 0)) current = k;
    }

    return current;
  }

  (int, int)? _remainingToNext(
    int nowMin,
    PwfPrayerTimesDay day,
    PwfPrayerKey active,
  ) {
    final idx = PwfPrayerKeyX.mainOrder.indexOf(active);
    if (idx < 0 || idx + 1 >= PwfPrayerKeyX.mainOrder.length) return null;

    final next = PwfPrayerKeyX.mainOrder[idx + 1];
    final nextMin = _toMin(day.timeOf(next));
    final diff = nextMin - nowMin;
    if (diff <= 0) return null;

    final h = diff ~/ 60;
    final m = diff % 60;
    return (h, m);
  }

  int _toMin(TimeOfDay t) => (t.hour * 60) + t.minute;

  IconData _iconFor(PwfPrayerKey k) {
    switch (k) {
      case PwfPrayerKey.fajr:
        return Icons.nightlight_round;
      case PwfPrayerKey.sunrise:
        return Icons.wb_sunny;
      case PwfPrayerKey.dhuhr:
        return Icons.wb_sunny_outlined;
      case PwfPrayerKey.asr:
        return Icons.wb_twilight;
      case PwfPrayerKey.maghrib:
        return Icons.nightlight;
      case PwfPrayerKey.isha:
        return Icons.dark_mode;
    }
  }
}

class _PrayerCard extends StatefulWidget {
  final String name;
  final String time;
  final IconData icon;
  final bool isActive;
  final String? remainingText;

  const _PrayerCard({
    required this.name,
    required this.time,
    required this.icon,
    required this.isActive,
    required this.remainingText,
  });

  @override
  State<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<_PrayerCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final baseBorder = widget.isActive
        ? PwfPrayerPalette.gold
        : PwfPrayerPalette.primaryBlue.withValues(alpha: 220);
    final bg = widget.isActive
        ? PwfPrayerPalette.primaryBlue.withValues(alpha: 20)
        : PwfPrayerPalette.card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
          border: Border(top: BorderSide(color: baseBorder, width: 4)),
          boxShadow: _hover
              ? PwfPrayerPalette.shadowHover
              : PwfPrayerPalette.shadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 36, color: PwfPrayerPalette.primaryBlue),
            const SizedBox(height: 10),
            Text(
              widget.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: PwfPrayerPalette.primaryBlue2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.time,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: PwfPrayerPalette.primaryBlue,
              ),
            ),
            if (widget.remainingText != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.remainingText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: PwfPrayerPalette.gray.withValues(alpha: 230),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
