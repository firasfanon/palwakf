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
    final textStyle = GoogleFonts.cairo(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: PwfHomePalette.secondary,
      decoration: _hover ? TextDecoration.underline : TextDecoration.none,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bounded = constraints.hasBoundedWidth;
            final label = Text(
              widget.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            );
            final icon = widget.icon == null
                ? null
                : Icon(widget.icon, size: 14, color: PwfHomePalette.secondary);

            if (!bounded) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label,
                  if (icon != null) ...[const SizedBox(width: 6), icon],
                ],
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: label),
                if (icon != null) ...[const SizedBox(width: 6), icon],
              ],
            );
          },
        ),
      ),
    );
  }
}
