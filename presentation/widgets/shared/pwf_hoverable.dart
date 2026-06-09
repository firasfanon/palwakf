import 'package:flutter/material.dart';

/// Small utility to mimic HTML hover transforms/shadows on web/desktop.
///
/// Keeps behavior inert on touch devices.
class PwfHoverable extends StatefulWidget {
  const PwfHoverable({
    super.key,
    required this.child,
    this.onTap,
    this.hoverTranslate = const Offset(0, -8),
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOut,
    this.borderRadius,
    this.normalShadow,
    this.hoverShadow,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Offset hoverTranslate;
  final Duration duration;
  final Curve curve;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? normalShadow;
  final List<BoxShadow>? hoverShadow;

  @override
  State<PwfHoverable> createState() => _PwfHoverableState();
}

class _PwfHoverableState extends State<PwfHoverable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final normalSh =
        widget.normalShadow ??
        const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ];
    final hoverSh =
        widget.hoverShadow ??
        const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ];

    Widget body = AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      transform: Matrix4.translationValues(
        _hover ? widget.hoverTranslate.dx : 0,
        _hover ? widget.hoverTranslate.dy : 0,
        0,
      ),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: _hover ? hoverSh : normalSh,
      ),
      child: widget.child,
    );

    body = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: body,
    );

    if (widget.onTap != null) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: body,
      );
    }

    return body;
  }
}
