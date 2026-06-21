import 'package:flutter/material.dart';

class PwfHeroLandmark {
  final String title;
  final String subtitle;
  final String assetPath;
  final String ctaText;
  final String ctaLink;
  final IconData? ctaIcon;
  final AlignmentGeometry imageAlignment;

  const PwfHeroLandmark({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.ctaText,
    required this.ctaLink,
    this.ctaIcon,
    this.imageAlignment = const Alignment(0, 0.36),
  });
}

class PwfHomeHeroLandmarks {
  const PwfHomeHeroLandmarks._();

  static const List<PwfHeroLandmark> slides = <PwfHeroLandmark>[
    PwfHeroLandmark(
      title: 'القدس الشريف',
      subtitle: 'عاصمة دولة فلسطين الأبدية',
      assetPath: 'assets/images/hero/quds.webp',
      ctaText: 'تعرف على خدماتنا',
      ctaLink: '#services',
      ctaIcon: Icons.explore_outlined,
    ),
    PwfHeroLandmark(
      title: 'الحرم الإبراهيمي الشريف',
      subtitle: 'مدينة خليل الرحمن',
      assetPath: 'assets/images/hero/ibrahimi.webp',
      ctaText: 'تعرف على خدماتنا',
      ctaLink: '#services',
      ctaIcon: Icons.explore_outlined,
    ),
    PwfHeroLandmark(
      title: 'مقام النبي موسى',
      subtitle: 'من أبرز المعالم الدينية في فلسطين',
      assetPath: 'assets/images/hero/nabi_musa.webp',
      ctaText: 'تعرف على خدماتنا',
      ctaLink: '#services',
      ctaIcon: Icons.explore_outlined,
    ),
  ];
}
