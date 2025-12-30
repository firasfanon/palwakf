// lib/presentation/providers/homepage_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/homepage_section.dart';
import '../../data/repositories/homepage_repository.dart';
import 'supabase_providers.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

// FIXED: Use supabaseServiceProvider instead of direct Supabase.instance access
final homepageRepositoryProvider = Provider<HomepageRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return HomepageRepository(supabaseService.client);
});

// ============================================
// SECTION PROVIDERS
// ============================================

/// Provider for all homepage sections
final allHomepageSectionsProvider =
FutureProvider<List<HomepageSection>>((ref) async {
  final repository = ref.watch(homepageRepositoryProvider);
  return repository.fetchAllSections();
});

/// Provider for minister section settings
final ministerSectionProvider =
FutureProvider<MinisterSectionSettings?>((ref) async {
  final repository = ref.watch(homepageRepositoryProvider);
  return repository.fetchMinisterSettings();
});

/// Provider for statistics section settings
final statisticsSectionProvider =
FutureProvider<StatisticsSectionSettings?>((ref) async {
  final repository = ref.watch(homepageRepositoryProvider);
  return repository.fetchStatisticsSettings();
});

/// Provider for news section settings
final newsSectionProvider =
FutureProvider<NewsSectionSettings?>((ref) async {
  final repository = ref.watch(homepageRepositoryProvider);
  return repository.fetchNewsSettings();
});

/// Provider for announcements section settings
final announcementsSectionProvider =
FutureProvider<AnnouncementsSectionSettings?>((ref) async {
  final repository = ref.watch(homepageRepositoryProvider);
  return repository.fetchAnnouncementsSettings();
});

// ============================================
// MINISTER SECTION NOTIFIER
// ============================================

class MinisterSectionState {
  final MinisterSectionSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;

  const MinisterSectionState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  MinisterSectionState copyWith({
    MinisterSectionSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return MinisterSectionState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class MinisterSectionNotifier extends StateNotifier<MinisterSectionState> {
  final HomepageRepository _repository;

  MinisterSectionNotifier(this._repository)
      : super(const MinisterSectionState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchMinisterSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings(MinisterSectionSettings settings) {
    state = state.copyWith(settings: settings, hasUnsavedChanges: true);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateMinisterSection(state.settings!);
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void resetChanges() {
    loadSettings();
  }
}

final ministerSectionNotifierProvider = StateNotifierProvider<MinisterSectionNotifier, MinisterSectionState>((ref) {
  final repository = ref.watch(homepageRepositoryProvider);
  return MinisterSectionNotifier(repository);
});

// ============================================
// STATISTICS SECTION NOTIFIER
// ============================================

class StatisticsSectionState {
  final StatisticsSectionSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;

  const StatisticsSectionState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  StatisticsSectionState copyWith({
    StatisticsSectionSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return StatisticsSectionState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class StatisticsSectionNotifier extends StateNotifier<StatisticsSectionState> {
  final HomepageRepository _repository;

  StatisticsSectionNotifier(this._repository)
      : super(const StatisticsSectionState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchStatisticsSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings(StatisticsSectionSettings settings) {
    state = state.copyWith(settings: settings, hasUnsavedChanges: true);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateStatisticsSection(state.settings!);
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void resetChanges() {
    loadSettings();
  }
}

final statisticsSectionNotifierProvider = StateNotifierProvider<
    StatisticsSectionNotifier, StatisticsSectionState>((ref) {
  final repository = ref.watch(homepageRepositoryProvider);
  return StatisticsSectionNotifier(repository);
});

// ============================================
// NEWS SECTION NOTIFIER
// ============================================

class NewsSectionState {
  final NewsSectionSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;

  const NewsSectionState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  NewsSectionState copyWith({
    NewsSectionSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return NewsSectionState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class NewsSectionNotifier extends StateNotifier<NewsSectionState> {
  final HomepageRepository _repository;

  NewsSectionNotifier(this._repository) : super(const NewsSectionState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchNewsSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings(NewsSectionSettings settings) {
    state = state.copyWith(settings: settings, hasUnsavedChanges: true);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateNewsSection(state.settings!);
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void resetChanges() {
    loadSettings();
  }
}

final newsSectionNotifierProvider = StateNotifierProvider<NewsSectionNotifier, NewsSectionState>((ref) {
  final repository = ref.watch(homepageRepositoryProvider);
  return NewsSectionNotifier(repository);
});

// ============================================
// ANNOUNCEMENTS SECTION NOTIFIER
// ============================================

class AnnouncementsSectionState {
  final AnnouncementsSectionSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;

  const AnnouncementsSectionState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  AnnouncementsSectionState copyWith({
    AnnouncementsSectionSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return AnnouncementsSectionState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class AnnouncementsSectionNotifier extends StateNotifier<AnnouncementsSectionState> {
  final HomepageRepository _repository;

  AnnouncementsSectionNotifier(this._repository)
      : super(const AnnouncementsSectionState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchAnnouncementsSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings(AnnouncementsSectionSettings settings) {
    state = state.copyWith(settings: settings, hasUnsavedChanges: true);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateAnnouncementsSection(state.settings!);
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void resetChanges() {
    loadSettings();
  }
}

final announcementsSectionNotifierProvider = StateNotifierProvider<AnnouncementsSectionNotifier, AnnouncementsSectionState>((ref) {
  final repository = ref.watch(homepageRepositoryProvider);
  return AnnouncementsSectionNotifier(repository);
});


// ============================================
// BREAKING NEWS SECTION NOTIFIER
// ============================================

class BreakingNewsSectionState {
  final BreakingNewsSectionSettings? settings;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool hasUnsavedChanges;

  const BreakingNewsSectionState({
    this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  BreakingNewsSectionState copyWith({
    BreakingNewsSectionSettings? settings,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return BreakingNewsSectionState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class BreakingNewsSectionNotifier extends StateNotifier<BreakingNewsSectionState> {
  final HomepageRepository _repository;

  BreakingNewsSectionNotifier(this._repository)
      : super(const BreakingNewsSectionState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchBreakingNewsSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings(BreakingNewsSectionSettings settings) {
    state = state.copyWith(settings: settings, hasUnsavedChanges: true);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.updateBreakingNewsSection(state.settings!);
      state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void resetChanges() {
    loadSettings();
  }
}

final breakingNewsSectionNotifierProvider = StateNotifierProvider<BreakingNewsSectionNotifier, BreakingNewsSectionState>((ref) {
  final repository = ref.watch(homepageRepositoryProvider);
  return BreakingNewsSectionNotifier(repository);
});

// Provider for active breaking news items
final activeBreakingNewsProvider = FutureProvider<List<BreakingNewsItem>>((ref) async {
  final repository = ref.watch(homepageRepositoryProvider);
  return repository.fetchActiveBreakingNews();
});