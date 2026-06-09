import 'package:flutter/material.dart';

/// Decorative overlay (subtle) similar to the HTML arabesque background.
/// Kept lightweight (no assets), pointer-events disabled.
class PwfIslamicPatternsOverlay extends StatelessWidget {
  const PwfIslamicPatternsOverlay({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();
    // IMPORTANT: Positioned widgets must be direct children of a Stack.
    // This overlay is inserted as a child of the page Stack, so we return
    // Positioned.fill at the root to avoid ParentData/layout assertions.
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: _PwfPatternPainter())),
    );
  }
}

class _PwfPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Simple repeating motif
    const spacing = 90.0;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final center = Offset(
          x + (y / spacing).floorToDouble() % 2 * spacing / 2,
          y,
        );
        canvas.drawCircle(center, 18, paint);
        canvas.drawCircle(center, 34, paint..strokeWidth = 0.8);
        paint.strokeWidth = 1.0;
      }
    }

    // Soft vignette
    final rect = Offset.zero & size;
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.06)],
        stops: const [0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
