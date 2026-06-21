import 'package:flutter/material.dart';

enum PwfBannerTone { info, success, warning, error }

class PwfStatusBanner extends StatelessWidget {
  const PwfStatusBanner({
    super.key,
    required this.message,
    this.tone = PwfBannerTone.info,
    this.icon,
    this.action,
    this.actionLabel,
    this.onDismiss,
  });

  final String message;
  final PwfBannerTone tone;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;
  final VoidCallback? onDismiss;

  Color get _bg => switch (tone) {
    PwfBannerTone.info => const Color(0xFFEFF6FF),
    PwfBannerTone.success => const Color(0xFFF0FDF4),
    PwfBannerTone.warning => const Color(0xFFFFFBEB),
    PwfBannerTone.error => const Color(0xFFFEF2F2),
  };

  Color get _fg => switch (tone) {
    PwfBannerTone.info => const Color(0xFF1D4ED8),
    PwfBannerTone.success => const Color(0xFF15803D),
    PwfBannerTone.warning => const Color(0xFFB45309),
    PwfBannerTone.error => const Color(0xFFDC2626),
  };

  Color get _border => switch (tone) {
    PwfBannerTone.info => const Color(0xFFBFDBFE),
    PwfBannerTone.success => const Color(0xFFBBF7D0),
    PwfBannerTone.warning => const Color(0xFFFDE68A),
    PwfBannerTone.error => const Color(0xFFFECACA),
  };

  IconData get _defaultIcon => switch (tone) {
    PwfBannerTone.info => Icons.info_outline_rounded,
    PwfBannerTone.success => Icons.check_circle_outline_rounded,
    PwfBannerTone.warning => Icons.warning_amber_rounded,
    PwfBannerTone.error => Icons.error_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon ?? _defaultIcon, size: 20, color: _fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'NotoSansArabic',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _fg,
              ),
            ),
          ),
          if (actionLabel != null && action != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: action,
              style: TextButton.styleFrom(
                foregroundColor: _fg,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, size: 18, color: _fg),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
          ],
        ],
      ),
    );
  }
}
