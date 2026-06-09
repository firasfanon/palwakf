import 'package:flutter/material.dart';

import '../../../assistant_core/presentation/theme/chat_palette.dart';
import '../../data/models/assistant_context.dart';

class AssistantContextSummary extends StatelessWidget {
  const AssistantContextSummary({
    super.key,
    required this.contextData,
    required this.isArabic,
  });

  final AssistantContext contextData;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    Widget tile({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ChatPalette.panelFor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ChatPalette.borderFor(context)),
        ),
        child: Row(
          children: [
            Icon(icon, color: ChatPalette.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 820;
        final children = <Widget>[
          tile(
            icon: Icons.person_rounded,
            label: isArabic ? 'المستخدم' : 'User',
            value: contextData.displayName,
          ),
          tile(
            icon: Icons.shield_rounded,
            label: isArabic ? 'الدور' : 'Role',
            value: contextData.roleLabel,
          ),
          tile(
            icon: Icons.hub_rounded,
            label: isArabic ? 'النظام' : 'System',
            value: contextData.systemLabel,
          ),
          tile(
            icon: Icons.layers_outlined,
            label: isArabic ? 'السياق' : 'Surface',
            value: contextData.surfaceKey,
          ),
          tile(
            icon: Icons.web_asset_rounded,
            label: isArabic ? 'الصفحة الحالية' : 'Current page',
            value: contextData.currentPageLabel ?? contextData.currentRoute,
          ),
          tile(
            icon: Icons.apartment_rounded,
            label: isArabic ? 'نطاق الوحدة' : 'Unit scope',
            value:
                (contextData.unitSlug ?? contextData.unitId ?? '')
                    .trim()
                    .isEmpty
                ? (isArabic ? 'غير محدد' : 'Not scoped')
                : (contextData.unitSlug ?? contextData.unitId ?? ''),
          ),
          tile(
            icon: Icons.rule_rounded,
            label: isArabic ? 'نطاق المعرفة' : 'Knowledge scope',
            value: contextData.knowledgeScopeLabel ?? contextData.scopeKey,
          ),
        ];

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}
