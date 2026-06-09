// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_article.dart';

// ***************************************************************************
// JsonSerializableGenerator
// ***************************************************************************

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) => NewsArticle(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  excerpt: json['excerpt'] as String,
  content: json['content'] as String,
  imageUrl: json['image_url'] as String?,
  attachmentUrl: json['attachment_url'] as String?,
  author: json['author'] as String,
  unitId: json['unit_id']?.toString(),
  category: $enumDecode(_$NewsCategoryEnumMap, json['category']),
  status: $enumDecode(_$PublishStatusEnumMap, json['status']),
  viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
  isFeatured: json['is_featured'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$NewsArticleToJson(NewsArticle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'excerpt': instance.excerpt,
      'content': instance.content,
      'image_url': instance.imageUrl,
      'attachment_url': instance.attachmentUrl,
      'author': instance.author,
      'unit_id': instance.unitId,
      'category': _$NewsCategoryEnumMap[instance.category]!,
      'status': _$PublishStatusEnumMap[instance.status]!,
      'view_count': instance.viewCount,
      'is_featured': instance.isFeatured,
      'is_pinned': instance.isPinned,
      'sort_order': instance.sortOrder,
      'tags': instance.tags,
      'published_at': instance.publishedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$NewsCategoryEnumMap = {
  NewsCategory.general: 'general',
  NewsCategory.mosques: 'mosques',
  NewsCategory.events: 'events',
  NewsCategory.education: 'education',
  NewsCategory.social: 'social',
  NewsCategory.religious: 'religious',
  NewsCategory.international: 'international',
  NewsCategory.administrative: 'administrative',
};

const _$PublishStatusEnumMap = {
  PublishStatus.draft: 'draft',
  PublishStatus.published: 'published',
  PublishStatus.archived: 'archived',
  PublishStatus.scheduled: 'scheduled',
};
