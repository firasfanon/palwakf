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

  @JsonKey(name: 'image_url')  // ← ADD THIS
  final String? imageUrl;

  final String author;
  final NewsCategory category;
  final PublishStatus status;

  @JsonKey(name: 'view_count')  // ← ADD THIS
  final int viewCount;

  @JsonKey(name: 'is_featured')  // ← ADD THIS
  final bool isFeatured;

  final List<String> tags;

  @JsonKey(name: 'published_at')  // ← ADD THIS
  final DateTime? publishedAt;

  @JsonKey(name: 'created_at')  // ← ADD THIS
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')  // ← ADD THIS
  final DateTime updatedAt;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    this.imageUrl,
    required this.author,
    required this.category,
    required this.status,
    this.viewCount = 0,
    this.isFeatured = false,
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
    String? author,
    NewsCategory? category,
    PublishStatus? status,
    int? viewCount,
    bool? isFeatured,
    List<String>? tags,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      category: category ?? this.category,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      isFeatured: isFeatured ?? this.isFeatured,
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