class PwfCanonicalUnitIdentity {
  final String canonicalOrgUnitId;
  final String internalSlug;
  final String unitNameAr;
  final String runtimeOrgUnitId;
  final String sourceOrgUnitId;

  const PwfCanonicalUnitIdentity({
    required this.canonicalOrgUnitId,
    required this.internalSlug,
    required this.unitNameAr,
    this.runtimeOrgUnitId = '',
    this.sourceOrgUnitId = '',
  });

  bool get hasRuntimeSourceMismatch =>
      runtimeOrgUnitId.isNotEmpty &&
      sourceOrgUnitId.isNotEmpty &&
      runtimeOrgUnitId != sourceOrgUnitId;

  factory PwfCanonicalUnitIdentity.fromRuntimeProfileRow(
    Map<String, dynamic> row,
  ) {
    final source = row['source_payload'] is Map
        ? Map<String, dynamic>.from(row['source_payload'] as Map)
        : const <String, dynamic>{};
    final runtimeId = _text(row, 'org_unit_id');
    final sourceId = _text(source, 'org_unit_id');
    return PwfCanonicalUnitIdentity(
      canonicalOrgUnitId: sourceId.isNotEmpty ? sourceId : runtimeId,
      internalSlug: _text(row, 'internal_slug'),
      unitNameAr: _text(row, 'unit_name_ar'),
      runtimeOrgUnitId: runtimeId,
      sourceOrgUnitId: sourceId,
    );
  }

  static String _text(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value == null) return '';
    final text = value.toString().trim();
    return text == 'null' ? '' : text;
  }
}

typedef PwfCanonicalUnitIdentityResolution = PwfCanonicalUnitIdentity;
