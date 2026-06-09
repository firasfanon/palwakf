import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pwf_quran_in_memory_bookmarks_store.dart';
import '../../data/pwf_quran_in_memory_repository.dart';
import '../../data/pwf_quran_bookmarks_store.dart';
import '../../data/pwf_quran_repository.dart';
import '../state/pwf_quran_notifier.dart';
import '../state/pwf_quran_state.dart';

final pwfQuranRepositoryProvider = Provider<PwfQuranRepository>((ref) {
  return PwfQuranInMemoryRepository();
});

final pwfQuranBookmarksStoreProvider = Provider<PwfQuranBookmarksStore>((ref) {
  return PwfQuranInMemoryBookmarksStore();
});

final pwfQuranNotifierProvider =
    StateNotifierProvider<PwfQuranNotifier, PwfQuranState>((ref) {
      final repo = ref.watch(pwfQuranRepositoryProvider);
      final store = ref.watch(pwfQuranBookmarksStoreProvider);
      final notifier = PwfQuranNotifier(repo: repo, bookmarksStore: store);
      notifier.init();
      return notifier;
    });
