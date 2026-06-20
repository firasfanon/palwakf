import 'package:json_annotation/json_annotation.dart';

part 'news_article.g.dart';

enum NewsCategory {
  @JsonValue('general')
  general,
  @JsonValue('mosques')
  mosques,
  @JsonValue('events')
  events,
  @JsonValue('education')
  education,
  @JsonValue('social')
  social,
  @JsonValue('religious')
  religious,
  @JsonValue('international')
  international,
  @JsonValue('administrative')
  administrative,
}

enum PublishStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived,
  @JsonValue('scheduled')
  scheduled,
}

@JsonSerializable()
class NewsArticle {
  final int id;
  final String title;
  final String excerpt;
  final String content;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;

  final String author;

  @JsonKey(name: 'unit_id')
  final String? unitId;

  /// Opaque `content_id` returned by the allow-listed public media RPC.
  /// It is not persisted by legacy JSON serializers.
  final String? runtimeContentId;

  String get publicDetailId {
    final value = runtimeContentId?.trim();
    return value == null || value.isEmpty ? id.toString() : value;
  }

  final NewsCategory category;
  final PublishStatus status;

  @JsonKey(name: 'view_count')
  final int viewCount;

  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  @JsonKey(name: 'is_pinned')
  final bool isPinned;

  @JsonKey(name: 'sort_order')
  final int sortOrder;

  final List<String> tags;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    this.imageUrl,
    this.attachmentUrl,
    required this.author,
    this.unitId,
    this.runtimeContentId,
    required this.category,
    required this.status,
    this.viewCount = 0,
    this.isFeatured = false,
    this.isPinned = false,
    this.sortOrder = 0,
    this.tags = const [],
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);

  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);

  NewsArticle copyWith({
    int? id,
    String? title,
    String? excerpt,
    String? content,
    String? imageUrl,
    String? attachmentUrl,
    String? author,
    String? unitId,
    NewsCategory? category,
    PublishStatus? status,
    int? viewCount,
    bool? isFeatured,
    bool? isPinned,
    int? sortOrder,
    List<String>? tags,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? runtimeContentId,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      runtimeContentId: runtimeContentId ?? this.runtimeContentId,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      author: author ?? this.author,
      unitId: unitId ?? this.unitId,
      category: category ?? this.category,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      tags: tags ?? this.tags,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension NewsCategoryExtension on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.general:
        return 'أخبار عامة';
      case NewsCategory.mosques:
        return 'أنشطة المساجد';
      case NewsCategory.events:
        return 'فعاليات';
      case NewsCategory.education:
        return 'تعليم ديني';
      case NewsCategory.social:
        return 'شؤون اجتماعية';
      case NewsCategory.religious:
        return 'شؤون دينية';
      case NewsCategory.international:
        return 'أخبار دولية';
      case NewsCategory.administrative:
        return 'إدارية';
    }
  }

  String get displayNameEn {
    switch (this) {
      case NewsCategory.general:
        return 'General News';
      case NewsCategory.mosques:
        return 'Mosque Activities';
      case NewsCategory.events:
        return 'Events';
      case NewsCategory.education:
        return 'Religious Education';
      case NewsCategory.social:
        return 'Social Affairs';
      case NewsCategory.religious:
        return 'Religious Affairs';
      case NewsCategory.international:
        return 'International News';
      case NewsCategory.administrative:
        return 'Administrative';
    }
  }
}

extension PublishStatusExtension on PublishStatus {
  String get displayName {
    switch (this) {
      case PublishStatus.draft:
        return 'مسودة';
      case PublishStatus.published:
        return 'منشور';
      case PublishStatus.archived:
        return 'مؤرشف';
      case PublishStatus.scheduled:
        return 'مجدول';
    }
  }

  String get displayNameEn {
    switch (this) {
      case PublishStatus.draft:
        return 'Draft';
      case PublishStatus.published:
        return 'Published';
      case PublishStatus.archived:
        return 'Archived';
      case PublishStatus.scheduled:
        return 'Scheduled';
    }
  }
}
