import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';

import '../specs/pwf_internal_public_page_specs.dart';
import 'pwf_section_container.dart';

class PwfInternalPublicPageIntro extends StatelessWidget {
  const PwfInternalPublicPageIntro({
    super.key,
    required this.specKey,
    required this.unitSlug,
    this.title,
    this.subtitle,
    this.note,
    this.icon,
    this.verticalPadding = 0,
    this.wrapInSectionContainer = true,
  });

  final String specKey;
  final String unitSlug;
  final String? title;
  final String? subtitle;
  final String? note;
  final IconData? icon;
  final double verticalPadding;
  final bool wrapInSectionContainer;

  @override
  Widget build(BuildContext context) {
    final spec = findPwfInternalPublicPageSpec(specKey);
    final locale = Localizations.localeOf(context);
    final card = PwfPublicIntroCard(
      title: title ?? spec?.titleFor(locale) ?? specKey,
      subtitle: subtitle ?? spec?.subtitleFor(locale) ?? '',
      icon: icon ?? spec?.icon ?? Icons.description_outlined,
      unitSlug: unitSlug,
      note: note,
    );
    if (!wrapInSectionContainer) return card;
    return PwfSectionContainer(
      sectionKey: 'PwfInternalIntro_$specKey',
      verticalPadding: verticalPadding,
      maxWidth: spec?.maxContentWidth ?? 1400,
      child: card,
    );
  }
}

class PwfInternalPublicPageBodySection extends StatelessWidget {
  const PwfInternalPublicPageBodySection({
    super.key,
    required this.specKey,
    required this.sectionKey,
    required this.child,
    this.verticalPadding = 18,
  });

  final String specKey;
  final String sectionKey;
  final Widget child;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final spec = findPwfInternalPublicPageSpec(specKey);
    return PwfSectionContainer(
      sectionKey: sectionKey,
      verticalPadding: verticalPadding,
      maxWidth: spec?.maxContentWidth ?? 1400,
      child: child,
    );
  }
}
