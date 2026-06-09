import 'package:flutter/foundation.dart';

class DocumentIntelligenceLabels {
  const DocumentIntelligenceLabels._();

  static String confidence(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return 'ثقة عالية';
      case 'medium':
        return 'ثقة متوسطة';
      case 'low':
        return 'ثقة منخفضة';
      case 'unreadable':
        return 'غير مقروء';
      default:
        return value.isEmpty ? 'غير محدد' : value;
    }
  }

  static String confidenceShort(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return 'عالية';
      case 'medium':
        return 'متوسطة';
      case 'low':
        return 'منخفضة';
      case 'unreadable':
        return 'غير مقروءة';
      default:
        return value.isEmpty ? 'غير محددة' : value;
    }
  }

  static String entityType(String value) {
    switch (value) {
      case 'waqf_asset':
        return 'أصل وقفي';
      case 'case':
        return 'قضية';
      case 'billing_record':
        return 'سجل مالي';
      case 'task':
        return 'مهمة';
      case 'historical_reference':
        return 'مرجع تاريخي';
      case 'map_evidence_snapshot':
        return 'لقطة دليل مكاني';
      default:
        return value.isEmpty ? 'كيان غير محدد' : value;
    }
  }

  static String matchBasis(String value) {
    switch (value) {
      case 'operator_input':
        return 'إدخال المشغل';
      case 'source_context':
        return 'سياق المصدر';
      case 'document_reference':
        return 'رقم مرجعي في المستند';
      case 'file_name':
        return 'اسم الملف';
      case 'source_system':
        return 'النظام المصدر';
      case 'sovereign_anchor':
        return 'رابط سيادي';
      case 'record_context':
        return 'سياق السجل';
      default:
        return value.isEmpty ? 'أساس غير محدد' : value;
    }
  }

  static String sourceSystem(String value) {
    switch (value) {
      case 'cases':
        return 'نظام القضايا';
      case 'mustakshif':
        return 'المستكشف';
      case 'billing_system':
        return 'النظام المالي';
      case 'tasks':
        return 'نظام المهام';
      case 'assistant':
        return 'المساعد الداخلي';
      case 'awqaf_system':
        return 'نظام الأوقاف';
      case 'nusuk':
        return 'نسك';
      case 'manasikuna':
        return 'مناسكونا';
      default:
        return value.isEmpty ? 'غير محدد' : value;
    }
  }

  static String fileFamily(String value) {
    switch (value) {
      case 'image_or_pdf':
        return 'صورة أو PDF';
      case 'word_processing':
        return 'مستند نصي';
      case 'spreadsheet':
        return 'جدول/كشف';
      case 'cad':
        return 'رسم هندسي/مساحي';
      case 'binary_document':
        return 'ملف ثنائي';
      default:
        return value.isEmpty ? 'غير محدد' : value;
    }
  }

  static String uncertaintyReason(String value) {
    switch (value) {
      case 'ocr_low_confidence':
        return 'ثقة OCR منخفضة';
      case 'htr_handwriting_review':
        return 'خط يد يحتاج مراجعة';
      case 'derived_from_binary_source':
        return 'مخرجات مشتقة من ملف ثنائي';
      case 'engine_adapter_status':
        return 'حالة محول المحرك';
      case 'cad_semantic_mapping':
        return 'مطابقة دلالية لملف هندسي';
      case 'tabular_header_mapping':
        return 'مطابقة عناوين جدول';
      case 'missing_operator_context':
        return 'نقص سياق تشغيلي';
      case 'missing_sovereign_anchor':
        return 'لا يوجد رابط سيادي مباشر';
      case 'weak_record_context':
        return 'سياق السجل غير كافٍ';
      default:
        return value.isEmpty ? 'سبب غير محدد' : value;
    }
  }
}

enum DocumentJobMode {
  restoreOnly('MODE_RESTORE_ONLY', 'استعادة فقط'),
  restoreOcr('MODE_RESTORE_OCR', 'استعادة + OCR'),
  restoreHtr('MODE_RESTORE_HTR', 'استعادة + HTR'),
  structuredExtraction('MODE_STRUCTURED_EXTRACTION', 'استخراج حقول'),
  evidenceLinking('MODE_EVIDENCE_LINKING', 'ربط أدلة');

  const DocumentJobMode(this.value, this.labelAr);
  final String value;
  final String labelAr;

  static DocumentJobMode fromValue(String? value) {
    return DocumentJobMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => DocumentJobMode.restoreOnly,
    );
  }
}

enum DocumentJobStatus {
  draft('draft', 'مسودة'),
  machineProcessed('machine_processed', 'معالج آليًا'),
  needsReview('needs_review', 'بحاجة لمراجعة'),
  reviewed('reviewed', 'تمت المراجعة'),
  approved('approved', 'معتمد'),
  rejected('rejected', 'مرفوض');

  const DocumentJobStatus(this.value, this.labelAr);
  final String value;
  final String labelAr;

  static DocumentJobStatus fromValue(String? value) {
    return DocumentJobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DocumentJobStatus.draft,
    );
  }
}

enum DocumentSensitivityLevel {
  general('general', 'عام'),
  historical('historical', 'تاريخي'),
  legal('legal', 'قانوني'),
  financial('financial', 'مالي'),
  identity('identity', 'هوية'),
  evidence('evidence', 'أدلة');

  const DocumentSensitivityLevel(this.value, this.labelAr);
  final String value;
  final String labelAr;

  static DocumentSensitivityLevel fromValue(String? value) {
    return DocumentSensitivityLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => DocumentSensitivityLevel.general,
    );
  }
}

@immutable
class DocumentJobSummary {
  const DocumentJobSummary({
    required this.id,
    required this.sourceSystem,
    required this.mode,
    required this.status,
    required this.sensitivityLevel,
    required this.requestedAt,
    this.sourceRecordId,
    this.waqfAssetId,
    this.caseId,
    this.billingRecordId,
    this.taskId,
    this.historicalReferenceId,
    this.mapEvidenceSnapshotId,
    this.documentTypePrimary,
    this.reviewRequired = true,
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String sourceSystem;
  final String? sourceRecordId;
  final String? waqfAssetId;
  final String? caseId;
  final String? billingRecordId;
  final String? taskId;
  final String? historicalReferenceId;
  final String? mapEvidenceSnapshotId;
  final DocumentJobMode mode;
  final DocumentJobStatus status;
  final String? documentTypePrimary;
  final DocumentSensitivityLevel sensitivityLevel;
  final DateTime? requestedAt;
  final bool reviewRequired;
  final Map<String, dynamic> metadata;

  factory DocumentJobSummary.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return DocumentJobSummary(
      id: (map['id'] ?? '').toString(),
      sourceSystem: (map['source_system'] ?? '').toString(),
      sourceRecordId: map['source_record_id']?.toString(),
      waqfAssetId: map['waqf_asset_id']?.toString(),
      caseId: map['case_id']?.toString(),
      billingRecordId: map['billing_record_id']?.toString(),
      taskId: map['task_id']?.toString(),
      historicalReferenceId: map['historical_reference_id']?.toString(),
      mapEvidenceSnapshotId: map['map_evidence_snapshot_id']?.toString(),
      mode: DocumentJobMode.fromValue(map['mode']?.toString()),
      status: DocumentJobStatus.fromValue(map['status']?.toString()),
      documentTypePrimary: map['document_type_primary']?.toString(),
      sensitivityLevel: DocumentSensitivityLevel.fromValue(
        map['sensitivity_level']?.toString(),
      ),
      requestedAt: parseDate(map['requested_at']),
      reviewRequired: map['review_required'] == true,
      metadata:
          (map['metadata'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }
}

@immutable
class DocumentFileRecord {
  const DocumentFileRecord({
    required this.id,
    required this.fileRole,
    required this.storageBucket,
    required this.storagePath,
    required this.mimeType,
    required this.pageCount,
    this.originalFileName,
    this.fileSizeBytes,
  });

  final String id;
  final String fileRole;
  final String storageBucket;
  final String storagePath;
  final String mimeType;
  final int pageCount;
  final String? originalFileName;
  final int? fileSizeBytes;

  factory DocumentFileRecord.fromMap(Map<String, dynamic> map) {
    return DocumentFileRecord(
      id: (map['id'] ?? '').toString(),
      fileRole: (map['file_role'] ?? '').toString(),
      storageBucket: (map['storage_bucket'] ?? '').toString(),
      storagePath: (map['storage_path'] ?? '').toString(),
      mimeType: (map['mime_type'] ?? '').toString(),
      pageCount: (map['page_count'] as num?)?.toInt() ?? 1,
      originalFileName: map['original_file_name']?.toString(),
      fileSizeBytes: (map['file_size_bytes'] as num?)?.toInt(),
    );
  }
}

@immutable
class DocumentStructuredField {
  const DocumentStructuredField({
    required this.fieldName,
    required this.confidence,
    this.rawValue,
    this.normalizedValue,
    this.pageNo,
  });

  final String fieldName;
  final String? rawValue;
  final String? normalizedValue;
  final String confidence;
  final int? pageNo;

  factory DocumentStructuredField.fromMap(Map<String, dynamic> map) {
    return DocumentStructuredField(
      fieldName: (map['field_name'] ?? '').toString(),
      rawValue: map['raw_value']?.toString(),
      normalizedValue: map['normalized_value']?.toString(),
      confidence: (map['confidence'] ?? '').toString(),
      pageNo: (map['page_no'] as num?)?.toInt(),
    );
  }
}

@immutable
class DocumentUncertainSegment {
  const DocumentUncertainSegment({
    required this.regionId,
    required this.rawText,
    required this.reason,
    required this.confidence,
    required this.pageNo,
  });

  final String regionId;
  final String rawText;
  final String reason;
  final String confidence;
  final int pageNo;

  factory DocumentUncertainSegment.fromMap(Map<String, dynamic> map) {
    return DocumentUncertainSegment(
      regionId: (map['region_id'] ?? '').toString(),
      rawText: (map['raw_text'] ?? '').toString(),
      reason: (map['reason'] ?? '').toString(),
      confidence: (map['confidence'] ?? '').toString(),
      pageNo: (map['page_no'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class DocumentCandidateLink {
  const DocumentCandidateLink({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.confidence,
    required this.requiresReview,
    this.displayLabel,
    this.score,
    this.matchBasis = const <String>[],
  });

  final String id;
  final String entityType;
  final String entityId;
  final String confidence;
  final bool requiresReview;
  final String? displayLabel;
  final double? score;
  final List<String> matchBasis;

  factory DocumentCandidateLink.fromMap(Map<String, dynamic> map) {
    final basisRaw = (map['match_basis'] as List?) ?? const [];
    final basis = basisRaw
        .map((item) {
          if (item is Map) {
            final type = item['type']?.toString() ?? '';
            final value = item['value']?.toString() ?? '';
            final label = DocumentIntelligenceLabels.matchBasis(type);
            if (type.isNotEmpty && value.isNotEmpty) return '$label: $value';
            return value.isNotEmpty ? value : label;
          }
          return item.toString();
        })
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return DocumentCandidateLink(
      id: (map['id'] ?? '').toString(),
      entityType: (map['entity_type'] ?? '').toString(),
      entityId: (map['entity_id'] ?? '').toString(),
      confidence: (map['confidence'] ?? '').toString(),
      requiresReview: map['requires_review'] == true,
      displayLabel: map['display_label']?.toString(),
      score: (map['score'] as num?)?.toDouble(),
      matchBasis: basis,
    );
  }

  Map<String, dynamic> toReviewPayload() {
    return <String, dynamic>{
      'candidate_link_id': id,
      'entity_type': entityType,
      'entity_type_label_ar': DocumentIntelligenceLabels.entityType(entityType),
      'entity_id': entityId,
      'confidence': confidence,
      'requires_review': requiresReview,
      if (displayLabel != null) 'display_label': displayLabel,
      if (score != null) 'score': score,
      'match_basis': matchBasis,
    };
  }
}

@immutable
class DocumentFileTypeUatCoverage {
  const DocumentFileTypeUatCoverage({
    required this.fileFamily,
    required this.labelAr,
    required this.uatScenario,
    required this.expectedExtensions,
    required this.evidenceCount,
    required this.observedFieldsCount,
    required this.observedUncertainSegmentsCount,
    required this.observedCandidateLinksCount,
    required this.isClosed,
    this.latestEngineProfile,
    this.latestRecordedAt,
  });

  final String fileFamily;
  final String labelAr;
  final String uatScenario;
  final List<String> expectedExtensions;
  final int evidenceCount;
  final int observedFieldsCount;
  final int observedUncertainSegmentsCount;
  final int observedCandidateLinksCount;
  final bool isClosed;
  final String? latestEngineProfile;
  final DateTime? latestRecordedAt;

  factory DocumentFileTypeUatCoverage.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    final extensionsRaw = (map['expected_extensions'] as List?) ?? const [];
    return DocumentFileTypeUatCoverage(
      fileFamily: (map['file_family'] ?? '').toString(),
      labelAr: (map['label_ar'] ?? '').toString(),
      uatScenario: (map['uat_scenario'] ?? '').toString(),
      expectedExtensions: extensionsRaw.map((item) => item.toString()).toList(),
      evidenceCount: (map['evidence_count'] as num?)?.toInt() ?? 0,
      observedFieldsCount: (map['observed_fields_count'] as num?)?.toInt() ?? 0,
      observedUncertainSegmentsCount:
          (map['observed_uncertain_segments_count'] as num?)?.toInt() ?? 0,
      observedCandidateLinksCount:
          (map['observed_candidate_links_count'] as num?)?.toInt() ?? 0,
      isClosed: map['is_closed'] == true,
      latestEngineProfile: map['latest_engine_profile']?.toString(),
      latestRecordedAt: parseDate(map['latest_recorded_at']),
    );
  }
}

@immutable
class DocumentJobDetail {
  const DocumentJobDetail({
    required this.job,
    required this.files,
    required this.structuredFields,
    required this.uncertainSegments,
    required this.candidateLinks,
    required this.transcriptions,
    required this.uatEvidence,
    required this.reviews,
    required this.auditEvents,
    required this.assistantCitations,
    this.rawResult = const <String, dynamic>{},
  });

  final DocumentJobSummary job;
  final List<DocumentFileRecord> files;
  final List<DocumentStructuredField> structuredFields;
  final List<DocumentUncertainSegment> uncertainSegments;
  final List<DocumentCandidateLink> candidateLinks;
  final List<Map<String, dynamic>> transcriptions;
  final List<Map<String, dynamic>> uatEvidence;
  final List<Map<String, dynamic>> reviews;
  final List<Map<String, dynamic>> auditEvents;
  final List<Map<String, dynamic>> assistantCitations;
  final Map<String, dynamic> rawResult;

  bool get hasSovereignAnchor {
    return <String?>[
      job.waqfAssetId,
      job.caseId,
      job.billingRecordId,
      job.taskId,
      job.historicalReferenceId,
      job.mapEvidenceSnapshotId,
      ...candidateLinks.map((link) => link.entityId),
    ].any((value) => _isUuidForModels(value));
  }

  bool get hasHumanReview =>
      reviews.isNotEmpty ||
      job.status == DocumentJobStatus.reviewed ||
      job.status == DocumentJobStatus.approved;

  bool get isAssistantReady =>
      job.status == DocumentJobStatus.approved && hasHumanReview;

  factory DocumentJobDetail.fromRpc({
    required Map<String, dynamic> jobPayload,
    required List<dynamic> filesPayload,
    required Map<String, dynamic>? resultPayload,
  }) {
    List<Map<String, dynamic>> maps(String key) {
      final rows = (resultPayload?[key] as List?) ?? const [];
      return rows
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
    }

    final structured = maps('structured_fields');
    final uncertain = maps('uncertain_segments');
    final candidate = maps('candidate_links');

    return DocumentJobDetail(
      job: DocumentJobSummary.fromMap(jobPayload),
      files: filesPayload
          .whereType<Map>()
          .map((m) => DocumentFileRecord.fromMap(m.cast<String, dynamic>()))
          .toList(),
      structuredFields: structured
          .map(DocumentStructuredField.fromMap)
          .toList(),
      uncertainSegments: uncertain
          .map(DocumentUncertainSegment.fromMap)
          .toList(),
      candidateLinks: candidate.map(DocumentCandidateLink.fromMap).toList(),
      transcriptions: maps('transcriptions'),
      uatEvidence: maps('uat_evidence'),
      reviews: maps('reviews'),
      auditEvents: maps('audit_events'),
      assistantCitations: maps('assistant_citations'),
      rawResult: resultPayload ?? const <String, dynamic>{},
    );
  }
}

bool _isUuidForModels(String? value) {
  final candidate = (value ?? '').trim();
  return RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(candidate);
}

@immutable
class DocumentDashboardMetrics {
  const DocumentDashboardMetrics({
    required this.totalJobs,
    required this.needsReview,
    required this.approved,
    required this.rejected,
    required this.withSovereignLinks,
    required this.withUatEvidence,
    required this.closedFileFamilies,
    required this.missingFileFamilies,
    required this.engineProfileLabel,
  });

  final int totalJobs;
  final int needsReview;
  final int approved;
  final int rejected;
  final int withSovereignLinks;
  final int withUatEvidence;
  final int closedFileFamilies;
  final int missingFileFamilies;
  final String engineProfileLabel;

  factory DocumentDashboardMetrics.empty() {
    return const DocumentDashboardMetrics(
      totalJobs: 0,
      needsReview: 0,
      approved: 0,
      rejected: 0,
      withSovereignLinks: 0,
      withUatEvidence: 0,
      closedFileFamilies: 0,
      missingFileFamilies: 4,
      engineProfileLabel: 'غير محدد',
    );
  }

  factory DocumentDashboardMetrics.fromMap(Map<String, dynamic> map) {
    return DocumentDashboardMetrics(
      totalJobs: (map['total_jobs'] as num?)?.toInt() ?? 0,
      needsReview: (map['needs_review'] as num?)?.toInt() ?? 0,
      approved: (map['approved'] as num?)?.toInt() ?? 0,
      rejected: (map['rejected'] as num?)?.toInt() ?? 0,
      withSovereignLinks: (map['with_sovereign_links'] as num?)?.toInt() ?? 0,
      withUatEvidence: (map['with_uat_evidence'] as num?)?.toInt() ?? 0,
      closedFileFamilies: (map['closed_file_families'] as num?)?.toInt() ?? 0,
      missingFileFamilies: (map['missing_file_families'] as num?)?.toInt() ?? 0,
      engineProfileLabel: (map['engine_profile_label'] ?? 'غير محدد')
          .toString(),
    );
  }
}

@immutable
class DocumentProductionReadinessItem {
  const DocumentProductionReadinessItem({
    required this.stageKey,
    required this.stageTitleAr,
    required this.statusKey,
    required this.statusLabelAr,
    required this.evidenceAr,
    required this.requiredNextActionAr,
    required this.isClosed,
  });

  final String stageKey;
  final String stageTitleAr;
  final String statusKey;
  final String statusLabelAr;
  final String evidenceAr;
  final String requiredNextActionAr;
  final bool isClosed;

  factory DocumentProductionReadinessItem.fromMap(Map<String, dynamic> map) {
    return DocumentProductionReadinessItem(
      stageKey: (map['stage_key'] ?? '').toString(),
      stageTitleAr: (map['stage_title_ar'] ?? '').toString(),
      statusKey: (map['status_key'] ?? 'unknown').toString(),
      statusLabelAr: (map['status_label_ar'] ?? 'غير محدد').toString(),
      evidenceAr: (map['evidence_ar'] ?? '').toString(),
      requiredNextActionAr: (map['required_next_action_ar'] ?? '').toString(),
      isClosed: map['is_closed'] == true,
    );
  }
}

@immutable
class DocumentWorkflowEvent {
  const DocumentWorkflowEvent({
    required this.eventType,
    required this.eventLabelAr,
    required this.createdAt,
    this.payload = const <String, dynamic>{},
  });

  final String eventType;
  final String eventLabelAr;
  final DateTime? createdAt;
  final Map<String, dynamic> payload;

  factory DocumentWorkflowEvent.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
      return null;
    }

    return DocumentWorkflowEvent(
      eventType: (map['event_type'] ?? '').toString(),
      eventLabelAr: (map['event_label_ar'] ?? map['event_type'] ?? '')
          .toString(),
      createdAt: parseDate(map['created_at']),
      payload:
          (map['event_payload'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }
}

@immutable
class DocumentCreateInput {
  const DocumentCreateInput({
    required this.sourceSystem,
    required this.mode,
    required this.sensitivityLevel,
    this.sourceRecordId,
    this.waqfAssetId,
    this.caseId,
    this.billingRecordId,
    this.taskId,
    this.historicalReferenceId,
    this.mapEvidenceSnapshotId,
    this.metadata = const <String, dynamic>{},
  });

  final String sourceSystem;
  final String? sourceRecordId;
  final String? waqfAssetId;
  final String? caseId;
  final String? billingRecordId;
  final String? taskId;
  final String? historicalReferenceId;
  final String? mapEvidenceSnapshotId;
  final DocumentJobMode mode;
  final DocumentSensitivityLevel sensitivityLevel;
  final Map<String, dynamic> metadata;
}
