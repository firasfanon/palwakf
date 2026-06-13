import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../data/models/homepage_section.dart';
import '../../../../../../data/repositories/homepage_repository.dart';
import '../../../../../../data/repositories/org_units_repository.dart';
import 'pwf_home_management_sections.dart';

class PwfHomepageSectionsState {
  final bool isLoading;
  final bool isSaving;
  final String unitSlug;
  final List<HomepageSection> original;
  final List<HomepageSection> draft;
  final String? error;

  bool get isDirty {
    if (original.length != draft.length) return true;
    for (int i = 0; i < draft.length; i++) {
      final a = original[i];
      final b = draft[i];
      if (a.sectionName != b.sectionName) return true;
      if (a.isActive != b.isActive) return true;
      if (a.displayOrder != b.displayOrder) return true;
      if (a.settings.toString() != b.settings.toString()) return true;
    }
    return false;
  }

  const PwfHomepageSectionsState({
    required this.isLoading,
    required this.isSaving,
    required this.unitSlug,
    required this.original,
    required this.draft,
    required this.error,
  });

  factory PwfHomepageSectionsState.initial() => const PwfHomepageSectionsState(
    isLoading: true,
    isSaving: false,
    unitSlug: 'home',
    original: <HomepageSection>[],
    draft: <HomepageSection>[],
    error: null,
  );

  PwfHomepageSectionsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? unitSlug,
    List<HomepageSection>? original,
    List<HomepageSection>? draft,
    String? error,
  }) {
    return PwfHomepageSectionsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      unitSlug: unitSlug ?? this.unitSlug,
      original: original ?? this.original,
      draft: draft ?? this.draft,
      error: error,
    );
  }
}

final homepageRepositoryProvider = Provider<HomepageRepository>((ref) {
  return HomepageRepository(Supabase.instance.client);
});

final orgUnitsRepositoryProvider = Provider<OrgUnitsRepository>((ref) {
  return OrgUnitsRepository(Supabase.instance.client);
});

final pwfHomepageSectionsManagerProvider =
    StateNotifierProvider<PwfHomepageSectionsManager, PwfHomepageSectionsState>(
      (ref) {
        final repo = ref.watch(homepageRepositoryProvider);
        final orgUnitsRepo = ref.watch(orgUnitsRepositoryProvider);
        return PwfHomepageSectionsManager(repo, orgUnitsRepo)..load();
      },
    );

class PwfHomepageSectionsManager
    extends StateNotifier<PwfHomepageSectionsState> {
  final HomepageRepository _repo;
  final OrgUnitsRepository _orgUnitsRepo;

  String? _currentUnitId;
  String? _homeUnitId;

  PwfHomepageSectionsManager(this._repo, this._orgUnitsRepo)
    : super(PwfHomepageSectionsState.initial());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final rows = await _loadSectionsForCurrentUnit();

      // Normalize to the official set of keys.
      final normalized = _ensureOfficialKeys(rows);
      final ordered = _sortWithPinnedEdges(normalized);

      state = state.copyWith(
        isLoading: false,
        original: List.unmodifiable(ordered),
        draft: List.unmodifiable(ordered),
      );
    } catch (e, st) {
      log('Home sections load failed: $e', stackTrace: st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setUnitSlug(String slug) async {
    final normalized = slug.trim().isEmpty ? 'home' : slug.trim().toLowerCase();
    if (normalized == state.unitSlug) return;
    state = state.copyWith(unitSlug: normalized);
    await load();
  }

  void toggleActive(String key, bool value) {
    final updated = state.draft.map((s) {
      if (s.sectionName != key) return s;
      return _copySection(
        s,
        isActive: value,
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      );
    }).toList();

    state = state.copyWith(
      draft: List.unmodifiable(_sortWithPinnedEdges(updated)),
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final list = state.draft.toList();
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex < 0 || newIndex > list.length) return;

    final topPinned = pwfTopPinnedCount();
    final bottomPinned = pwfBottomPinnedCount();
    final movableStart = topPinned;
    final movableEndExclusive = list.length - bottomPinned;
    if (movableEndExclusive <= movableStart) return;

    final moving = list[oldIndex];
    final movingDef = findPwfHomeSection(moving.sectionName);
    if (movingDef?.isPinned ?? false) return;

    if (newIndex > oldIndex) newIndex -= 1;
    newIndex = newIndex.clamp(movableStart, movableEndExclusive - 1).toInt();

    final top = list.take(topPinned).toList(growable: false);
    final movable = list.sublist(movableStart, movableEndExclusive).toList();
    final bottom = list.skip(movableEndExclusive).toList(growable: false);

    final localOld = oldIndex - movableStart;
    var localNew = newIndex - movableStart;
    if (localOld < 0 || localOld >= movable.length) return;
    if (localNew < 0) localNew = 0;
    if (localNew > movable.length) localNew = movable.length;

    final item = movable.removeAt(localOld);
    if (localNew > movable.length) localNew = movable.length;
    movable.insert(localNew, item);

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final reordered = <HomepageSection>[];
    reordered.addAll(top);
    reordered.addAll(movable);
    reordered.addAll(bottom);

    for (int i = 0; i < reordered.length; i++) {
      final s = reordered[i];
      reordered[i] = _copySection(s, displayOrder: i, updatedAtIso: nowIso);
    }

    state = state.copyWith(draft: List.unmodifiable(reordered));
  }

  /// Adds a new section (only if missing).
  void addSection(String key) {
    final exists = state.draft.any((e) => e.sectionName == key);
    if (exists) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final newItem = _sectionFromValues(
      id: '',
      sectionName: key,
      settings: const <String, dynamic>{},
      isActive: true,
      displayOrder: state.draft.length,
      createdAtIso: nowIso,
      updatedAtIso: nowIso,
      updatedBy: null,
    );

    final list = state.draft.toList();

    // Insert after top pinned items and before bottom pinned items.
    final insertIndex = (list.length - pwfBottomPinnedCount())
        .clamp(pwfTopPinnedCount(), list.length)
        .toInt();
    list.insert(insertIndex, newItem);

    state = state.copyWith(
      draft: List.unmodifiable(_sortWithPinnedEdges(list)),
    );
  }

  void resetDraft() {
    state = state.copyWith(
      draft: List.unmodifiable(state.original),
      error: null,
    );
  }

  Future<void> save() async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true, error: null);
    try {
      if (state.unitSlug != 'home' &&
          (_currentUnitId == null || _currentUnitId!.isEmpty)) {
        throw StateError('تعذر تحديد الوحدة المختارة للحفظ.');
      }

      await _repo.saveSectionsMeta(state.draft, unitId: _currentUnitId);
      await _repo.deleteSectionsOutsideCatalog(
        keepSectionNames: state.draft.map((e) => e.sectionName).toSet(),
        unitId: _currentUnitId,
      );

      // Reload from DB to get canonical ordering/values.
      final rows = await _loadSectionsForCurrentUnit();
      final normalized = _ensureOfficialKeys(rows);
      final ordered = _sortWithPinnedEdges(normalized);
      state = state.copyWith(
        isSaving: false,
        original: List.unmodifiable(ordered),
        draft: List.unmodifiable(ordered),
      );
    } catch (e, st) {
      log('Home sections save failed: $e', stackTrace: st);
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  List<HomepageSection> _ensureOfficialKeys(List<HomepageSection> existing) {
    final byKey = <String, HomepageSection>{};
    final nowIso = DateTime.now().toUtc().toIso8601String();

    for (final row in existing) {
      final canonicalKey = canonicalPwfHomeSectionKey(row.sectionName);
      if (!isOfficialPwfHomeSectionKey(canonicalKey)) {
        continue;
      }

      final normalizedRow = row.sectionName == canonicalKey
          ? row
          : HomepageSection.fromJson(<String, dynamic>{
              ...row.toJson(),
              'section_name': canonicalKey,
            });

      final previous = byKey[canonicalKey];
      if (previous == null || _shouldPreferRow(previous, normalizedRow)) {
        byKey[canonicalKey] = normalizedRow;
      }
    }

    for (final def in kPwfHomeSections) {
      byKey.putIfAbsent(
        def.key,
        () => _sectionFromValues(
          id: '',
          sectionName: def.key,
          settings: const <String, dynamic>{},
          isActive: _defaultActiveForMissingCatalogKey(def),
          displayOrder: kPwfHomeSections.indexOf(def),
          createdAtIso: nowIso,
          updatedAtIso: nowIso,
          updatedBy: null,
        ),
      );
    }

    return byKey.values.toList(growable: false);
  }

  bool _defaultActiveForMissingCatalogKey(PwfHomeSectionDef def) {
    // Missing catalog rows are shown in the admin manager for discoverability,
    // but they must not become active public sections merely because the
    // catalog grew. Pinned shell rows stay active so header/footer controls
    // remain visible when a scoped page has partial data.
    return def.pin != PwfHomeSectionPin.none;
  }

  bool _shouldPreferRow(HomepageSection current, HomepageSection candidate) {
    final currentExact =
        current.sectionName == canonicalPwfHomeSectionKey(current.sectionName);
    final candidateExact =
        candidate.sectionName ==
        canonicalPwfHomeSectionKey(candidate.sectionName);
    if (candidateExact != currentExact) return candidateExact;
    if (candidate.displayOrder != current.displayOrder) {
      return candidate.displayOrder < current.displayOrder;
    }
    return candidate.updatedAt.compareTo(current.updatedAt) > 0;
  }

  List<HomepageSection> _sortWithPinnedEdges(List<HomepageSection> list) {
    int catalogIndex(String key) {
      for (int i = 0; i < kPwfHomeSections.length; i++) {
        if (kPwfHomeSections[i].key == key) return i;
      }
      return 9999;
    }

    int pinRank(String key) {
      final pin = findPwfHomeSection(key)?.pin;
      if (pin == PwfHomeSectionPin.top) return 0;
      if (pin == PwfHomeSectionPin.bottom) return 2;
      return 1;
    }

    final sorted = list.toList()
      ..sort((a, b) {
        final ar = pinRank(a.sectionName);
        final br = pinRank(b.sectionName);
        if (ar != br) return ar.compareTo(br);

        // Within pinned top/bottom: follow catalog order.
        if (ar != 1) {
          return catalogIndex(
            a.sectionName,
          ).compareTo(catalogIndex(b.sectionName));
        }

        // Movable: by displayOrder, then catalog order, then key.
        final c = a.displayOrder.compareTo(b.displayOrder);
        if (c != 0) return c;
        final ci = catalogIndex(
          a.sectionName,
        ).compareTo(catalogIndex(b.sectionName));
        if (ci != 0) return ci;
        return a.sectionName.compareTo(b.sectionName);
      });
    return sorted;
  }

  // --------------------------------------------
  // Safe constructors (avoid tight coupling to model constructor signature)
  // --------------------------------------------

  HomepageSection _sectionFromValues({
    required String id,
    required String sectionName,
    required Map<String, dynamic> settings,
    required bool isActive,
    required int displayOrder,
    required String createdAtIso,
    required String updatedAtIso,
    required String? updatedBy,
  }) {
    return HomepageSection.fromJson(<String, dynamic>{
      'id': id,
      'section_name': sectionName,
      'settings': settings,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAtIso,
      'updated_at': updatedAtIso,
      'updated_by': updatedBy,
    });
  }

  HomepageSection _copySection(
    HomepageSection s, {
    bool? isActive,
    int? displayOrder,
    Map<String, dynamic>? settings,
    String? updatedAtIso,
  }) {
    final createdAtIso = _asIso(s.createdAt);
    final nextUpdatedAtIso = updatedAtIso ?? _asIso(DateTime.now().toUtc());

    return _sectionFromValues(
      id: s.id,
      sectionName: s.sectionName,
      settings: settings ?? s.settings,
      isActive: isActive ?? s.isActive,
      displayOrder: displayOrder ?? s.displayOrder,
      createdAtIso: createdAtIso,
      updatedAtIso: nextUpdatedAtIso,
      updatedBy: s.updatedBy,
    );
  }

  String _asIso(Object? v) {
    if (v is DateTime) return v.toUtc().toIso8601String();
    if (v is String && v.isNotEmpty) return v;
    return DateTime.now().toUtc().toIso8601String();
  }

  Future<List<HomepageSection>> _loadSectionsForCurrentUnit() async {
    final normalizedSlug = state.unitSlug.trim().isEmpty
        ? 'home'
        : state.unitSlug.trim().toLowerCase();

    try {
      _homeUnitId ??= await _orgUnitsRepo.fetchUnitIdBySlug('home');
      _currentUnitId = normalizedSlug == 'home'
          ? _homeUnitId
          : await _orgUnitsRepo.fetchUnitIdBySlug(normalizedSlug);

      if (_currentUnitId != null && _currentUnitId!.isNotEmpty) {
        return _repo.fetchAllSectionsForUnit(
          unitId: _currentUnitId!,
          homeUnitId: _homeUnitId,
        );
      }
    } catch (e, st) {
      log(
        'Home sections unit-scope load failed for $normalizedSlug: $e',
        stackTrace: st,
      );
    }

    return _repo.fetchAllSections();
  }
}
