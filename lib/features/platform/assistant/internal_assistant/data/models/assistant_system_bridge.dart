import 'package:flutter/foundation.dart';

@immutable
class AssistantSystemBridge {
  const AssistantSystemBridge({
    required this.id,
    required this.systemKey,
    required this.titleAr,
    required this.titleEn,
    required this.summaryAr,
    required this.summaryEn,
    required this.statusLabelAr,
    required this.statusLabelEn,
    required this.nextStepsAr,
    required this.nextStepsEn,
    required this.docPaths,
    required this.routeHints,
  });

  final String id;
  final String systemKey;
  final String titleAr;
  final String titleEn;
  final String summaryAr;
  final String summaryEn;
  final String statusLabelAr;
  final String statusLabelEn;
  final List<String> nextStepsAr;
  final List<String> nextStepsEn;
  final List<String> docPaths;
  final List<String> routeHints;
}
