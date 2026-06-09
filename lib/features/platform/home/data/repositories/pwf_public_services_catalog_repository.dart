import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';
import 'package:waqf/features/platform/home/domain/pwf_platform_navigation_runtime_gate.dart';

import '../models/pwf_public_service_catalog_item.dart';

class PwfPublicServicesCatalogRepository {
  const PwfPublicServicesCatalogRepository(this._client);

  final SupabaseClient _client;

  /// Root cutover read contract:
  /// - default runtime reads from platform_navigation owner wrappers.
  /// - legacy public compatibility is fallback/rollback only.
  /// - no deletion/archive/runtime DDL/production approval is performed here.
  Future<List<PwfPublicServiceCatalogItem>> fetchActiveServices() async {
    if (PwfPlatformNavigationRuntimeGate.forceLegacyPublicServices) {
      return _fetchActiveServicesFromLegacyCompatSurface(
        reason: 'forced-by-emergency-dart-define',
      );
    }

    try {
      final ownerItems = await _fetchActiveServicesFromOwnerSurface();
      if (ownerItems.isNotEmpty) return ownerItems;
      _debugTraceRuntimeFallback(
        operation: 'services_catalog',
        fromSurface: PwfDatabaseOwnerSurfaces
            .vPlatformNavigationServicesCatalogFromOwnerV1,
        toSurface: PwfDatabaseOwnerSurfaces.vServicesCatalogCompatV1,
        reason: 'owner-empty-result',
      );
    } on PostgrestException catch (error) {
      _debugTraceRuntimeFallback(
        operation: 'services_catalog',
        fromSurface: PwfDatabaseOwnerSurfaces
            .vPlatformNavigationServicesCatalogFromOwnerV1,
        toSurface: PwfDatabaseOwnerSurfaces.vServicesCatalogCompatV1,
        reason: 'owner-postgrest-error:${error.code ?? error.message}',
      );
    } catch (error) {
      _debugTraceRuntimeFallback(
        operation: 'services_catalog',
        fromSurface: PwfDatabaseOwnerSurfaces
            .vPlatformNavigationServicesCatalogFromOwnerV1,
        toSurface: PwfDatabaseOwnerSurfaces.vServicesCatalogCompatV1,
        reason: 'owner-runtime-error:${error.runtimeType}',
      );
    }

    return _fetchActiveServicesFromLegacyCompatSurface(
      reason: PwfPlatformNavigationRuntimeGate.legacyCompatibilityDecision,
    );
  }

  Future<List<PwfPublicServiceCatalogItem>>
  _fetchActiveServicesFromOwnerSurface() async {
    const surface =
        PwfDatabaseOwnerSurfaces.vPlatformNavigationServicesCatalogFromOwnerV1;
    const projection = '*';

    _debugTraceRuntimeSource(
      marker: 'PWF_PUBLIC_SERVICES_ROOT_CUTOVER',
      operation: 'services_catalog_owner_default',
      surface: surface,
      ownerRead: true,
      projection: projection,
      filtering: 'client-side',
      ordering: 'client-side',
      decision: PwfPlatformNavigationRuntimeGate.runtimeReadSourceDecision,
    );

    final rows = await _client.from(surface).select(projection);
    return _parsePublicCatalogRows(rows);
  }

  Future<List<PwfPublicServiceCatalogItem>>
  _fetchActiveServicesFromLegacyCompatSurface({required String reason}) async {
    const surface = PwfDatabaseOwnerSurfaces.vServicesCatalogCompatV1;
    const projection = '*';

    _debugTraceRuntimeSource(
      marker: 'PWF_PUBLIC_SERVICES_LEGACY_FALLBACK_ONLY',
      operation: 'services_catalog_legacy_fallback',
      surface: surface,
      ownerRead: false,
      projection: projection,
      filtering: 'client-side',
      ordering: 'client-side',
      decision: reason,
    );

    final rows = await _client.from(surface).select(projection);
    return _parsePublicCatalogRows(rows);
  }

  /// Owner-read home services adapter.
  ///
  /// Root cutover reads owner home entries by default. If the owner surface is
  /// unavailable or empty, the caller keeps the existing footer/static fallback
  /// path; no public.home_services mutation or archive/delete occurs.
  Future<List<PwfPublicServiceCatalogItem>> fetchActiveHomeServices() async {
    if (PwfPlatformNavigationRuntimeGate.forceLegacyPublicServices) {
      _debugTraceRuntimeFallback(
        operation: 'home_services',
        fromSurface:
            PwfDatabaseOwnerSurfaces.vPlatformNavigationHomeServicesFromOwnerV1,
        toSurface: 'footer_settings.services_links',
        reason: 'forced-by-emergency-dart-define',
      );
      return const <PwfPublicServiceCatalogItem>[];
    }

    const surface =
        PwfDatabaseOwnerSurfaces.vPlatformNavigationHomeServicesFromOwnerV1;
    const projection = '*';

    try {
      _debugTraceRuntimeSource(
        marker: 'PWF_PUBLIC_SERVICES_ROOT_CUTOVER',
        operation: 'home_services_owner_default',
        surface: surface,
        ownerRead: true,
        projection: projection,
        filtering: 'client-side',
        ordering: 'client-side',
        decision: PwfPlatformNavigationRuntimeGate.runtimeReadSourceDecision,
      );

      final rows = await _client.from(surface).select(projection);
      final items = _parsePublicCatalogRows(rows);
      if (items.isNotEmpty) return items;
      _debugTraceRuntimeFallback(
        operation: 'home_services',
        fromSurface: surface,
        toSurface: 'footer_settings.services_links',
        reason: 'owner-empty-result',
      );
    } on PostgrestException catch (error) {
      _debugTraceRuntimeFallback(
        operation: 'home_services',
        fromSurface: surface,
        toSurface: 'footer_settings.services_links',
        reason: 'owner-postgrest-error:${error.code ?? error.message}',
      );
    } catch (error) {
      _debugTraceRuntimeFallback(
        operation: 'home_services',
        fromSurface: surface,
        toSurface: 'footer_settings.services_links',
        reason: 'owner-runtime-error:${error.runtimeType}',
      );
    }

    return const <PwfPublicServiceCatalogItem>[];
  }

  void _debugTraceRuntimeSource({
    required String marker,
    required String operation,
    required String surface,
    required bool ownerRead,
    required String projection,
    required String filtering,
    required String ordering,
    required String decision,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '$marker '
      'operation=$operation '
      'owner_read=$ownerRead '
      'surface=public.$surface '
      'projection=$projection '
      'filtering=$filtering '
      'ordering=$ordering '
      'decision=$decision',
    );
  }

  void _debugTraceRuntimeFallback({
    required String operation,
    required String fromSurface,
    required String toSurface,
    required String reason,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_PUBLIC_SERVICES_ROOT_CUTOVER_FALLBACK '
      'operation=$operation '
      'from=public.$fromSurface '
      'to=$toSurface '
      'reason=$reason',
    );
  }

  List<PwfPublicServiceCatalogItem> _parsePublicCatalogRows(
    List<dynamic> rows,
  ) {
    final items = <PwfPublicServiceCatalogItem>[];
    for (final row in rows) {
      if (row is! Map) continue;
      final item = PwfPublicServiceCatalogItem.fromJson(
        row.map<String, dynamic>(
          (key, dynamic value) => MapEntry(key.toString(), value),
        ),
      );
      if (!item.isPublicCatalogSafe) continue;
      items.add(item);
    }

    items.sort(_comparePublicCatalogItems);

    return List<PwfPublicServiceCatalogItem>.unmodifiable(items);
  }

  int _comparePublicCatalogItems(
    PwfPublicServiceCatalogItem left,
    PwfPublicServiceCatalogItem right,
  ) {
    final orderComparison = left.orderIndex.compareTo(right.orderIndex);
    if (orderComparison != 0) return orderComparison;
    return left.title.compareTo(right.title);
  }
}
