import 'package:flutter/material.dart';

enum PwfInternalPublicPageType { informational, listing, serviceTool, reader }

enum PwfInternalPublicSectionType {
  intro,
  stats,
  filters,
  mainContent,
  complementary,
  detail,
}

class PwfInternalPublicPageSpec {
  const PwfInternalPublicPageSpec({
    required this.key,
    required this.pageSlug,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.icon,
    required this.type,
    this.maxContentWidth = 1400,
    this.useIntroCard = true,
    this.allowHeroImage = false,
    this.defaultSections = const <PwfInternalPublicSectionType>[],
  });

  final String key;
  final String pageSlug;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final IconData icon;
  final PwfInternalPublicPageType type;
  final double maxContentWidth;
  final bool useIntroCard;
  final bool allowHeroImage;
  final List<PwfInternalPublicSectionType> defaultSections;

  String titleFor(Locale locale) =>
      locale.languageCode.toLowerCase().startsWith('ar') ? titleAr : titleEn;
  String subtitleFor(Locale locale) =>
      locale.languageCode.toLowerCase().startsWith('ar')
      ? subtitleAr
      : subtitleEn;
}

class PwfInternalPublicSectionSpec {
  const PwfInternalPublicSectionSpec({
    required this.key,
    required this.titleAr,
    required this.pageSpecKey,
    this.supportsListing = false,
    this.supportsDetail = false,
    this.supportsFilters = false,
    this.supportsCompanion = false,
  });

  final String key;
  final String titleAr;
  final String pageSpecKey;
  final bool supportsListing;
  final bool supportsDetail;
  final bool supportsFilters;
  final bool supportsCompanion;
}
