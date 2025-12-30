import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Reusable status badge widget
/// Displays status indicators with icons and colors
/// Follows DRY principle to eliminate repeated status badge code
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool showIcon;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.showIcon = true,
    this.onTap,
  });

  /// Active/Available status
  factory StatusBadge.active({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: AppConstants.success.withValues(alpha: 0.1),
      textColor: AppConstants.success,
      icon: Icons.check_circle,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Inactive/Unavailable status
  factory StatusBadge.inactive({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: Colors.grey.withValues(alpha: 0.1),
      textColor: Colors.grey,
      icon: Icons.cancel,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Pending/In Progress status
  factory StatusBadge.pending({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: AppConstants.warning.withValues(alpha: 0.1),
      textColor: AppConstants.warning,
      icon: Icons.access_time,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Completed/Resolved status
  factory StatusBadge.completed({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: AppConstants.islamicGreen.withValues(alpha: 0.1),
      textColor: AppConstants.islamicGreen,
      icon: Icons.done_all,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Cancelled/Rejected status
  factory StatusBadge.cancelled({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: AppConstants.error.withValues(alpha: 0.1),
      textColor: AppConstants.error,
      icon: Icons.highlight_off,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Urgent/Critical status
  factory StatusBadge.urgent({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: AppConstants.error.withValues(alpha: 0.15),
      textColor: AppConstants.error,
      icon: Icons.warning,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Upcoming status
  factory StatusBadge.upcoming({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: AppConstants.info.withValues(alpha: 0.1),
      textColor: AppConstants.info,
      icon: Icons.event_available,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Ongoing status
  factory StatusBadge.ongoing({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      textColor: Colors.blue,
      icon: Icons.play_circle,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Postponed status
  factory StatusBadge.postponed({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: Colors.orange.withValues(alpha: 0.1),
      textColor: Colors.orange,
      icon: Icons.schedule,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Disputed status
  factory StatusBadge.disputed({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
      textColor: Colors.deepOrange,
      icon: Icons.gavel,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  /// Leased status
  factory StatusBadge.leased({
    required String label,
    VoidCallback? onTap,
  }) {
    return StatusBadge(
      label: label,
      backgroundColor: Colors.teal.withValues(alpha: 0.1),
      textColor: Colors.teal,
      icon: Icons.handshake,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 4,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(
              icon,
              size: (fontSize ?? 12) + 2,
              color: textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize ?? 12,
              fontWeight: fontWeight ?? FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
        child: badge,
      );
    }

    return badge;
  }
}

/// Priority badge variant (for announcements, cases, etc.)
class PriorityBadge extends StatelessWidget {
  final String label;
  final String priority; // low, medium, high, urgent, critical

  const PriorityBadge({
    super.key,
    required this.label,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return StatusBadge.urgent(label: label);
      case 'urgent':
        return StatusBadge.urgent(label: label);
      case 'high':
        return StatusBadge(
          label: label,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          textColor: Colors.red,
          icon: Icons.priority_high,
        );
      case 'medium':
        return StatusBadge.pending(label: label);
      case 'low':
      default:
        return StatusBadge(
          label: label,
          backgroundColor: Colors.grey.withValues(alpha: 0.1),
          textColor: Colors.grey,
          icon: Icons.low_priority,
        );
    }
  }
}
