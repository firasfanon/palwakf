
class PwfPayloadContractResult {
  const PwfPayloadContractResult({
    required this.payload,
    this.strippedFields = const <String>[],
    this.defaultedFields = const <String>[],
    this.normalizedFields = const <String>[],
  });

  final Map<String, dynamic> payload;
  final List<String> strippedFields;
  final List<String> defaultedFields;
  final List<String> normalizedFields;

  bool get changed =>
      strippedFields.isNotEmpty ||
      defaultedFields.isNotEmpty ||
      normalizedFields.isNotEmpty;
}

class PwfPayloadContract {
  const PwfPayloadContract({
    required this.name,
    required this.allowedFields,
    this.requiredFields = const <String>{},
    this.stripFields = const <String>{},
    this.defaults = const <String, dynamic>{},
    this.normalizers = const <String, dynamic Function(dynamic)>{},
  });

  final String name;
  final Set<String> allowedFields;
  final Set<String> requiredFields;
  final Set<String> stripFields;
  final Map<String, dynamic> defaults;
  final Map<String, dynamic Function(dynamic)> normalizers;

  PwfPayloadContractResult sanitize(Map<String, dynamic> input) {
    final payload = <String, dynamic>{};
    final stripped = <String>[];
    final defaulted = <String>[];
    final normalized = <String>[];

    for (final entry in input.entries) {
      final key = entry.key;
      if (stripFields.contains(key) || !allowedFields.contains(key)) {
        stripped.add(key);
        continue;
      }

      final normalizer = normalizers[key];
      if (normalizer == null) {
        payload[key] = entry.value;
      } else {
        final next = normalizer(entry.value);
        payload[key] = next;
        if (next != entry.value) {
          normalized.add(key);
        }
      }
    }

    for (final entry in defaults.entries) {
      if (_isBlank(payload[entry.key])) {
        payload[entry.key] = entry.value;
        defaulted.add(entry.key);
      }
    }

    for (final field in requiredFields) {
      if (_isBlank(payload[field])) {
        throw PwfPayloadContractException(
          contractName: name,
          field: field,
          message: 'Required field "$field" is missing for payload contract "$name".',
        );
      }
    }

    return PwfPayloadContractResult(
      payload: payload,
      strippedFields: List.unmodifiable(stripped),
      defaultedFields: List.unmodifiable(defaulted),
      normalizedFields: List.unmodifiable(normalized),
    );
  }

  static bool _isBlank(dynamic value) {
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    return false;
  }
}

class PwfPayloadContractException implements Exception {
  const PwfPayloadContractException({
    required this.contractName,
    required this.field,
    required this.message,
  });

  final String contractName;
  final String field;
  final String message;

  @override
  String toString() => 'PwfPayloadContractException($contractName.$field): $message';
}
