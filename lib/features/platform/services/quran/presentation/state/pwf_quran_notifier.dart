import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pwf_quran_bookmarks_store.dart';
import '../../data/pwf_quran_repository.dart';
import '../../domain/pwf_quran_models.dart';
import 'pwf_quran_state.dart';

class PwfQuranNotifier extends StateNotifier<PwfQuranState> {
  PwfQuranNotifier({
    required PwfQuranRepository repo,
    required PwfQuranBookmarksStore bookmarksStore,
  }) : _repo = repo,
       _bookmarksStore = bookmarksStore,
       super(PwfQuranState.initial());

  final PwfQuranRepository _repo;
  final PwfQuranBookmarksStore _bookmarksStore;

  Future<void> init() async {
    final surahs = await _repo.listSurahs();
    final reciters = await _repo.listReciters();
    final bookmarks = await _bookmarksStore.load();

    final safeSurahId = surahs.any((s) => s.id == state.currentSurahId)
        ? state.currentSurahId
        : (surahs.isNotEmpty ? surahs.first.id : 1);

    final safeReciterId = reciters.any((r) => r.id == state.currentReciterId)
        ? state.currentReciterId
        : (reciters.isNotEmpty ? reciters.first.id : 1);

    state = state.copyWith(
      isLoading: false,
      surahs: surahs,
      reciters: reciters,
      currentSurahId: safeSurahId,
      currentReciterId: safeReciterId,
      bookmarks: bookmarks,
    );
  }

  void setSurah(int surahId) {
    if (surahId == state.currentSurahId) return;
    state = state.copyWith(currentSurahId: surahId, isPlaying: false);
  }

  void prevSurah() {
    final current = state.currentSurahId;
    if (current <= 1) return;
    state = state.copyWith(currentSurahId: current - 1, isPlaying: false);
  }

  void nextSurah() {
    final current = state.currentSurahId;
    if (current >= 114) return;
    state = state.copyWith(currentSurahId: current + 1, isPlaying: false);
  }

  void setReciter(int reciterId) {
    if (reciterId == state.currentReciterId) return;
    state = state.copyWith(currentReciterId: reciterId);
  }

  void setFontScale(double rem) {
    final clamped = rem.clamp(1.0, 3.0);
    state = state.copyWith(fontScaleRem: clamped.toDouble());
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  bool isSurahBookmarked(int surahId) {
    return state.bookmarks.any((b) => b.surahId == surahId);
  }

  Future<bool> toggleBookmarkForCurrentSurah() async {
    final surahId = state.currentSurahId;
    final list = List<PwfQuranBookmark>.from(state.bookmarks);

    final existingIndex = list.indexWhere((b) => b.surahId == surahId);
    final added = existingIndex < 0;

    if (added) {
      list.add(
        PwfQuranBookmark(
          surahId: surahId,
          ayahNo: 1,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      list.removeAt(existingIndex);
    }

    final next = List<PwfQuranBookmark>.unmodifiable(list);
    state = state.copyWith(bookmarks: next);

    await _bookmarksStore.save(next);
    return added;
  }
}
