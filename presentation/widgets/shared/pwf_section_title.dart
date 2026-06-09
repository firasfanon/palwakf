import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/pwf_home_palette.dart';

class PwfSectionTitle extends StatelessWidget {
  const PwfSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.scheherazadeNew(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: PwfHomePalette.primary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 4,
          decoration: const BoxDecoration(
            color: PwfHomePalette.secondary,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: PwfHomePalette.gray,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
