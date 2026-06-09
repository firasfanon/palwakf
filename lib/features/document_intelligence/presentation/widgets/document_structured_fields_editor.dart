import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentStructuredFieldsEditor extends StatelessWidget {
  const DocumentStructuredFieldsEditor({super.key, required this.fields});

  final List<DocumentStructuredField> fields;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const Text('لا توجد حقول مستخرجة بعد.');
    }
    return Column(
      children: fields.map((field) {
        final value = field.normalizedValue ?? field.rawValue ?? '—';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(_fieldLabel(field.fieldName)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(value),
                if ((field.rawValue ?? '').isNotEmpty &&
                    field.rawValue != field.normalizedValue)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('القيمة الخام: ${field.rawValue}'),
                  ),
                if (field.pageNo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('الصفحة: ${field.pageNo}'),
                  ),
              ],
            ),
            trailing: _ConfidenceBadge(value: field.confidence),
          ),
        );
      }).toList(),
    );
  }

  String _fieldLabel(String key) {
    switch (key) {
      case 'document_title':
        return 'عنوان المستند';
      case 'document_type_primary':
        return 'نوع المستند';
      case 'source_system':
        return 'النظام المصدر';
      case 'review_required':
        return 'حالة المراجعة';
      case 'sovereign_anchor_status':
        return 'حالة الرابط السيادي';
      case 'record_context_status':
        return 'حالة سياق السجل';
      case 'expected_next_action':
        return 'الإجراء التالي المتوقع';
      case 'linking_policy':
        return 'سياسة الربط';
      case 'processing_mode':
        return 'نمط المعالجة';
      case 'file_extension':
        return 'امتداد الملف';
      case 'file_family':
        return 'عائلة الملف';
      case 'mime_type':
        return 'نوع MIME';
      case 'original_file_name':
        return 'اسم الملف الأصلي';
      case 'page_count_estimate':
        return 'تقدير الصفحات';
      case 'sensitivity_level':
        return 'الحساسية';
      case 'document_reference_no':
        return 'الرقم المرجعي';
      case 'source_record_id':
        return 'معرف السجل المصدر';
      case 'case_id':
        return 'معرف القضية';
      case 'waqf_asset_id':
        return 'معرف الأصل الوقفي';
      case 'billing_record_id':
        return 'معرف السجل المالي';
      case 'task_id':
        return 'معرف المهمة';
      case 'operator_notes':
        return 'ملاحظات المشغل';
      case 'engineering_content':
        return 'تصنيف هندسي';
      case 'spatial_verification_need':
        return 'احتياج التحقق المكاني';
      case 'tabular_review_need':
        return 'احتياج تدقيق الجدول';
      case 'text_review_need':
        return 'احتياج تدقيق النص';
      case 'ocr_review_need':
        return 'احتياج تدقيق OCR';
      case 'historical_reference_id':
        return 'معرف المرجع التاريخي';
      case 'map_evidence_snapshot_id':
        return 'معرف لقطة الدليل المكاني';
      case 'tabular_content':
        return 'تصنيف جدولي';
      case 'narrative_content':
        return 'تصنيف نصي';
      default:
        return key;
    }
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(_label(value)));
  }

  String _label(String value) => DocumentIntelligenceLabels.confidence(value);
}
