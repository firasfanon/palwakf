import 'package:flutter/foundation.dart';

@immutable
class PwfQuranSurah {
  const PwfQuranSurah({
    required this.id,
    required this.name,
    required this.type,
    required this.ayahCount,
    required this.part,
    required this.ayahText,
  });

  final int id;
  final String name;
  final String type; // مكية/مدنية
  final int ayahCount;
  final int part;
  final List<String> ayahText;
}

@immutable
class PwfQuranReciter {
  const PwfQuranReciter({
    required this.id,
    required this.name,
    this.audioBaseUrl,
  });

  final int id;
  final String name;
  final String? audioBaseUrl;
}

@immutable
class PwfQuranBookmark {
  const PwfQuranBookmark({
    required this.surahId,
    required this.ayahNo,
    required this.createdAt,
  });

  final int surahId;
  final int ayahNo;
  final DateTime createdAt;
}
