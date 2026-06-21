import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/data/pwf_runtime_payload_normalizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/presentation/providers/org_units_provider.dart';

import 'pwf_unit_pages_execution_store.dart';

const String kPwfUnitPagesContractSlug = '__unit_page_contract__';

class PwfUnitPagesRepository {
  const PwfUnitPagesRepository(this._client);

  final SupabaseClient _client;

  // Public-schema Phase 1 remediation. Runtime/admin reads use compatibility
  // wrappers. Mutating admin operations keep using preserved legacy public
  // tables until an explicit owner-write RPC migration is approved.
  static const String _sitePagesReadSurface = 'v_platform_site_pages_compat_v1';
  static const String _sitePagesLegacyWriteTable = 'site_pages';
  static const String _sectionsReadSurface =
      'v_platform_homepage_sections_compat_v1';
  static const String _sectionsLegacyWriteTable = 'homepage_sections';

  Future<List<PwfUnitPageExecutionRow>> fetchPersistedContracts({
    required List<Map<String, dynamic>> units,
  }) async {
    final unitIds = units
        .map((e) => (e['id'] ?? '').toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (unitIds.isEmpty) return const <PwfUnitPageExecutionRow>[];

    final pageRows = await _client
        .from(_sitePagesReadSurface)
        .select('unit_id,title_ar,title_en,is_published,body_en,updated_at')
        .eq('slug', kPwfUnitPagesContractSlug)
        .inFilter('unit_id', unitIds);

    final sectionRows = await _client
        .from(_sectionsReadSurface)
        .select(
          'unit_id,section_name,is_active,display_order,updated_at,updated_by,settings',
        )
        .inFilter('unit_id', unitIds)
        .inFilter(
          'section_name',
          kPwfUnitPageAllowedSectionOptions
              .map((e) => e.key)
              .toList(growable: false),
        );

    final pagesByUnit = <String, Map<String, dynamic>>{};
    for (final raw in PwfRuntimePayloadNormalizer.rows(
      pageRows,
      source: 'public.v_platform_site_pages_compat_v1 unit contracts',
    )) {
      final row = Map<String, dynamic>.from(raw);
      final unitId = (row['unit_id'] ?? '').toString().trim();
      if (unitId.isEmpty) continue;
      pagesByUnit[unitId] = row;
    }

    final sectionsByUnit = <String, List<Map<String, dynamic>>>{};
    for (final raw in PwfRuntimePayloadNormalizer.rows(
      sectionRows,
      source: 'public.v_platform_homepage_sections_compat_v1 unit contracts',
    )) {
      final row = Map<String, dynamic>.from(raw);
      final unitId = (row['unit_id'] ?? '').toString().trim();
      if (unitId.isEmpty) continue;
      sectionsByUnit
          .putIfAbsent(unitId, () => <Map<String, dynamic>>[])
          .add(row);
    }

    final results = <PwfUnitPageExecutionRow>[];
    for (var i = 0; i < units.length; i++) {
      final unit = units[i];
      final unitId = (unit['id'] ?? '').toString().trim();
      if (unitId.isEmpty) continue;
      final slug = (unit['slug'] ?? '').toString().trim();
      final unitNameAr = ((unit['name_ar'] ?? unit['name'] ?? slug) ?? '')
          .toString()
          .trim();
      final pageRow = pagesByUnit[unitId];
      final meta = _decodeMeta(pageRow?['body_en']);
      final unitSections =
          sectionsByUnit[unitId] ?? const <Map<String, dynamic>>[];
      final activeSections = unitSections
          .where((e) => (e['is_active'] as bool?) ?? false)
          .map((e) => (e['section_name'] ?? '').toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      final metaSections = (meta['allowed_sections'] is List)
          ? (meta['allowed_sections'] as List)
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
          : const <String>[];
      final allowedSections = _normalizeAllowedSections(
        activeSections.isNotEmpty ? activeSections : metaSections,
      );
      final latestSectionUpdate = _latestSectionUpdatedAt(unitSections);
      final pageUpdatedAt = _parseDateTime(pageRow?['updated_at']);
      final updatedAt =
          _maxDateTime(pageUpdatedAt, latestSectionUpdate) ??
          _parseDateTime(meta['saved_at']);

      final pageTitleArCandidate =
          ((pageRow?['title_ar'] ?? meta['page_title_ar']) ?? '')
              .toString()
              .trim();
      final pageTitleEnCandidate =
          ((pageRow?['title_en'] ??
                      meta['page_title_en'] ??
                      unit['name_en'] ??
                      slug) ??
                  '')
              .toString()
              .trim();

      results.add(
        PwfUnitPageExecutionRow(
          unitId: unitId,
          unitNameAr: unitNameAr.isEmpty ? slug : unitNameAr,
          slug: slug,
          pageTitleAr: pageTitleArCandidate.isEmpty
              ? (unitNameAr.isEmpty ? 'صفحة الوحدة' : unitNameAr)
              : pageTitleArCandidate,
          pageTitleEn: pageTitleEnCandidate,
          isPublished:
              (pageRow?['is_published'] as bool?) ??
              (meta['is_published'] as bool?) ??
              (slug == 'home'),
          visibility: PwfUnitPageVisibilityModeX.fromValue(
            (meta['visibility'] ?? 'public').toString(),
          ),
          allowedSections: allowedSections.isEmpty
              ? const [
                  'pwf_news',
                  'pwf_announcements',
                  'pwf_activities',
                  'pwf_friday_sermons',
                ]
              : allowedSections,
          displayOrder: _asInt(meta['display_order'], i + 1),
          updatedAt: updatedAt,
          updatedByLabel: (meta['updated_by_label'] ?? 'من قاعدة البيانات')
              .toString(),
          isArchived: (meta['is_archived'] as bool?) ?? false,
        ),
      );
    }

    results.sort((a, b) {
      final order = a.displayOrder.compareTo(b.displayOrder);
      if (order != 0) return order;
      return a.unitNameAr.compareTo(b.unitNameAr);
    });
    return results;
  }

  Future<PwfUnitPageExecutionRow> saveContract(
    PwfUnitPageExecutionRow draft, {
    required String actorLabel,
  }) async {
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final userId = _client.auth.currentUser?.id;
    final normalizedSections = _normalizeAllowedSections(draft.allowedSections);
    final payload = <String, dynamic>{
      'unit_id': draft.unitId,
      'slug': kPwfUnitPagesContractSlug,
      'title_ar': draft.pageTitleAr.trim(),
      'title_en': draft.pageTitleEn.trim(),
      'subtitle_ar': 'PalWakf Unit Page Contract',
      'subtitle_en': 'PalWakf Unit Page Contract',
      'body_ar': 'عقد تشغيلي موضعي لصفحات الوحدات داخل PalWakf.',
      'body_en': jsonEncode(<String, dynamic>{
        'page_title_ar': draft.pageTitleAr.trim(),
        'page_title_en': draft.pageTitleEn.trim(),
        'visibility': draft.visibility.value,
        'display_order': draft.displayOrder,
        'allowed_sections': normalizedSections,
        'is_archived': draft.isArchived,
        'is_published': draft.isPublished,
        'updated_by_label': actorLabel,
        'updated_by_user_id': userId,
        'saved_at': nowIso,
      }),
      'is_published': draft.isPublished,
      'updated_at': nowIso,
    };

    final existingPage = await _client
        .from(_sitePagesReadSurface)
        .select('id')
        .eq('unit_id', draft.unitId)
        .eq('slug', kPwfUnitPagesContractSlug)
        .maybeSingle();

    final existingPageId = (existingPage?['id'] ?? '').toString().trim();
    if (existingPageId.isEmpty) {
      await _client.from(_sitePagesLegacyWriteTable).insert(payload);
    } else {
      await _client
          .from(_sitePagesLegacyWriteTable)
          .update(payload)
          .eq('id', existingPageId);
    }

    // Use the write table for conflict detection. The public compatibility
    // view can be runtime-scoped or omit inactive rows, which makes an admin
    // insert attempt collide with ux_homepage_sections_scope even though the
    // pre-read looked empty.
    final existingSectionsRows = await _client
        .from(_sectionsLegacyWriteTable)
        .select('id,section_name,settings,display_order')
        .eq('unit_id', draft.unitId)
        .inFilter(
          'section_name',
          kPwfUnitPageAllowedSectionOptions
              .map((e) => e.key)
              .toList(growable: false),
        );

    final existingByKey = <String, Map<String, dynamic>>{};
    for (final raw in (existingSectionsRows as List<dynamic>)) {
      final row = Map<String, dynamic>.from(raw as Map);
      final key = (row['section_name'] ?? '').toString().trim();
      if (key.isEmpty) continue;
      existingByKey[key] = row;
    }

    for (var i = 0; i < kPwfUnitPageAllowedSectionOptions.length; i++) {
      final option = kPwfUnitPageAllowedSectionOptions[i];
      final existing = existingByKey[option.key];
      final sectionPayload = <String, dynamic>{
        'section_name': option.key,
        'unit_id': draft.unitId,
        'settings': (existing?['settings'] is Map)
            ? Map<String, dynamic>.from(existing!['settings'] as Map)
            : <String, dynamic>{},
        'is_active': normalizedSections.contains(option.key),
        'display_order': _asInt(existing?['display_order'], i + 1),
        'updated_at': nowIso,
        'updated_by': userId,
      };
      final existingId = (existing?['id'] ?? '').toString().trim();
      if (existingId.isEmpty) {
        try {
          await _client.from(_sectionsLegacyWriteTable).insert(sectionPayload);
        } catch (e) {
          if (e is! PostgrestException || e.code != '23505') rethrow;
          final duplicateRows = await _client
              .from(_sectionsLegacyWriteTable)
              .select('id')
              .eq('unit_id', draft.unitId)
              .eq('section_name', option.key)
              .limit(1);
          final duplicateId = duplicateRows.isNotEmpty
              ? ((duplicateRows.first as Map)['id'] ?? '').toString()
              : '';
          if (duplicateId.isEmpty) rethrow;
          await _client
              .from(_sectionsLegacyWriteTable)
              .update(sectionPayload)
              .eq('id', duplicateId);
        }
      } else {
        await _client
            .from(_sectionsLegacyWriteTable)
            .update(sectionPayload)
            .eq('id', existingId);
      }
    }

    return draft.copyWith(
      allowedSections: normalizedSections,
      updatedAt: now.toLocal(),
      updatedByLabel: actorLabel,
    );
  }

  List<String> _normalizeAllowedSections(List<String> values) {
    final official = kPwfUnitPageAllowedSectionOptions
        .map((e) => e.key)
        .toList(growable: false);
    final seen = <String>{};
    final result = <String>[];
    for (final key in official) {
      if (values.contains(key) && !seen.contains(key)) {
        seen.add(key);
        result.add(key);
      }
    }
    return result;
  }

  Map<String, dynamic> _decodeMeta(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return const <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // ignore malformed legacy data
    }
    return const <String, dynamic>{};
  }

  DateTime? _latestSectionUpdatedAt(List<Map<String, dynamic>> rows) {
    DateTime? latest;
    for (final row in rows) {
      final current = _parseDateTime(row['updated_at']);
      latest = _maxDateTime(latest, current);
    }
    return latest;
  }

  DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toLocal();
  }

  DateTime? _maxDateTime(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  int _asInt(dynamic raw, int fallback) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? fallback;
  }
}

final pwfUnitPagesRepositoryProvider = Provider<PwfUnitPagesRepository>((ref) {
  return PwfUnitPagesRepository(Supabase.instance.client);
});

final pwfUnitPagesPersistedContractsProvider =
    FutureProvider<List<PwfUnitPageExecutionRow>>((ref) async {
      final units = await ref.watch(orgUnitsListProvider.future);
      final repo = ref.watch(pwfUnitPagesRepositoryProvider);
      return repo.fetchPersistedContracts(units: units);
    });
