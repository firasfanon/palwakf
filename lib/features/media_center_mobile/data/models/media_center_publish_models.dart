
import 'package:flutter/foundation.dart';

enum MediaPublishingContentType {
  news,
  announcement,
  activity,
}

extension MediaPublishingContentTypeX on MediaPublishingContentType {
  String get key {
    switch (this) {
      case MediaPublishingContentType.news:
        return 'news';
      case MediaPublishingContentType.announcement:
        return 'announcement';
      case MediaPublishingContentType.activity:
        return 'activity';
    }
  }

  String get familyKey {
    switch (this) {
      case MediaPublishingContentType.news:
        return 'news';
      case MediaPublishingContentType.announcement:
        return 'announcements';
      case MediaPublishingContentType.activity:
        return 'activities';
    }
  }

  String get labelAr {
    switch (this) {
      case MediaPublishingContentType.news:
        return 'خبر';
      case MediaPublishingContentType.announcement:
        return 'إعلان';
      case MediaPublishingContentType.activity:
        return 'نشاط';
    }
  }

  String officialPathFor(String id) => '/official/media/$familyKey/$id';
}

enum MediaMobilePublishAction {
  saveDraft,
  submitForReview,
  publishNow,
}

extension MediaMobilePublishActionX on MediaMobilePublishAction {
  String get labelAr {
    switch (this) {
      case MediaMobilePublishAction.saveDraft:
        return 'حفظ مسودة';
      case MediaMobilePublishAction.submitForReview:
        return 'إرسال للمراجعة';
      case MediaMobilePublishAction.publishNow:
        return 'نشر مباشر';
    }
  }
}

@immutable
class MediaMobilePublishDraft {
  const MediaMobilePublishDraft({
    required this.contentType,
    required this.titleAr,
    required this.summaryAr,
    required this.bodyAr,
    this.unitId,
    this.unitSlug,
    this.primaryAssetBucket,
    this.primaryAssetPath,
    this.primaryAssetMimeType,
    this.primaryAssetSizeBytes,
  });

  final MediaPublishingContentType contentType;
  final String titleAr;
  final String summaryAr;
  final String bodyAr;
  final String? unitId;
  final String? unitSlug;
  final String? primaryAssetBucket;
  final String? primaryAssetPath;
  final String? primaryAssetMimeType;
  final int? primaryAssetSizeBytes;

  bool get hasAsset =>
      primaryAssetBucket != null &&
      primaryAssetBucket!.trim().isNotEmpty &&
      primaryAssetPath != null &&
      primaryAssetPath!.trim().isNotEmpty;

  Map<String, dynamic> toCreateDraftParams() {
    return {
      'p_content_type': contentType.key,
      'p_title_ar': titleAr.trim(),
      'p_summary_ar': summaryAr.trim(),
      'p_body_ar': bodyAr.trim(),
      'p_unit_id': unitId?.trim().isEmpty == true ? null : unitId,
      'p_unit_slug': unitSlug?.trim().isEmpty == true ? null : unitSlug,
      'p_primary_asset_bucket': primaryAssetBucket,
      'p_primary_asset_path': primaryAssetPath,
      'p_primary_asset_mime_type': primaryAssetMimeType,
      'p_primary_asset_size_bytes': primaryAssetSizeBytes,
    };
  }
}

@immutable
class MediaMobilePublishResult {
  const MediaMobilePublishResult({
    required this.success,
    required this.contentItemId,
    required this.status,
    required this.officialPath,
    required this.officialUrl,
    required this.messageAr,
    required this.publicVisibilityGranted,
  });

  final bool success;
  final String contentItemId;
  final String status;
  final String officialPath;
  final String officialUrl;
  final String messageAr;
  final bool publicVisibilityGranted;

  bool get isPublished => status == 'published';

  factory MediaMobilePublishResult.fromJson(Map<String, dynamic> json) {
    return MediaMobilePublishResult(
      success: json['success'] == true,
      contentItemId: (json['content_item_id'] ?? '').toString(),
      status: (json['status'] ?? 'draft').toString(),
      officialPath: (json['official_path'] ?? '').toString(),
      officialUrl: (json['official_url'] ?? '').toString(),
      messageAr: (json['message_ar'] ?? 'تم تنفيذ العملية.').toString(),
      publicVisibilityGranted: json['public_visibility_granted'] == true,
    );
  }
}
