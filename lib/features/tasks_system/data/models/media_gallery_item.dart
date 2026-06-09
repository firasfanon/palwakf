import 'package:flutter/foundation.dart';

enum MediaType { photo, video }

extension MediaTypeX on MediaType {
  String get dbValue => switch (this) {
    MediaType.photo => 'photo',
    MediaType.video => 'video',
  };

  static MediaType fromDb(String? v) {
    final s = (v ?? '').toLowerCase().trim();
    if (s == 'video') return MediaType.video;
    return MediaType.photo;
  }
}

@immutable
class MediaGalleryItem {
  final String id;
  final String unitId;
  final MediaType mediaType;
  final String title;
  final String description;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? externalUrl;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;

  const MediaGalleryItem({
    required this.id,
    required this.unitId,
    required this.mediaType,
    required this.title,
    required this.description,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.externalUrl,
    required this.isActive,
    required this.displayOrder,
    this.createdAt,
  });

  factory MediaGalleryItem.fromMap(Map<String, dynamic> map) {
    return MediaGalleryItem(
      id: (map['id'] ?? '').toString(),
      unitId: (map['unit_id'] ?? '').toString(),
      mediaType: MediaTypeX.fromDb(map['media_type']?.toString()),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      mediaUrl: (map['media_url'] ?? '').toString(),
      thumbnailUrl: (map['thumbnail_url'] ?? '').toString().trim().isEmpty
          ? null
          : (map['thumbnail_url'] ?? '').toString(),
      externalUrl: (map['external_url'] ?? '').toString().trim().isEmpty
          ? null
          : (map['external_url'] ?? '').toString(),
      isActive: (map['is_active'] as bool?) ?? true,
      displayOrder: (map['display_order'] as int?) ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}
