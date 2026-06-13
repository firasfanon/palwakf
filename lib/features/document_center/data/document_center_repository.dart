
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/document_center_models.dart';

class DocumentCenterRepository {
  DocumentCenterRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<DocumentCenterDashboard> loadDashboard({int limitPerSurface = 12}) async {
    final items = <DocumentCenterItem>[];
    final errors = <String, String>{};
    final loaded = <DocumentCenterSurface>{};

    try {
      final rows = await _loadDocumentIntelligenceRows(limitPerSurface);
      items.addAll(rows.map(_documentIntelligenceItemFromRow));
      loaded.add(DocumentCenterSurface.documentIntelligence);
    } catch (error) {
      errors['document_intelligence'] = error.toString();
    }

    final serviceRows = await _loadServiceAttachmentRows(limitPerSurface);
    items.addAll(serviceRows.map(_serviceAttachmentItemFromRow));
    loaded.add(DocumentCenterSurface.serviceAttachment);

    final mediaRows = await _loadMediaAssetRows(limitPerSurface);
    items.addAll(mediaRows.map(_mediaAssetItemFromRow));
    loaded.add(DocumentCenterSurface.mediaAsset);

    final storageObjectRows = await _loadStorageObjectRows(limitPerSurface);
    items.addAll(storageObjectRows.map(_storageObjectItemFromRow));
    loaded.add(DocumentCenterSurface.storageObject);

    items.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null && bDate == null) return a.title.compareTo(b.title);
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return DocumentCenterDashboard(
      items: items,
      metrics: DocumentCenterMetrics.fromItems(items),
      surfaceErrors: errors,
      loadedSurfaces: loaded,
    );
  }

  Future<List<Map<String, dynamic>>> _loadDocumentIntelligenceRows(int limit) async {
    final result = await _client.rpc(
      'rpc_document_job_list_v1',
      params: const <String, dynamic>{
        'p_source_system': null,
        'p_mode': null,
        'p_status': null,
        'p_waqf_asset_id': null,
        'p_case_id': null,
      },
    );

    return _rowsFrom(result).take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> _loadServiceAttachmentRows(int limit) {
    return _loadOptionalPublicRows(
      'v_document_center_service_attachments_v1',
      limit,
    );
  }

  Future<List<Map<String, dynamic>>> _loadMediaAssetRows(int limit) {
    return _loadOptionalPublicRows(
      'v_document_center_media_assets_v1',
      limit,
    );
  }

  Future<List<Map<String, dynamic>>> _loadStorageObjectRows(int limit) {
    return _loadOptionalPublicRows(
      'v_document_center_storage_objects_v1',
      limit,
    );
  }

  Future<List<Map<String, dynamic>>> _loadOptionalPublicRows(
    String viewName,
    int limit,
  ) async {
    try {
      final result = await _client.from(viewName).select('*').limit(limit);
      return _rowsFrom(result);
    } catch (_) {
      // Owner schemas such as platform_services and media_center are not exposed
      // directly to PostgREST. Until the public wrapper views are applied, the
      // unified portal must degrade gracefully instead of surfacing PGRST106.
      return const <Map<String, dynamic>>[];
    }
  }

  DocumentCenterItem _documentIntelligenceItemFromRow(Map<String, dynamic> row) {
    final id = _string(row['id'] ?? row['job_id']);
    final sourceSystem = _string(row['source_system']);
    final sourceRecordId = _string(row['source_record_id']);
    final status = _string(row['status']);
    final mode = _string(row['mode']);

    return DocumentCenterItem(
      id: id.isEmpty ? 'document-job-${row.hashCode}' : id,
      title: _firstNonEmpty(<String>[
        _string(row['title']),
        _string(row['document_title']),
        _string(row['original_file_name']),
        id.isEmpty ? 'مهمة ذكاء وثائقي' : 'مهمة ذكاء وثائقي $id',
      ]),
      subtitle: _firstNonEmpty(<String>[
        sourceSystem.isEmpty ? '' : 'النظام المصدر: $sourceSystem',
        mode.isEmpty ? '' : 'وضع المعالجة: $mode',
      ]),
      status: status,
      sourceSystem: sourceSystem,
      sourceRecordId: sourceRecordId,
      createdAt: _date(row['created_at'] ?? row['updated_at']),
      surface: DocumentCenterSurface.documentIntelligence,
      retentionClass: _documentIntelligenceRetention(sourceSystem),
      raw: row,
    );
  }

  DocumentCenterItem _serviceAttachmentItemFromRow(Map<String, dynamic> row) {
    final id = _string(row['id']);
    final attachmentKey = _string(row['attachment_key']);
    final requestId = _string(row['request_id']);
    final reviewStatus = _string(row['review_status']);

    return DocumentCenterItem(
      id: id.isEmpty ? 'service-attachment-${row.hashCode}' : id,
      title: _firstNonEmpty(<String>[
        _string(row['title']),
        _string(row['file_name']),
        attachmentKey.isEmpty ? '' : 'مرفق خدمة: $attachmentKey',
        'مرفق طلب خدمة',
      ]),
      subtitle: requestId.isEmpty ? null : 'طلب الخدمة: $requestId',
      fileName: _string(row['file_name']),
      mimeType: _string(row['mime_type']),
      fileSizeBytes: _int(row['file_size_bytes']),
      storageBucket: _string(row['storage_bucket']),
      storagePath: _string(row['storage_path']),
      status: reviewStatus,
      sourceSystem: 'platform_services',
      sourceRecordId: requestId,
      createdAt: _date(row['uploaded_at'] ?? row['created_at']),
      surface: DocumentCenterSurface.serviceAttachment,
      retentionClass: _retentionFromRow(
        row,
        fallback: _serviceAttachmentRetention(attachmentKey, reviewStatus),
      ),
      raw: row,
    );
  }


  DocumentCenterItem _storageObjectItemFromRow(Map<String, dynamic> row) {
    final id = _string(row['id']);
    final bucket = _string(row['storage_bucket']);
    final path = _string(row['storage_path']);
    final sourceSystem = _string(row['source_system']);
    final assignmentStatus = _string(row['unit_assignment_status']);
    final visibilityScope = _string(row['visibility_scope']);
    final mappingStatus = _string(row['mapping_status']);
    final ownerUnitName = _string(row['owner_unit_name_ar']);
    final scopeType = _string(row['scope_type']);

    final pathParts = path
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    final fileNameFromPath = pathParts.isEmpty ? '' : pathParts.last;

    final title = _firstNonEmpty(<String>[
      _string(row['title']),
      fileNameFromPath,
      'ملف تخزين',
    ]);

    return DocumentCenterItem(
      id: id.isEmpty ? 'storage-object-${row.hashCode}' : id,
      title: title,
      subtitle: _firstNonEmpty(<String>[
        ownerUnitName.isEmpty ? '' : 'الوحدة المالكة: $ownerUnitName',
        scopeType.isEmpty ? '' : 'النطاق: $scopeType',
        sourceSystem.isEmpty ? '' : 'النظام المصدر: $sourceSystem',
      ]),
      fileName: title,
      mimeType: _string(row['mime_type']),
      fileSizeBytes: _int(row['file_size_bytes']),
      storageBucket: bucket,
      storagePath: path,
      status: _firstNonEmpty(<String>[
        assignmentStatus.isEmpty ? '' : 'الوحدة: $assignmentStatus',
        visibilityScope.isEmpty ? '' : 'الرؤية: $visibilityScope',
        mappingStatus.isEmpty ? '' : 'الربط: $mappingStatus',
      ]),
      sourceSystem: sourceSystem,
      sourceRecordId: _string(row['source_record_id']),
      createdAt: _date(row['created_at'] ?? row['updated_at']),
      surface: DocumentCenterSurface.storageObject,
      retentionClass: _retentionFromRow(
        row,
        fallback: DocumentRetentionClass.operational,
      ),
      raw: row,
    );
  }

  DocumentCenterItem _mediaAssetItemFromRow(Map<String, dynamic> row) {
    final id = _string(row['id']);
    final status = _firstNonEmpty(<String>[
      _string(row['status']),
      _string(row['publication_status']),
      'active',
    ]);
    final contentId = _string(row['content_item_id'] ?? row['content_id']);
    final title = _firstNonEmpty(<String>[
      _string(row['title']),
      _string(row['title_ar']),
      _string(row['name_ar']),
      _string(row['filename']),
      _string(row['file_name']),
      _string(row['url']),
      'أصل إعلامي',
    ]);

    return DocumentCenterItem(
      id: id.isEmpty ? 'media-asset-${row.hashCode}' : id,
      title: title,
      subtitle: contentId.isEmpty ? null : 'محتوى إعلامي: $contentId',
      fileName: _firstNonEmpty(<String>[
        _string(row['filename']),
        _string(row['file_name']),
      ]),
      mimeType: _string(row['mime_type']),
      fileSizeBytes: _int(row['file_size_bytes']),
      storageBucket: _string(row['storage_bucket']),
      storagePath: _string(row['storage_path']),
      status: status,
      sourceSystem: 'media_center',
      sourceRecordId: contentId,
      createdAt: _date(row['created_at'] ?? row['uploaded_at']),
      surface: DocumentCenterSurface.mediaAsset,
      retentionClass: _retentionFromRow(
        row,
        fallback: DocumentRetentionClass.publicMedia,
      ),
      raw: row,
    );
  }

  DocumentRetentionClass _documentIntelligenceRetention(String sourceSystem) {
    switch (sourceSystem) {
      case 'cases':
      case 'legal_system':
      case 'awqaf_system':
        return DocumentRetentionClass.legalEvidence;
      case 'assistant':
        return DocumentRetentionClass.longTermReference;
      default:
        return DocumentRetentionClass.operational;
    }
  }

  DocumentRetentionClass _serviceAttachmentRetention(
    String attachmentKey,
    String reviewStatus,
  ) {
    final normalized = attachmentKey.toLowerCase();
    if (normalized.contains('identity') ||
        normalized.contains('id') ||
        normalized.contains('deed') ||
        normalized.contains('حجة') ||
        normalized.contains('سند') ||
        normalized.contains('قرار')) {
      return DocumentRetentionClass.longTermReference;
    }

    if (reviewStatus == 'rejected') {
      return DocumentRetentionClass.operational;
    }

    return DocumentRetentionClass.operational;
  }

  DocumentRetentionClass _retentionFromRow(
    Map<String, dynamic> row, {
    required DocumentRetentionClass fallback,
  }) {
    switch (_string(row['retention_class'])) {
      case 'transient':
        return DocumentRetentionClass.transient;
      case 'operational':
        return DocumentRetentionClass.operational;
      case 'long_term_reference':
        return DocumentRetentionClass.longTermReference;
      case 'legal_evidence':
        return DocumentRetentionClass.legalEvidence;
      case 'public_media':
        return DocumentRetentionClass.publicMedia;
      default:
        return fallback;
    }
  }

  List<Map<String, dynamic>> _rowsFrom(dynamic result) {
    if (result is List) {
      return result
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList();
    }
    if (result is Map && result['data'] is List) {
      return _rowsFrom(result['data']);
    }
    return const <Map<String, dynamic>>[];
  }

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  String _string(dynamic value) => value == null ? '' : value.toString();

  int? _int(dynamic value) {
    if (value is int) return value;
    return int.tryParse(_string(value));
  }

  DateTime? _date(dynamic value) {
    final text = _string(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
