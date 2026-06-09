import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
  @JsonValue('critical')
  critical,
}

@JsonSerializable()
class Announcement {
  final int id;
  final String title;
  final String content;
  final Priority priority;
  final DateTime? validUntil;
  final bool isActive;
  final String targetAudience;
  final int createdBy;
  final DateTime createdAt;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @JsonKey(name: 'publish_at')
  final DateTime? publishAt;
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    this.validUntil,
    required this.isActive,
    required this.targetAudience,
    required this.createdBy,
    required this.createdAt,
    this.imageUrl,
    this.attachmentUrl,
    this.isFeatured = false,
    this.isPinned = false,
    this.publishAt,
    this.sortOrder = 0,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  factory Announcement.fromDb(Map<String, dynamic> row) {
    T? pick<T>(String camel, String snake) {
      final v = row[camel];
      if (v != null) return v as T;
      final s = row[snake];
      if (s != null) return s as T;
      return null;
    }

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    final id = (pick<num>('id', 'id') ?? 0).toInt();
    final title = (pick<String>('title', 'title') ?? '').toString();
    final content = (pick<String>('content', 'content') ?? '').toString();

    final priorityRaw = (pick<String>('priority', 'priority') ?? 'low')
        .toString();
    final priority = Priority.values.firstWhere(
      (e) => e.name == priorityRaw,
      orElse: () => Priority.low,
    );

    final validUntil = parseDt(pick<dynamic>('validUntil', 'valid_until'));
    final isActive = (pick<bool>('isActive', 'is_active') ?? true) == true;
    final targetAudience =
        (pick<String>('targetAudience', 'target_audience') ?? 'public')
            .toString();

    final createdBy = (pick<num>('createdBy', 'created_by') ?? 0).toInt();
    final createdAt =
        parseDt(pick<dynamic>('createdAt', 'created_at')) ?? DateTime.now();

    return Announcement(
      id: id,
      title: title,
      content: content,
      priority: priority,
      validUntil: validUntil,
      isActive: isActive,
      targetAudience: targetAudience,
      createdBy: createdBy,
      createdAt: createdAt,
      imageUrl: pick<dynamic>('imageUrl', 'image_url')?.toString(),
      attachmentUrl: pick<dynamic>(
        'attachmentUrl',
        'attachment_url',
      )?.toString(),
      isFeatured: (pick<bool>('isFeatured', 'is_featured') ?? false) == true,
      isPinned: (pick<bool>('isPinned', 'is_pinned') ?? false) == true,
      publishAt: parseDt(pick<dynamic>('publishAt', 'publish_at')),
      sortOrder: (pick<num>('sortOrder', 'sort_order') ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => _$AnnouncementToJson(this);

  Map<String, dynamic> toDb() {
    return <String, dynamic>{
      'title': title,
      'content': content,
      'priority': priority.name,
      'valid_until': validUntil?.toIso8601String(),
      'is_active': isActive,
      'target_audience': targetAudience,
      'image_url': imageUrl,
      'attachment_url': attachmentUrl,
      'is_featured': isFeatured,
      'is_pinned': isPinned,
      'publish_at': publishAt?.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

  Announcement copyWith({
    int? id,
    String? title,
    String? content,
    Priority? priority,
    DateTime? validUntil,
    bool? isActive,
    String? targetAudience,
    int? createdBy,
    DateTime? createdAt,
    String? imageUrl,
    String? attachmentUrl,
    bool? isFeatured,
    bool? isPinned,
    DateTime? publishAt,
    int? sortOrder,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      targetAudience: targetAudience ?? this.targetAudience,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isPinned: isPinned ?? this.isPinned,
      publishAt: publishAt ?? this.publishAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'منخفض';
      case Priority.normal:
        return 'عادي';
      case Priority.medium:
        return 'متوسط';
      case Priority.high:
        return 'عالي';
      case Priority.urgent:
        return 'عاجل';
      case Priority.critical:
        return 'طارئ';
    }
  }

  String get displayNameEn {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.normal:
        return 'Normal';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
      case Priority.critical:
        return 'Critical';
    }
  }
}
