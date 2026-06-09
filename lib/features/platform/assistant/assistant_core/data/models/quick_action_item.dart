import 'package:flutter/material.dart';

@immutable
class QuickActionItem {
  const QuickActionItem({
    required this.id,
    required this.label,
    this.icon = Icons.flash_on_rounded,
    this.message,
    this.route,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? message;
  final String? route;
}
