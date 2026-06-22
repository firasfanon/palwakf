import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/content/pwf_temporal_ordering.dart';

import '../models/media_gallery_item.dart';
import '../services/media_compat_mapper.dart';
import '../services/supabase_service.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/core/public_runtime/pwf_public_media_runtime_gateway.dart';

class MediaGalleryRepository {
  final SupabaseService _service;
  MediaGalleryRepository(this._service);

  static const String _legacySelect =
      'id,unit_id,media_type,title,description,media_url,thumbnail_url,external_url,is_active,display_order,created_at';
  static const String _extendedSelect =
      'id,unit_id,media_type,title,description,media_url,thumbnail_url,external_url,is_active,display_order,is_featured,is_pinned,publish_at,created_at';

  SupabaseClient get _client => _service.client;

  Future<List<MediaGalleryItem>> fetchActiveForUnit(
    String unitId, {
    String? unitSlug,
    required MediaType mediaType,
    int limit = 8,
  }) async {
    try {
      final rows = await _fetchRows(
        unitId: unitId,
        unitSlug: unitSlug,
        mediaType: mediaType,
        includeInactive: false,
        search: '',
        limit: limit,
        publicMode: true,
      );
      return _sortNewestFirst(rows.map(MediaGalleryItem.fromMap));
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (_isSchemaMismatch(msg)) {
        return [];
      }
      rethrow;
    } catch (_) {
      return [];
    }
  }

  Future<List<MediaGalleryItem>> fetchForUnit(
    String unitId, {
    String? unitSlug,
    required MediaType mediaType,
    bool includeInactive = true,
    String search = '',
    int? limit,
  }) async {
    try {
      final rows = await _fetchRows(
        unitId: unitId,
        unitSlug: unitSlug,
        mediaType: mediaType,
        includeInactive: includeInactive,
        search: search,
        limit: limit,
        publicMode: false,
      );
      return _sortNewestFirst(rows.map(MediaGalleryItem.fromMap));
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (_isSchemaMismatch(msg)) {
        return [];
      }
      rethrow;
    } catch (_) {
      return [];
    }
  }

  Future<List<MediaGalleryItem>> fetchPublicForUnit(
    String unitId, {
    String? unitSlug,
    required MediaType mediaType,
    String search = '',
    int? limit,
  }) async {
    try {
      final rows = await _fetchRows(
        unitId: unitId,
        unitSlug: unitSlug,
        mediaType: mediaType,
        includeInactive: false,
        search: search,
        limit: limit,
        publicMode: true,
      );
      return _sortNewestFirst(rows.map(MediaGalleryItem.fromMap));
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (_isSchemaMismatch(msg)) {
        return [];
      }
      rethrow;
    } catch (_) {
      return [];
    }
  }

  List<MediaGalleryItem> _sortNewestFirst(
    Iterable<MediaGalleryItem> items,
  ) {
    final sorted = items.toList(growable: true)
      ..sort(
        (a, b) => PwfTemporalOrdering.newestFirst(
          a.publishAt ?? a.createdAt,
          b.publishAt ?? b.createdAt,
          leftStableKey: a.id,
          rightStableKey: b.id,
        ),
      );
    return List<MediaGalleryItem>.unmodifiable(sorted);
  }

  Future<MediaGalleryItem> createItem({
    required String unitId,
    required MediaType mediaType,
    required String title,
    required String description,
    required String mediaUrl,
    String? thumbnailUrl,
    String? externalUrl,
    required bool isActive,
    required int displayOrder,
    bool isFeatured = false,
    bool isPinned = false,
    DateTime? publishAt,
  }) async {
    final payload = _basePayload(
      unitId: unitId,
      mediaType: mediaType,
      title: title,
      description: description,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      externalUrl: externalUrl,
      isActive: isActive,
      displayOrder: displayOrder,
      isFeatured: isFeatured,
      isPinned: isPinned,
      publishAt: publishAt,
    );

    try {
      final row = await _client
          .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
          .insert(payload)
          .select(_extendedSelect)
          .single();
      return MediaGalleryItem.fromMap(Map<String, dynamic>.from(row));
    } on PostgrestException catch (e) {
      if (!_isSchemaMismatch(e.message.toLowerCase())) rethrow;
      final fallbackPayload = Map<String, dynamic>.from(payload)
        ..remove('is_featured')
        ..remove('is_pinned')
        ..remove('publish_at');
      final row = await _client
          .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
          .insert(fallbackPayload)
          .select(_legacySelect)
          .single();
      return MediaGalleryItem.fromMap(Map<String, dynamic>.from(row));
    }
  }

  Future<MediaGalleryItem> updateItem(
    String id, {
    required String unitId,
    required MediaType mediaType,
    required String title,
    required String description,
    required String mediaUrl,
    String? thumbnailUrl,
    String? externalUrl,
    required bool isActive,
    required int displayOrder,
    bool isFeatured = false,
    bool isPinned = false,
    DateTime? publishAt,
  }) async {
    final payload = _basePayload(
      unitId: unitId,
      mediaType: mediaType,
      title: title,
      description: description,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      externalUrl: externalUrl,
      isActive: isActive,
      displayOrder: displayOrder,
      isFeatured: isFeatured,
      isPinned: isPinned,
      publishAt: publishAt,
    )..['updated_at'] = DateTime.now().toIso8601String();

    try {
      final row = await _client
          .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
          .update(payload)
          .eq('id', id)
          .select(_extendedSelect)
          .single();
      return MediaGalleryItem.fromMap(Map<String, dynamic>.from(row));
    } on PostgrestException catch (e) {
      if (!_isSchemaMismatch(e.message.toLowerCase())) rethrow;
      final fallbackPayload = Map<String, dynamic>.from(payload)
        ..remove('is_featured')
        ..remove('is_pinned')
        ..remove('publish_at');
      final row = await _client
          .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
          .update(fallbackPayload)
          .eq('id', id)
          .select(_legacySelect)
          .single();
      return MediaGalleryItem.fromMap(Map<String, dynamic>.from(row));
    }
  }

  Future<void> deleteItem(String id) async {
    await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .delete()
        .eq('id', id);
  }

  Future<void> deleteItems(Iterable<String> ids) async {
    final safeIds = ids
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (safeIds.isEmpty) return;
    await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .delete()
        .inFilter('id', safeIds);
  }

  Future<void> setActive(String id, bool isActive) async {
    await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> _fetchRows({
    required String unitId,
    String? unitSlug,
    required MediaType mediaType,
    required bool includeInactive,
    required String search,
    required int? limit,
    required bool publicMode,
  }) async {
    // Public runtime must not probe optional extended columns first because a
    // failed schema-probe still appears as a red PostgREST 400 in Chrome.
    // The legacy column set is the stable public contract until gallery is
    // formally migrated to media_center/content_assets.
    if (publicMode) {
      final compatRows = await _fetchCompatGalleryRows(
        unitId: unitId,
        unitSlug: unitSlug,
        mediaType: mediaType,
        search: search,
        limit: limit,
      );
      // Public runtime must not fall back to legacy media_gallery_items REST
      // reads. In several deployments unit_id is uuid-typed while the public
      // homepage passes a slug/context value; the failed REST request shows up
      // as a red PostgREST 400 in Chrome even when caught. The compatibility
      // view is the only public read surface until the gallery ownership
      // migration is certified.
      return compatRows;
    }

    try {
      return await _runFetch(
        selectColumns: _extendedSelect,
        unitId: unitId,
        mediaType: mediaType,
        includeInactive: includeInactive,
        search: search,
        limit: limit,
        publicMode: publicMode,
        extendedSchema: true,
      );
    } on PostgrestException catch (e) {
      if (!_isSchemaMismatch(e.message.toLowerCase())) rethrow;
      return _runFetch(
        selectColumns: _legacySelect,
        unitId: unitId,
        mediaType: mediaType,
        includeInactive: includeInactive,
        search: search,
        limit: limit,
        publicMode: publicMode,
        extendedSchema: false,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCompatGalleryRows({
    required String unitId,
    String? unitSlug,
    required MediaType mediaType,
    required String search,
    required int? limit,
  }) async {
    final unitRef = unitSlug?.trim().isNotEmpty == true
        ? unitSlug!.trim()
        : unitId.trim();
    try {
      final rows = await PwfPublicMediaRuntimeGateway(_client).fetchFeed(
        unitRef: unitRef.isEmpty ? 'home' : unitRef,
        familyKey: mediaType == MediaType.video
            ? 'gallery_videos'
            : 'gallery_images',
        limit: (limit ?? 50).clamp(1, 50).toInt(),
      );

      var mapped = rows
          .map(MediaCompatMapper.galleryLegacyMapFromCompatRow)
          .where(
            (row) =>
                MediaTypeX.fromDb(row['media_type']?.toString()) == mediaType,
          )
          .toList(growable: false);

      final normalizedSearch = search.trim().toLowerCase();
      if (normalizedSearch.isNotEmpty) {
        mapped = mapped
            .where((row) {
              final title = (row['title'] ?? '').toString().toLowerCase();
              final description =
                  (row['description'] ?? '').toString().toLowerCase();
              return title.contains(normalizedSearch) ||
                  description.contains(normalizedSearch);
            })
            .toList(growable: false);
      }
      return mapped;
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _runFetch({
    required String selectColumns,
    required String unitId,
    required MediaType mediaType,
    required bool includeInactive,
    required String search,
    required int? limit,
    required bool publicMode,
    required bool extendedSchema,
  }) async {
    var filtered = _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .select(selectColumns)
        .eq('unit_id', unitId)
        .eq('media_type', mediaType.dbValue);

    if (!includeInactive) {
      filtered = filtered.eq('is_active', true);
    }

    final s = search.trim();
    if (s.isNotEmpty) {
      filtered = filtered.or('title.ilike.%$s%,description.ilike.%$s%');
    }

    if (publicMode && extendedSchema) {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      filtered = filtered.or('publish_at.is.null,publish_at.lte.$nowIso');
    }

    final ordered = extendedSchema
        ? filtered
              .order('publish_at', ascending: false)
              .order('created_at', ascending: false)
        : filtered.order('created_at', ascending: false);

    final res = limit != null ? await ordered.limit(limit) : await ordered;
    return List<Map<String, dynamic>>.from(res);
  }

  Map<String, dynamic> _basePayload({
    required String unitId,
    required MediaType mediaType,
    required String title,
    required String description,
    required String mediaUrl,
    required String? thumbnailUrl,
    required String? externalUrl,
    required bool isActive,
    required int displayOrder,
    required bool isFeatured,
    required bool isPinned,
    required DateTime? publishAt,
  }) {
    return <String, dynamic>{
      'unit_id': unitId,
      'media_type': mediaType.dbValue,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'thumbnail_url': (thumbnailUrl ?? '').trim().isEmpty
          ? null
          : thumbnailUrl,
      'external_url': (externalUrl ?? '').trim().isEmpty ? null : externalUrl,
      'is_active': isActive,
      'display_order': displayOrder,
      'is_featured': isFeatured,
      'is_pinned': isPinned,
      'publish_at': publishAt?.toUtc().toIso8601String(),
    };
  }

  bool _isSchemaMismatch(String msg) {
    return msg.contains('does not exist') ||
        msg.contains('not found') ||
        msg.contains('column') ||
        msg.contains('schema cache');
  }
}
