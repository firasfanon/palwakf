import 'package:flutter/foundation.dart';

import 'assistant_context_contract.dart';

enum AssistantSourceKind {
  routeContext,
  sitePage,
  homepageSection,
  sharedContent,
  quickLinks,
  docsAdmin,
  docsSystems,
  docsVisualIdentity,
  internalGuide,
  systemPage,
  governance,
  documentIntelligence,
  waqfAssets,
  ragIndex,
  toolRegistry,
  evaluation,
}

@immutable
class AssistantSourceRegistryEntry {
  const AssistantSourceRegistryEntry({
    required this.id,
    required this.kind,
    required this.labelAr,
    required this.labelEn,
    required this.ownerSystemKey,
    required this.allowedChannels,
    required this.allowedSurfaces,
    required this.allowedScopeKeys,
    required this.isTrusted,
    required this.directAnswerAllowed,
    this.enabledByDefault = true,
  });

  final String id;
  final AssistantSourceKind kind;
  final String labelAr;
  final String labelEn;
  final String ownerSystemKey;
  final Set<AssistantChannel> allowedChannels;
  final Set<AssistantSurface> allowedSurfaces;
  final Set<AssistantScopeKey> allowedScopeKeys;
  final bool isTrusted;
  final bool directAnswerAllowed;
  final bool enabledByDefault;

  bool supportsContract(AssistantContextContract contract) {
    return allowedChannels.contains(contract.channel) &&
        allowedSurfaces.contains(contract.surface) &&
        allowedScopeKeys.contains(contract.scopeKey);
  }
}
