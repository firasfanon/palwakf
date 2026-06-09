// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// ***************************************************************************
// JsonSerializableGenerator
// ***************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  validUntil: json['validUntil'] == null
      ? null
      : DateTime.parse(json['validUntil'] as String),
  isActive: json['isActive'] as bool,
  targetAudience: json['targetAudience'] as String,
  createdBy: (json['createdBy'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  imageUrl: json['image_url'] as String?,
  attachmentUrl: json['attachment_url'] as String?,
  isFeatured: json['is_featured'] as bool? ?? false,
  isPinned: json['is_pinned'] as bool? ?? false,
  publishAt: json['publish_at'] == null
      ? null
      : DateTime.parse(json['publish_at'] as String),
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AnnouncementToJson(Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'validUntil': instance.validUntil?.toIso8601String(),
      'isActive': instance.isActive,
      'targetAudience': instance.targetAudience,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'image_url': instance.imageUrl,
      'attachment_url': instance.attachmentUrl,
      'is_featured': instance.isFeatured,
      'is_pinned': instance.isPinned,
      'publish_at': instance.publishAt?.toIso8601String(),
      'sort_order': instance.sortOrder,
    };

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.normal: 'normal',
  Priority.medium: 'medium',
  Priority.high: 'high',
  Priority.urgent: 'urgent',
  Priority.critical: 'critical',
};
