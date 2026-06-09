import 'package:flutter/foundation.dart';

import '../../../../../data/services/supabase_service.dart';
import '../models/pwf_dynamic_system_models.dart';

class PwfDynamicSystemRegistryRepository {
  PwfDynamicSystemRegistryRepository(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<List<PwfDynamicSystemModule>> visibleForCurrentUser() async {
    try {
      final response = await _supabaseService.client.rpc(
        'pwf_platform_visible_systems_for_user_v1',
      );
      return _parseSystemList(response);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('visibleForCurrentUser dynamic systems failed: $error');
        debugPrint('$stackTrace');
      }
      return const <PwfDynamicSystemModule>[];
    }
  }

  Future<List<PwfDynamicSystemModule>> adminCatalog() async {
    try {
      final response = await _supabaseService.client.rpc(
        'pwf_platform_system_registry_list_v1',
      );
      return _parseSystemList(response);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('adminCatalog dynamic systems failed: $error');
        debugPrint('$stackTrace');
      }
      return const <PwfDynamicSystemModule>[];
    }
  }

  Future<List<PwfDynamicSystemSection>> sectionsForSystem(
    String systemKey,
  ) async {
    try {
      final response = await _supabaseService.client.rpc(
        'pwf_platform_system_sections_list_v1',
        params: {'p_system_key': systemKey},
      );
      if (response is! List) return const <PwfDynamicSystemSection>[];
      return response
          .whereType<Map>()
          .map(
            (row) =>
                PwfDynamicSystemSection.fromMap(Map<String, dynamic>.from(row)),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('sectionsForSystem failed: $error');
        debugPrint('$stackTrace');
      }
      return const <PwfDynamicSystemSection>[];
    }
  }

  Future<void> upsertSystem(PwfDynamicSystemModule system) async {
    final response = await _supabaseService.client.rpc(
      'pwf_platform_system_upsert_v1',
      params: system.toUpsertParams(),
    );
    _assertSuccess(response);
  }

  Future<void> upsertSection(PwfDynamicSystemSection section) async {
    final response = await _supabaseService.client.rpc(
      'pwf_platform_system_section_upsert_v1',
      params: section.toUpsertParams(),
    );
    _assertSuccess(response);
  }

  Future<void> seedDefaultCatalogIfEmpty() async {
    try {
      await _supabaseService.client.rpc(
        'pwf_platform_system_registry_seed_defaults_v1',
      );
    } catch (error) {
      if (kDebugMode) debugPrint('seedDefaultCatalogIfEmpty skipped: $error');
    }
  }

  List<PwfDynamicSystemModule> _parseSystemList(dynamic response) {
    if (response is! List) return const <PwfDynamicSystemModule>[];
    return response
        .whereType<Map>()
        .map(
          (row) =>
              PwfDynamicSystemModule.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false)
      ..sort((a, b) {
        final order = a.displayOrder.compareTo(b.displayOrder);
        if (order != 0) return order;
        return a.nameAr.compareTo(b.nameAr);
      });
  }

  void _assertSuccess(dynamic response) {
    if (response is Map && response['success'] == false) {
      throw StateError(
        (response['message_ar'] ??
                response['message'] ??
                'تعذر حفظ السجل الديناميكي.')
            .toString(),
      );
    }
    if (response is List &&
        response.isNotEmpty &&
        response.first is Map &&
        response.first['success'] == false) {
      throw StateError(
        (response.first['message_ar'] ??
                response.first['message'] ??
                'تعذر حفظ السجل الديناميكي.')
            .toString(),
      );
    }
  }
}
