
import 'pwf_payload_contract.dart';

class CmsPayloadContracts {
  const CmsPayloadContracts._();

  static const String defaultAuthor = 'إدارة المحتوى';

  static final PwfPayloadContract newsArticles = PwfPayloadContract(
    name: 'news_articles',
    allowedFields: {
      'title',
      'excerpt',
      'content',
      'category',
      'status',
      'image_url',
      'author',
      'published_at',
      'created_at',
      'updated_at',
      'unit_id',
      'tags',
      'view_count',
      'is_featured',
    },
    requiredFields: {
      'title',
      'content',
      'author',
    },
    defaults: {
      'author': defaultAuthor,
    },
    stripFields: {
      'attachment_url',
      'attachment_path',
      'is_pinned',
      'sort_order',
      'publish_at',
    },
    normalizers: {
      'status': _normalizePublicationStatus,
      'title': _trimString,
      'excerpt': _trimNullableString,
      'content': _trimString,
      'author': _trimNullableString,
      'category': _trimNullableString,
    },
  );

  static final PwfPayloadContract announcements = PwfPayloadContract(
    name: 'announcements',
    allowedFields: {
      'title',
      'content',
      'priority',
      'is_active',
      'published_at',
      'created_at',
      'updated_at',
      'unit_id',
      'target_audience',
      'start_date',
      'end_date',
    },
    requiredFields: {
      'title',
      'content',
    },
    stripFields: {
      'attachment_url',
      'attachment_path',
      'image_url',
      'is_featured',
      'is_pinned',
      'publish_at',
      'sort_order',
    },
    normalizers: {
      'title': _trimString,
      'content': _trimString,
      'priority': _normalizePriority,
    },
  );

  static final PwfPayloadContract activities = PwfPayloadContract(
    name: 'activities',
    allowedFields: {
      'title',
      'description',
      'content',
      'start_date',
      'end_date',
      'location',
      'status',
      'image_url',
      'created_at',
      'updated_at',
      'unit_id',
      'registration_info',
    },
    requiredFields: {
      'title',
    },
    stripFields: {
      'attachment_url',
      'attachment_path',
      'is_featured',
      'is_pinned',
      'publish_at',
      'sort_order',
    },
    normalizers: {
      'title': _trimString,
      'description': _trimNullableString,
      'content': _trimNullableString,
      'status': _normalizePublicationStatus,
    },
  );

  static PwfPayloadContractResult sanitizeTablePayload(
    String table,
    Map<String, dynamic> payload,
  ) {
    switch (table) {
      case 'news_articles':
        return newsArticles.sanitize(payload);
      case 'announcements':
        return announcements.sanitize(payload);
      case 'activities':
        return activities.sanitize(payload);
      default:
        return PwfPayloadContract(
          name: table,
          allowedFields: payload.keys.toSet(),
        ).sanitize(payload);
    }
  }

  static dynamic _trimString(dynamic value) {
    if (value is String) return value.trim();
    return value;
  }

  static dynamic _trimNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value;
  }

  static dynamic _normalizePublicationStatus(dynamic value) {
    if (value == null) return value;
    final raw = value.toString().trim().toLowerCase();
    switch (raw) {
      case 'draft':
      case 'مسودة':
        return 'draft';
      case 'published':
      case 'منشور':
      case 'published_now':
        return 'published';
      case 'archived':
      case 'مؤرشف':
        return 'archived';
      default:
        return value;
    }
  }

  static dynamic _normalizePriority(dynamic value) {
    if (value == null) return value;
    final raw = value.toString().trim().toLowerCase();
    switch (raw) {
      case 'low':
      case 'منخفض':
        return 'low';
      case 'medium':
      case 'متوسط':
        return 'medium';
      case 'high':
      case 'مرتفع':
        return 'high';
      case 'urgent':
      case 'عاجل':
        return 'urgent';
      default:
        return value;
    }
  }
}
