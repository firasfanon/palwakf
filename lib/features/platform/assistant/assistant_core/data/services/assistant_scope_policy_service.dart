import 'package:flutter/foundation.dart';

import '../models/assistant_context_contract.dart';
import '../models/assistant_source_registry_entry.dart';
import 'assistant_source_registry_service.dart';
import 'chat_route_context_service.dart';

@immutable
class AssistantScopePolicy {
  const AssistantScopePolicy({
    required this.channel,
    required this.surface,
    required this.scopeKey,
    required this.persistenceMode,
    required this.labelAr,
    required this.labelEn,
    required this.directAnswerAllowed,
    required this.allowDocsReferences,
    required this.allowInternalGuidance,
    required this.allowedSourceIds,
  });

  final AssistantChannel channel;
  final AssistantSurface surface;
  final AssistantScopeKey scopeKey;
  final AssistantPersistenceMode persistenceMode;
  final String labelAr;
  final String labelEn;
  final bool directAnswerAllowed;
  final bool allowDocsReferences;
  final bool allowInternalGuidance;
  final List<String> allowedSourceIds;
}

class AssistantScopePolicyService {
  const AssistantScopePolicyService({
    AssistantSourceRegistryService registry =
        const AssistantSourceRegistryService(),
  }) : _registry = registry;

  final AssistantSourceRegistryService _registry;

  AssistantScopePolicy resolvePublicPolicy(ChatRouteContext routeContext) {
    final surface = _publicSurface(routeContext);
    final scopeKey = surface == AssistantSurface.platformHome
        ? AssistantScopeKey.publicHome
        : AssistantScopeKey.publicUnit;
    final labelAr = scopeKey == AssistantScopeKey.publicHome
        ? 'عام / الوزارة'
        : 'عام / الوحدة';
    final labelEn = scopeKey == AssistantScopeKey.publicHome
        ? 'Public / ministry'
        : 'Public / unit';
    final baseContract = AssistantContextContract(
      channel: AssistantChannel.publicChatbot,
      surface: surface,
      scopeKey: scopeKey,
      persistenceMode: AssistantPersistenceMode.ephemeral,
      systemKey: routeContext.systemKey,
      systemLabelAr: routeContext.pageLabelAr,
      systemLabelEn: routeContext.pageLabelEn,
      currentRoute: routeContext.route,
      pageLabelAr: routeContext.pageLabelAr,
      pageLabelEn: routeContext.pageLabelEn,
      unitSlug: routeContext.unitSlug,
      roleLabel: 'public',
      permissions: const <String>[],
      allowedSourceIds: const <String>[],
      knowledgeScopeLabelAr: labelAr,
      knowledgeScopeLabelEn: labelEn,
      unitId: routeContext.unitSlug,
      publicSessionId: 'guest-session',
      waqfAssetId: routeContext.waqfAssetId,
      nationalAssetCode: routeContext.nationalAssetCode,
    );
    final sources = _registry
        .resolveForContract(baseContract)
        .where((e) => e.enabledByDefault)
        .toList(growable: false);
    return AssistantScopePolicy(
      channel: baseContract.channel,
      surface: baseContract.surface,
      scopeKey: baseContract.scopeKey,
      persistenceMode: baseContract.persistenceMode,
      labelAr: labelAr,
      labelEn: labelEn,
      directAnswerAllowed: true,
      allowDocsReferences: false,
      allowInternalGuidance: false,
      allowedSourceIds: sources.map((e) => e.id).toList(growable: false),
    );
  }

  AssistantScopePolicy resolveInternalPolicy({
    required ChatRouteContext routeContext,
    required String roleLabel,
    required List<String> permissions,
  }) {
    final surface = _internalSurface(routeContext);
    final baseScopeKey = surface == AssistantSurface.adminInternal
        ? AssistantScopeKey.internalAdmin
        : AssistantScopeKey.internalSystem;
    final normalizedPermissions = permissions
        .map((e) => e.toLowerCase())
        .toSet();
    final isSuperuser = roleLabel.toLowerCase() == 'superuser';
    final canManageUsers =
        isSuperuser || normalizedPermissions.contains('manageusers');
    final canManageSite =
        isSuperuser || normalizedPermissions.contains('managesite');
    final canManageHome =
        isSuperuser || normalizedPermissions.contains('managehome');
    final canManageSystems =
        isSuperuser || normalizedPermissions.contains('managesystems');
    final canViewReports =
        isSuperuser || normalizedPermissions.contains('viewreports');
    final canCrud =
        isSuperuser ||
        normalizedPermissions.any(
          (p) => p == 'create' || p == 'update' || p == 'delete',
        );
    final isPrivileged =
        isSuperuser ||
        canManageUsers ||
        canManageSite ||
        canManageHome ||
        canManageSystems ||
        canViewReports ||
        canCrud;
    final effectiveScopeKey = isPrivileged
        ? baseScopeKey
        : AssistantScopeKey.restricted;
    final labelAr = effectiveScopeKey == AssistantScopeKey.restricted
        ? 'داخلي / إرشادي مقيّد'
        : (baseScopeKey == AssistantScopeKey.internalAdmin
              ? 'داخلي / إداري محكوم'
              : 'داخلي / نظام تخصصي محكوم');
    final labelEn = effectiveScopeKey == AssistantScopeKey.restricted
        ? 'Internal / restricted guidance'
        : (baseScopeKey == AssistantScopeKey.internalAdmin
              ? 'Internal / governed admin'
              : 'Internal / governed system');
    final baseContract = AssistantContextContract(
      channel: AssistantChannel.internalAssistant,
      surface: surface,
      scopeKey: effectiveScopeKey,
      persistenceMode: AssistantPersistenceMode.persisted,
      systemKey: routeContext.systemKey,
      systemLabelAr: _systemLabelAr(
        routeContext.systemKey,
        fallback: routeContext.pageLabelAr,
      ),
      systemLabelEn: _systemLabelEn(
        routeContext.systemKey,
        fallback: routeContext.pageLabelEn,
      ),
      currentRoute: routeContext.route,
      pageLabelAr: routeContext.pageLabelAr,
      pageLabelEn: routeContext.pageLabelEn,
      unitSlug: routeContext.unitSlug,
      roleLabel: roleLabel,
      permissions: List<String>.unmodifiable(permissions),
      allowedSourceIds: const <String>[],
      knowledgeScopeLabelAr: labelAr,
      knowledgeScopeLabelEn: labelEn,
      unitId: routeContext.unitSlug,
      adminUserId: 'internal-user',
      waqfAssetId: routeContext.waqfAssetId,
      nationalAssetCode: routeContext.nationalAssetCode,
    );
    final supportedEntries = _registry
        .resolveForContract(baseContract)
        .where((e) => e.enabledByDefault)
        .where((entry) {
          if (entry.id == 'route-context') return true;
          if (entry.id == 'admin-guides')
            return surface == AssistantSurface.adminInternal;
          if (entry.id == 'docs-admin' || entry.id == 'unit-pages-governance') {
            return canManageHome ||
                canManageSite ||
                canCrud ||
                canViewReports ||
                isSuperuser;
          }
          if (entry.id == 'governance-rbac')
            return canManageUsers || isSuperuser;
          if (entry.id == 'docs-systems' || entry.id == 'system-pages') {
            return surface == AssistantSurface.systemPages ||
                canManageSystems ||
                isSuperuser;
          }
          if (entry.id == 'docs-visual-identity')
            return canManageSite || canManageHome || isSuperuser;
          return isPrivileged;
        })
        .toList(growable: false);
    return AssistantScopePolicy(
      channel: baseContract.channel,
      surface: baseContract.surface,
      scopeKey: baseContract.scopeKey,
      persistenceMode: baseContract.persistenceMode,
      labelAr: labelAr,
      labelEn: labelEn,
      directAnswerAllowed: isPrivileged,
      allowDocsReferences: supportedEntries.any(
        (e) =>
            e.kind == AssistantSourceKind.docsAdmin ||
            e.kind == AssistantSourceKind.docsSystems ||
            e.kind == AssistantSourceKind.docsVisualIdentity,
      ),
      allowInternalGuidance: true,
      allowedSourceIds: supportedEntries
          .map((e) => e.id)
          .toList(growable: false),
    );
  }

  AssistantContextContract buildPublicContract({
    required ChatRouteContext routeContext,
    required String unitSlug,
    String? publicSessionId,
  }) {
    final policy = resolvePublicPolicy(routeContext);
    return AssistantContextContract(
      channel: policy.channel,
      surface: policy.surface,
      scopeKey: policy.scopeKey,
      persistenceMode: policy.persistenceMode,
      systemKey: routeContext.systemKey,
      systemLabelAr: routeContext.pageLabelAr,
      systemLabelEn: routeContext.pageLabelEn,
      currentRoute: routeContext.route,
      pageLabelAr: routeContext.pageLabelAr,
      pageLabelEn: routeContext.pageLabelEn,
      unitSlug: unitSlug,
      unitId: unitSlug,
      publicSessionId: publicSessionId,
      roleLabel: 'public',
      permissions: const <String>[],
      waqfAssetId: routeContext.waqfAssetId,
      nationalAssetCode: routeContext.nationalAssetCode,
      allowedSourceIds: policy.allowedSourceIds,
      knowledgeScopeLabelAr: policy.labelAr,
      knowledgeScopeLabelEn: policy.labelEn,
    );
  }

  AssistantContextContract buildInternalContract({
    required ChatRouteContext routeContext,
    required String displayName,
    required String roleLabel,
    required List<String> permissions,
    String? adminUserId,
    String? unitId,
    String? unitSlug,
    String? waqfAssetId,
    String? nationalAssetCode,
  }) {
    final policy = resolveInternalPolicy(
      routeContext: routeContext,
      roleLabel: roleLabel,
      permissions: permissions,
    );
    return AssistantContextContract(
      channel: policy.channel,
      surface: policy.surface,
      scopeKey: policy.scopeKey,
      persistenceMode: policy.persistenceMode,
      systemKey: routeContext.systemKey,
      systemLabelAr: _systemLabelAr(
        routeContext.systemKey,
        fallback: routeContext.pageLabelAr,
      ),
      systemLabelEn: _systemLabelEn(
        routeContext.systemKey,
        fallback: routeContext.pageLabelEn,
      ),
      currentRoute: routeContext.route,
      pageLabelAr: routeContext.pageLabelAr,
      pageLabelEn: routeContext.pageLabelEn,
      unitSlug: unitSlug ?? routeContext.unitSlug,
      unitId: unitId ?? unitSlug ?? routeContext.unitSlug,
      adminUserId: adminUserId,
      roleLabel: roleLabel,
      permissions: List<String>.unmodifiable(permissions),
      waqfAssetId: waqfAssetId ?? routeContext.waqfAssetId,
      nationalAssetCode: nationalAssetCode ?? routeContext.nationalAssetCode,
      allowedSourceIds: policy.allowedSourceIds,
      knowledgeScopeLabelAr: policy.labelAr,
      knowledgeScopeLabelEn: policy.labelEn,
    );
  }

  AssistantSurface _publicSurface(ChatRouteContext routeContext) {
    if (routeContext.unitSlug == 'home') return AssistantSurface.platformHome;
    return AssistantSurface.unitPages;
  }

  AssistantSurface _internalSurface(ChatRouteContext routeContext) {
    if (routeContext.route.startsWith('/admin'))
      return AssistantSurface.adminInternal;
    return AssistantSurface.systemPages;
  }

  String _systemLabelAr(String systemKey, {required String fallback}) {
    switch (systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        return 'مستكشف الوقف';
      case 'waqf_cases_system':
        return 'نظام القضايا الوقفية';
      case 'billing_system':
        return 'نظام الفوترة';
      case 'tasks_system':
        return 'نظام المهام';
      case 'public_site':
        return 'الموقع العام';
      case 'awqaf_system':
        return 'نظام الأوقاف';
      default:
        return fallback;
    }
  }

  String _systemLabelEn(String systemKey, {required String fallback}) {
    switch (systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        return 'Waqf explorer';
      case 'waqf_cases_system':
        return 'Waqf cases';
      case 'billing_system':
        return 'Billing system';
      case 'tasks_system':
        return 'Tasks system';
      case 'public_site':
        return 'Public site';
      case 'awqaf_system':
        return 'Awqaf system';
      default:
        return fallback;
    }
  }
}
