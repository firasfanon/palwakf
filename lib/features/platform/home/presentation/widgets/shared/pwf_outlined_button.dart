import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';

/// Outlined button styled by [PwfThemeTokens].
///
/// Used for secondary actions (e.g., closing modals) to keep the HTML identity.
class PwfOutlinedButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool dense;

  const PwfOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.dense = false,
  });

  @override
  ConsumerState<PwfOutlinedButton> createState() => _PwfOutlinedButtonState();
}

class _PwfOutlinedButtonState extends ConsumerState<PwfOutlinedButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider.select((s) => s.themeKey));
    final t = PwfThemeTokens.forKey(themeKey);

    final pad = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 12);

    final bg = _hover ? t.outlinedHoverBg : Colors.transparent;

    final child = widget.icon == null
        ? Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          );

    return MouseRegion(
      cursor: widget.onPressed == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: OutlinedButton(
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          padding: pad,
          backgroundColor: bg,
          foregroundColor: t.outlinedFg,
          side: BorderSide(color: t.outlinedBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}
