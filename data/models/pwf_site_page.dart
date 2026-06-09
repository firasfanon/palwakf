class PwfSitePage {
  const PwfSitePage({
    required this.id,
    required this.slug,
    required this.unitId,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.isPublished,
    required this.updatedAt,
  });

  final String id;
  final String slug;
  final String? unitId;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final String bodyAr;
  final String bodyEn;
  final bool isPublished;
  final DateTime? updatedAt;

  factory PwfSitePage.fromJson(Map<String, dynamic> json) {
    return PwfSitePage(
      id: (json['id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      unitId: json['unit_id']?.toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      titleEn: (json['title_en'] ?? '').toString(),
      subtitleAr: (json['subtitle_ar'] ?? '').toString(),
      subtitleEn: (json['subtitle_en'] ?? '').toString(),
      bodyAr: (json['body_ar'] ?? '').toString(),
      bodyEn: (json['body_en'] ?? '').toString(),
      isPublished: (json['is_published'] as bool?) ?? true,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
