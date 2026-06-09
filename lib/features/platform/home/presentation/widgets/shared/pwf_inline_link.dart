import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/pwf_home_palette.dart';

class PwfInlineLink extends StatefulWidget {
  const PwfInlineLink({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  State<PwfInlineLink> createState() => _PwfInlineLinkState();
}

class _PwfInlineLinkState extends State<PwfInlineLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PwfHomePalette.secondary,
                decoration: _hover
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: 6),
              Icon(widget.icon, size: 14, color: PwfHomePalette.secondary),
            ],
          ],
        ),
      ),
    );
  }
}
