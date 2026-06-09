import '../../../assistant_core/data/models/assistant_source_registry_entry.dart';
import '../../../assistant_core/data/services/assistant_scope_policy_service.dart';
import '../../../assistant_core/data/services/assistant_source_registry_service.dart';
import '../../../assistant_core/data/services/chat_route_context_service.dart';
import '../models/assistant_knowledge_source.dart';

class AssistantKnowledgeGovernanceService {
  const AssistantKnowledgeGovernanceService({
    AssistantSourceRegistryService registry =
        const AssistantSourceRegistryService(),
    AssistantScopePolicyService policyService =
        const AssistantScopePolicyService(),
  }) : _registry = registry,
       _policyService = policyService;

  final AssistantSourceRegistryService _registry;
  final AssistantScopePolicyService _policyService;

  List<AssistantKnowledgeSource> publicSources({
    ChatRouteContext? routeContext,
  }) {
    final effectiveRoute =
        routeContext ??
        ChatRouteContextService.resolve('/home', fallbackUnitSlug: 'home');
    final policy = _policyService.resolvePublicPolicy(effectiveRoute);
    return _registry
        .resolveByIds(policy.allowedSourceIds)
        .map(_toSource)
        .toList(growable: false);
  }

  List<AssistantKnowledgeSource> internalSources({
    ChatRouteContext? routeContext,
    String roleLabel = 'viewer',
    List<String> permissions = const <String>[],
  }) {
    final effectiveRoute =
        routeContext ??
        ChatRouteContextService.resolve(
          '/admin/dashboard',
          fallbackUnitSlug: 'home',
        );
    final policy = _policyService.resolveInternalPolicy(
      routeContext: effectiveRoute,
      roleLabel: roleLabel,
      permissions: permissions,
    );
    return _registry
        .resolveByIds(policy.allowedSourceIds)
        .map(_toSource)
        .toList(growable: false);
  }

  AssistantKnowledgeScope scopeForMode({required bool isInternal}) {
    return isInternal
        ? AssistantKnowledgeScope.internal
        : AssistantKnowledgeScope.public;
  }

  String scopeLabelAr(AssistantKnowledgeScope scope) {
    switch (scope) {
      case AssistantKnowledgeScope.public:
        return 'عام';
      case AssistantKnowledgeScope.internal:
        return 'داخلي';
      case AssistantKnowledgeScope.restricted:
        return 'غير مسموح';
      case AssistantKnowledgeScope.uncertain:
        return 'غير مؤكّد';
    }
  }

  String scopeLabelArForRoute({
    required bool isInternal,
    required ChatRouteContext routeContext,
    String roleLabel = 'viewer',
    List<String> permissions = const <String>[],
  }) {
    if (!isInternal) {
      return _policyService.resolvePublicPolicy(routeContext).labelAr;
    }
    return _policyService
        .resolveInternalPolicy(
          routeContext: routeContext,
          roleLabel: roleLabel,
          permissions: permissions,
        )
        .labelAr;
  }

  AssistantKnowledgeSource _toSource(AssistantSourceRegistryEntry entry) {
    return AssistantKnowledgeSource(
      id: entry.id,
      labelAr: entry.labelAr,
      labelEn: entry.labelEn,
      owner: entry.ownerSystemKey,
      scope:
          entry.allowedChannels.length == 1 &&
              entry.allowedChannels.first.name == 'publicChatbot'
          ? AssistantKnowledgeScope.public
          : AssistantKnowledgeScope.internal,
      isTrusted: entry.isTrusted,
      directAnswerAllowed: entry.directAnswerAllowed,
    );
  }
}
