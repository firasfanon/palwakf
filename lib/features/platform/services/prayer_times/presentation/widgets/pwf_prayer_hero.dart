import 'package:flutter/material.dart';

import 'pwf_prayer_i18n.dart';

class PwfPrayerHero extends StatelessWidget {
  const PwfPrayerHero({super.key});

  static const String _bgUrl =
      'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1470&q=80';

  @override
  Widget build(BuildContext context) {
    final t = context.pwfPrayerI18n;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = w < 600 ? 300.0 : 400.0;

        return SizedBox(
          height: h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _bgUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 170),
                      Colors.black.withValues(alpha: 170),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.pageTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.pageSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 230),
                            fontSize: 16,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
