import 'package:flutter/foundation.dart';

@immutable
class AssistantCapabilitySnapshot {
  const AssistantCapabilitySnapshot({
    required this.accessModeAr,
    required this.accessModeEn,
    required this.roleTierAr,
    required this.roleTierEn,
    required this.capabilityLabelsAr,
    required this.capabilityLabelsEn,
    required this.canUseDocsAdmin,
    required this.canUseDocsSystems,
    required this.canUseVisualIdentityDocs,
    required this.canUseRbacGuidance,
  });

  final String accessModeAr;
  final String accessModeEn;
  final String roleTierAr;
  final String roleTierEn;
  final List<String> capabilityLabelsAr;
  final List<String> capabilityLabelsEn;
  final bool canUseDocsAdmin;
  final bool canUseDocsSystems;
  final bool canUseVisualIdentityDocs;
  final bool canUseRbacGuidance;
}
