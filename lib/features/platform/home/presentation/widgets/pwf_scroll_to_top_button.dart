import 'package:flutter/material.dart';

class PwfScrollToTopButton extends StatelessWidget {
  const PwfScrollToTopButton({
    super.key,
    this.onPressed,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  final VoidCallback? onPressed;
  final Object? heroTag;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    void defaultScrollToTop() {
      final ctrl = PrimaryScrollController.maybeOf(context);
      if (ctrl == null) return;
      ctrl.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }

    return FloatingActionButton(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      heroTag: heroTag ?? 'pwf_scroll_top',
      onPressed: onPressed ?? defaultScrollToTop,
      child: const Icon(Icons.keyboard_arrow_up),
    );
  }
}
