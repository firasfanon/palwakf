
import 'package:flutter/foundation.dart';

enum MediaCenterMobileFamily {
  news,
  announcements,
  activities,
}

extension MediaCenterMobileFamilyX on MediaCenterMobileFamily {
  String get key {
    switch (this) {
      case MediaCenterMobileFamily.news:
        return 'news';
      case MediaCenterMobileFamily.announcements:
        return 'announcements';
      case MediaCenterMobileFamily.activities:
        return 'activities';
    }
  }

  String get labelAr {
    switch (this) {
      case MediaCenterMobileFamily.news:
        return 'الأخبار';
      case MediaCenterMobileFamily.announcements:
        return 'الإعلانات';
      case MediaCenterMobileFamily.activities:
        return 'الأنشطة';
    }
  }

  String get apiEdgeSurface {
    switch (this) {
      case MediaCenterMobileFamily.news:
        return 'public.v_media_news_compat_v1';
      case MediaCenterMobileFamily.announcements:
        return 'public.v_media_announcements_compat_v1';
      case MediaCenterMobileFamily.activities:
        return 'public.v_media_activities_compat_v1';
    }
  }
}

@immutable
class MediaCenterMobileItem {
  const MediaCenterMobileItem({
    required this.id,
    required this.family,
    required this.title,
    required this.summary,
    required this.body,
    required this.ownerName,
    required this.scopeLabel,
    required this.status,
    required this.publicRoute,
    this.imageUrl,
    this.attachmentUrl,
    this.publishedAt,
    this.isPinned = false,
    this.isFeatured = false,
    this.isFallback = false,
  });

  final String id;
  final MediaCenterMobileFamily family;
  final String title;
  final String summary;
  final String body;
  final String ownerName;
  final String scopeLabel;
  final String status;
  final String publicRoute;
  final String? imageUrl;
  final String? attachmentUrl;
  final DateTime? publishedAt;
  final bool isPinned;
  final bool isFeatured;
  final bool isFallback;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;
  bool get hasAttachment =>
      attachmentUrl != null && attachmentUrl!.trim().isNotEmpty;

  String get publishedLabelAr {
    final value = publishedAt;
    if (value == null) return 'غير محدد';
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  factory MediaCenterMobileItem.fromRow(
    Map<String, dynamic> row,
    MediaCenterMobileFamily family,
  ) {
    final legacy = _legacyPayload(row);

    return MediaCenterMobileItem(
      id: _firstText(row, legacy, const [
        'id',
        'legacy_id',
        'legacy_source_id',
        'content_key',
      ], '${family.key}_${row.hashCode}'),
      family: family,
      title: _firstText(row, legacy, const [
        'title_ar',
        'title',
        'headline_ar',
        'name_ar',
        'content_key',
      ], 'عنصر إعلامي'),
      summary: _firstText(row, legacy, const [
        'summary_ar',
        'excerpt_ar',
        'description_ar',
        'summary',
        'excerpt',
        'description',
      ], 'لا يوجد ملخص متاح.'),
      body: _firstText(row, legacy, const [
        'body_ar',
        'content_ar',
        'body',
        'content',
        'description',
        'summary_ar',
        'summary',
      ], ''),
      ownerName: _firstText(row, legacy, const [
        'owner_name',
        'unit_name',
        'created_by_name',
        'author',
        'author_ar',
      ], 'مركز الإعلام'),
      scopeLabel: _firstText(row, legacy, const [
        'scope_type',
        'scope',
        'unit_slug',
        'unit_id',
      ], 'الوزارة'),
      status: _firstText(row, legacy, const [
        'workflow_status',
        'publication_status',
        'status',
      ], 'published'),
      publicRoute: _firstText(row, legacy, const [
        'public_route',
        'route',
        'href',
        'url',
      ], ''),
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
      publishedAt: _firstDate(row, legacy, const [
        'published_at',
        'publish_at',
        'publish_date',
        'event_date',
        'start_date',
        'created_at',
      ]),
      isPinned: _firstBool(row, legacy, const [
            'is_pinned',
            'pinned',
          ]) ??
          false,
      isFeatured: _firstBool(row, legacy, const [
            'is_featured',
            'featured',
          ]) ??
          false,
      isFallback: false,
    );
  }

  static List<MediaCenterMobileItem> fallbackItems(
    MediaCenterMobileFamily family,
  ) {
    final now = DateTime.now();
    return <MediaCenterMobileItem>[
      MediaCenterMobileItem(
        id: '${family.key}_fallback_1',
        family: family,
        title: '${family.labelAr} — نموذج تشغيل محلي',
        summary:
            'يعرض هذا العنصر عندما تكون واجهة API غير متاحة مؤقتًا، دون الرجوع إلى public base tables.',
        body:
            'هذا محتوى احتياطي محلي لإبقاء تطبيق الهاتف قابلاً للتشغيل أثناء اختبار الشبكة. مصدر الحقيقة يبقى media_center.',
        ownerName: 'مركز الإعلام',
        scopeLabel: 'الوزارة',
        status: 'fallback',
        publicRoute: '',
        publishedAt: now,
        isFallback: true,
      ),
    ];
  }

  static Map<String, dynamic> _legacyPayload(Map<String, dynamic> row) {
    final value = row['legacy_payload'] ?? row['payload'] ?? row['metadata'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  static String _firstText(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = row[key] ?? legacy[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  static String? _firstNullableText(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    final value = _firstText(row, legacy, keys, '');
    return value.isEmpty ? null : value;
  }

  static DateTime? _firstDate(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = row[key] ?? legacy[key];
      if (value == null) continue;
      if (value is DateTime) return value;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  static bool? _firstBool(
    Map<String, dynamic> row,
    Map<String, dynamic> legacy,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = row[key] ?? legacy[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' || normalized == '0' || normalized == 'no') {
          return false;
        }
      }
    }
    return null;
  }
}
