// lib/presentation/providers/header_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/header_settings.dart';
import '../../data/repositories/header_repository.dart';
import 'unit_context_provider.dart';

// Repository Provider
final headerRepositoryProvider = Provider<HeaderRepository>((ref) {
  return HeaderRepository(Supabase.instance.client);
});

// State class for header settings
class HeaderSettingsState {
  final HeaderSettings? settings;
  final HeaderSettings? originalSettings;
  final bool isLoading;
  final String? error;

  HeaderSettingsState({
    this.settings,
    this.originalSettings,
    this.isLoading = false,
    this.error,
  });

  HeaderSettingsState copyWith({
    HeaderSettings? settings,
    HeaderSettings? originalSettings,
    bool? isLoading,
    String? error,
  }) {
    return HeaderSettingsState(
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
class HeaderSettingsNotifier extends StateNotifier<HeaderSettingsState> {
  final HeaderRepository _repository;

  HeaderSettingsNotifier(this._repository) : super(HeaderSettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final settings = await _repository.fetchHeaderSettings();
      state = state.copyWith(
        settings: settings,
        originalSettings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateSettings(HeaderSettings settings) {
    state = state.copyWith(settings: settings);
  }

  Future<bool> saveSettings() async {
    if (state.settings == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateHeaderSettings(state.settings!);
      state = state.copyWith(
        originalSettings: state.settings,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void resetChanges() {
    state = state.copyWith(settings: state.originalSettings);
  }
}

// Provider
final headerSettingsProvider =
    StateNotifierProvider<HeaderSettingsNotifier, HeaderSettingsState>((ref) {
      final repository = ref.watch(headerRepositoryProvider);
      return HeaderSettingsNotifier(repository);
    });

final publicHeaderSettingsProvider =
    FutureProvider.family<HeaderSettings, String>((ref, unitSlug) async {
      final repository = ref.watch(headerRepositoryProvider);
      final normalized = unitSlug.trim().isEmpty
          ? 'home'
          : unitSlug.trim().toLowerCase();
      String? unitId;
      String? homeUnitId;

      try {
        unitId = await ref.watch(unitIdBySlugProvider(normalized).future);
      } catch (_) {
        unitId = null;
      }

      try {
        homeUnitId = await ref.watch(unitIdBySlugProvider('home').future);
      } catch (_) {
        homeUnitId = null;
      }

      return repository.fetchHeaderSettingsForScopes(
        unitId: unitId,
        homeUnitId: homeUnitId,
      );
    });
