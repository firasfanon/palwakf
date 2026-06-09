import 'package:flutter/foundation.dart';

enum AssistantChannel { publicChatbot, internalAssistant }

enum AssistantSurface { platformHome, unitPages, systemPages, adminInternal }

enum AssistantScopeKey {
  publicHome,
  publicUnit,
  internalAdmin,
  internalSystem,
  restricted,
}

enum AssistantPersistenceMode { ephemeral, persisted }

@immutable
class AssistantContextContract {
  const AssistantContextContract({
    required this.channel,
    required this.surface,
    required this.scopeKey,
    required this.persistenceMode,
    required this.systemKey,
    required this.systemLabelAr,
    required this.systemLabelEn,
    required this.currentRoute,
    required this.pageLabelAr,
    required this.pageLabelEn,
    required this.unitSlug,
    required this.roleLabel,
    required this.permissions,
    required this.allowedSourceIds,
    required this.knowledgeScopeLabelAr,
    required this.knowledgeScopeLabelEn,
    this.unitId,
    this.adminUserId,
    this.publicSessionId,
    this.waqfAssetId,
    this.nationalAssetCode,
  });

  final AssistantChannel channel;
  final AssistantSurface surface;
  final AssistantScopeKey scopeKey;
  final AssistantPersistenceMode persistenceMode;
  final String systemKey;
  final String systemLabelAr;
  final String systemLabelEn;
  final String currentRoute;
  final String pageLabelAr;
  final String pageLabelEn;
  final String unitSlug;
  final String roleLabel;
  final List<String> permissions;
  final List<String> allowedSourceIds;
  final String knowledgeScopeLabelAr;
  final String knowledgeScopeLabelEn;
  final String? unitId;
  final String? adminUserId;
  final String? publicSessionId;
  final String? waqfAssetId;
  final String? nationalAssetCode;

  bool get isInternal => channel == AssistantChannel.internalAssistant;
  bool get hasUnitContext =>
      (unitSlug.trim().isNotEmpty) || ((unitId ?? '').trim().isNotEmpty);
  bool get hasAssetContext =>
      (waqfAssetId ?? '').trim().isNotEmpty ||
      (nationalAssetCode ?? '').trim().isNotEmpty;

  String get channelKey => channel.name;
  String get surfaceKey => surface.name;
  String get scopeKeyName => scopeKey.name;

  AssistantContextContract copyWith({
    List<String>? allowedSourceIds,
    String? knowledgeScopeLabelAr,
    String? knowledgeScopeLabelEn,
  }) {
    return AssistantContextContract(
      channel: channel,
      surface: surface,
      scopeKey: scopeKey,
      persistenceMode: persistenceMode,
      systemKey: systemKey,
      systemLabelAr: systemLabelAr,
      systemLabelEn: systemLabelEn,
      currentRoute: currentRoute,
      pageLabelAr: pageLabelAr,
      pageLabelEn: pageLabelEn,
      unitSlug: unitSlug,
      roleLabel: roleLabel,
      permissions: permissions,
      allowedSourceIds: allowedSourceIds ?? this.allowedSourceIds,
      knowledgeScopeLabelAr:
          knowledgeScopeLabelAr ?? this.knowledgeScopeLabelAr,
      knowledgeScopeLabelEn:
          knowledgeScopeLabelEn ?? this.knowledgeScopeLabelEn,
      unitId: unitId,
      adminUserId: adminUserId,
      publicSessionId: publicSessionId,
      waqfAssetId: waqfAssetId,
      nationalAssetCode: nationalAssetCode,
    );
  }
}
