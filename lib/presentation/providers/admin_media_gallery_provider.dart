import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/media_gallery_item.dart';
import 'media_gallery_provider.dart';
import 'unit_context_provider.dart';

@immutable
class AdminMediaGalleryQuery {
  final String unitSlug;
  final MediaType mediaType;
  final bool includeInactive;
  final String search;

  const AdminMediaGalleryQuery({
    required this.unitSlug,
    required this.mediaType,
    this.includeInactive = true,
    this.search = '',
  });

  @override
  bool operator ==(Object other) {
    return other is AdminMediaGalleryQuery &&
        other.unitSlug == unitSlug &&
        other.mediaType == mediaType &&
        other.includeInactive == includeInactive &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(unitSlug, mediaType, includeInactive, search);
}

/// Admin list provider for gallery items.
///
/// Note: uses the same repository as public gallery but with includeInactive/search.
final adminMediaGalleryItemsProvider =
    FutureProvider.family<List<MediaGalleryItem>, AdminMediaGalleryQuery>((
      ref,
      q,
    ) async {
      final unitId = await ref.watch(unitIdBySlugExactProvider(q.unitSlug).future);
      if (unitId == null || unitId.isEmpty) {
        throw StateError('Unknown or unavailable editorial unit scope.');
      }
      final repo = ref.read(mediaGalleryRepositoryProvider);
      return repo.fetchForUnit(
        unitId,
        mediaType: q.mediaType,
        includeInactive: q.includeInactive,
        search: q.search,
      );
    });
