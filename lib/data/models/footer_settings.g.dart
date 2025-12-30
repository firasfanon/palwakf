// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'footer_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FooterLink _$FooterLinkFromJson(Map<String, dynamic> json) => FooterLink(
      label: json['label'] as String,
      route: json['route'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$FooterLinkToJson(FooterLink instance) =>
    <String, dynamic>{
      'label': instance.label,
      'route': instance.route,
      'enabled': instance.enabled,
    };

FooterPartner _$FooterPartnerFromJson(Map<String, dynamic> json) =>
    FooterPartner(
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$FooterPartnerToJson(FooterPartner instance) =>
    <String, dynamic>{
      'name': instance.name,
      'logo_url': instance.logoUrl,
      'enabled': instance.enabled,
    };

FooterSettings _$FooterSettingsFromJson(Map<String, dynamic> json) =>
    FooterSettings(
      id: json['id'] as String,
      ministryLogoUrl: json['ministry_logo_url'] as String?,
      ministryName: json['ministry_name'] as String? ?? 'وزارة الأوقاف',
      ministrySubtitle: json['ministry_subtitle'] as String? ?? 'دولة فلسطين',
      ministryDescription: json['ministry_description'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactFax: json['contact_fax'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactAddress: json['contact_address'] as String?,
      workingDays: json['working_days'] as String? ?? 'من الأحد إلى الخميس',
      workingHours:
          json['working_hours'] as String? ?? '8:00 صباحاً - 3:00 مساءً',
      facebookUrl: json['facebook_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      quickLinks: (json['quick_links'] as List<dynamic>?)
              ?.map((e) => FooterLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      servicesLinks: (json['services_links'] as List<dynamic>?)
              ?.map((e) => FooterLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bottomLinks: (json['bottom_links'] as List<dynamic>?)
              ?.map((e) => FooterLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      partners: (json['partners'] as List<dynamic>?)
              ?.map((e) => FooterPartner.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      showPartners: json['show_partners'] as bool? ?? true,
      copyrightText: json['copyright_text'] as String? ??
          '© 2024 وزارة الأوقاف والشؤون الدينية - دولة فلسطين. جميع الحقوق محفوظة.',
      developerCredit: json['developer_credit'] as String? ??
          'تم التطوير بواسطة فريق تقنية المعلومات',
      showDeveloperCredit: json['show_developer_credit'] as bool? ?? true,
      showPhone: json['show_phone'] as bool? ?? true,
      showEmail: json['show_email'] as bool? ?? true,
      showAddress: json['show_address'] as bool? ?? true,
      showWorkingHours: json['show_working_hours'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FooterSettingsToJson(FooterSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ministry_logo_url': instance.ministryLogoUrl,
      'ministry_name': instance.ministryName,
      'ministry_subtitle': instance.ministrySubtitle,
      'ministry_description': instance.ministryDescription,
      'contact_phone': instance.contactPhone,
      'contact_fax': instance.contactFax,
      'contact_email': instance.contactEmail,
      'contact_address': instance.contactAddress,
      'working_days': instance.workingDays,
      'working_hours': instance.workingHours,
      'facebook_url': instance.facebookUrl,
      'twitter_url': instance.twitterUrl,
      'instagram_url': instance.instagramUrl,
      'youtube_url': instance.youtubeUrl,
      'linkedin_url': instance.linkedinUrl,
      'quick_links': instance.quickLinks.map((e) => e.toJson()).toList(),
      'services_links': instance.servicesLinks.map((e) => e.toJson()).toList(),
      'bottom_links': instance.bottomLinks.map((e) => e.toJson()).toList(),
      'partners': instance.partners.map((e) => e.toJson()).toList(),
      'show_partners': instance.showPartners,
      'copyright_text': instance.copyrightText,
      'developer_credit': instance.developerCredit,
      'show_developer_credit': instance.showDeveloperCredit,
      'show_phone': instance.showPhone,
      'show_email': instance.showEmail,
      'show_address': instance.showAddress,
      'show_working_hours': instance.showWorkingHours,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
