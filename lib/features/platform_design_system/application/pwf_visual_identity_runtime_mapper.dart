import 'package:flutter/material.dart';

class PwfVisualIdentityRuntimeMapper {
  const PwfVisualIdentityRuntimeMapper();

  ThemeData applyOverrides(ThemeData base, Map<String, Object?> overrides) {
    final primary = _color(overrides['primary']);
    final secondary = _color(overrides['gold']);
    final error = _color(overrides['royalRed']);

    if (primary == null && secondary == null && error == null) return base;

    final current = base.colorScheme;
    return base.copyWith(
      colorScheme: current.copyWith(
        primary: primary ?? current.primary,
        secondary: secondary ?? current.secondary,
        error: error ?? current.error,
      ),
    );
  }

  Color? _color(Object? value) {
    if (value is! String) return null;
    final normalized = value.replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    return Color(normalized.length == 6 ? 0xFF000000 | parsed : parsed);
  }
}
