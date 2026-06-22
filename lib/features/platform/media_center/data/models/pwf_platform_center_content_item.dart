import 'package:flutter/foundation.dart';

@immutable
class PwfPlatformCenterContentQuery {
  const PwfPlatformCenterContentQuery({
    required this.familyKey,
    required this.unitSlug,
    this.publishedOnly = false,
    this.limit = 12,
  });

  final String familyKey;
  final String unitSlug;
  final bool publishedOnly;
  final int limit;

  String get normalizedFamilyKey => familyKey.trim().replaceAll('-', '_');

  Map<String, dynamic> toRpcParams() => <String, dynamic>{
    'p_family_key': normalizedFamilyKey,
    'p_unit_slug': unitSlug.trim().isEmpty ? 'home' : unitSlug.trim(),
    'p_published_only': publishedOnly,
    'p_limit': limit,
  };

  @override
  bool operator ==(Object other) {
    return other is PwfPlatformCenterContentQuery &&
        other.familyKey == familyKey &&
        other.unitSlug == unitSlug &&
        other.publishedOnly == publishedOnly &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(familyKey, unitSlug, publishedOnly, limit);
}

@immutable
class PwfPlatformCenterContentItem {
  const PwfPlatformCenterContentItem({
    required this.id,
    required this.familyKey,
    required this.title,
    required this.summary,
    required this.ownerName,
    required this.scopeType,
    required this.status,
    required this.route,
    this.publishedAt,
    this.documentUrl,
    this.body = '',
    this.categoryKey = '',
    this.unitSlug = 'home',
    this.metadata = const <String, dynamic>{},
    this.isFallback = false,
  });

  final String id;
  final String familyKey;
  final String title;
  final String summary;
  final String ownerName;
  final String scopeType;
  final String status;
  final String route;
  final DateTime? publishedAt;
  final String? documentUrl;
  final String body;
  final String categoryKey;
  final String unitSlug;
  final Map<String, dynamic> metadata;
  final bool isFallback;

  bool get isPublished {
    final value = status.trim().toLowerCase();
    return value == 'published' ||
        value == 'ready_to_publish' ||
        value == 'منشور' ||
        value == 'جاهز للنشر';
  }

  bool get isReview {
    final value = status.trim().toLowerCase();
    return value == 'review' ||
        value == 'in_review' ||
        status == 'قيد المراجعة';
  }

  bool get isDraft =>
      status.trim().toLowerCase() == 'draft' || status == 'مسودة';

  /// Date used for strict newest-first display across Media Center lists.
  /// Activities and events use their occurrence date; other families use their
  /// publication/issue date with created-at as a final fallback.
  DateTime? get chronologyDate {
    final family = familyKey.trim().toLowerCase().replaceAll('-', '_');
    if (family == 'activities' || family == 'events') {
      return _metadataDate(const <String>[
        'event_date',
        'start_date',
        'published_at',
        'publish_at',
        'created_at',
      ]) ?? publishedAt;
    }
    return publishedAt ?? _metadataDate(const <String>[
      'issue_date',
      'published_at',
      'publish_at',
      'date',
      'created_at',
    ]);
  }

  DateTime? _metadataDate(List<String> keys) {
    for (final key in keys) {
      final value = metadata[key];
      if (value is DateTime) return value;
      final parsed = DateTime.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return null;
  }

  factory PwfPlatformCenterContentItem.fromJson(Map<String, dynamic> json) {
    String text(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final stringValue = value.toString().trim();
        if (stringValue.isNotEmpty) return stringValue;
      }
      return fallback;
    }

    DateTime? date(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is DateTime) return value;
        final parsed = DateTime.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
      return null;
    }

    final family = text([
      'family_key',
      'family',
      'content_family',
      'type',
      'category',
    ], 'media_center');
    final id = text(['id', 'content_id', 'uuid'], '${family}_${json.hashCode}');
    return PwfPlatformCenterContentItem(
      id: id,
      familyKey: family,
      title: text([
        'title_ar',
        'title',
        'name_ar',
        'name',
        'label_ar',
      ], 'عنصر محتوى'),
      summary: text([
        'summary_ar',
        'summary',
        'description_ar',
        'description',
        'excerpt',
        'body_ar',
      ], 'لا يوجد وصف مختصر.'),
      ownerName: text([
        'owner_unit_name_ar',
        'owner_name',
        'unit_name',
        'unit_name_ar',
        'created_by_name',
        'source_name',
      ], 'الوزارة'),
      scopeType: text(['scope_type', 'scope', 'visibility_scope'], 'central'),
      status: text([
        'workflow_status',
        'status',
        'publication_status',
      ], 'draft'),
      route: text(['public_route', 'route', 'href', 'url'], ''),
      publishedAt: date(['published_at', 'publish_at', 'date', 'created_at']),
      documentUrl:
          text(['document_url', 'file_url', 'attachment_url'], '').isEmpty
          ? null
          : text(['document_url', 'file_url', 'attachment_url'], ''),
      body: text(['body_ar', 'body', 'content_ar', 'content'], ''),
      categoryKey: text(['category_key', 'category', 'type_key'], ''),
      unitSlug: text([
        'owner_unit_slug',
        'unit_slug',
        'unit',
        'scope_slug',
      ], 'home'),
      metadata: json,
      isFallback: false,
    );
  }

  static List<PwfPlatformCenterContentItem> fallbackItems(
    PwfPlatformCenterContentQuery query,
  ) {
    final family = query.normalizedFamilyKey;
    final labels = _labelsForFamily(family);
    final baseRoute = _routeForFamily(family);
    final rows = <PwfPlatformCenterContentItem>[
      PwfPlatformCenterContentItem(
        id: '${family}_published',
        familyKey: family,
        title: '${labels.$1} — عنصر منشور',
        summary: labels.$2,
        ownerName: query.unitSlug == 'home'
            ? 'الإدارة العامة المختصة'
            : 'وحدة ${query.unitSlug}',
        scopeType: query.unitSlug == 'home' ? 'central' : 'unit',
        status: 'جاهز للنشر',
        route: baseRoute,
        publishedAt: DateTime(2026, 5, 9),
        body: labels.$2,
        categoryKey: 'general',
        unitSlug: query.unitSlug,
        isFallback: true,
      ),
      PwfPlatformCenterContentItem(
        id: '${family}_review',
        familyKey: family,
        title: '${labels.$1} — قيد المراجعة',
        summary:
            'عنصر محفوظ ضمن سير المراجعة ولا يظهر للجمهور إلا بعد اعتماد النشر.',
        ownerName: 'فريق المراجعة',
        scopeType: 'central',
        status: 'قيد المراجعة',
        route: baseRoute,
        publishedAt: DateTime(2026, 5, 8),
        body:
            'عنصر محفوظ ضمن سير المراجعة ولا يظهر للجمهور إلا بعد اعتماد النشر.',
        categoryKey: 'review',
        unitSlug: query.unitSlug,
        isFallback: true,
      ),
      PwfPlatformCenterContentItem(
        id: '${family}_draft',
        familyKey: family,
        title: '${labels.$1} — مسودة',
        summary:
            'مسودة داخلية تظهر للإدارة فقط ضمن بيئة fallback إلى حين تفعيل RPC/Views.',
        ownerName: 'محرر المحتوى',
        scopeType: 'central',
        status: 'مسودة',
        route: baseRoute,
        publishedAt: null,
        body:
            'مسودة داخلية تظهر للإدارة فقط ضمن بيئة fallback إلى حين تفعيل RPC/Views.',
        categoryKey: 'draft',
        unitSlug: query.unitSlug,
        isFallback: true,
      ),
    ];
    if (query.publishedOnly) {
      return rows
          .where((row) => row.isPublished)
          .take(query.limit)
          .toList(growable: false);
    }
    return rows.take(query.limit).toList(growable: false);
  }

  static (String, String) _labelsForFamily(String family) {
    switch (family) {
      case 'social_posts':
        return (
          'الاجتماعيات',
          'منشور اجتماعي رسمي ضمن المركز الإعلامي، مفصول عن الخدمات الاجتماعية والمعاملات.',
        );
      case 'press_releases':
        return (
          'البيانات الصحفية',
          'بيان صحفي رسمي قابل للأرشفة والاستشهاد بعد اعتماده من الجهة المخولة.',
        );
      case 'official_statements':
        return (
          'التصريحات الرسمية',
          'تصريح منسوب لجهة مخولة مع حالة نشر ونطاق واضحين.',
        );
      case 'awareness_campaigns':
        return (
          'الحملات التوعوية',
          'حملة توعوية لها هدف وفترة ورسائل ومواد إعلامية مرتبطة.',
        );
      case 'sanctities_observatory':
        return (
          'مرصد حماية المقدسات',
          'واقعة أو تقرير موثق بلغة حكومية قابلة للتدقيق والاستشهاد.',
        );
      case 'legal_references':
        return (
          'المراجع القانونية والتنظيمية',
          'مرجع رسمي من القوانين أو التعليمات أو النماذج أو الأدلة الإجرائية.',
        );
      case 'events':
        return (
          'الفعاليات',
          'فعالية رسمية لها موعد ومكان وحالة، منفصلة عن أرشيف الأنشطة.',
        );
      case 'services_center':
        return (
          'مركز الخدمات',
          'مدخل خدمة أو نموذج أو متابعة طلب ضمن مركز الخدمات.',
        );
      default:
        return (
          'المركز الإعلامي',
          'محتوى رسمي قابل للربط بالمركز الإعلامي والصفحة الرئيسية.',
        );
    }
  }

  static String _routeForFamily(String family) {
    switch (family) {
      case 'social_posts':
        return '/home/social-posts';
      case 'press_releases':
        return '/home/press-releases';
      case 'official_statements':
        return '/home/official-statements';
      case 'awareness_campaigns':
        return '/home/awareness-campaigns';
      case 'sanctities_observatory':
        return '/home/sanctities-observatory';
      case 'legal_references':
        return '/home/legal-references';
      case 'events':
        return '/home/events';
      case 'services_center':
        return '/home/services';
      default:
        return '/home/media-center';
    }
  }
}

@immutable
class PwfPlatformCenterContentDraft {
  const PwfPlatformCenterContentDraft({
    this.id,
    required this.familyKey,
    required this.title,
    required this.summary,
    this.body = '',
    required this.scopeType,
    required this.unitSlug,
    this.categoryKey = 'general',
    this.documentUrl,
    this.metadata = const <String, dynamic>{},
  });

  final String? id;
  final String familyKey;
  final String title;
  final String summary;
  final String body;
  final String scopeType;
  final String unitSlug;
  final String categoryKey;
  final String? documentUrl;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toRpcParams() => <String, dynamic>{
    'p_id': id,
    'p_family_key': familyKey.trim().replaceAll('-', '_'),
    'p_title': title.trim(),
    'p_summary': summary.trim(),
    'p_body': body.trim(),
    'p_scope_type': scopeType.trim(),
    'p_unit_slug': unitSlug.trim().isEmpty ? 'home' : unitSlug.trim(),
    'p_category_key': categoryKey.trim().isEmpty
        ? 'general'
        : categoryKey.trim(),
    'p_document_url': documentUrl?.trim(),
    'p_metadata': metadata,
  };

  Map<String, dynamic> toLegacyRpcParams() => <String, dynamic>{
    'p_family_key': familyKey.trim().replaceAll('-', '_'),
    'p_title': title.trim(),
    'p_summary': summary.trim(),
    'p_scope_type': scopeType.trim(),
    'p_unit_slug': unitSlug.trim().isEmpty ? 'home' : unitSlug.trim(),
  };
}

@immutable
class PwfPlatformCenterContentWriteResult {
  const PwfPlatformCenterContentWriteResult({
    required this.success,
    required this.messageAr,
    this.id,
    this.isFallback = false,
  });

  final bool success;
  final String messageAr;
  final String? id;
  final bool isFallback;
}
