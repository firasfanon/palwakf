import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';

/// A small pill/tag used inside cards (categories, status chips).
///
/// Styled by [PwfThemeTokens] to respond to (islamic/light/dark) without...
class PwfChipTag extends ConsumerStatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const PwfChipTag({super.key, required this.label, this.icon, this.onTap});

  @override
  ConsumerState<PwfChipTag> createState() => _PwfChipTagState();
}

class _PwfChipTagState extends ConsumerState<PwfChipTag> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider.select((s) => s.themeKey));
    final t = PwfThemeTokens.forKey(themeKey);

    final bg = _hover ? t.chipHoverBg : t.chipBg;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 14, color: t.chipFg),
          const SizedBox(width: 6),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: t.chipFg,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: t.chipBorder),
          ),
          child: content,
        ),
      ),
    );
  }
}
