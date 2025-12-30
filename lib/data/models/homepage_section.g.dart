// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homepage_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomepageSection _$HomepageSectionFromJson(Map<String, dynamic> json) =>
    HomepageSection(
      id: json['id'] as String,
      sectionName: json['sectionName'] as String,
      settings: json['settings'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$HomepageSectionToJson(HomepageSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sectionName': instance.sectionName,
      'settings': instance.settings,
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };

SiteSettings _$SiteSettingsFromJson(Map<String, dynamic> json) => SiteSettings(
      id: json['id'] as String,
      logoUrl: json['logoUrl'] as String,
      faviconUrl: json['faviconUrl'] as String?,
      siteTitle: json['siteTitle'] as String,
      siteSubtitle: json['siteSubtitle'] as String,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactAddress: json['contactAddress'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      twitterUrl: json['twitterUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      footerText: json['footerText'] as String?,
      sliderAutoplay: json['sliderAutoplay'] as bool? ?? true,
      sliderSpeed: (json['sliderSpeed'] as num?)?.toInt() ?? 5000,
      sliderShowDots: json['sliderShowDots'] as bool? ?? true,
      sliderShowArrows: json['sliderShowArrows'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$SiteSettingsToJson(SiteSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'logoUrl': instance.logoUrl,
      'faviconUrl': instance.faviconUrl,
      'siteTitle': instance.siteTitle,
      'siteSubtitle': instance.siteSubtitle,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'contactAddress': instance.contactAddress,
      'facebookUrl': instance.facebookUrl,
      'twitterUrl': instance.twitterUrl,
      'instagramUrl': instance.instagramUrl,
      'youtubeUrl': instance.youtubeUrl,
      'footerText': instance.footerText,
      'sliderAutoplay': instance.sliderAutoplay,
      'sliderSpeed': instance.sliderSpeed,
      'sliderShowDots': instance.sliderShowDots,
      'sliderShowArrows': instance.sliderShowArrows,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };

HeroSlide _$HeroSlideFromJson(Map<String, dynamic> json) => HeroSlide(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      ctaText: json['ctaText'] as String?,
      ctaLink: json['ctaLink'] as String?,
      displayOrder: (json['displayOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      updatedBy: json['updatedBy'] as String?,
    );

Map<String, dynamic> _$HeroSlideToJson(HeroSlide instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'ctaText': instance.ctaText,
      'ctaLink': instance.ctaLink,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };
