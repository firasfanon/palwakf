import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/document_intelligence_models.dart';
import '../providers/document_intelligence_providers.dart';

class DocumentFileTypeReadinessPanel extends ConsumerWidget {
  const DocumentFileTypeReadinessPanel({super.key});

  static const _items = <_FileTypeReadiness>[
    _FileTypeReadiness(
      'image_or_pdf',
      'PDF / صور',
      'OCR + مراجعة بشرية',
      'uat_pdf_image_ocr_review',
      'جاهز للتشغيل الأولي مع Evidence',
    ),
    _FileTypeReadiness(
      'word_processing',
      'DOC/DOCX/ODT/RTF/TXT',
      'استخراج حقول وسياق نصي',
      'uat_word_text_context_extraction',
      'جاهز للتشغيل الأولي مع Evidence',
    ),
    _FileTypeReadiness(
      'spreadsheet',
      'XLS/XLSX/CSV/ODS',
      'كشف جدولي ومفاتيح ربط',
      'uat_spreadsheet_header_mapping',
      'جاهز للتشغيل الأولي مع Evidence',
    ),
    _FileTypeReadiness(
      'cad',
      'DWG/DXF',
      'رسم هندسي/مساحي + تحقق مكاني لاحق',
      'uat_cad_spatial_verification_stub',
      'جاهز كمدخل أولي لا كقراءة CAD إنتاجية',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverageAsync = ref.watch(documentFileTypeUatCoverageProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'جاهزية أنواع الملفات و Evidence UAT',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'تحديث تغطية UAT',
                  onPressed: () =>
                      ref.invalidate(documentFileTypeUatCoverageProvider),
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'هذه الجاهزية تخص دورة الرفع والتسجيل وتوليد مخرجات مراجعة أولية وتسجيل أثر اختبار لكل نوع ملف. لا تعني وجود OCR/CAD engine إنتاجي كامل.',
            ),
            const SizedBox(height: 12),
            coverageAsync.when(
              data: (coverage) =>
                  _CoverageRows(fallbackItems: _items, coverage: coverage),
              loading: () => Column(
                children: _items
                    .map((item) => _ReadinessTile(item: item))
                    .toList(),
              ),
              error: (error, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لم يتم تحميل تغطية UAT الحية. غالبًا لم يطبّق SQL 05 أو RPC التغطية بعد.',
                  ),
                  const SizedBox(height: 8),
                  Text('تفصيل الخطأ: $error'),
                  const SizedBox(height: 12),
                  ..._items.map((item) => _ReadinessTile(item: item)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageRows extends StatelessWidget {
  const _CoverageRows({required this.fallbackItems, required this.coverage});

  final List<_FileTypeReadiness> fallbackItems;
  final List<DocumentFileTypeUatCoverage> coverage;

  @override
  Widget build(BuildContext context) {
    final coverageByFamily = {
      for (final item in coverage) item.fileFamily: item,
    };
    final closedCount = coverage.where((item) => item.isClosed).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.verified_outlined, size: 18),
              label: Text('مغلق: $closedCount / ${fallbackItems.length}'),
            ),
            Chip(
              avatar: const Icon(Icons.dataset_linked_outlined, size: 18),
              label: Text(
                'Evidence: ${coverage.fold<int>(0, (sum, item) => sum + item.evidenceCount)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...fallbackItems.map((item) {
          final row = coverageByFamily[item.fileFamily];
          if (row == null) return _ReadinessTile(item: item);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              row.isClosed
                  ? Icons.task_alt_outlined
                  : Icons.pending_actions_outlined,
            ),
            title: Text(item.group),
            subtitle: Text(
              '${item.path}\n'
              'سيناريو UAT: ${row.uatScenario}\n'
              'Evidence: ${row.evidenceCount} • حقول: ${row.observedFieldsCount} • غموض: ${row.observedUncertainSegmentsCount} • روابط: ${row.observedCandidateLinksCount}\n'
              'آخر محرك: ${row.latestEngineProfile ?? 'غير مسجل'}',
            ),
            trailing: Chip(label: Text(row.isClosed ? 'مغلق' : 'بانتظار عينة')),
            isThreeLine: true,
          );
        }),
      ],
    );
  }
}

class _ReadinessTile extends StatelessWidget {
  const _ReadinessTile({required this.item});

  final _FileTypeReadiness item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.task_alt_outlined),
      title: Text(item.group),
      subtitle: Text(
        '${item.path}\nسيناريو UAT: ${item.uatScenario}\n${item.status}',
      ),
      trailing: const Chip(label: Text('بانتظار Evidence')),
      isThreeLine: true,
    );
  }
}

class _FileTypeReadiness {
  const _FileTypeReadiness(
    this.fileFamily,
    this.group,
    this.path,
    this.uatScenario,
    this.status,
  );

  final String fileFamily;
  final String group;
  final String path;
  final String uatScenario;
  final String status;
}
