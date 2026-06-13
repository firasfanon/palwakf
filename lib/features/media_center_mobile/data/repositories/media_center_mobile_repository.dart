
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

import '../models/media_center_mobile_models.dart';

class MediaCenterMobileRepository {
  const MediaCenterMobileRepository(this._client);

  final SupabaseClient _client;

  static const Duration _timeout = Duration(seconds: 8);

  Future<List<MediaCenterMobileItem>> fetchFamily({
    required MediaCenterMobileFamily family,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from(_surfaceFor(family))
          .select('*')
          .timeout(_timeout);

      final rows = _rows(response);
      final items = rows
          .map((row) => MediaCenterMobileItem.fromRow(row, family))
          .toList(growable: false);

      final sorted = [...items]..sort(_sort);
      final result = sorted.take(limit).toList(growable: false);
      _logRuntimeSource(family: family, rows: result.length);
      return result;
    } on TimeoutException {
      _logFallback(family: family, reason: 'api-edge-timeout');
      return MediaCenterMobileItem.fallbackItems(family);
    } catch (error, stackTrace) {
      dev.log(
        'Media center mobile API edge read failed.',
        name: 'MediaCenterMobileRepository',
        error: error,
        stackTrace: stackTrace,
      );
      _logFallback(family: family, reason: 'api-edge-failure');
      return MediaCenterMobileItem.fallbackItems(family);
    }
  }

  Future<MediaCenterMobileSnapshot> loadSnapshot() async {
    final families = await Future.wait([
      fetchFamily(family: MediaCenterMobileFamily.news, limit: 12),
      fetchFamily(family: MediaCenterMobileFamily.announcements, limit: 12),
      fetchFamily(family: MediaCenterMobileFamily.activities, limit: 12),
    ]);

    return MediaCenterMobileSnapshot(
      news: families[0],
      announcements: families[1],
      activities: families[2],
    );
  }

  String _surfaceFor(MediaCenterMobileFamily family) {
    switch (family) {
      case MediaCenterMobileFamily.news:
        return PwfDatabaseOwnerSurfaces.vMediaNewsCompatV1;
      case MediaCenterMobileFamily.announcements:
        return PwfDatabaseOwnerSurfaces.vMediaAnnouncementsCompatV1;
      case MediaCenterMobileFamily.activities:
        return PwfDatabaseOwnerSurfaces.vMediaActivitiesCompatV1;
    }
  }

  int _sort(MediaCenterMobileItem a, MediaCenterMobileItem b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
    final ad = a.publishedAt;
    final bd = b.publishedAt;
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return bd.compareTo(ad);
  }

  List<Map<String, dynamic>> _rows(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((row) => row.map((key, value) => MapEntry(key.toString(), value)))
          .toList(growable: false);
    }
    if (response is Map) {
      return <Map<String, dynamic>>[
        response.map((key, value) => MapEntry(key.toString(), value)),
      ];
    }
    return const <Map<String, dynamic>>[];
  }

  void _logRuntimeSource({
    required MediaCenterMobileFamily family,
    required int rows,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_MOBILE_APP '
      'family=${family.key} '
      'owner_schema=media_center '
      'api_edge=${family.apiEdgeSurface} '
      'rows=$rows '
      'public_schema_source_of_truth=false '
      'decision=media-center-mobile-owner-schema-public-api-edge-mvp',
    );
  }

  void _logFallback({
    required MediaCenterMobileFamily family,
    required String reason,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_MOBILE_APP_FALLBACK '
      'family=${family.key} '
      'reason=$reason '
      'fallback=local-only '
      'legacy_public_base_table_fallback=false',
    );
  }
}

@immutable
class MediaCenterMobileSnapshot {
  const MediaCenterMobileSnapshot({
    required this.news,
    required this.announcements,
    required this.activities,
  });

  final List<MediaCenterMobileItem> news;
  final List<MediaCenterMobileItem> announcements;
  final List<MediaCenterMobileItem> activities;

  int get totalCount => news.length + announcements.length + activities.length;

  List<MediaCenterMobileItem> itemsFor(MediaCenterMobileFamily family) {
    switch (family) {
      case MediaCenterMobileFamily.news:
        return news;
      case MediaCenterMobileFamily.announcements:
        return announcements;
      case MediaCenterMobileFamily.activities:
        return activities;
    }
  }
}
