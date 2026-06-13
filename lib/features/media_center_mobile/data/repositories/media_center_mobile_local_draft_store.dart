
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/media_center_publish_models.dart';

@immutable
class MediaCenterLocalDraft {
  const MediaCenterLocalDraft({
    required this.id,
    required this.contentType,
    required this.titleAr,
    required this.summaryAr,
    required this.bodyAr,
    required this.unitSlug,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final MediaPublishingContentType contentType;
  final String titleAr;
  final String summaryAr;
  final String bodyAr;
  final String unitSlug;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEmpty =>
      titleAr.trim().isEmpty &&
      summaryAr.trim().isEmpty &&
      bodyAr.trim().isEmpty;

  MediaCenterLocalDraft copyWith({
    MediaPublishingContentType? contentType,
    String? titleAr,
    String? summaryAr,
    String? bodyAr,
    String? unitSlug,
    DateTime? updatedAt,
  }) {
    return MediaCenterLocalDraft(
      id: id,
      contentType: contentType ?? this.contentType,
      titleAr: titleAr ?? this.titleAr,
      summaryAr: summaryAr ?? this.summaryAr,
      bodyAr: bodyAr ?? this.bodyAr,
      unitSlug: unitSlug ?? this.unitSlug,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_type': contentType.key,
      'title_ar': titleAr,
      'summary_ar': summaryAr,
      'body_ar': bodyAr,
      'unit_slug': unitSlug,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MediaCenterLocalDraft.fromJson(Map<String, dynamic> json) {
    final type = _typeFromKey((json['content_type'] ?? 'news').toString());
    final now = DateTime.now();

    return MediaCenterLocalDraft(
      id: (json['id'] ?? 'draft_${now.microsecondsSinceEpoch}').toString(),
      contentType: type,
      titleAr: (json['title_ar'] ?? '').toString(),
      summaryAr: (json['summary_ar'] ?? '').toString(),
      bodyAr: (json['body_ar'] ?? '').toString(),
      unitSlug: (json['unit_slug'] ?? 'home').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? now,
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()) ?? now,
    );
  }

  static MediaPublishingContentType _typeFromKey(String key) {
    switch (key) {
      case 'announcement':
      case 'announcements':
        return MediaPublishingContentType.announcement;
      case 'activity':
      case 'activities':
        return MediaPublishingContentType.activity;
      case 'news':
      default:
        return MediaPublishingContentType.news;
    }
  }
}

class MediaCenterMobileLocalDraftStore {
  const MediaCenterMobileLocalDraftStore();

  static const String _key = 'palwakf.media_center.mobile.local_drafts.v1';
  static const int _maxDrafts = 25;

  Future<List<MediaCenterLocalDraft>> loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);
    if (encoded == null || encoded.trim().isEmpty) {
      return const <MediaCenterLocalDraft>[];
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const <MediaCenterLocalDraft>[];

      final drafts = decoded
          .whereType<Map>()
          .map((item) => MediaCenterLocalDraft.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ))
          .toList();

      drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return drafts;
    } catch (_) {
      return const <MediaCenterLocalDraft>[];
    }
  }

  Future<void> saveDraft(MediaCenterLocalDraft draft) async {
    if (draft.isEmpty) return;

    final drafts = await loadDrafts();
    final next = <MediaCenterLocalDraft>[
      draft.copyWith(updatedAt: DateTime.now()),
      ...drafts.where((item) => item.id != draft.id),
    ].take(_maxDrafts).toList(growable: false);

    await _write(next);
  }

  Future<void> deleteDraft(String id) async {
    final drafts = await loadDrafts();
    await _write(drafts.where((item) => item.id != id).toList(growable: false));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _write(List<MediaCenterLocalDraft> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(drafts.map((draft) => draft.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  MediaCenterLocalDraft newDraft({
    MediaPublishingContentType type = MediaPublishingContentType.news,
  }) {
    final now = DateTime.now();
    return MediaCenterLocalDraft(
      id: 'local_${now.microsecondsSinceEpoch}',
      contentType: type,
      titleAr: '',
      summaryAr: '',
      bodyAr: '',
      unitSlug: 'home',
      createdAt: now,
      updatedAt: now,
    );
  }
}
