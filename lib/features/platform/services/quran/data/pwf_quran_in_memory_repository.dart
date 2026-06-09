import '../domain/pwf_quran_models.dart';
import 'pwf_quran_repository.dart';

class PwfQuranInMemoryRepository implements PwfQuranRepository {
  static const _reciters = <PwfQuranReciter>[
    PwfQuranReciter(id: 1, name: 'مشغل تجريبي داخلي'),
    PwfQuranReciter(id: 2, name: 'قارئ افتراضي'),
  ];

  static const _surahs = <PwfQuranSurah>[
    PwfQuranSurah(
      id: 1,
      name: 'سورة الفاتحة',
      type: 'مكية',
      ayahCount: 7,
      part: 1,
      ayahText: <String>[
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'الرَّحْمَٰنِ الرَّحِيمِ',
        'مَالِكِ يَوْمِ الدِّينِ',
        'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرَ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      ],
    ),
    PwfQuranSurah(
      id: 2,
      name: 'سورة البقرة',
      type: 'مدنية',
      ayahCount: 286,
      part: 1,
      ayahText: <String>[
        'الم',
        'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِلْمُتَّقِينَ',
        'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ',
      ],
    ),
    PwfQuranSurah(
      id: 36,
      name: 'سورة يس',
      type: 'مكية',
      ayahCount: 83,
      part: 22,
      ayahText: <String>[
        'يس',
        'وَالْقُرْآنِ الْحَكِيمِ',
        'إِنَّكَ لَمِنَ الْمُرْسَلِينَ',
        'عَلَىٰ صِرَاطٍ مُّسْتَقِيمٍ',
      ],
    ),
    PwfQuranSurah(
      id: 55,
      name: 'سورة الرحمن',
      type: 'مدنية',
      ayahCount: 78,
      part: 27,
      ayahText: <String>[
        'الرَّحْمَٰنُ',
        'عَلَّمَ الْقُرْآنَ',
        'خَلَقَ الْإِنسَانَ',
        'عَلَّمَهُ الْبَيَانَ',
      ],
    ),
    PwfQuranSurah(
      id: 112,
      name: 'سورة الإخلاص',
      type: 'مكية',
      ayahCount: 4,
      part: 30,
      ayahText: <String>[
        'قُلْ هُوَ اللَّهُ أَحَدٌ',
        'اللَّهُ الصَّمَدُ',
        'لَمْ يَلِدْ وَلَمْ يُولَدْ',
        'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      ],
    ),
  ];

  @override
  Future<List<PwfQuranSurah>> listSurahs() async => _surahs;

  @override
  Future<List<PwfQuranReciter>> listReciters() async => _reciters;

  @override
  Future<PwfQuranSurah?> getSurah(int id) async {
    try {
      return _surahs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
