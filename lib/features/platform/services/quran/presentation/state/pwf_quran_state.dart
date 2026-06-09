import 'package:flutter/foundation.dart';
import '../../domain/pwf_quran_models.dart';

@immutable
class PwfQuranState {
  const PwfQuranState({
    required this.isLoading,
    required this.surahs,
    required this.reciters,
    required this.currentSurahId,
    required this.currentReciterId,
    required this.fontScaleRem,
    required this.searchQuery,
    required this.isPlaying,
    required this.bookmarks,
  });

  factory PwfQuranState.initial() {
    return const PwfQuranState(
      isLoading: true,
      surahs: <PwfQuranSurah>[],
      reciters: <PwfQuranReciter>[],
      currentSurahId: 1,
      currentReciterId: 1,
      fontScaleRem: 1.5,
      searchQuery: '',
      isPlaying: false,
      bookmarks: <PwfQuranBookmark>[],
    );
  }

  final bool isLoading;
  final List<PwfQuranSurah> surahs;
  final List<PwfQuranReciter> reciters;

  final int currentSurahId;
  final int currentReciterId;

  /// HTML range: 1..3 (rem). We keep same semantics.
  final double fontScaleRem;

  final String searchQuery;
  final bool isPlaying;

  final List<PwfQuranBookmark> bookmarks;

  PwfQuranState copyWith({
    bool? isLoading,
    List<PwfQuranSurah>? surahs,
    List<PwfQuranReciter>? reciters,
    int? currentSurahId,
    int? currentReciterId,
    double? fontScaleRem,
    String? searchQuery,
    bool? isPlaying,
    List<PwfQuranBookmark>? bookmarks,
  }) {
    return PwfQuranState(
      isLoading: isLoading ?? this.isLoading,
      surahs: surahs ?? this.surahs,
      reciters: reciters ?? this.reciters,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentReciterId: currentReciterId ?? this.currentReciterId,
      fontScaleRem: fontScaleRem ?? this.fontScaleRem,
      searchQuery: searchQuery ?? this.searchQuery,
      isPlaying: isPlaying ?? this.isPlaying,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}
