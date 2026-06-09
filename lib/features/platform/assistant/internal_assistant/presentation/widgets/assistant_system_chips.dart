import 'package:flutter/material.dart';

import '../../../assistant_core/presentation/theme/chat_palette.dart';
import '../../data/models/assistant_context.dart';

class AssistantSystemChips extends StatelessWidget {
  const AssistantSystemChips({
    super.key,
    required this.contextData,
    required this.isArabic,
  });

  final AssistantContext contextData;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      '${isArabic ? 'الصفحة' : 'Page'}: ${contextData.currentPageLabel ?? contextData.currentRoute}',
      if (contextData.unitId != null && contextData.unitId!.trim().isNotEmpty)
        '${isArabic ? 'الوحدة' : 'Unit'}: ${contextData.unitId}',
      '${isArabic ? 'عدد الصلاحيات' : 'Permissions'}: ${contextData.permissions.length}',
      if (contextData.knowledgeScopeLabel != null)
        '${isArabic ? 'النطاق' : 'Scope'}: ${contextData.knowledgeScopeLabel}',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips
          .map((chip) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ChatPalette.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: ChatPalette.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                chip,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ChatPalette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
