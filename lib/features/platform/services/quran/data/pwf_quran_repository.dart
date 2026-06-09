import '../domain/pwf_quran_models.dart';

abstract class PwfQuranRepository {
  Future<List<PwfQuranSurah>> listSurahs();
  Future<List<PwfQuranReciter>> listReciters();
  Future<PwfQuranSurah?> getSurah(int id);
}
