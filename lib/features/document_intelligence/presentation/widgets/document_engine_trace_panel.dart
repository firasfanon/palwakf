import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentEngineTracePanel extends StatelessWidget {
  const DocumentEngineTracePanel({super.key, required this.detail});

  final DocumentJobDetail detail;

  @override
  Widget build(BuildContext context) {
    final metadata = detail.job.metadata;
    final evidenceRows =
        ((detail.rawResult['uat_evidence'] as List?) ?? const [])
            .whereType<Map>()
            .map((row) => row.cast<String, dynamic>())
            .toList();

    final engineProfile = _value(metadata, 'engine_profile', 'غير محدد');
    final engineStatus = _value(metadata, 'engine_status', 'غير محدد');
    final fileFamily = _value(metadata, 'file_family', 'غير محدد');
    final uatScenario = _value(metadata, 'file_type_uat_scenario', 'غير محدد');
    final adapterContract = _value(
      metadata,
      'engine_adapter_contract',
      'غير محدد',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TraceChip(label: 'المحول', value: engineProfile),
            _TraceChip(label: 'الحالة', value: engineStatus),
            _TraceChip(
              label: 'عائلة الملف',
              value: DocumentIntelligenceLabels.fileFamily(fileFamily),
            ),
            _TraceChip(label: 'UAT', value: _scenarioLabel(uatScenario)),
          ],
        ),
        const SizedBox(height: 12),
        Text('عقد الربط: $adapterContract'),
        const SizedBox(height: 8),
        const Text(
          'هذه اللوحة تعرض أثر المحرك/المحول. عند تشغيل محرك خارجي فعلي يجب أن يلتزم بنفس شكل PwfDocumentProcessingEngineAdapter ولا يتجاوز المراجعة البشرية.',
        ),
        const SizedBox(height: 16),
        if (evidenceRows.isEmpty)
          const Text(
            'لم يتم تسجيل Evidence UAT في قاعدة البيانات بعد. طبّق SQL patch 05 ليبدأ التسجيل الآلي غير المعطل.',
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evidence UAT المسجلة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...evidenceRows.take(5).map((row) {
                final payload =
                    (row['evidence_payload'] as Map?)
                        ?.cast<String, dynamic>() ??
                    const <String, dynamic>{};
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_outlined),
                  title: Text(
                    '${row['file_family'] ?? '-'} • ${row['engine_profile'] ?? '-'}',
                  ),
                  subtitle: Text(
                    'حقول: ${payload['structured_fields_count'] ?? row['observed_fields_count'] ?? '-'} • '
                    'غموض: ${payload['uncertain_segments_count'] ?? row['observed_uncertain_segments_count'] ?? '-'} • '
                    'روابط: ${payload['candidate_links_count'] ?? row['observed_candidate_links_count'] ?? '-'}',
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }

  String _value(Map<String, dynamic> metadata, String key, String fallback) {
    final value = metadata[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  String _scenarioLabel(String value) {
    switch (value) {
      case 'uat_pdf_image_ocr_review':
        return 'PDF/صورة + OCR';
      case 'uat_word_text_context_extraction':
        return 'Word/Text';
      case 'uat_spreadsheet_header_mapping':
        return 'Excel/CSV';
      case 'uat_cad_spatial_verification_stub':
        return 'DWG/DXF';
      default:
        return value;
    }
  }
}

class _TraceChip extends StatelessWidget {
  const _TraceChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.memory_outlined, size: 18),
      label: Text('$label: $value'),
    );
  }
}
