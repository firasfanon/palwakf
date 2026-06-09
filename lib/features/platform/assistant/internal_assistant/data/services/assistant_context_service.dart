import '../../../assistant_core/data/services/assistant_scope_policy_service.dart';
import '../../../assistant_core/data/services/chat_route_context_service.dart';
import '../models/assistant_context.dart';

class AssistantContextService {
  const AssistantContextService({
    AssistantScopePolicyService policyService =
        const AssistantScopePolicyService(),
  }) : _policyService = policyService;

  final AssistantScopePolicyService _policyService;

  AssistantContext resolve({AssistantContextSeed? seed}) {
    final route = seed?.currentRoute ?? '/admin/dashboard';
    final routeContext = ChatRouteContextService.resolve(
      route,
      fallbackUnitSlug: seed?.unitSlug ?? seed?.unitId ?? 'home',
    );
    final roleLabel = seed?.roleLabel ?? 'viewer';
    final permissions = List<String>.unmodifiable(
      seed?.permissions ?? const <String>[],
    );
    final contract = _policyService.buildInternalContract(
      routeContext: routeContext,
      displayName: seed?.displayName ?? 'PalWakf User',
      adminUserId: seed?.adminUserId ?? 'local-admin-user',
      roleLabel: roleLabel,
      permissions: permissions,
      unitId: seed?.unitId ?? seed?.unitSlug,
      unitSlug: seed?.unitSlug ?? seed?.unitId ?? routeContext.unitSlug,
      waqfAssetId: seed?.waqfAssetId,
      nationalAssetCode: seed?.nationalAssetCode,
    );

    return AssistantContext(
      displayName: seed?.displayName ?? 'PalWakf User',
      adminUserId: seed?.adminUserId ?? 'local-admin-user',
      systemKey: contract.systemKey,
      systemLabel: seed?.systemLabel ?? contract.systemLabelAr,
      roleLabel: roleLabel,
      permissions: permissions,
      currentRoute: route,
      channelKey: contract.channelKey,
      surfaceKey: contract.surfaceKey,
      scopeKey: contract.scopeKeyName,
      allowedSourceIds: contract.allowedSourceIds,
      unitId: seed?.unitId ?? contract.unitId,
      unitSlug: seed?.unitSlug ?? contract.unitSlug,
      waqfAssetId: seed?.waqfAssetId ?? contract.waqfAssetId,
      nationalAssetCode: seed?.nationalAssetCode ?? contract.nationalAssetCode,
      currentPageLabel: seed?.currentPageLabel ?? contract.pageLabelAr,
      currentPageLabelEn: seed?.currentPageLabelEn ?? contract.pageLabelEn,
      lastActionLabel: seed?.lastActionLabel,
      lastRoute: seed?.lastRoute,
      knowledgeScopeLabel:
          seed?.knowledgeScopeLabel ?? contract.knowledgeScopeLabelAr,
      knowledgeScopeLabelEn:
          seed?.knowledgeScopeLabelEn ?? contract.knowledgeScopeLabelEn,
    );
  }
}
