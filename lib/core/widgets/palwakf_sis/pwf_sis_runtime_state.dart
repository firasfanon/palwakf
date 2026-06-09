import 'package:flutter/material.dart';

import 'pwf_sis_status_badge.dart';

class PwfSisRuntimeState extends StatelessWidget {
  const PwfSisRuntimeState({
    super.key,
    required this.title,
    required this.message,
    this.tone = PwfSisStatusTone.info,
    this.action,
  });

  final String title;
  final String message;
  final PwfSisStatusTone tone;
  final Widget? action;

  const PwfSisRuntimeState.loading({super.key})
    : title = 'جارٍ التحميل',
      message = 'يتم تحميل البيانات من مصدر التشغيل.',
      tone = PwfSisStatusTone.info,
      action = null;

  const PwfSisRuntimeState.empty({super.key})
    : title = 'لا توجد بيانات',
      message = 'لا توجد سجلات ضمن الفلتر الحالي.',
      tone = PwfSisStatusTone.neutral,
      action = null;

  const PwfSisRuntimeState.forbidden({super.key})
    : title = 'وصول غير مصرح',
      message = 'لا تملك صلاحية الوصول إلى هذه المساحة التشغيلية.',
      tone = PwfSisStatusTone.restricted,
      action = null;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      PwfSisStatusTone.danger => Theme.of(context).colorScheme.error,
      PwfSisStatusTone.review => Theme.of(context).colorScheme.secondary,
      PwfSisStatusTone.success => Colors.green,
      PwfSisStatusTone.restricted => Colors.deepPurple,
      _ => Theme.of(context).colorScheme.primary,
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.layers_outlined, color: color, size: 42),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                if (action != null) ...[const SizedBox(height: 16), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
