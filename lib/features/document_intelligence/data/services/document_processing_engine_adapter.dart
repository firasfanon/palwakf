import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/document_intelligence_models.dart';

class PwfDocumentProcessingRequest {
  const PwfDocumentProcessingRequest({
    required this.jobId,
    required this.sourceFile,
    required this.input,
  });

  final String jobId;
  final DocumentFileRecord sourceFile;
  final DocumentCreateInput input;

  Map<String, dynamic> toEnginePayload() {
    return <String, dynamic>{
      'job_id': jobId,
      'source_file': <String, dynamic>{
        'id': sourceFile.id,
        'file_role': sourceFile.fileRole,
        'storage_bucket': sourceFile.storageBucket,
        'storage_path': sourceFile.storagePath,
        'mime_type': sourceFile.mimeType,
        'page_count': sourceFile.pageCount,
        'original_file_name': sourceFile.originalFileName,
        'file_size_bytes': sourceFile.fileSizeBytes,
      },
      'input': <String, dynamic>{
        'source_system': input.sourceSystem,
        'source_record_id': input.sourceRecordId,
        'mode': input.mode.value,
        'sensitivity_level': input.sensitivityLevel.value,
        'waqf_asset_id': input.waqfAssetId,
        'case_id': input.caseId,
        'billing_record_id': input.billingRecordId,
        'task_id': input.taskId,
        'historical_reference_id': input.historicalReferenceId,
        'map_evidence_snapshot_id': input.mapEvidenceSnapshotId,
        'metadata': input.metadata,
      },
    };
  }
}

class PwfDocumentProcessingResult {
  const PwfDocumentProcessingResult({
    required this.documentTypePrimary,
    required this.status,
    required this.pages,
    required this.transcriptions,
    required this.structuredFields,
    required this.uncertainSegments,
    required this.candidateLinks,
    required this.metadataPatch,
    required this.fileFamily,
    required this.fileExtension,
    required this.engineProfile,
    required this.engineStatus,
    required this.uatScenario,
  });

  final String documentTypePrimary;
  final String status;
  final List<Map<String, dynamic>> pages;
  final List<Map<String, dynamic>> transcriptions;
  final List<Map<String, dynamic>> structuredFields;
  final List<Map<String, dynamic>> uncertainSegments;
  final List<Map<String, dynamic>> candidateLinks;
  final Map<String, dynamic> metadataPatch;
  final String fileFamily;
  final String fileExtension;
  final String engineProfile;
  final String engineStatus;
  final String uatScenario;

  factory PwfDocumentProcessingResult.fromMap(
    Map<String, dynamic> map, {
    required String fallbackDocumentType,
    required String fallbackFileFamily,
    required String fallbackFileExtension,
    required String fallbackEngineProfile,
    required String fallbackEngineStatus,
    required String fallbackUatScenario,
  }) {
    List<Map<String, dynamic>> listOfMaps(dynamic value) {
      final rows = (value as List?) ?? const [];
      return rows
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList();
    }

    final metadata =
        (map['metadata_patch'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    return PwfDocumentProcessingResult(
      documentTypePrimary:
          (map['document_type_primary'] ?? fallbackDocumentType).toString(),
      status: (map['status'] ?? 'needs_review').toString(),
      pages: listOfMaps(map['pages']),
      transcriptions: listOfMaps(map['transcriptions']),
      structuredFields: listOfMaps(map['structured_fields']),
      uncertainSegments: listOfMaps(map['uncertain_segments']),
      candidateLinks: listOfMaps(map['candidate_links']),
      metadataPatch: metadata,
      fileFamily:
          (metadata['file_family'] ?? map['file_family'] ?? fallbackFileFamily)
              .toString(),
      fileExtension:
          (metadata['file_extension'] ??
                  map['file_extension'] ??
                  fallbackFileExtension)
              .toString(),
      engineProfile:
          (metadata['engine_profile'] ??
                  map['engine_profile'] ??
                  fallbackEngineProfile)
              .toString(),
      engineStatus:
          (metadata['engine_status'] ??
                  map['engine_status'] ??
                  fallbackEngineStatus)
              .toString(),
      uatScenario:
          (metadata['file_type_uat_scenario'] ??
                  map['file_type_uat_scenario'] ??
                  fallbackUatScenario)
              .toString(),
    );
  }

  Map<String, dynamic> toUatEvidencePayload() {
    return <String, dynamic>{
      'engine_profile': engineProfile,
      'engine_status': engineStatus,
      'file_family': fileFamily,
      'file_extension': fileExtension,
      'file_type_uat_scenario': uatScenario,
      'document_type_primary': documentTypePrimary,
      'status': status,
      'pages_count': pages.length,
      'transcriptions_count': transcriptions.length,
      'structured_fields_count': structuredFields.length,
      'uncertain_segments_count': uncertainSegments.length,
      'candidate_links_count': candidateLinks.length,
      'candidate_links_policy': metadataPatch['candidate_links_policy'],
      'supports_real_engine_adapter':
          metadataPatch['supports_real_engine_adapter'],
      'requires_human_review': metadataPatch['requires_human_review'],
    };
  }
}

abstract class PwfDocumentProcessingEngineAdapter {
  const PwfDocumentProcessingEngineAdapter();

  String get profile;

  Future<PwfDocumentProcessingResult> process(
    PwfDocumentProcessingRequest request,
  );
}

class PwfSupabaseRpcDocumentProcessingEngineAdapter
    extends PwfDocumentProcessingEngineAdapter {
  const PwfSupabaseRpcDocumentProcessingEngineAdapter({
    required this.client,
    this.rpcName = 'rpc_document_engine_process_v1',
  });

  final SupabaseClient client;
  final String rpcName;

  @override
  String get profile => 'supabase_rpc_real_engine_adapter_v1';

  @override
  Future<PwfDocumentProcessingResult> process(
    PwfDocumentProcessingRequest request,
  ) async {
    final originalName =
        request.sourceFile.originalFileName ??
        p.basename(request.sourceFile.storagePath);
    final extension = p.extension(originalName).toLowerCase();
    final fileFamily = _inferFileFamily(extension, request.sourceFile.mimeType);
    final documentType = _inferDocumentType(
      request.input.sourceSystem,
      originalName,
      request.input.mode,
    );
    final result = await client.rpc(
      rpcName,
      params: <String, dynamic>{
        'p_job_id': request.jobId,
        'p_payload': request.toEnginePayload(),
      },
    );
    return PwfDocumentProcessingResult.fromMap(
      (result as Map).cast<String, dynamic>(),
      fallbackDocumentType: documentType,
      fallbackFileFamily: fileFamily,
      fallbackFileExtension: extension,
      fallbackEngineProfile: profile,
      fallbackEngineStatus: 'external_rpc_processed',
      fallbackUatScenario: _uatScenarioForFileFamily(fileFamily),
    );
  }
}

class PwfLocalReviewDocumentProcessingEngineAdapter
    extends PwfDocumentProcessingEngineAdapter {
  const PwfLocalReviewDocumentProcessingEngineAdapter();

  @override
  String get profile => 'local_review_engine_adapter_v3';

  @override
  Future<PwfDocumentProcessingResult> process(
    PwfDocumentProcessingRequest request,
  ) async {
    final input = request.input;
    final sourceFile = request.sourceFile;
    final originalName =
        sourceFile.originalFileName ?? p.basename(sourceFile.storagePath);
    final extension = p.extension(originalName).toLowerCase();
    final baseName = p.basenameWithoutExtension(originalName);
    final fileFamily = _inferFileFamily(extension, sourceFile.mimeType);
    final sourceLabel = _friendlySourceSystemLabel(input.sourceSystem);
    final documentTypePrimary = _inferDocumentType(
      input.sourceSystem,
      originalName,
      input.mode,
    );
    final docNumber = _extractDocumentNumber(originalName);
    final recordContext = _recordContext(input);
    final uatScenario = _uatScenarioForFileFamily(fileFamily);

    final pages = _buildPages(input: input, fileFamily: fileFamily);
    final transcriptions = _buildTranscriptions(
      input: input,
      originalName: originalName,
      sourceLabel: sourceLabel,
      fileFamily: fileFamily,
      recordContext: recordContext,
    );
    final structuredFields = _buildStructuredFields(
      input: input,
      sourceFile: sourceFile,
      originalName: originalName,
      baseName: baseName,
      extension: extension,
      fileFamily: fileFamily,
      documentTypePrimary: documentTypePrimary,
      sourceLabel: sourceLabel,
      docNumber: docNumber,
      engineProfile: profile,
      uatScenario: uatScenario,
    );
    final uncertainSegments = _buildUncertainSegments(
      input: input,
      baseName: baseName,
      fileFamily: fileFamily,
      engineStatus: 'local_review_stub_requires_human_validation',
    );
    final candidateLinks = _buildCandidateLinks(
      input: input,
      originalName: originalName,
      baseName: baseName,
      fileFamily: fileFamily,
      docNumber: docNumber,
    );

    return PwfDocumentProcessingResult(
      documentTypePrimary: documentTypePrimary,
      status: 'needs_review',
      pages: pages,
      transcriptions: transcriptions,
      structuredFields: structuredFields,
      uncertainSegments: uncertainSegments,
      candidateLinks: candidateLinks,
      fileFamily: fileFamily,
      fileExtension: extension,
      engineProfile: profile,
      engineStatus: 'local_review_stub_requires_human_validation',
      uatScenario: uatScenario,
      metadataPatch: <String, dynamic>{
        'original_file_name': originalName,
        'source_file_id': sourceFile.id,
        'file_extension': extension,
        'file_family': fileFamily,
        'file_family_label_ar': _friendlyFileFamilyLabel(fileFamily),
        'source_system_label_ar': sourceLabel,
        'ingested_from_platform': true,
        'supports_review_cycle': true,
        'candidate_links_policy': 'uuid_only_sovereign_links',
        'rich_extraction_profile':
            'document_center_v3_real_engine_adapter_ready',
        'engine_profile': profile,
        'engine_status': 'local_review_stub_requires_human_validation',
        'engine_adapter_contract': 'PwfDocumentProcessingEngineAdapter',
        'supports_real_engine_adapter': true,
        'requires_human_review': true,
        'file_type_uat_scenario': uatScenario,
        'file_type_uat_evidence_ready': true,
      },
    );
  }

  List<Map<String, dynamic>> _buildPages({
    required DocumentCreateInput input,
    required String fileFamily,
  }) {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'page_no': 1,
        'width_px': fileFamily == 'cad' ? 1600 : 1200,
        'height_px': fileFamily == 'cad' ? 1200 : 1700,
        'page_confidence': _defaultConfidenceForMode(input.mode),
        'has_handwriting': input.mode == DocumentJobMode.restoreHtr,
        'has_table': fileFamily == 'spreadsheet',
        'has_stamp':
            input.sourceSystem == 'cases' ||
            input.sensitivityLevel == DocumentSensitivityLevel.legal,
        'has_signature':
            input.mode == DocumentJobMode.restoreHtr ||
            input.sourceSystem == 'cases',
      },
    ];
  }

  List<Map<String, dynamic>> _buildTranscriptions({
    required DocumentCreateInput input,
    required String originalName,
    required String sourceLabel,
    required String fileFamily,
    required String? recordContext,
  }) {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'page_no': 1,
        'printed_text': _buildPrintedSummary(
          originalName: originalName,
          sourceLabel: sourceLabel,
          fileFamily: fileFamily,
          recordContext: recordContext,
        ),
        'handwritten_text': input.mode == DocumentJobMode.restoreHtr
            ? 'تم رصد أجزاء يحتمل أنها بخط يد وتحتاج مراجعة بشرية.'
            : null,
        'full_text': _buildFullSummary(
          originalName: originalName,
          sourceLabel: sourceLabel,
          fileFamily: fileFamily,
          recordContext: recordContext,
          notes: (input.metadata['notes'] ?? '').toString(),
        ),
        'document_confidence': _defaultConfidenceForMode(input.mode),
      },
    ];
  }

  List<Map<String, dynamic>> _buildStructuredFields({
    required DocumentCreateInput input,
    required DocumentFileRecord sourceFile,
    required String originalName,
    required String baseName,
    required String extension,
    required String fileFamily,
    required String documentTypePrimary,
    required String sourceLabel,
    required String? docNumber,
    required String engineProfile,
    required String uatScenario,
  }) {
    final extensionLabel = extension.replaceFirst('.', '').toUpperCase();
    final hasSovereignAnchor = _hasAnySovereignAnchor(input);
    final recordContext = _recordContext(input);
    final fields = <Map<String, dynamic>>[
      _field('document_title', baseName, baseName, 'high'),
      _field(
        'document_type_primary',
        documentTypePrimary,
        documentTypePrimary,
        'high',
      ),
      _field('source_system', sourceLabel, input.sourceSystem, 'high'),
      _field('processing_mode', input.mode.labelAr, input.mode.value, 'high'),
      _field('engine_profile', engineProfile, engineProfile, 'high'),
      _field(
        'engine_status',
        'محول محرك جاهز مع fallback محلي للمراجعة',
        'adapter_ready_local_review_stub',
        'medium',
      ),
      _field(
        'file_type_uat_scenario',
        _fileTypeUatLabel(uatScenario),
        uatScenario,
        'high',
      ),
      _field(
        'file_extension',
        extensionLabel.isEmpty ? 'غير محدد' : extensionLabel,
        extension,
        'high',
      ),
      _field(
        'file_family',
        _friendlyFileFamilyLabel(fileFamily),
        fileFamily,
        'high',
      ),
      _field('mime_type', sourceFile.mimeType, sourceFile.mimeType, 'medium'),
      _field('original_file_name', originalName, originalName, 'high'),
      _field(
        'page_count_estimate',
        sourceFile.pageCount.toString(),
        sourceFile.pageCount.toString(),
        'medium',
      ),
      _field(
        'sensitivity_level',
        input.sensitivityLevel.labelAr,
        input.sensitivityLevel.value,
        'medium',
      ),
      _field('review_required', 'نعم', 'true', 'high'),
      _field(
        'sovereign_anchor_status',
        hasSovereignAnchor
            ? 'يوجد رابط سيادي مباشر'
            : 'لا يوجد رابط سيادي مباشر',
        hasSovereignAnchor ? 'linked' : 'missing',
        hasSovereignAnchor ? 'high' : 'low',
      ),
      _field(
        'record_context_status',
        (recordContext ?? '').isEmpty
            ? 'لا يوجد معرف سياقي'
            : 'يوجد معرف سياقي',
        (recordContext ?? '').isEmpty ? 'missing' : recordContext,
        (recordContext ?? '').isEmpty ? 'low' : 'medium',
      ),
      _field(
        'expected_next_action',
        _expectedNextAction(input, fileFamily),
        _expectedNextActionKey(input, fileFamily),
        'medium',
      ),
      _field(
        'linking_policy',
        'الروابط المرشحة تُحفظ فقط عندما يكون معرف الكيان UUID سياديًا',
        'uuid_only',
        'high',
      ),
    ];

    if ((docNumber ?? '').isNotEmpty) {
      fields.add(
        _field('document_reference_no', docNumber, docNumber, 'medium'),
      );
    }
    if ((input.sourceRecordId ?? '').isNotEmpty) {
      fields.add(
        _field(
          'source_record_id',
          input.sourceRecordId,
          input.sourceRecordId,
          'medium',
        ),
      );
    }
    if ((input.caseId ?? '').isNotEmpty) {
      fields.add(_field('case_id', input.caseId, input.caseId, 'high'));
    }
    if ((input.waqfAssetId ?? '').isNotEmpty) {
      fields.add(
        _field('waqf_asset_id', input.waqfAssetId, input.waqfAssetId, 'high'),
      );
    }
    if ((input.billingRecordId ?? '').isNotEmpty) {
      fields.add(
        _field(
          'billing_record_id',
          input.billingRecordId,
          input.billingRecordId,
          'high',
        ),
      );
    }
    if ((input.taskId ?? '').isNotEmpty) {
      fields.add(_field('task_id', input.taskId, input.taskId, 'high'));
    }
    if ((input.historicalReferenceId ?? '').isNotEmpty) {
      fields.add(
        _field(
          'historical_reference_id',
          input.historicalReferenceId,
          input.historicalReferenceId,
          'high',
        ),
      );
    }
    if ((input.mapEvidenceSnapshotId ?? '').isNotEmpty) {
      fields.add(
        _field(
          'map_evidence_snapshot_id',
          input.mapEvidenceSnapshotId,
          input.mapEvidenceSnapshotId,
          'high',
        ),
      );
    }
    final notes = (input.metadata['notes'] ?? '').toString().trim();
    if (notes.isNotEmpty) {
      fields.add(_field('operator_notes', notes, notes, 'medium'));
    }

    if (fileFamily == 'cad') {
      fields
        ..add(
          _field(
            'engineering_content',
            'ملف هندسي/مساحي',
            'cad_plan',
            'medium',
          ),
        )
        ..add(
          _field(
            'spatial_verification_need',
            'يحتاج مطابقة لاحقة مع طبقات التسوية/التخمين داخل المستكشف',
            'spatial_verification_required',
            'medium',
          ),
        )
        ..add(
          _field(
            'cad_engine_policy',
            'يقبل محرك خارجي DXF/DWG عند توفره، والفحص المحلي لا يدعي قراءة CAD إنتاجية',
            'external_cad_engine_required_for_production',
            'high',
          ),
        );
    }
    if (fileFamily == 'spreadsheet') {
      fields
        ..add(
          _field('tabular_content', 'جدول أو كشف بيانات', 'sheet', 'medium'),
        )
        ..add(
          _field(
            'tabular_review_need',
            'يحتاج تدقيق عناوين الأعمدة ومفاتيح الربط',
            'header_mapping_required',
            'medium',
          ),
        );
    }
    if (fileFamily == 'word_processing') {
      fields
        ..add(
          _field(
            'narrative_content',
            'مستند نصي قابل للتحرير',
            'document',
            'medium',
          ),
        )
        ..add(
          _field(
            'text_review_need',
            'يحتاج تأكيد العنوان والمرجع والسياق الإداري',
            'text_context_required',
            'medium',
          ),
        );
    }
    if (fileFamily == 'image_or_pdf') {
      fields.add(
        _field(
          'ocr_review_need',
          'يحتاج تدقيق OCR بصري قبل الاعتماد',
          'ocr_review_required',
          input.mode == DocumentJobMode.restoreOcr ? 'medium' : 'low',
        ),
      );
    }

    return fields;
  }

  List<Map<String, dynamic>> _buildUncertainSegments({
    required DocumentCreateInput input,
    required String baseName,
    required String fileFamily,
    required String engineStatus,
  }) {
    final segments = <Map<String, dynamic>>[];

    void addSegment({
      required String regionId,
      required String rawText,
      required String reason,
      required String confidence,
    }) {
      segments.add(<String, dynamic>{
        'page_no': 1,
        'region_id': regionId,
        'raw_text': rawText,
        'reason': reason,
        'confidence': confidence,
      });
    }

    addSegment(
      regionId: 'region-engine-adapter-status',
      rawText:
          'حالة المحرك: $engineStatus. يجب عدم اعتماد المخرجات النهائية قبل مراجعة بشرية أو محرك إنتاجي متصل.',
      reason: 'engine_adapter_status',
      confidence: 'medium',
    );

    if (input.mode == DocumentJobMode.restoreOcr ||
        input.mode == DocumentJobMode.restoreHtr) {
      addSegment(
        regionId: 'region-title-reference',
        rawText:
            'العنوان أو الرقم المرجعي في الملف "$baseName" بحاجة لتأكيد بشري قبل الاعتماد.',
        reason: input.mode == DocumentJobMode.restoreHtr
            ? 'htr_handwriting_review'
            : 'ocr_low_confidence',
        confidence: input.mode == DocumentJobMode.restoreHtr ? 'low' : 'medium',
      );
    }

    if (!_hasAnySovereignAnchor(input)) {
      addSegment(
        regionId: 'region-sovereign-anchor',
        rawText:
            'لم يتم تزويد معرف سيادي مباشر مثل waqf_asset_id أو case_id أو task_id، لذلك ستبقى المطابقة بحاجة لمراجعة.',
        reason: 'missing_sovereign_anchor',
        confidence: 'low',
      );
    }

    if ((input.sourceRecordId ?? '').isEmpty &&
        (input.metadata['notes'] ?? '').toString().trim().isEmpty) {
      addSegment(
        regionId: 'region-record-context',
        rawText:
            'سياق السجل غير كافٍ؛ أضف معرفًا مرجعيًا أو ملاحظة تشغيلية لتقليل الالتباس.',
        reason: 'weak_record_context',
        confidence: 'low',
      );
    }

    if (fileFamily == 'cad') {
      addSegment(
        regionId: 'region-cad-layer',
        rawText:
            'أسماء الطبقات أو أرقام القطع في ملف AutoCAD تحتاج ربطًا يدويًا أو محرك CAD خارجي قبل المطابقة مع المستكشف.',
        reason: 'cad_semantic_mapping',
        confidence: 'medium',
      );
    }

    if (fileFamily == 'spreadsheet') {
      addSegment(
        regionId: 'region-sheet-header',
        rawText:
            'عناوين الأعمدة أو مفاتيح السجل قد تحتاج مطابقة يدوية قبل الإدخال السيادي.',
        reason: 'tabular_header_mapping',
        confidence: 'medium',
      );
    }

    if (fileFamily == 'word_processing' &&
        (input.metadata['notes'] ?? '').toString().trim().isEmpty) {
      addSegment(
        regionId: 'region-context',
        rawText:
            'لم يتم تزويد ملاحظات تشغيلية لهذا المستند النصي، وقد يلزم تأكيد السياق.',
        reason: 'missing_operator_context',
        confidence: 'low',
      );
    }

    if (fileFamily == 'binary_document') {
      addSegment(
        regionId: 'region-binary-source',
        rawText:
            'نوع الملف غير معروف بالكامل، وتم التعامل معه كمرفق ثنائي يحتاج مراجعة يدوية.',
        reason: 'derived_from_binary_source',
        confidence: 'low',
      );
    }

    return segments;
  }

  List<Map<String, dynamic>> _buildCandidateLinks({
    required DocumentCreateInput input,
    required String originalName,
    required String baseName,
    required String fileFamily,
    required String? docNumber,
  }) {
    final links = <Map<String, dynamic>>[];

    void addLink({
      required String entityType,
      required String? entityId,
      required String confidence,
      required String displayLabel,
      bool requiresReview = true,
      double? score,
      List<Map<String, dynamic>> matchBasis = const <Map<String, dynamic>>[],
    }) {
      final id = (entityId ?? '').trim();
      if (!_isUuid(id)) return;
      links.add(<String, dynamic>{
        'entity_type': entityType,
        'entity_id': id,
        'confidence': confidence,
        'requires_review': requiresReview,
        'display_label': displayLabel,
        'score': score,
        'match_basis': <Map<String, dynamic>>[
          <String, dynamic>{'type': 'sovereign_anchor', 'value': entityType},
          <String, dynamic>{'type': 'file_name', 'value': originalName},
          <String, dynamic>{'type': 'record_context', 'value': fileFamily},
          ...matchBasis,
        ],
      });
    }

    addLink(
      entityType: 'case',
      entityId: input.caseId,
      confidence: 'high',
      displayLabel: 'قضية مرتبطة',
      score: 0.98,
      matchBasis: <Map<String, dynamic>>[
        <String, dynamic>{'type': 'source_context', 'value': 'case_id'},
        if ((docNumber ?? '').isNotEmpty)
          <String, dynamic>{'type': 'document_reference', 'value': docNumber},
      ],
    );

    addLink(
      entityType: 'waqf_asset',
      entityId: input.waqfAssetId,
      confidence: 'high',
      displayLabel: 'أصل وقفي مرتبط',
      score: 0.97,
      matchBasis: const <Map<String, dynamic>>[
        <String, dynamic>{'type': 'operator_input', 'value': 'waqf_asset_id'},
      ],
    );

    addLink(
      entityType: 'billing_record',
      entityId: input.billingRecordId,
      confidence: 'high',
      displayLabel: 'سجل مالي مرتبط',
      score: 0.96,
      matchBasis: const <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'operator_input',
          'value': 'billing_record_id',
        },
      ],
    );

    addLink(
      entityType: 'task',
      entityId: input.taskId,
      confidence: 'high',
      displayLabel: 'مهمة مرتبطة',
      score: 0.95,
      matchBasis: const <Map<String, dynamic>>[
        <String, dynamic>{'type': 'operator_input', 'value': 'task_id'},
      ],
    );

    addLink(
      entityType: 'historical_reference',
      entityId: input.historicalReferenceId,
      confidence: input.sourceSystem == 'awqaf_system' ? 'high' : 'medium',
      displayLabel: 'مرجع تاريخي مرتبط',
      score: input.sourceSystem == 'awqaf_system' ? 0.94 : 0.82,
      matchBasis: const <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'operator_input',
          'value': 'historical_reference_id',
        },
      ],
    );

    addLink(
      entityType: 'map_evidence_snapshot',
      entityId: input.mapEvidenceSnapshotId,
      confidence: input.sourceSystem == 'mustakshif' ? 'high' : 'medium',
      displayLabel: 'لقطة دليل مكاني مرتبطة',
      score: input.sourceSystem == 'mustakshif' ? 0.93 : 0.8,
      matchBasis: <Map<String, dynamic>>[
        <String, dynamic>{
          'type': 'operator_input',
          'value': 'map_evidence_snapshot_id',
        },
        <String, dynamic>{'type': 'file_name', 'value': baseName},
        <String, dynamic>{'type': 'source_system', 'value': input.sourceSystem},
      ],
    );

    return links;
  }
}

Map<String, dynamic> _field(
  String name,
  String? rawValue,
  String? normalizedValue,
  String confidence,
) {
  return <String, dynamic>{
    'field_name': name,
    'raw_value': rawValue,
    'normalized_value': normalizedValue,
    'confidence': confidence,
    'page_no': 1,
  };
}

String? _recordContext(DocumentCreateInput input) {
  return input.sourceRecordId ??
      input.caseId ??
      input.waqfAssetId ??
      input.billingRecordId ??
      input.taskId ??
      input.historicalReferenceId ??
      input.mapEvidenceSnapshotId;
}

bool _hasAnySovereignAnchor(DocumentCreateInput input) {
  return <String?>[
    input.caseId,
    input.waqfAssetId,
    input.billingRecordId,
    input.taskId,
    input.historicalReferenceId,
    input.mapEvidenceSnapshotId,
  ].any((value) => _isUuid((value ?? '').trim()));
}

bool _isUuid(String value) {
  return RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(value);
}

String _expectedNextAction(DocumentCreateInput input, String fileFamily) {
  if (!_hasAnySovereignAnchor(input)) {
    return 'استكمال معرف الربط السيادي قبل الاعتماد';
  }
  if (fileFamily == 'cad') return 'فتح مسار تحقق مكاني داخل المستكشف';
  if (fileFamily == 'spreadsheet')
    return 'مراجعة عناوين الأعمدة ومفاتيح السجلات';
  if (input.mode == DocumentJobMode.restoreHtr)
    return 'مراجعة بشرية للنصوص المكتوبة بخط اليد';
  return 'مراجعة واعتماد المخرجات';
}

String _expectedNextActionKey(DocumentCreateInput input, String fileFamily) {
  if (!_hasAnySovereignAnchor(input)) return 'complete_sovereign_anchor';
  if (fileFamily == 'cad') return 'open_spatial_verification';
  if (fileFamily == 'spreadsheet') return 'review_table_headers';
  if (input.mode == DocumentJobMode.restoreHtr) return 'review_handwriting';
  return 'review_and_approve';
}

String _inferDocumentType(
  String sourceSystem,
  String fileName,
  DocumentJobMode mode,
) {
  final ext = p.extension(fileName).toLowerCase();
  final family = _inferFileFamily(ext, _guessMimeType(fileName));
  if (sourceSystem == 'cases') {
    return family == 'word_processing' ? 'مذكرة/مستند قضية' : 'مستند قضية';
  }
  if (sourceSystem == 'billing_system') {
    return family == 'spreadsheet' ? 'كشف/سجل مالي' : 'مستند مالي';
  }
  if (sourceSystem == 'mustakshif') {
    return family == 'cad' ? 'مخطط/رسم مساحي' : 'مستند استكشاف مكاني';
  }
  if (sourceSystem == 'tasks') {
    return 'مرفق مهمة';
  }
  if (family == 'word_processing') {
    return 'مستند نصي';
  }
  if (family == 'spreadsheet') {
    return 'مستند جدولي';
  }
  if (family == 'cad') {
    return 'ملف هندسي/AutoCAD';
  }
  if (ext == '.pdf') {
    return mode == DocumentJobMode.structuredExtraction
        ? 'ملف PDF منظم'
        : 'وثيقة PDF';
  }
  return 'وثيقة ممسوحة';
}

String _inferFileFamily(String extension, String mimeType) {
  if (<String>{
    '.pdf',
    '.png',
    '.jpg',
    '.jpeg',
    '.tif',
    '.tiff',
  }.contains(extension)) {
    return 'image_or_pdf';
  }
  if (<String>{'.doc', '.docx', '.odt', '.rtf', '.txt'}.contains(extension)) {
    return 'word_processing';
  }
  if (<String>{'.xls', '.xlsx', '.csv', '.ods'}.contains(extension)) {
    return 'spreadsheet';
  }
  if (<String>{'.dwg', '.dxf'}.contains(extension)) {
    return 'cad';
  }
  if (mimeType.startsWith('image/')) return 'image_or_pdf';
  return 'binary_document';
}

String _guessMimeType(String fileName) {
  switch (p.extension(fileName).toLowerCase()) {
    case '.pdf':
      return 'application/pdf';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.png':
      return 'image/png';
    case '.tif':
    case '.tiff':
      return 'image/tiff';
    case '.doc':
      return 'application/msword';
    case '.docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case '.xls':
      return 'application/vnd.ms-excel';
    case '.xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    case '.csv':
      return 'text/csv';
    case '.odt':
      return 'application/vnd.oasis.opendocument.text';
    case '.ods':
      return 'application/vnd.oasis.opendocument.spreadsheet';
    case '.rtf':
      return 'application/rtf';
    case '.txt':
      return 'text/plain';
    case '.dwg':
      return 'application/acad';
    case '.dxf':
      return 'image/vnd.dxf';
    default:
      return 'application/octet-stream';
  }
}

String _friendlyFileFamilyLabel(String fileFamily) {
  return DocumentIntelligenceLabels.fileFamily(fileFamily);
}

String _friendlySourceSystemLabel(String sourceSystem) {
  return DocumentIntelligenceLabels.sourceSystem(sourceSystem);
}

String _defaultConfidenceForMode(DocumentJobMode mode) {
  switch (mode) {
    case DocumentJobMode.restoreHtr:
      return 'medium';
    case DocumentJobMode.restoreOcr:
    case DocumentJobMode.structuredExtraction:
      return 'high';
    case DocumentJobMode.evidenceLinking:
      return 'medium';
    case DocumentJobMode.restoreOnly:
      return 'high';
  }
}

String? _extractDocumentNumber(String fileName) {
  final match = RegExp(
    r'(?:doc|ref|case|plan|sheet|map)[-_ ]?(\d{3,})',
    caseSensitive: false,
  ).firstMatch(fileName);
  return match?.group(1);
}

String _uatScenarioForFileFamily(String fileFamily) {
  switch (fileFamily) {
    case 'image_or_pdf':
      return 'uat_pdf_image_ocr_review';
    case 'word_processing':
      return 'uat_word_text_context_extraction';
    case 'spreadsheet':
      return 'uat_spreadsheet_header_mapping';
    case 'cad':
      return 'uat_cad_spatial_verification_stub';
    default:
      return 'uat_binary_manual_review';
  }
}

String _fileTypeUatLabel(String scenario) {
  switch (scenario) {
    case 'uat_pdf_image_ocr_review':
      return 'اختبار PDF/صورة: OCR + مراجعة بشرية';
    case 'uat_word_text_context_extraction':
      return 'اختبار Word/Text: استخراج سياق نصي';
    case 'uat_spreadsheet_header_mapping':
      return 'اختبار Excel/CSV: مطابقة عناوين ومفاتيح';
    case 'uat_cad_spatial_verification_stub':
      return 'اختبار DWG/DXF: تحقق مكاني لاحق';
    default:
      return 'اختبار ملف ثنائي: مراجعة يدوية';
  }
}

String _buildPrintedSummary({
  required String originalName,
  required String sourceLabel,
  required String fileFamily,
  required String? recordContext,
}) {
  final contextPart = (recordContext ?? '').isEmpty
      ? ''
      : ' وربطه بالسجل $recordContext';
  return 'تمت قراءة الملف "$originalName" ضمن $sourceLabel ($fileFamily)$contextPart.';
}

String _buildFullSummary({
  required String originalName,
  required String sourceLabel,
  required String fileFamily,
  required String? recordContext,
  required String notes,
}) {
  final notesPart = notes.trim().isEmpty ? '' : ' ملاحظات التشغيل: $notes';
  final contextPart = (recordContext ?? '').isEmpty
      ? 'لا يوجد سياق معرف.'
      : 'مرجع السجل: $recordContext.';
  switch (fileFamily) {
    case 'spreadsheet':
      return 'تم إنشاء دورة ذكاء وثائقي لكشف جدولي "$originalName" من $sourceLabel. $contextPart يحتاج الاختبار إلى مطابقة عناوين الأعمدة ومفاتيح السجلات.$notesPart';
    case 'cad':
      return 'تم إنشاء دورة ذكاء وثائقي لمخطط مساحي/هندسي "$originalName" من $sourceLabel. $contextPart يحتاج الاختبار إلى تحقق مكاني داخل المستكشف أو محرك CAD خارجي.$notesPart';
    case 'word_processing':
      return 'تم إنشاء دورة ذكاء وثائقي لمستند نصي "$originalName" من $sourceLabel. $contextPart يحتاج الاختبار إلى مراجعة السياق والعنوان والمرجع.$notesPart';
    case 'image_or_pdf':
      return 'تم إنشاء دورة ذكاء وثائقي لملف PDF/صورة "$originalName" من $sourceLabel. $contextPart يحتاج الاختبار إلى تدقيق OCR بصري قبل الاعتماد.$notesPart';
    default:
      return 'تم إنشاء دورة ذكاء وثائقي للملف "$originalName" من $sourceLabel. عائلة الملف: $fileFamily. $contextPart$notesPart';
  }
}
