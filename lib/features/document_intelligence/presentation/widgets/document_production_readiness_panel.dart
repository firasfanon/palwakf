import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/document_intelligence_providers.dart';

class DocumentProductionReadinessPanel extends ConsumerWidget {
  const DocumentProductionReadinessPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessAsync = ref.watch(documentProductionReadinessProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إغلاق المراحل 1–10',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'لوحة تشغيلية تقيس اكتمال UAT، التحليل، المحرك، جودة الاستخراج، الربط السيادي، المراجعة، الواجهة، الصلاحيات، المساعد، والتوثيق.',
            ),
            const SizedBox(height: 16),
            readinessAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text(
                    'لم يتم تطبيق SQL 06 بعد. ستظهر حالة الإغلاق بعد تطبيق migration الموحد.',
                  );
                }
                return Column(
                  children: items.map((item) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        item.isClosed
                            ? Icons.check_circle_outline
                            : Icons.pending_actions_outlined,
                      ),
                      title: Text(item.stageTitleAr),
                      subtitle: Text(
                        item.evidenceAr.isEmpty
                            ? item.requiredNextActionAr
                            : item.evidenceAr,
                      ),
                      trailing: Chip(label: Text(item.statusLabelAr)),
                    );
                  }).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('تعذر تحميل جاهزية الإنتاج: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
