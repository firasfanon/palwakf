import 'package:flutter/material.dart';

enum AssistantActionType {
  openRoute,
  resumeLastWork,
  searchWaqfAsset,
  openSystemModule,
  openPendingItems,
  openRelatedCases,
  openInvoices,
  openTasks,
}

class AssistantAction {
  const AssistantAction({
    required this.id,
    required this.type,
    required this.labelAr,
    required this.labelEn,
    required this.icon,
    this.route,
    this.messageAr,
    this.messageEn,
  });

  final String id;
  final AssistantActionType type;
  final String labelAr;
  final String labelEn;
  final IconData icon;
  final String? route;
  final String? messageAr;
  final String? messageEn;
}
