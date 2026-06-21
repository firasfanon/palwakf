class PwfUnitPublicProfile {
  final String orgUnitId;
  final String publicSlug;
  final String unitNameAr;
  final bool isPublished;
  final String? heroTitleAr;
  final String? heroSubtitleAr;
  final String? heroImageUrl;

  const PwfUnitPublicProfile({
    required this.orgUnitId,
    required this.publicSlug,
    required this.unitNameAr,
    this.isPublished = false,
    this.heroTitleAr,
    this.heroSubtitleAr,
    this.heroImageUrl,
  });

  factory PwfUnitPublicProfile.fromJson(Map<String, dynamic> json) {
    return PwfUnitPublicProfile(
      orgUnitId: (json['org_unit_id'] ?? json['id'] ?? '').toString().trim(),
      publicSlug:
          (json['public_slug'] ?? json['internal_slug'] ?? '').toString().trim(),
      unitNameAr: (json['unit_name_ar'] ?? '').toString().trim(),
      isPublished: (json['is_published'] ?? false) == true,
      heroTitleAr: json['hero_title_ar']?.toString(),
      heroSubtitleAr: json['hero_subtitle_ar']?.toString(),
      heroImageUrl: json['hero_image_url']?.toString(),
    );
  }
}
