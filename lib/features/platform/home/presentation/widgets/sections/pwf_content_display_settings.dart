import 'package:flutter/material.dart';

@immutable
class PwfContentDisplaySettings {
  const PwfContentDisplaySettings({
    required this.homeLimit,
    required this.showViewAll,
    this.extra = const <String, dynamic>{},
  });

  final int homeLimit;
  final bool showViewAll;
  final Map<String, dynamic> extra;

  factory PwfContentDisplaySettings.fromMap(
    Map<String, dynamic>? raw, {
    required int defaultHomeLimit,
    bool defaultShowViewAll = true,
  }) {
    final map = raw == null
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(raw);
    final homeLimit = _readInt(
      map,
      keys: const [
        'home_limit',
        'max_items',
        'maxItems',
        'show_count',
        'showCount',
      ],
      fallback: defaultHomeLimit,
      min: 1,
      max: 12,
    );
    final showViewAll = _readBool(
      map,
      keys: const ['show_view_all', 'showViewAll'],
      fallback: defaultShowViewAll,
    );
    return PwfContentDisplaySettings(
      homeLimit: homeLimit,
      showViewAll: showViewAll,
      extra: map,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    'home_limit': homeLimit,
    'show_view_all': showViewAll,
    ...extra,
  };

  static Map<String, dynamic>? pickSectionSettings(
    Iterable<dynamic> sections, {
    required List<String> aliases,
  }) {
    for (final alias in aliases) {
      for (final section in sections) {
        final name = ((section as dynamic).sectionName ?? '').toString().trim();
        if (name == alias) {
          final raw = (section as dynamic).settings;
          if (raw is Map<String, dynamic>)
            return Map<String, dynamic>.from(raw);
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return <String, dynamic>{};
        }
      }
    }
    return null;
  }

  static int _readInt(
    Map<String, dynamic> map, {
    required List<String> keys,
    required int fallback,
    required int min,
    required int max,
  }) {
    for (final key in keys) {
      final value = map[key];
      if (value is int) return value.clamp(min, max);
      if (value is num) return value.toInt().clamp(min, max);
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed.clamp(min, max);
      }
    }
    return fallback.clamp(min, max);
  }

  static bool _readBool(
    Map<String, dynamic> map, {
    required List<String> keys,
    required bool fallback,
  }) {
    for (final key in keys) {
      final value = map[key];
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
    }
    return fallback;
  }
}
