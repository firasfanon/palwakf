
enum DocumentCenterSurface {
  documentIntelligence,
  serviceAttachment,
  mediaAsset,
  storageObject,
}

enum DocumentRetentionClass {
  transient,
  operational,
  longTermReference,
  legalEvidence,
  publicMedia,
}

class DocumentCenterLabels {
  const DocumentCenterLabels._();

  static String surface(DocumentCenterSurface value) {
    switch (value) {
      case DocumentCenterSurface.documentIntelligence:
        return 'الذكاء الوثائقي';
      case DocumentCenterSurface.serviceAttachment:
        return 'مرفقات الخدمات';
      case DocumentCenterSurface.mediaAsset:
        return 'أصول المركز الإعلامي';
      case DocumentCenterSurface.storageObject:
        return 'سجل ملفات التخزين';
    }
  }

  static String retention(DocumentRetentionClass value) {
    switch (value) {
      case DocumentRetentionClass.transient:
        return 'مؤقت';
      case DocumentRetentionClass.operational:
        return 'تشغيلي';
      case DocumentRetentionClass.longTermReference:
        return 'مرجع طويل الأمد';
      case DocumentRetentionClass.legalEvidence:
        return 'دليل قانوني';
      case DocumentRetentionClass.publicMedia:
        return 'إعلامي عام';
    }
  }
}

class DocumentCenterItem {
  const DocumentCenterItem({
    required this.id,
    required this.title,
    required this.surface,
    required this.retentionClass,
    this.subtitle,
    this.fileName,
    this.mimeType,
    this.fileSizeBytes,
    this.storageBucket,
    this.storagePath,
    this.status,
    this.sourceSystem,
    this.sourceRecordId,
    this.createdAt,
    this.raw = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? fileName;
  final String? mimeType;
  final int? fileSizeBytes;
  final String? storageBucket;
  final String? storagePath;
  final String? status;
  final String? sourceSystem;
  final String? sourceRecordId;
  final DateTime? createdAt;
  final DocumentCenterSurface surface;
  final DocumentRetentionClass retentionClass;
  final Map<String, dynamic> raw;

  bool get hasStorageReference =>
      storageBucket != null &&
      storageBucket!.trim().isNotEmpty &&
      storagePath != null &&
      storagePath!.trim().isNotEmpty;

  bool get isLongLived =>
      retentionClass == DocumentRetentionClass.longTermReference ||
      retentionClass == DocumentRetentionClass.legalEvidence;

  String get surfaceLabel => DocumentCenterLabels.surface(surface);

  String get retentionLabel => DocumentCenterLabels.retention(retentionClass);
}

class DocumentCenterMetrics {
  const DocumentCenterMetrics({
    required this.total,
    required this.documentIntelligence,
    required this.serviceAttachments,
    required this.mediaAssets,
    required this.storageObjects,
    required this.longLived,
    required this.transient,
    required this.withStorageReference,
  });

  final int total;
  final int documentIntelligence;
  final int serviceAttachments;
  final int mediaAssets;
  final int storageObjects;
  final int longLived;
  final int transient;
  final int withStorageReference;

  factory DocumentCenterMetrics.fromItems(List<DocumentCenterItem> items) {
    int countSurface(DocumentCenterSurface surface) =>
        items.where((item) => item.surface == surface).length;

    return DocumentCenterMetrics(
      total: items.length,
      documentIntelligence: countSurface(
        DocumentCenterSurface.documentIntelligence,
      ),
      serviceAttachments: countSurface(DocumentCenterSurface.serviceAttachment),
      mediaAssets: countSurface(DocumentCenterSurface.mediaAsset),
      storageObjects: countSurface(DocumentCenterSurface.storageObject),
      longLived: items.where((item) => item.isLongLived).length,
      transient: items
          .where((item) => item.retentionClass == DocumentRetentionClass.transient)
          .length,
      withStorageReference: items.where((item) => item.hasStorageReference).length,
    );
  }

  static const empty = DocumentCenterMetrics(
    total: 0,
    documentIntelligence: 0,
    serviceAttachments: 0,
    mediaAssets: 0,
    storageObjects: 0,
    longLived: 0,
    transient: 0,
    withStorageReference: 0,
  );
}

class DocumentCenterDashboard {
  const DocumentCenterDashboard({
    required this.items,
    required this.metrics,
    required this.surfaceErrors,
    required this.loadedSurfaces,
  });

  final List<DocumentCenterItem> items;
  final DocumentCenterMetrics metrics;
  final Map<String, String> surfaceErrors;
  final Set<DocumentCenterSurface> loadedSurfaces;

  bool get hasErrors => surfaceErrors.isNotEmpty;

  static const empty = DocumentCenterDashboard(
    items: <DocumentCenterItem>[],
    metrics: DocumentCenterMetrics.empty,
    surfaceErrors: <String, String>{},
    loadedSurfaces: <DocumentCenterSurface>{},
  );
}
