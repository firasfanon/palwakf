// Patch v13: Fail-open model parsing for homepage sections.
// This file is intended to replace/override the existing model in projects
// where NULL timestamps (created_at/updated_at) caused runtime crashes.

class HomepageSection {
  final String id;
  final String sectionName;
  final Map<String, dynamic> settings;
  final bool isActive;
  final int displayOrder;
  final String createdAt;
  final String updatedAt;
  final String? updatedBy;
  final String? unitId;

  const HomepageSection({
    required this.id,
    required this.sectionName,
    required this.settings,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedBy,
    this.unitId,
  });

  static String _iso(dynamic v, String fallback) {
    if (v is String && v.isNotEmpty) return v;
    if (v == null) return fallback;
    return v.toString();
  }

  static int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return fallback;
  }

  static bool _asBool(dynamic v, bool fallback) {
    if (v is bool) return v;
    return fallback;
  }

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  factory HomepageSection.fromJson(Map<String, dynamic> json) {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return HomepageSection(
      id: (json['id'] ?? '').toString(),
      sectionName: (json['section_name'] ?? '').toString(),
      settings: _asMap(json['settings']),
      isActive: _asBool(json['is_active'], true),
      displayOrder: _asInt(json['display_order'], 0),
      createdAt: _iso(json['created_at'], nowIso),
      updatedAt: _iso(json['updated_at'], nowIso),
      updatedBy: json['updated_by']?.toString(),
      unitId: json['unit_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'section_name': sectionName,
    'settings': settings,
    'is_active': isActive,
    'display_order': displayOrder,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'updated_by': updatedBy,
    'unit_id': unitId,
  };

  HomepageSection copyWith({
    String? id,
    String? sectionName,
    Map<String, dynamic>? settings,
    bool? isActive,
    int? displayOrder,
    String? createdAt,
    String? updatedAt,
    String? updatedBy,
    String? unitId,
  }) {
    return HomepageSection(
      id: id ?? this.id,
      sectionName: sectionName ?? this.sectionName,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      unitId: unitId ?? this.unitId,
    );
  }
}

// The rest of the models (HeroSlide / BreakingNewsItem / Settings classes) are
// intentionally NOT included here.
