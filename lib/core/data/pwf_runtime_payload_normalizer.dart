import 'dart:developer' as dev;

abstract final class PwfRuntimePayloadNormalizer {
  static List<Map<String, dynamic>> rows(
    dynamic raw, {
    String source = '',
  }) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }
    dev.log('PwfRuntimePayloadNormalizer.rows: unexpected type '
        '${raw.runtimeType} from $source');
    return const [];
  }

  static Map<String, dynamic>? firstRow(
    dynamic raw, {
    String source = '',
  }) {
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List && raw.isNotEmpty && raw.first is Map) {
      return Map<String, dynamic>.from(raw.first as Map);
    }
    dev.log('PwfRuntimePayloadNormalizer.firstRow: unexpected type '
        '${raw.runtimeType} from $source');
    return null;
  }
}
