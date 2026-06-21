import 'package:flutter/material.dart';

class PwfStatCard extends StatelessWidget {
  const PwfStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 20, color: accent),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'NotoSansArabic',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    height: 1.1,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontFamily: 'NotoSansArabic',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
