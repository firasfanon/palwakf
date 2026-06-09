import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../data/models/document_intelligence_models.dart';
import '../providers/document_intelligence_providers.dart';
import '../widgets/document_mode_selector.dart';

class DocumentJobCreatePage extends ConsumerStatefulWidget {
  const DocumentJobCreatePage({super.key});

  @override
  ConsumerState<DocumentJobCreatePage> createState() =>
      _DocumentJobCreatePageState();
}

class _DocumentJobCreatePageState extends ConsumerState<DocumentJobCreatePage> {
  static const List<String> _supportedExtensions = <String>[
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'tif',
    'tiff',
    'dwg',
    'dxf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'csv',
    'odt',
    'ods',
    'rtf',
    'txt',
  ];

  static const List<_SourceSystemOption> _sourceSystemOptions =
      <_SourceSystemOption>[
        _SourceSystemOption('cases', 'نظام القضايا'),
        _SourceSystemOption('mustakshif', 'المستكشف'),
        _SourceSystemOption('billing_system', 'النظام المالي'),
        _SourceSystemOption('tasks', 'نظام المهام'),
        _SourceSystemOption('assistant', 'المساعد الداخلي'),
        _SourceSystemOption('awqaf_system', 'نظام الأوقاف'),
        _SourceSystemOption('nusuk', 'نسك'),
        _SourceSystemOption('manasikuna', 'مناسكونا'),
      ];

  final _formKey = GlobalKey<FormState>();
  final _sourceSystemController = TextEditingController(text: 'cases');
  final _sourceRecordIdController = TextEditingController();
  final _caseIdController = TextEditingController();
  final _waqfAssetIdController = TextEditingController();
  final _billingRecordIdController = TextEditingController();
  final _taskIdController = TextEditingController();
  final _historicalReferenceIdController = TextEditingController();
  final _mapEvidenceSnapshotIdController = TextEditingController();
  final _notesController = TextEditingController();
  DocumentJobMode _mode = DocumentJobMode.restoreOcr;
  DocumentSensitivityLevel _sensitivity = DocumentSensitivityLevel.legal;
  bool _submitting = false;
  PlatformFile? _selectedFile;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  @override
  void dispose() {
    _sourceSystemController.dispose();
    _sourceRecordIdController.dispose();
    _caseIdController.dispose();
    _waqfAssetIdController.dispose();
    _billingRecordIdController.dispose();
    _taskIdController.dispose();
    _historicalReferenceIdController.dispose();
    _mapEvidenceSnapshotIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: _supportedExtensions,
    );
    if (result == null || result.files.isEmpty) return;

    final selected = result.files.single;
    setState(() {
      _selectedFile = selected;
      _mode = _suggestModeForExtension(selected.extension, current: _mode);
    });
  }

  DocumentJobMode _suggestModeForExtension(
    String? extension, {
    required DocumentJobMode current,
  }) {
    final ext = '.${(extension ?? '').toLowerCase()}';
    if ({'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.pdf'}.contains(ext)) {
      return current == DocumentJobMode.evidenceLinking
          ? current
          : DocumentJobMode.restoreOcr;
    }
    if ({'.dwg', '.dxf', '.xls', '.xlsx', '.csv', '.ods'}.contains(ext)) {
      return DocumentJobMode.structuredExtraction;
    }
    if ({'.doc', '.docx', '.odt', '.rtf', '.txt'}.contains(ext)) {
      return DocumentJobMode.structuredExtraction;
    }
    return current;
  }

  String? _validateOptionalUuid(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return null;
    if (!_uuidPattern.hasMatch(trimmed)) {
      return 'أدخل UUID صحيحًا أو اترك الحقل فارغًا';
    }
    return null;
  }

  String? _uuidOrNull(TextEditingController controller) {
    final trimmed = controller.text.trim();
    if (trimmed.isEmpty) return null;
    return _uuidPattern.hasMatch(trimmed) ? trimmed : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null || (_selectedFile!.bytes?.isNotEmpty != true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر ملفًا فعليًا لبدء الدورة الكاملة.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(documentIntelligenceRepositoryProvider);
      final input = DocumentCreateInput(
        sourceSystem: _sourceSystemController.text.trim(),
        sourceRecordId: _uuidOrNull(_sourceRecordIdController),
        caseId: _uuidOrNull(_caseIdController),
        waqfAssetId: _uuidOrNull(_waqfAssetIdController),
        billingRecordId: _uuidOrNull(_billingRecordIdController),
        taskId: _uuidOrNull(_taskIdController),
        historicalReferenceId: _uuidOrNull(_historicalReferenceIdController),
        mapEvidenceSnapshotId: _uuidOrNull(_mapEvidenceSnapshotIdController),
        mode: _mode,
        sensitivityLevel: _sensitivity,
        metadata: {
          'notes': _notesController.text.trim(),
          'created_from_platform': true,
          'original_file_name': _selectedFile!.name,
          'file_extension': _selectedFile!.extension,
          'operator_selected_source_system': _sourceSystemController.text
              .trim(),
          'file_size_bytes': _selectedFile!.size,
        },
      );

      final job = await repo.createJobWithSourceFile(
        input: input,
        fileBytes: _selectedFile!.bytes as Uint8List,
        fileName: _selectedFile!.name,
      );

      if (!mounted) return;
      ref.invalidate(documentJobsProvider);
      ref.invalidate(documentReviewQueueProvider);
      ref.invalidate(documentDashboardMetricsProvider);
      ref.invalidate(documentFileTypeUatCoverageProvider);
      ref.invalidate(documentProductionReadinessProvider);
      ref.invalidate(documentJobDetailProvider(job.id));
      context.go(AppRoutes.adminDocumentIntelligenceJob(job.id));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنشاء الدورة الكاملة: $error')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء وظيفة ذكاء وثائقي')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إعداد الدورة الكاملة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'رفع ملف فعلي + تسجيل الملف المصدر + تخزين مخرجات أولية + إظهار الحقول والروابط المرشحة.',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _sourceSystemController,
                          decoration: const InputDecoration(
                            labelText: 'النظام المصدر',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'الحقل مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sourceSystemOptions.map((option) {
                            final selected =
                                _sourceSystemController.text.trim() ==
                                option.key;
                            return ChoiceChip(
                              label: Text(option.labelAr),
                              selected: selected,
                              onSelected: (_) => setState(
                                () => _sourceSystemController.text = option.key,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _sourceRecordIdController,
                          decoration: const InputDecoration(
                            labelText: 'المعرف المرجعي للمصدر (UUID اختياري)',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateOptionalUuid,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _caseIdController,
                                decoration: const InputDecoration(
                                  labelText: 'معرف القضية (UUID اختياري)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateOptionalUuid,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _waqfAssetIdController,
                                decoration: const InputDecoration(
                                  labelText: 'معرف الأصل الوقفي (UUID اختياري)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateOptionalUuid,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _billingRecordIdController,
                                decoration: const InputDecoration(
                                  labelText: 'معرف السجل المالي (UUID اختياري)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateOptionalUuid,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _taskIdController,
                                decoration: const InputDecoration(
                                  labelText: 'معرف المهمة (UUID اختياري)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateOptionalUuid,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _historicalReferenceIdController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'معرف المرجع التاريخي (UUID اختياري)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateOptionalUuid,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _mapEvidenceSnapshotIdController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'معرف لقطة الدليل المكاني (UUID اختياري)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: _validateOptionalUuid,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DocumentModeSelector(
                          value: _mode,
                          onChanged: (value) => setState(
                            () => _mode = value ?? DocumentJobMode.restoreOnly,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اقتراحات الاستخدام: OCR/HTR للصور وPDF، واستخراج الحقول لملفات Word/Excel/AutoCAD.',
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<DocumentSensitivityLevel>(
                          initialValue: _sensitivity,
                          decoration: const InputDecoration(
                            labelText: 'مستوى الحساسية',
                            border: OutlineInputBorder(),
                          ),
                          items: DocumentSensitivityLevel.values
                              .map(
                                (level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level.labelAr),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(
                            () => _sensitivity =
                                value ?? DocumentSensitivityLevel.general,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات تشغيلية',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الملف الفعلي',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _submitting ? null : _pickFile,
                                      icon: const Icon(
                                        Icons.upload_file_outlined,
                                      ),
                                      label: const Text('اختيار ملف'),
                                    ),
                                    if (_selectedFile != null)
                                      Chip(
                                        avatar: const Icon(
                                          Icons.description_outlined,
                                          size: 18,
                                        ),
                                        label: Text(
                                          '${_selectedFile!.name} • ${((_selectedFile!.size) / 1024).toStringAsFixed(1)} KB',
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'الأنواع المدعومة الآن: PDF / PNG / JPG / TIFF / DWG / DXF / DOC / DOCX / XLS / XLSX / CSV / ODT / ODS / RTF / TXT',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: const Icon(
                              Icons.playlist_add_check_circle_outlined,
                            ),
                            label: Text(
                              _submitting
                                  ? 'جاري تنفيذ الدورة...'
                                  : 'إنشاء الوظيفة ورفع الملف',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceSystemOption {
  const _SourceSystemOption(this.key, this.labelAr);
  final String key;
  final String labelAr;
}
