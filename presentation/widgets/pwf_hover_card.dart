import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pwf_ui_prefs_provider.dart';
import '../theme/pwf_home_tokens.dart';
import '../theme/pwf_theme_tokens.dart';

/// A lightweight hoverable card to mimic the HTML hover effects on web.
///
/// Keeps the effect local to the new home UI and does not touch global theming.
class PwfHoverCard extends ConsumerStatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Optional overrides (rare). Defaults come from [PwfThemeTokens].
  final Color? backgroundColor;
  final Color? borderColor;

  const PwfHoverCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  ConsumerState<PwfHoverCard> createState() => _PwfHoverCardState();
}

class _PwfHoverCardState extends ConsumerState<PwfHoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final themeKey = ref.watch(pwfUiPrefsProvider.select((s) => s.themeKey));
    final t = PwfThemeTokens.forKey(themeKey);

    final bg = widget.backgroundColor ?? t.cardBg;
    final border = widget.borderColor ?? t.cardBorder;

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PwfHomeTokens.radius),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: (t.cardShadow.isNotEmpty
                ? t.cardShadow.first.color
                : Colors.black.withValues(alpha: 0.12)),
            blurRadius: _hover ? 22 : 14,
            spreadRadius: 0,
            offset: Offset(0, _hover ? 12 : 8),
          ),
        ],
      ),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: widget.onTap == null
          ? body
          : InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(PwfHomeTokens.radius),
              child: body,
            ),
    );
  }
}
