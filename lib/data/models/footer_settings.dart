// lib/data/models/footer_settings.dart
import 'package:json_annotation/json_annotation.dart';

part 'footer_settings.g.dart';

@JsonSerializable(explicitToJson: true)
class FooterLink {
  final String label;
  final String route;
  final bool enabled;

  FooterLink({
    required this.label,
    required this.route,
    this.enabled = true,
  });

  factory FooterLink.fromJson(Map<String, dynamic> json) =>
      _$FooterLinkFromJson(json);

  Map<String, dynamic> toJson() => _$FooterLinkToJson(this);

  FooterLink copyWith({
    String? label,
    String? route,
    bool? enabled,
  }) {
    return FooterLink(
      label: label ?? this.label,
      route: route ?? this.route,
      enabled: enabled ?? this.enabled,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FooterPartner {
  final String name;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;
  final bool enabled;

  FooterPartner({
    required this.name,
    this.logoUrl,
    this.enabled = true,
  });

  factory FooterPartner.fromJson(Map<String, dynamic> json) =>
      _$FooterPartnerFromJson(json);

  Map<String, dynamic> toJson() => _$FooterPartnerToJson(this);

  FooterPartner copyWith({
    String? name,
    String? logoUrl,
    bool? enabled,
  }) {
    return FooterPartner(
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      enabled: enabled ?? this.enabled,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FooterSettings {
  final String id;

  // Ministry Info
  @JsonKey(name: 'ministry_logo_url')
  final String? ministryLogoUrl;
  @JsonKey(name: 'ministry_name')
  final String ministryName;
  @JsonKey(name: 'ministry_subtitle')
  final String ministrySubtitle;
  @JsonKey(name: 'ministry_description')
  final String? ministryDescription;

  // Contact Information
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @JsonKey(name: 'contact_fax')
  final String? contactFax;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'contact_address')
  final String? contactAddress;
  @JsonKey(name: 'working_days')
  final String workingDays;
  @JsonKey(name: 'working_hours')
  final String workingHours;

  // Social Media
  @JsonKey(name: 'facebook_url')
  final String? facebookUrl;
  @JsonKey(name: 'twitter_url')
  final String? twitterUrl;
  @JsonKey(name: 'instagram_url')
  final String? instagramUrl;
  @JsonKey(name: 'youtube_url')
  final String? youtubeUrl;
  @JsonKey(name: 'linkedin_url')
  final String? linkedinUrl;

  // Links
  @JsonKey(name: 'quick_links')
  final List<FooterLink> quickLinks;
  @JsonKey(name: 'services_links')
  final List<FooterLink> servicesLinks;
  @JsonKey(name: 'bottom_links')
  final List<FooterLink> bottomLinks;

  // Partners
  final List<FooterPartner> partners;
  @JsonKey(name: 'show_partners')
  final bool showPartners;

  // Copyright
  @JsonKey(name: 'copyright_text')
  final String copyrightText;

  // Developer Credit
  @JsonKey(name: 'developer_credit')
  final String developerCredit;
  @JsonKey(name: 'show_developer_credit')
  final bool showDeveloperCredit;

  // Toggles
  @JsonKey(name: 'show_phone')
  final bool showPhone;
  @JsonKey(name: 'show_email')
  final bool showEmail;
  @JsonKey(name: 'show_address')
  final bool showAddress;
  @JsonKey(name: 'show_working_hours')
  final bool showWorkingHours;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  FooterSettings({
    required this.id,
    this.ministryLogoUrl,
    this.ministryName = 'وزارة الأوقاف',
    this.ministrySubtitle = 'دولة فلسطين',
    this.ministryDescription,
    this.contactPhone,
    this.contactFax,
    this.contactEmail,
    this.contactAddress,
    this.workingDays = 'من الأحد إلى الخميس',
    this.workingHours = '8:00 صباحاً - 3:00 مساءً',
    this.facebookUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.linkedinUrl,
    this.quickLinks = const [],
    this.servicesLinks = const [],
    this.bottomLinks = const [],
    this.partners = const [],
    this.showPartners = true,
    this.copyrightText = '© 2024 وزارة الأوقاف والشؤون الدينية - دولة فلسطين. جميع الحقوق محفوظة.',
    this.developerCredit = 'تم التطوير بواسطة فريق تقنية المعلومات',
    this.showDeveloperCredit = true,
    this.showPhone = true,
    this.showEmail = true,
    this.showAddress = true,
    this.showWorkingHours = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FooterSettings.fromJson(Map<String, dynamic> json) =>
      _$FooterSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$FooterSettingsToJson(this);

  FooterSettings copyWith({
    String? id,
    String? ministryLogoUrl,
    String? ministryName,
    String? ministrySubtitle,
    String? ministryDescription,
    String? contactPhone,
    String? contactFax,
    String? contactEmail,
    String? contactAddress,
    String? workingDays,
    String? workingHours,
    String? facebookUrl,
    String? twitterUrl,
    String? instagramUrl,
    String? youtubeUrl,
    String? linkedinUrl,
    List<FooterLink>? quickLinks,
    List<FooterLink>? servicesLinks,
    List<FooterLink>? bottomLinks,
    List<FooterPartner>? partners,
    bool? showPartners,
    String? copyrightText,
    String? developerCredit,
    bool? showDeveloperCredit,
    bool? showPhone,
    bool? showEmail,
    bool? showAddress,
    bool? showWorkingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FooterSettings(
      id: id ?? this.id,
      ministryLogoUrl: ministryLogoUrl ?? this.ministryLogoUrl,
      ministryName: ministryName ?? this.ministryName,
      ministrySubtitle: ministrySubtitle ?? this.ministrySubtitle,
      ministryDescription: ministryDescription ?? this.ministryDescription,
      contactPhone: contactPhone ?? this.contactPhone,
      contactFax: contactFax ?? this.contactFax,
      contactEmail: contactEmail ?? this.contactEmail,
      contactAddress: contactAddress ?? this.contactAddress,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      quickLinks: quickLinks ?? this.quickLinks,
      servicesLinks: servicesLinks ?? this.servicesLinks,
      bottomLinks: bottomLinks ?? this.bottomLinks,
      partners: partners ?? this.partners,
      showPartners: showPartners ?? this.showPartners,
      copyrightText: copyrightText ?? this.copyrightText,
      developerCredit: developerCredit ?? this.developerCredit,
      showDeveloperCredit: showDeveloperCredit ?? this.showDeveloperCredit,
      showPhone: showPhone ?? this.showPhone,
      showEmail: showEmail ?? this.showEmail,
      showAddress: showAddress ?? this.showAddress,
      showWorkingHours: showWorkingHours ?? this.showWorkingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}