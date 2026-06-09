import 'package:flutter/material.dart';

import '../../domain/models/pwf_prayer_models.dart';
import 'pwf_prayer_i18n.dart';

class PwfQiblaSection extends StatefulWidget {
  final double bearingDeg;

  const PwfQiblaSection({super.key, required this.bearingDeg});

  @override
  State<PwfQiblaSection> createState() => _PwfQiblaSectionState();
}

class _PwfQiblaSectionState extends State<PwfQiblaSection> {
  double _shownDeg = 45; // بداية مشابهة للـ HTML

  @override
  Widget build(BuildContext context) {
    final t = context.pwfPrayerI18n;

    return Container(
      decoration: BoxDecoration(
        color: PwfPrayerPalette.card,
        borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
        boxShadow: PwfPrayerPalette.shadow,
      ),
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final isNarrow = w < 900;

          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: isNarrow ? double.infinity : (w - 24) / 2,
                child: _InfoBlock(),
              ),
              SizedBox(
                width: isNarrow ? double.infinity : (w - 24) / 2,
                child: Column(
                  children: [
                    _Compass(deg: _shownDeg),
                    const SizedBox(height: 10),
                    Text(
                      t.qiblaLabel(_shownDeg),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: PwfPrayerPalette.primaryBlue2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _shownDeg = widget.bearingDeg);
                      },
                      icon: const Icon(Icons.explore, size: 18),
                      label: Text(t.findQibla),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PwfPrayerPalette.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            PwfPrayerPalette.radius,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.pwfPrayerI18n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.qiblaHowTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: PwfPrayerPalette.primaryBlue2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t.qiblaHowBody,
          style: const TextStyle(height: 1.8, color: PwfPrayerPalette.text),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PwfPrayerPalette.primaryBlue.withValues(alpha: 12),
            borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.tipsTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: PwfPrayerPalette.primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              ...t.tips.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: PwfPrayerPalette.primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e, style: const TextStyle(height: 1.6)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Compass extends StatelessWidget {
  final double deg;

  const _Compass({required this.deg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width < 600 ? 160.0 : 200.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: PwfPrayerPalette.primaryBlue2,
                width: 3,
              ),
            ),
          ),
          AnimatedRotation(
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            turns: deg / 360.0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 4,
                height: size * 0.42,
                decoration: BoxDecoration(
                  color: PwfPrayerPalette.gold,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: PwfPrayerPalette.royalRed,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
