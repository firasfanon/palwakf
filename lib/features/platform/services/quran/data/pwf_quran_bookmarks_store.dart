import '../domain/pwf_quran_models.dart';

abstract class PwfQuranBookmarksStore {
  Future<List<PwfQuranBookmark>> load();
  Future<void> save(List<PwfQuranBookmark> bookmarks);
}
