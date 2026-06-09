import 'package:flutter/material.dart';

@immutable
class FeatureCardItem {
  const FeatureCardItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.route,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
  final String? route;
}
