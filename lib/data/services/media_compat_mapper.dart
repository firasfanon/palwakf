import '../models/activity.dart';
import '../models/announcement.dart';
import '../models/media_gallery_item.dart';
import '../models/news_article.dart';

/// Maps Database Wave B-1A media compatibility rows into the legacy public
/// models that current public Flutter surfaces already render.
///
/// This is a controlled runtime bridge, not a domain extraction layer. It reads
/// from owner-schema media_center.v_unit_public_*_runtime_v1 surfaces and keeps the
/// old public models stable until the media_center domain receives native UI
/// models in a later wave.
class MediaCompatMapper {
  const MediaCompatMapper._();

  static NewsArticle newsFromCompatRow(Map<String, dynamic> row) {
    final legacy = _legacyPayload(row);
    final title = _firstText(row, legacy, const [
      'title_ar',
      'title',
      'headline_ar',
      'name_ar',
      'content_key',
    ], fallback: 'خبر بدون عنوان');
    final summary = _firstText(row, legacy, const [
      'summary_ar',
      'excerpt_ar',
      'description_ar',
      'summary',
      'excerpt',
      'description',
    ], fallback: title);
    final body = _firstText(row, legacy, const [
      'body_ar',
      'content_ar',
      'body',
      'content',
      'description',
      'summary_ar',
      'summary',
      'excerpt',
    ], fallback: summary);
    final publishedAt = _firstDate(row, legacy, const [
      'published_at',
      'publish_date',
      'publish_at',
      'created_at',
    ]);
    final createdAt =
        _firstDate(row, legacy, const [
          'created_at',
          'published_at',
          'publish_date',
        ]) ??
        DateTime.now();
    final updatedAt =
        _firstDate(row, legacy, const [
          'updated_at',
          'modified_at',
          'created_at',
        ]) ??
        createdAt;

    return NewsArticle(
      id: _stableIntId(
        _firstRaw(row, legacy, const [
          'content_id',
          'legacy_source_id',
          'legacy_id',
          'id',
          'content_key',
        ]),
      ),
      runtimeContentId: _runtimeContentId(row, legacy),
      title: title,
      excerpt: summary,
      content: body,
      imageUrl: _firstNullableText(row, legacy, const [
        'image_url',
        'imageUrl',
        'thumbnail_url',
        'cover_url',
        'photo_url',
      ]),
      attachmentUrl: _firstNullableText(row, legacy, const [
        'attachment_url',
        'file_url',
        'document_url',
      ]),
      author: _firstText(row, legacy, const [
        'author',
        'author_ar',
        'created_by_name',
      ], fallback: 'مركز الإعلام'),
      unitId: _firstNullableText(row, legacy, const [
        'owner_org_unit_id',
        'org_unit_id',
        'owner_unit_id',
        'unit_id',
        'owner_unit_slug',
        'unit_slug',
        'scope_slug',
        'public_slug',
        'canonical_slug',
        'directorate_slug',
        'directorate_name',
        'unit_name_ar',
        'owner_name',
      ]),
      category: _newsCategory(
        _firstNullableText(row, legacy, const [
          'category_key',
          'category',
          'content_type',
        ]),
      ),
      status: PublishStatus.published,
      viewCount: _firstInt(row, legacy, const ['view_count', 'views']) ?? 0,
      isFeatured:
          _firstBool(row, legacy, const ['is_featured', 'featured']) ?? false,
      isPinned: _firstBool(row, legacy, const ['is_pinned', 'pinned']) ?? false,
      sortOrder: _firstInt(row, legacy, const ['sort_order']) ?? 0,
      tags: _tags(row, legacy),
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static Announcement announcementFromCompatRow(Map<String, dynamic> row) {
    final legacy = _legacyPayload(row);
    final title = _firstText(row, legacy, const [
      'title_ar',
      'title',
      'name_ar',
      'content_key',
    ], fallback: 'إعلان بدون عنوان');
    final content = _firstText(row, legacy, const [
      'body_ar',
      'content_ar',
      'body',
      'content',
      'summary_ar',
      'summary',
      'description',
    ], fallback: title);
    final createdAt =
        _firstDate(row, legacy, const [
          'created_at',
          'published_at',
          'publish_date',
        ]) ??
        DateTime.now();

    return Announcement(
      id: _stableIntId(
        _firstRaw(row, legacy, const [
          'content_id',
          'legacy_source_id',
          'legacy_id',
          'id',
          'content_key',
        ]),
      ),
      runtimeContentId: _runtimeContentId(row, legacy),
      title: title,
      content: content,
      priority: _priority(
        _firstNullableText(row, legacy, const [
          'priority',
          'importance',
          'category_key',
        ]),
      ),
      validUntil: _firstDate(row, legacy, const ['valid_until', 'expires_at']),
      isActive: true,
      targetAudience: _firstText(row, legacy, const [
        'target_audience',
        'audience',
        'owner_org_unit_id',
        'org_unit_id',
        'owner_unit_id',
        'unit_id',
        'owner_unit_slug',
        'unit_slug',
        'scope_slug',
        'public_slug',
        'canonical_slug',
        'directorate_slug',
        'directorate_name',
        'unit_name_ar',
        'owner_name',
      ], fallback: 'public'),
      createdBy: _firstInt(row, legacy, const ['created_by']) ?? 0,
      createdAt: createdAt,
      imageUrl: _firstNullableText(row, legacy, const [
        'image_url',
        'imageUrl',
        'thumbnail_url',
        'cover_url',
      ]),
      attachmentUrl: _firstNullableText(row, legacy, const [
        'attachment_url',
        'file_url',
        'document_url',
      ]),
      isFeatured:
          _firstBool(row, legacy, const ['is_featured', 'featured']) ?? false,
      isPinned: _firstBool(row, legacy, const ['is_pinned', 'pinned']) ?? false,
      publishAt: _firstDate(row, legacy, const ['published_at', 'publish_at']),
      sortOrder: _firstInt(row, legacy, const ['sort_order']) ?? 0,
    );
  }

  static Activity activityFromCompatRow(Map<String, dynamic> row) {
    final legacy = _legacyPayload(row);
    final title = _firstText(row, legacy, const [
      'title_ar',
      'title',
      'name_ar',
      'content_key',
    ], fallback: 'نشاط بدون عنوان');
    final description = _firstText(row, legacy, const [
      'body_ar',
      'content_ar',
      'body',
      'content',
      'summary_ar',
      'summary',
      'description',
    ], fallback: title);
    final createdAt =
        _firstDate(row, legacy, const [
          'created_at',
          'published_at',
          'start_date',
        ]) ??
        DateTime.now();
    final startDate =
        _firstDate(row, legacy, const [
          'start_date',
          'event_date',
          'published_at',
          'publish_at',
          'created_at',
        ]) ??
        createdAt;
    final endDate = _firstDate(row, legacy, const ['end_date', 'finish_date']);
    final organizer = _firstText(row, legacy, const [
      'organizer',
      'owner_name',
      'created_by_name',
    ], fallback: 'وزارة الأوقاف والشؤون الدينية');

    return Activity(
      id: _stableIntId(
        _firstRaw(row, legacy, const [
          'content_id',
          'legacy_source_id',
          'legacy_id',
          'id',
          'content_key',
        ]),
      ),
      runtimeContentId: _runtimeContentId(row, legacy),
      title: title,
      description: description,
      category: _activityCategory(
        _firstNullableText(row, legacy, const [
          'category_key',
          'category',
          'content_type',
        ]),
      ),
      type: _activityType(
        _firstNullableText(row, legacy, const [
          'activity_type',
          'type',
          'content_type',
        ]),
      ),
      startDate: startDate,
      endDate: endDate,
      location: _firstText(row, legacy, const [
        'location',
        'place',
        'venue',
      ], fallback: ''),
      organizer: organizer,
      maxParticipants:
          _firstInt(row, legacy, const ['max_participants', 'capacity']) ?? 0,
      currentParticipants:
          _firstInt(row, legacy, const [
            'current_participants',
            'participants_count',
          ]) ??
          0,
      status: _activityStatus(
        _firstNullableText(row, legacy, const [
          'activity_status',
          'status',
          'content_type',
        ]),
      ),
      imageUrl: _firstNullableText(row, legacy, const [
        'image_url',
        'imageUrl',
        'thumbnail_url',
        'cover_url',
        'photo_url',
      ]),
      attachmentUrl: _firstNullableText(row, legacy, const [
        'attachment_url',
        'file_url',
        'document_url',
      ]),
      registrationInfo: <String, dynamic>{
        'legacy_payload': legacy,
        'compatibility_metadata': row['metadata'],
        'runtime_contract': row['compatibility_contract'],
      },
      requirements: const <String>[],
      contact: ContactInfo(name: organizer),
      requiresRegistration:
          _firstBool(row, legacy, const [
            'requires_registration',
            'registration_required',
          ]) ??
          false,
      isFree: _firstBool(row, legacy, const ['is_free', 'free']) ?? true,
      price: null,
      registrationUrl: _firstNullableText(row, legacy, const [
        'registration_url',
        'external_url',
      ]),
      registrationDeadline: _firstDate(row, legacy, const [
        'registration_deadline',
      ]),
      governorate: _firstText(row, legacy, const [
        'governorate',
        'governorate_name',
      ], fallback: ''),
      tags: _tags(row, legacy),
      isFeatured:
          _firstBool(row, legacy, const ['is_featured', 'featured']) ?? false,
      isPinned: _firstBool(row, legacy, const ['is_pinned', 'pinned']) ?? false,
      publishAt: _firstDate(row, legacy, const ['published_at', 'publish_at']),
      sortOrder: _firstInt(row, legacy, const ['sort_order']) ?? 0,
      createdAt: createdAt,
      updatedAt:
          _firstDate(row, legacy, const ['updated_at', 'modified_at']) ??
          createdAt,
      unitId: _firstNullableText(row, legacy, const [
        'owner_org_unit_id',
        'org_unit_id',
        'owner_unit_id',
        'unit_id',
        'owner_unit_slug',
        'unit_slug',
        'scope_slug',
        'public_slug',
        'canonical_slug',
        'directorate_slug',
        'directorate_name',
        'unit_name_ar',
        'owner_name',
      ]),
    );
  }

  static Map<String, dynamic> galleryLegacyMapFromCompatRow(
    Map<String, dynamic> row,
  ) {
    final legacy = _legacyPayload(row);
    final mediaUrl = _firstText(row, legacy, const [
      'media_url',
      'public_url',
      'url',
      'image_url',
      'video_url',
      'thumbnail_url',
      'cover_url',
      'external_url',
    ], fallback: '');
    final contentType = _firstNullableText(row, legacy, const [
      'asset_type',
      'media_type',
      'content_type',
      'mime_type',
    ]);

    return <String, dynamic>{
      'id': _firstRaw(row, legacy, const [
        'content_id',
        'legacy_source_id',
        'legacy_id',
        'id',
        'content_key',
      ]).toString(),
      'unit_id':
          _firstNullableText(row, legacy, const [
        'owner_org_unit_id',
        'org_unit_id',
        'owner_unit_id',
        'unit_id',
        'owner_unit_slug',
        'unit_slug',
        'scope_slug',
        'public_slug',
        'canonical_slug',
        'directorate_slug',
        'directorate_name',
        'unit_name_ar',
        'owner_name',
      ]) ?? '',
      'media_type': _galleryMediaType(contentType).dbValue,
      'title': _firstText(row, legacy, const [
        'title_ar',
        'title',
        'name_ar',
        'content_key',
      ], fallback: 'عنصر معرض'),
      'description': _firstText(row, legacy, const [
        'summary_ar',
        'description_ar',
        'description',
        'summary',
      ], fallback: ''),
      'media_url': mediaUrl,
      'thumbnail_url': _firstNullableText(row, legacy, const [
        'thumbnail_url',
        'cover_url',
        'image_url',
      ]),
      'external_url': _firstNullableText(row, legacy, const [
        'external_url',
        'public_url',
      ]),
      'is_active': true,
      'display_order': _firstInt(row, legacy, const ['display_order']) ?? 0,
      'is_featured': _firstBool(row, legacy, const ['is_featured']) ?? false,
      'is_pinned': _firstBool(row, legacy, const ['is_pinned']) ?? false,
      'publish_at': _firstDate(row, legacy, const [
        'published_at',
        'publish_at',
      ])?.toIso8601String(),
      'created_at': _firstDate(row, legacy, const [
        'created_at',
        'published_at',
      ])?.toIso8601String(),
    };
  }

  static MediaGalleryItem galleryItemFromCompatRow(Map<String, dynamic> row) {
    return MediaGalleryItem.fromMap(galleryLegacyMapFromCompatRow(row));
  }

  static int stableCompatIdFromRow(Map<String, dynamic> row) {
    final legacy = _legacyPayload(row);
    return _stableIntId(
      _firstRaw(row, legacy, const [
        'content_id',
        'legacy_source_id',
        'legacy_id',
        'id',
        'content_key',
      ]),
    );
  }

  static Map<String, dynamic> _legacyPayload(Map<String, dynamic> row) {
    final merged = <String, dynamic>{};

    final sourcePayload = row['source_payload'];
    if (sourcePayload is Map<String, dynamic>) {
      merged.addAll(sourcePayload);
      final sourceMetadata = sourcePayload['metadata'];
      if (sourceMetadata is Map<String, dynamic>) {
        final nested = sourceMetadata['legacy_payload'];
        if (nested is Map<String, dynamic>) merged.addAll(nested);
        if (nested is Map) merged.addAll(Map<String, dynamic>.from(nested));
      }
    } else if (sourcePayload is Map) {
      final sourceMap = Map<String, dynamic>.from(sourcePayload);
      merged.addAll(sourceMap);
      final sourceMetadata = sourceMap['metadata'];
      if (sourceMetadata is Map<String, dynamic>) {
        final nested = sourceMetadata['legacy_payload'];
        if (nested is Map<String, dynamic>) merged.addAll(nested);
        if (nested is Map) merged.addAll(Map<String, dynamic>.from(nested));
      }
    }

    final metadata = row['metadata'];
    if (metadata is Map<String, dynamic>) {
      final payload = metadata['legacy_payload'];
      if (payload is Map<String, dynamic>) merged.addAll(payload);
      if (payload is Map) merged.addAll(Map<String, dynamic>.from(payload));
    } else if (metadata is Map) {
      final payload = metadata['legacy_payload'];
      if (payload is Map<String, dynamic>) merged.addAll(payload);
      if (payload is Map) merged.addAll(Map<String, dynamic>.from(payload));
    }

    return merged;
  }

  static String? _runtimeContentId(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
  ) {
    final raw = _firstRaw(row, legacy, const [
      'content_id',
      'legacy_source_id',
      'legacy_id',
      'id',
      'content_key',
    ]);
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static dynamic _firstRaw(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rowValue = row[key];
      if (rowValue != null && rowValue.toString().trim().isNotEmpty) {
        return rowValue;
      }
      final legacyValue = legacy[key];
      if (legacyValue != null && legacyValue.toString().trim().isNotEmpty) {
        return legacyValue;
      }
    }
    return row['id'] ?? row['content_key'] ?? legacy['id'] ?? row.hashCode;
  }

  static String _firstText(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys, {
    required String fallback,
  }) {
    return _firstNullableText(row, legacy, keys) ?? fallback;
  }

  static String? _firstNullableText(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rowValue = row[key];
      final normalizedRow = _normalizeText(rowValue);
      if (normalizedRow != null) return normalizedRow;
      final legacyValue = legacy[key];
      final normalizedLegacy = _normalizeText(legacyValue);
      if (normalizedLegacy != null) return normalizedLegacy;
    }
    return null;
  }

  static String? _normalizeText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static DateTime? _firstDate(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rowDate = _parseDate(row[key]);
      if (rowDate != null) return rowDate;
      final legacyDate = _parseDate(legacy[key]);
      if (legacyDate != null) return legacyDate;
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static int? _firstInt(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rowInt = _parseInt(row[key]);
      if (rowInt != null) return rowInt;
      final legacyInt = _parseInt(legacy[key]);
      if (legacyInt != null) return legacyInt;
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _firstBool(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rowBool = _parseBool(row[key]);
      if (rowBool != null) return rowBool;
      final legacyBool = _parseBool(legacy[key]);
      if (legacyBool != null) return legacyBool;
    }
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty) return null;
    if (const ['true', 't', '1', 'yes', 'y'].contains(text)) return true;
    if (const ['false', 'f', '0', 'no', 'n'].contains(text)) return false;
    return null;
  }

  static List<String> _tags(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
  ) {
    final raw = legacy['tags'] ?? row['tags'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    final category = _firstNullableText(row, legacy, const ['category_key']);
    return category == null ? const <String>[] : <String>[category];
  }

  static ActivityCategory _activityCategory(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('educat') || value.contains('تعليم')) {
      return ActivityCategory.educational;
    }
    if (value.contains('cultur') || value.contains('ثقاف')) {
      return ActivityCategory.cultural;
    }
    if (value.contains('social') || value.contains('اجتماع')) {
      return ActivityCategory.social;
    }
    if (value.contains('family') || value.contains('عائل')) {
      return ActivityCategory.family;
    }
    if (value.contains('train') || value.contains('تدريب')) {
      return ActivityCategory.training;
    }
    if (value.contains('community') || value.contains('مجتمع')) {
      return ActivityCategory.community;
    }
    return ActivityCategory.religious;
  }

  static ActivityType _activityType(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('seminar') || value.contains('ندوة')) {
      return ActivityType.seminar;
    }
    if (value.contains('workshop') || value.contains('ورشة')) {
      return ActivityType.workshop;
    }
    if (value.contains('competition') || value.contains('مسابقة')) {
      return ActivityType.competition;
    }
    if (value.contains('exhibition') || value.contains('معرض')) {
      return ActivityType.exhibition;
    }
    if (value.contains('course') || value.contains('دورة')) {
      return ActivityType.course;
    }
    if (value.contains('conference') || value.contains('مؤتمر')) {
      return ActivityType.conference;
    }
    if (value.contains('ceremony') || value.contains('حفل')) {
      return ActivityType.ceremony;
    }
    return ActivityType.lecture;
  }

  static ActivityStatus _activityStatus(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('ongoing') || value.contains('جاري')) {
      return ActivityStatus.ongoing;
    }
    if (value.contains('cancel') || value.contains('ملغ')) {
      return ActivityStatus.cancelled;
    }
    if (value.contains('postpon') || value.contains('مؤجل')) {
      return ActivityStatus.postponed;
    }
    if (value.contains('complete') ||
        value.contains('published') ||
        value.contains('active') ||
        value.contains('منتهي')) {
      return ActivityStatus.completed;
    }
    return ActivityStatus.upcoming;
  }

  static MediaType _galleryMediaType(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('video') ||
        value.contains('mp4') ||
        value.contains('فيديو')) {
      return MediaType.video;
    }
    return MediaType.photo;
  }

  static NewsCategory _newsCategory(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('mosque') || value.contains('مسجد')) {
      return NewsCategory.mosques;
    }
    if (value.contains('event') || value.contains('فعالية')) {
      return NewsCategory.events;
    }
    if (value.contains('education') || value.contains('تعليم')) {
      return NewsCategory.education;
    }
    if (value.contains('social') || value.contains('اجتماع')) {
      return NewsCategory.social;
    }
    if (value.contains('religious') || value.contains('ديني')) {
      return NewsCategory.religious;
    }
    if (value.contains('international') || value.contains('دولي')) {
      return NewsCategory.international;
    }
    if (value.contains('administrative') || value.contains('إدار')) {
      return NewsCategory.administrative;
    }
    return NewsCategory.general;
  }

  static Priority _priority(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value.contains('critical') || value.contains('طارئ')) {
      return Priority.critical;
    }
    if (value.contains('urgent') || value.contains('عاجل')) {
      return Priority.urgent;
    }
    if (value.contains('high') ||
        value.contains('مهم') ||
        value.contains('عالي')) {
      return Priority.high;
    }
    if (value.contains('medium') || value.contains('متوسط')) {
      return Priority.medium;
    }
    if (value.contains('low') || value.contains('منخفض')) {
      return Priority.low;
    }
    return Priority.normal;
  }

  static int _stableIntId(dynamic raw) {
    final text = (raw ?? '').toString();
    var hash = 0x811c9dc5;
    for (var i = 0; i < text.length; i++) {
      hash ^= text.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
