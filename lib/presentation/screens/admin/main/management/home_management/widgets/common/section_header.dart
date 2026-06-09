import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 720;
        final titleWidget = Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );

        final headerIcon = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        );

        if (isTight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  headerIcon,
                  const SizedBox(width: 16),
                  Expanded(child: titleWidget),
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: trailing!),
              ],
            ],
          );
        }

        return Row(
          children: [
            headerIcon,
            const SizedBox(width: 16),
            Expanded(child: titleWidget),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Align(alignment: Alignment.centerLeft, child: trailing!),
              ),
            ],
          ],
        );
      },
    );
  }
}
