// lib/presentation/providers/footer_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/footer_settings.dart';
import '../../data/repositories/footer_repository.dart';


// Repository Provider
final footerRepositoryProvider = Provider<FooterRepository>((ref) {
  return FooterRepository(Supabase.instance.client);
});

// State class
class FooterSettingsState {
  final FooterSettings? settings;
  final FooterSettings? originalSettings;
  final bool isLoading;
  final String? error;

  FooterSettingsState({
    this.settings,
    this.originalSettings,
    this.isLoading = false,
    this.error,
  });

  FooterSettingsState copyWith({
    FooterSettings? settings,
    FooterSettings? originalSettings,
    bool? isLoading,
    String? error,
  }) {
    return FooterSettingsState(
      settings: settings ?? this.settings,
      originalSettings: originalSettings ?? this.originalSettings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get hasChanges =>
      settings != null &&
          originalSettings != null &&
          settings != originalSettings;
}

// Notifier
class FooterSettingsNotifier extends StateNotifier<FooterSettingsState> {
  final FooterRepository _repository;

  FooterSettingsNotifier(this._repository) : super(FooterSettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchFooterSettings();
      state = state.copyWith(
        settings: settings,
        originalSettings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateSettings(FooterSettings settings) {
    state = state.copyWith(settings: settings);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateFooterSettings(state.settings!);
      state = state.copyWith(
        originalSettings: state.settings,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void resetChanges() {
    state = state.copyWith(settings: state.originalSettings);
  }
}

// Provider
final footerSettingsProvider =
StateNotifierProvider<FooterSettingsNotifier, FooterSettingsState>((ref) {
  final repository = ref.watch(footerRepositoryProvider);
  return FooterSettingsNotifier(repository);
});