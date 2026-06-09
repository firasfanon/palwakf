import 'package:flutter/material.dart';

class InternalAssistantI18n {
  const InternalAssistantI18n(this.locale);

  final Locale locale;

  static InternalAssistantI18n of(BuildContext context) =>
      InternalAssistantI18n(Localizations.localeOf(context));

  bool get isArabic => locale.languageCode.toLowerCase().startsWith('ar');

  String get pageTitle =>
      isArabic ? 'مساعد PalWakf الداخلي' : 'PalWakf Internal Assistant';
  String get headerTitle =>
      isArabic ? 'مساعد العمل الداخلي' : 'Internal Work Assistant';
  String get headerSubtitle => isArabic
      ? 'مساعد سياقي مرتبط بالدور والنظام الحالي والصفحة التي تعمل عليها.'
      : 'A contextual assistant linked to the current role, system, and page.';
  String get inputHint => isArabic
      ? 'اسأل عن خطوة العمل التالية...'
      : 'Ask about the next work step...';
  String get resumeSectionTitle => isArabic ? 'الاستئناف' : 'Resume';
  String get suggestionsSectionTitle =>
      isArabic ? 'اقتراحات مباشرة' : 'Quick suggestions';
}
