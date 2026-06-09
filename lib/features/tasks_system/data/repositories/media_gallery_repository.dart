import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/media_gallery_item.dart';
import '../services/supabase_service.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class MediaGalleryRepository {
  final SupabaseService _service;
  MediaGalleryRepository(this._service);

  SupabaseClient get _client => _service.client;

  Future<List<MediaGalleryItem>> fetchActiveForUnit(
    String unitId, {
    required MediaType mediaType,
    int limit = 8,
  }) async {
    try {
      final res = await _client
          .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
          .select(
            'id,unit_id,media_type,title,description,media_url,thumbnail_url,external_url,is_active,display_order,created_at',
          )
          .eq('unit_id', unitId)
          .eq('media_type', mediaType.dbValue)
          .eq('is_active', true)
          .order('display_order', ascending: true)
          .order('created_at', ascending: false)
          .limit(limit);

      final rows = List<Map<String, dynamic>>.from(res);
      return rows.map(MediaGalleryItem.fromMap).toList();
    } on PostgrestException catch (e) {
      // Fail-open (important for local/dev envs before applying SQL migrations)
      final msg = (e.message).toLowerCase();
      if (msg.contains('does not exist') || msg.contains('not found')) {
        return [];
      }
      rethrow;
    } catch (_) {
      // Fail-open for any other issues (network/rls/etc.)
      return [];
    }
  }

  /// Admin: fetch items for a unit (optionally include inactive / search)
  ///
  /// Fail-open: if the table/column does not exist yet, return empty list.
  Future<List<MediaGalleryItem>> fetchForUnit(
    String unitId, {
    required MediaType mediaType,
    bool includeInactive = true,
    String search = '',
    int? limit,
  }) async {
    try {
      // NOTE: Do not reassign a FilterBuilder with a TransformBuilder (postgrest 2.x types differ).
      // Build filters first, then apply ordering/limit on a separate variable.
      var filtered = _client
          .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
          .select(
            'id,unit_id,media_type,title,description,media_url,thumbnail_url,external_url,is_active,display_order,created_at',
          )
          .eq('unit_id', unitId)
          .eq('media_type', mediaType.dbValue);

      if (!includeInactive) {
        filtered = filtered.eq('is_active', true);
      }

      final s = search.trim();
      if (s.isNotEmpty) {
        // Search across title/description
        filtered = filtered.or('title.ilike.%$s%,description.ilike.%$s%');
      }

      final ordered = filtered
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);

      final res = limit != null ? await ordered.limit(limit) : await ordered;
      final rows = List<Map<String, dynamic>>.from(res);
      return rows.map(MediaGalleryItem.fromMap).toList();
    } on PostgrestException catch (e) {
      final msg = (e.message).toLowerCase();
      if (msg.contains('does not exist') || msg.contains('not found')) {
        return [];
      }
      rethrow;
    } catch (_) {
      return [];
    }
  }

  /// Admin: create item
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
  }) async {
    final payload = <String, dynamic>{
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
    };

    final row = await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .insert(payload)
        .select(
          'id,unit_id,media_type,title,description,media_url,thumbnail_url,external_url,is_active,display_order,created_at',
        )
        .single();

    return MediaGalleryItem.fromMap(Map<String, dynamic>.from(row));
  }

  /// Admin: update item
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
  }) async {
    final payload = <String, dynamic>{
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
      'updated_at': DateTime.now().toIso8601String(),
    };

    final row = await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .update(payload)
        .eq('id', id)
        .select(
          'id,unit_id,media_type,title,description,media_url,thumbnail_url,external_url,is_active,display_order,created_at',
        )
        .single();

    return MediaGalleryItem.fromMap(Map<String, dynamic>.from(row));
  }

  /// Admin: delete item
  Future<void> deleteItem(String id) async {
    await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .delete()
        .eq('id', id);
  }

  /// Admin: quick toggle active flag
  Future<void> setActive(String id, bool isActive) async {
    await _client
        .from(PwfDatabaseOwnerSurfaces.mediaGalleryItems)
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}
