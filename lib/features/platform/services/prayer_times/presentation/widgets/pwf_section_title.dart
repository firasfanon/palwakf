import 'package:flutter/material.dart';

import '../../domain/models/pwf_prayer_models.dart';

class PwfSectionTitle extends StatelessWidget {
  final Widget? leadingIcon;
  final String title;
  final String? subtitle;

  const PwfSectionTitle({
    super.key,
    this.leadingIcon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              IconTheme(
                data: const IconThemeData(
                  color: PwfPrayerPalette.primaryBlue,
                  size: 22,
                ),
                child: leadingIcon!,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: PwfPrayerPalette.primaryBlue2,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: PwfPrayerPalette.gray.withValues(alpha: 230),
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
