// lib/data/models/header_settings.dart
import 'package:json_annotation/json_annotation.dart';

part 'header_settings.g.dart';

@JsonSerializable()
class HeaderSettings {
  final String id;
  @JsonKey(name: 'logo_url')
  final String logoUrl;
  @JsonKey(name: 'logo_alt')
  final String logoAlt;
  @JsonKey(name: 'site_name')
  final String siteName;
  @JsonKey(name: 'site_tagline')
  final String siteTagline;
  @JsonKey(name: 'favicon_url')
  final String? faviconUrl;
  @JsonKey(name: 'show_breaking_news')
  final bool showBreakingNews;
  @JsonKey(name: 'breaking_news_text')
  final String? breakingNewsText;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  HeaderSettings({
    required this.id,
    required this.logoUrl,
    this.logoAlt = 'Ministry Logo',
    required this.siteName,
    this.siteTagline = 'دولة فلسطين',
    this.faviconUrl,
    this.showBreakingNews = true,
    this.breakingNewsText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HeaderSettings.fromJson(Map<String, dynamic> json) =>
      _$HeaderSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$HeaderSettingsToJson(this);

  HeaderSettings copyWith({
    String? id,
    String? logoUrl,
    String? logoAlt,
    String? siteName,
    String? siteTagline,
    String? faviconUrl,
    bool? showBreakingNews,
    String? breakingNewsText,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HeaderSettings(
      id: id ?? this.id,
      logoUrl: logoUrl ?? this.logoUrl,
      logoAlt: logoAlt ?? this.logoAlt,
      siteName: siteName ?? this.siteName,
      siteTagline: siteTagline ?? this.siteTagline,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      showBreakingNews: showBreakingNews ?? this.showBreakingNews,
      breakingNewsText: breakingNewsText ?? this.breakingNewsText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}