import 'package:flutter/foundation.dart';

@immutable
class AssistantContext {
  const AssistantContext({
    required this.displayName,
    required this.adminUserId,
    required this.systemKey,
    required this.systemLabel,
    required this.roleLabel,
    required this.permissions,
    required this.currentRoute,
    required this.channelKey,
    required this.surfaceKey,
    required this.scopeKey,
    required this.allowedSourceIds,
    this.unitId,
    this.unitSlug,
    this.waqfAssetId,
    this.nationalAssetCode,
    this.currentPageLabel,
    this.currentPageLabelEn,
    this.lastActionLabel,
    this.lastRoute,
    this.knowledgeScopeLabel,
    this.knowledgeScopeLabelEn,
  });

  final String displayName;
  final String adminUserId;
  final String systemKey;
  final String systemLabel;
  final String roleLabel;
  final List<String> permissions;
  final String currentRoute;
  final String channelKey;
  final String surfaceKey;
  final String scopeKey;
  final List<String> allowedSourceIds;
  final String? unitId;
  final String? unitSlug;
  final String? waqfAssetId;
  final String? nationalAssetCode;
  final String? currentPageLabel;
  final String? currentPageLabelEn;
  final String? lastActionLabel;
  final String? lastRoute;
  final String? knowledgeScopeLabel;
  final String? knowledgeScopeLabelEn;

  bool get hasUnitContext => (unitSlug ?? unitId ?? '').trim().isNotEmpty;

  bool get hasAssetContext =>
      (waqfAssetId ?? '').trim().isNotEmpty ||
      (nationalAssetCode ?? '').trim().isNotEmpty;

  AssistantContext copyWith({String? lastActionLabel, String? lastRoute}) {
    return AssistantContext(
      displayName: displayName,
      adminUserId: adminUserId,
      systemKey: systemKey,
      systemLabel: systemLabel,
      roleLabel: roleLabel,
      permissions: permissions,
      currentRoute: currentRoute,
      channelKey: channelKey,
      surfaceKey: surfaceKey,
      scopeKey: scopeKey,
      allowedSourceIds: allowedSourceIds,
      unitId: unitId,
      unitSlug: unitSlug,
      waqfAssetId: waqfAssetId,
      nationalAssetCode: nationalAssetCode,
      currentPageLabel: currentPageLabel,
      currentPageLabelEn: currentPageLabelEn,
      lastActionLabel: lastActionLabel ?? this.lastActionLabel,
      lastRoute: lastRoute ?? this.lastRoute,
      knowledgeScopeLabel: knowledgeScopeLabel,
      knowledgeScopeLabelEn: knowledgeScopeLabelEn,
    );
  }
}

@immutable
class AssistantContextSeed {
  const AssistantContextSeed({
    this.displayName,
    this.adminUserId,
    this.systemKey,
    this.systemLabel,
    this.roleLabel,
    this.permissions,
    this.currentRoute,
    this.unitId,
    this.unitSlug,
    this.waqfAssetId,
    this.nationalAssetCode,
    this.currentPageLabel,
    this.currentPageLabelEn,
    this.lastActionLabel,
    this.lastRoute,
    this.knowledgeScopeLabel,
    this.knowledgeScopeLabelEn,
  });

  final String? displayName;
  final String? adminUserId;
  final String? systemKey;
  final String? systemLabel;
  final String? roleLabel;
  final List<String>? permissions;
  final String? currentRoute;
  final String? unitId;
  final String? unitSlug;
  final String? waqfAssetId;
  final String? nationalAssetCode;
  final String? currentPageLabel;
  final String? currentPageLabelEn;
  final String? lastActionLabel;
  final String? lastRoute;
  final String? knowledgeScopeLabel;
  final String? knowledgeScopeLabelEn;
}
