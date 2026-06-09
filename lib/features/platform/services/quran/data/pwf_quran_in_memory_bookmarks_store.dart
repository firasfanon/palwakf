import '../domain/pwf_quran_models.dart';
import 'pwf_quran_bookmarks_store.dart';

class PwfQuranInMemoryBookmarksStore implements PwfQuranBookmarksStore {
  List<PwfQuranBookmark> _cache = const [];

  @override
  Future<List<PwfQuranBookmark>> load() async => _cache;

  @override
  Future<void> save(List<PwfQuranBookmark> bookmarks) async {
    _cache = List<PwfQuranBookmark>.unmodifiable(bookmarks);
  }
}
