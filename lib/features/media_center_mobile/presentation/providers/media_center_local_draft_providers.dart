
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/media_center_mobile_local_draft_store.dart';

final mediaCenterLocalDraftStoreProvider =
    Provider<MediaCenterMobileLocalDraftStore>((ref) {
  return const MediaCenterMobileLocalDraftStore();
});

final mediaCenterLocalDraftsProvider =
    FutureProvider<List<MediaCenterLocalDraft>>((ref) async {
  final store = ref.watch(mediaCenterLocalDraftStoreProvider);
  return store.loadDrafts();
});
