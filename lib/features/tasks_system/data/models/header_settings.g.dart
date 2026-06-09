// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'header_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeaderSettings _$HeaderSettingsFromJson(Map<String, dynamic> json) =>
    HeaderSettings(
      id: json['id'] as String,
      logoUrl: json['logo_url'] as String,
      logoAlt: json['logo_alt'] as String? ?? 'Ministry Logo',
      siteName: json['site_name'] as String,
      siteTagline: json['site_tagline'] as String? ?? 'دولة فلسطين',
      faviconUrl: json['favicon_url'] as String?,
      showBreakingNews: json['show_breaking_news'] as bool? ?? true,
      breakingNewsText: json['breaking_news_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$HeaderSettingsToJson(HeaderSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'logo_url': instance.logoUrl,
      'logo_alt': instance.logoAlt,
      'site_name': instance.siteName,
      'site_tagline': instance.siteTagline,
      'favicon_url': instance.faviconUrl,
      'show_breaking_news': instance.showBreakingNews,
      'breaking_news_text': instance.breakingNewsText,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
