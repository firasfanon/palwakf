import 'package:flutter/material.dart';

import 'pwf_max_width.dart';
import 'pwf_zakat_theme.dart';

class PwfZakatHero extends StatelessWidget {
  const PwfZakatHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 400,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final double height;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stack) =>
                Container(color: PwfZakatPalette.primary2),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(color: PwfZakatPalette.primary2);
            },
          ),
          Container(color: Colors.black.withAlpha(160)),
          Center(
            child: PwfMaxWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: PwfZakatTextStyles.heroTitle(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        subtitle,
                        style: PwfZakatTextStyles.heroSubtitle(context),
                        textAlign: TextAlign.center,
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
  }
}
