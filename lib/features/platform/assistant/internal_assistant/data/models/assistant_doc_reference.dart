import 'package:flutter/foundation.dart';

@immutable
class AssistantDocReference {
  const AssistantDocReference({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.path,
    required this.summaryAr,
    required this.summaryEn,
    required this.systemKeys,
    this.isGovernance = false,
    this.isDocsAdmin = false,
    this.isDocsSystems = false,
    this.isDocsVisualIdentity = false,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String path;
  final String summaryAr;
  final String summaryEn;
  final Set<String> systemKeys;
  final bool isGovernance;
  final bool isDocsAdmin;
  final bool isDocsSystems;
  final bool isDocsVisualIdentity;
}
