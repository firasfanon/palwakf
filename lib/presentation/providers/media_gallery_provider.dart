import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/media_gallery_item.dart';
import '../../data/repositories/media_gallery_repository.dart';
import '../../data/services/supabase_service.dart';
import 'unit_context_provider.dart';

final mediaGalleryRepositoryProvider = Provider<MediaGalleryRepository>((ref) {
  return MediaGalleryRepository(SupabaseService());
});

@immutable
class MediaGalleryQuery {
  final String unitSlug;
  final MediaType type;
  final int limit;

  const MediaGalleryQuery({
    required this.unitSlug,
    required this.type,
    this.limit = 8,
  });

  @override
  bool operator ==(Object other) {
    return other is MediaGalleryQuery &&
        other.unitSlug == unitSlug &&
        other.type == type &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(unitSlug, type, limit);
}

@immutable
class PublicMediaGalleryBrowseQuery {
  final String unitSlug;
  final MediaType type;
  final String search;
  final int? limit;

  const PublicMediaGalleryBrowseQuery({
    required this.unitSlug,
    required this.type,
    this.search = '',
    this.limit,
  });

  @override
  bool operator ==(Object other) {
    return other is PublicMediaGalleryBrowseQuery &&
        other.unitSlug == unitSlug &&
        other.type == type &&
        other.search == search &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(unitSlug, type, search, limit);
}

final unitMediaGalleryProvider =
    FutureProvider.family<List<MediaGalleryItem>, MediaGalleryQuery>((
      ref,
      q,
    ) async {
      final unitId = await ref.watch(unitIdBySlugProvider(q.unitSlug).future);
      final repo = ref.read(mediaGalleryRepositoryProvider);
      return repo.fetchActiveForUnit(unitId, mediaType: q.type, limit: q.limit);
    });

final publicMediaGalleryBrowseProvider =
    FutureProvider.family<
      List<MediaGalleryItem>,
      PublicMediaGalleryBrowseQuery
    >((ref, q) async {
      final unitId = await ref.watch(unitIdBySlugProvider(q.unitSlug).future);
      final repo = ref.read(mediaGalleryRepositoryProvider);
      return repo.fetchPublicForUnit(
        unitId,
        mediaType: q.type,
        search: q.search,
        limit: q.limit,
      );
    });

final unitPhotosProvider =
    FutureProvider.family<List<MediaGalleryItem>, String>((
      ref,
      unitSlug,
    ) async {
      return ref.watch(
        unitMediaGalleryProvider(
          MediaGalleryQuery(unitSlug: unitSlug, type: MediaType.photo),
        ).future,
      );
    });

final unitVideosProvider =
    FutureProvider.family<List<MediaGalleryItem>, String>((
      ref,
      unitSlug,
    ) async {
      return ref.watch(
        unitMediaGalleryProvider(
          MediaGalleryQuery(unitSlug: unitSlug, type: MediaType.video),
        ).future,
      );
    });
