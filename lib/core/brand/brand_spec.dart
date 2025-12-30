import 'package:flutter/material.dart';

class BrandSpec {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Brightness brightness;

  const BrandSpec({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.brightness = Brightness.light,
  });

  Color get onPrimary => brightness == Brightness.dark ? Colors.white : Colors.white;
  Color get onSecondary => brightness == Brightness.dark ? Colors.white : Colors.black;
}
