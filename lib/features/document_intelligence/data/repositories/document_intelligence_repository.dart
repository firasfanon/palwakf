import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/document_intelligence_models.dart';
import '../services/document_processing_engine_adapter.dart';

class DocumentIntelligenceRepository {
  DocumentIntelligenceRepository({
    SupabaseClient? client,
    PwfDocumentProcessingEngineAdapter? processingEngineAdapter,
  }) : _client = client ?? Supabase.instance.client,
       _processingEngineAdapter =
           processingEngineAdapter ??
           const PwfLocalReviewDocumentProcessingEngineAdapter();

  final SupabaseClient _client;
  final PwfDocumentProcessingEngineAdapter _processingEngineAdapter;
  static const String _bucketName = 'document-intelligence';

  Future<List<DocumentJobSummary>> listJobs({
    String? sourceSystem,
    DocumentJobMode? mode,
    DocumentJobStatus? status,
    String? waqfAssetId,
    String? caseId,
  }) async {
    final result = await _client.rpc(
      'rpc_document_job_list_v1',
      params: {
        'p_source_system': sourceSystem,
        'p_mode': mode?.value,
        'p_status': status?.value,
        'p_waqf_asset_id': waqfAssetId,
        'p_case_id': caseId,
      },
    );

    final rows = (result as List?) ?? const [];
    return rows
        .whereType<Map>()
        .map((row) => DocumentJobSummary.fromMap(row.cast<String, dynamic>()))
        .toList();
  }

  Future<List<DocumentFileTypeUatCoverage>> listFileTypeUatCoverage() async {
    final result = await _client.rpc('rpc_document_file_type_uat_coverage_v1');
    final rows = (result as List?) ?? const [];
    return rows
        .whereType<Map>()
        .map(
          (row) =>
              DocumentFileTypeUatCoverage.fromMap(row.cast<String, dynamic>()),
        )
        .toList();
  }

  Future<DocumentDashboardMetrics> getDashboardMetrics() async {
    try {
      final result = await _client.rpc('rpc_document_dashboard_metrics_v1');
      if (result is Map)
        return DocumentDashboardMetrics.fromMap(result.cast<String, dynamic>());
      if (result is List && result.isNotEmpty && result.first is Map) {
        return DocumentDashboardMetrics.fromMap(
          (result.first as Map).cast<String, dynamic>(),
        );
      }
    } catch (_) {
      // Fallback remains read-only and keeps old SQL baselines usable.
    }
    return DocumentDashboardMetrics.empty();
  }

  Future<List<DocumentProductionReadinessItem>>
  listProductionReadiness() async {
    try {
      final result = await _client.rpc('rpc_document_production_readiness_v1');
      final rows = (result as List?) ?? const [];
      return rows
          .whereType<Map>()
          .map(
            (row) => DocumentProductionReadinessItem.fromMap(
              row.cast<String, dynamic>(),
            ),
          )
          .toList();
    } catch (_) {
      return const <DocumentProductionReadinessItem>[];
    }
  }

  Future<void> recordOperationalAction({
    required String jobId,
    required String actionType,
    String? notes,
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) async {
    await _client.rpc(
      'rpc_document_operational_action_record_v1',
      params: {
        'p_job_id': jobId,
        'p_action_type': actionType,
        'p_notes': notes,
        'p_payload': payload,
      },
    );
  }

  Future<void> publishAssistantKnowledgeCandidate({
    required String jobId,
    String? notes,
  }) async {
    await _client.rpc(
      'rpc_document_assistant_knowledge_candidate_v1',
      params: {'p_job_id': jobId, 'p_notes': notes},
    );
  }

  Future<DocumentJobSummary> createJob(DocumentCreateInput input) async {
    final result = await _client.rpc(
      'rpc_document_job_create_v1',
      params: {
        'p_source_system': input.sourceSystem,
        'p_source_record_id': input.sourceRecordId,
        'p_mode': input.mode.value,
        'p_sensitivity_level': input.sensitivityLevel.value,
        'p_waqf_asset_id': input.waqfAssetId,
        'p_case_id': input.caseId,
        'p_billing_record_id': input.billingRecordId,
        'p_task_id': input.taskId,
        'p_historical_reference_id': input.historicalReferenceId,
        'p_map_evidence_snapshot_id': input.mapEvidenceSnapshotId,
        'p_metadata': input.metadata,
      },
    );

    return DocumentJobSummary.fromMap((result as Map).cast<String, dynamic>());
  }

  Future<DocumentJobSummary> createJobWithSourceFile({
    required DocumentCreateInput input,
    required Uint8List fileBytes,
    required String fileName,
    String? mimeType,
    int? pageCount,
    bool autoGenerateProcessingOutput = true,
  }) async {
    final effectiveMimeType = mimeType ?? _guessMimeType(fileName);
    final effectivePageCount =
        pageCount ?? _estimatePageCount(fileName, input.mode);

    final createdJob = await createJob(input);
    final registeredFile = await uploadAndRegisterSourceFile(
      jobId: createdJob.id,
      fileBytes: fileBytes,
      fileName: fileName,
      mimeType: effectiveMimeType,
      pageCount: effectivePageCount,
    );

    if (autoGenerateProcessingOutput) {
      await ingestProcessingOutput(
        jobId: createdJob.id,
        sourceFile: registeredFile,
        input: input,
      );
    }

    final detail = await getJobDetail(createdJob.id);
    return detail.job;
  }

  Future<DocumentFileRecord> uploadAndRegisterSourceFile({
    required String jobId,
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
    int pageCount = 1,
  }) async {
    final sanitizedFileName = _sanitizeFileName(fileName);
    final storagePath =
        'jobs/$jobId/original/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';

    await _client.storage
        .from(_bucketName)
        .uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final result = await _client.rpc(
      'rpc_document_source_file_register_v1',
      params: {
        'p_job_id': jobId,
        'p_storage_bucket': _bucketName,
        'p_storage_path': storagePath,
        'p_mime_type': mimeType,
        'p_page_count': pageCount,
        'p_original_file_name': fileName,
        'p_file_size_bytes': fileBytes.length,
      },
    );

    return DocumentFileRecord.fromMap((result as Map).cast<String, dynamic>());
  }

  Future<void> ingestProcessingOutput({
    required String jobId,
    required DocumentFileRecord sourceFile,
    required DocumentCreateInput input,
  }) async {
    final engineResult = await _processingEngineAdapter.process(
      PwfDocumentProcessingRequest(
        jobId: jobId,
        sourceFile: sourceFile,
        input: input,
      ),
    );

    await _client.rpc(
      'rpc_document_job_ingest_result_v1',
      params: {
        'p_job_id': jobId,
        'p_document_type_primary': engineResult.documentTypePrimary,
        'p_status': engineResult.status,
        'p_pages': engineResult.pages,
        'p_transcriptions': engineResult.transcriptions,
        'p_structured_fields': engineResult.structuredFields,
        'p_uncertain_segments': engineResult.uncertainSegments,
        'p_candidate_links': engineResult.candidateLinks,
        'p_metadata_patch': engineResult.metadataPatch,
      },
    );

    await _tryRecordFileTypeUatEvidence(
      jobId: jobId,
      engineResult: engineResult,
    );
  }

  Future<DocumentJobDetail> getJobDetail(String jobId) async {
    final jobResult = await _client.rpc(
      'rpc_document_job_get_v1',
      params: {'p_job_id': jobId},
    );
    final resultResult = await _client.rpc(
      'rpc_document_job_result_v1',
      params: {'p_job_id': jobId},
    );

    final jobMap = (jobResult as Map).cast<String, dynamic>();
    final resultMap = (resultResult as Map?)?.cast<String, dynamic>();

    return DocumentJobDetail.fromRpc(
      jobPayload:
          (jobMap['job'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
      filesPayload: (jobMap['files'] as List?) ?? const [],
      resultPayload: resultMap,
    );
  }

  Future<List<DocumentCandidateLink>> getCandidateLinks(String jobId) async {
    final result = await _client.rpc(
      'rpc_document_candidate_links_v1',
      params: {'p_job_id': jobId},
    );

    final rows = (result as List?) ?? const [];
    return rows
        .whereType<Map>()
        .map(
          (row) => DocumentCandidateLink.fromMap(row.cast<String, dynamic>()),
        )
        .toList();
  }

  Future<void> submitReview({
    required String jobId,
    required String reviewStatus,
    String? notes,
    Map<String, dynamic> fieldCorrections = const <String, dynamic>{},
    List<Map<String, dynamic>> approvedLinks = const <Map<String, dynamic>>[],
    List<Map<String, dynamic>> rejectedLinks = const <Map<String, dynamic>>[],
  }) async {
    await _client.rpc(
      'rpc_document_job_review_submit_v1',
      params: {
        'p_job_id': jobId,
        'p_review_status': reviewStatus,
        'p_notes': notes,
        'p_field_corrections': fieldCorrections,
        'p_approved_links': approvedLinks,
        'p_rejected_links': rejectedLinks,
      },
    );
  }

  Future<void> requestReprocess({
    required String jobId,
    DocumentJobMode? mode,
    Map<String, dynamic> metadataPatch = const <String, dynamic>{},
  }) async {
    await _client.rpc(
      'rpc_document_reprocess_v1',
      params: {
        'p_job_id': jobId,
        'p_mode': mode?.value,
        'p_metadata_patch': metadataPatch,
      },
    );
  }

  Future<void> _tryRecordFileTypeUatEvidence({
    required String jobId,
    required PwfDocumentProcessingResult engineResult,
  }) async {
    try {
      await _client.rpc(
        'rpc_document_file_type_uat_evidence_record_v1',
        params: {
          'p_job_id': jobId,
          'p_file_family': engineResult.fileFamily,
          'p_file_extension': engineResult.fileExtension,
          'p_engine_profile': engineResult.engineProfile,
          'p_evidence_payload': engineResult.toUatEvidencePayload(),
        },
      );
    } catch (_) {
      // Non-blocking: older baselines may not have SQL patch 05 applied yet.
    }
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  int _estimatePageCount(String fileName, DocumentJobMode mode) {
    final ext = p.extension(fileName).toLowerCase();
    if ({'.pdf', '.tif', '.tiff'}.contains(ext)) return 2;
    if (mode == DocumentJobMode.restoreHtr ||
        mode == DocumentJobMode.restoreOcr)
      return 1;
    return 1;
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
}
