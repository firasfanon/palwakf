import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pwf_ui_prefs_provider.dart';
import '../../theme/pwf_theme_tokens.dart';

/// Primary button in the new HTML identity.
///
/// Uses [PwfThemeTokens] and provides hover/pressed states on web.
class PwfPrimaryButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool dense;

  const PwfPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.dense = false,
  });

  @override
  ConsumerState<PwfPrimaryButton> createState() => _PwfPrimaryButtonState();
}

class _PwfPrimaryButtonState extends ConsumerState<PwfPrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider.select((s) => s.themeKey));
    final t = PwfThemeTokens.forKey(themeKey);

    final pad = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 12);

    final bg = _hover ? t.primaryButtonBgHover : t.primaryButtonBg;

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
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.pressed))
              return t.primaryButtonBgPressed;
            return bg;
          }),
          foregroundColor: MaterialStateProperty.all(t.primaryButtonFg),
          padding: MaterialStateProperty.all(pad),
          elevation: MaterialStateProperty.all(0),
          overlayColor: MaterialStateProperty.all(
            Colors.white.withValues(alpha: 0.08),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        child: child,
      ),
    );
  }
}
