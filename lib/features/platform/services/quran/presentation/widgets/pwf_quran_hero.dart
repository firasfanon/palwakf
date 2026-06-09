import 'package:flutter/material.dart';

class PwfQuranPalette {
  static const primary = Color(0xFF1A4D7C); // platform-ish blue
  static const gold = Color(0xFFD4AF37);
  static const accent = Color(0xFF2A6E3F);
  static const bg = Color(0xFFF5F7FA);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF1A1A1A);
  static const gray = Color(0xFF6C757D);
  static const royalRed = Color(0xFFB22222);
}

class PwfQuranTr {
  static String t(BuildContext context, String key) =>
      key; // fallback (no external l10n touch)
}

class PwfQuranKeys {
  static const heroTitle = 'quran.hero.title';
  static const heroSubtitle = 'quran.hero.subtitle';
}

class PwfQuranHero extends StatelessWidget {
  const PwfQuranHero({
    super.key,
    required this.height,
    required this.titleKey,
    required this.subtitleKey,
    this.backgroundImageUrl,
  });

  final double height;
  final String titleKey;
  final String subtitleKey;
  final String? backgroundImageUrl;

  @override
  Widget build(BuildContext context) {
    final url =
        backgroundImageUrl ??
        'https://images.unsplash.com/photo-1519735777090-ec97162dc266?auto=format&fit=crop&w=1470&q=80';

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              url,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: PwfQuranPalette.primary.withValues(alpha: 20),
                  ),
                );
              },
              errorBuilder: (_, __, ___) {
                return const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [PwfQuranPalette.primary, PwfQuranPalette.accent],
                    ),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 140),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        PwfQuranTr.t(context, titleKey),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 42,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Scheherazade New',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        PwfQuranTr.t(context, subtitleKey),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.white.withValues(alpha: 230),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
