import 'package:flutter/foundation.dart';

@immutable
class PublicChatbotBotReply {
  const PublicChatbotBotReply(this.text);

  final String text;
}

@immutable
class PublicChatbotRulesStrings {
  const PublicChatbotRulesStrings({
    required this.replySalam,
    required this.replyAbout,
    required this.replyServices,
    required this.replyFaq,
    required this.replyPrayerTimes,
    required this.replyZakat,
    required this.replyNearestMosque,
    required this.replyForms,
    required this.replyUnits,
    required this.replyContact,
    required this.replyThanks,
    required this.replyBye,
    required this.replyFallback,
  });

  final String replySalam;
  final String replyAbout;
  final String replyServices;
  final String replyFaq;
  final String replyPrayerTimes;
  final String replyZakat;
  final String replyNearestMosque;
  final String replyForms;
  final String replyUnits;
  final String replyContact;
  final String replyThanks;
  final String replyBye;
  final String Function(String userMessage) replyFallback;
}

@immutable
class PublicChatbotRulesService {
  const PublicChatbotRulesService();

  PublicChatbotBotReply reply({
    required String userMessage,
    required bool isArabic,
    required PublicChatbotRulesStrings strings,
  }) {
    final message = userMessage.trim();
    final lower = message.toLowerCase();

    bool hasAny(List<String> tokens) {
      for (final token in tokens) {
        if (lower.contains(token.toLowerCase())) return true;
      }
      return false;
    }

    if (isArabic) {
      if (hasAny(const ['سلام', 'السلام', 'مرحبا', 'أهلا']))
        return PublicChatbotBotReply(strings.replySalam);
      if (hasAny(const ['وزارة', 'المؤسسة', 'عن الوزارة', 'من أنتم']))
        return PublicChatbotBotReply(strings.replyAbout);
      if (hasAny(const ['خدمة', 'الخدمات', 'إلكترونية', 'نماذج']))
        return PublicChatbotBotReply(strings.replyServices);
      if (hasAny(const ['شائع', 'الأسئلة', 'faq']))
        return PublicChatbotBotReply(strings.replyFaq);
      if (hasAny(const [
        'مواقيت',
        'الصلاة',
        'اذان',
        'أذان',
        'الفجر',
        'العشاء',
        'المغرب',
      ]))
        return PublicChatbotBotReply(strings.replyPrayerTimes);
      if (hasAny(const ['زكاة', 'الزكاة', 'حساب الزكاة']))
        return PublicChatbotBotReply(strings.replyZakat);
      if (hasAny(const ['أقرب مسجد', 'اقرب مسجد', 'مسجد']))
        return PublicChatbotBotReply(strings.replyNearestMosque);
      if (hasAny(const ['رابط', 'نموذج', 'استمارة', 'تحميل']))
        return PublicChatbotBotReply(strings.replyForms);
      if (hasAny(const ['وحدة', 'مديرية', 'المديريات', 'وحدات']))
        return PublicChatbotBotReply(strings.replyUnits);
      if (hasAny(const ['اتصال', 'تواصل', 'هاتف', 'البريد', 'العنوان']))
        return PublicChatbotBotReply(strings.replyContact);
      if (hasAny(const ['شكر', 'جزاك']))
        return PublicChatbotBotReply(strings.replyThanks);
      if (hasAny(const ['مع السلامة', 'وداعاً']))
        return PublicChatbotBotReply(strings.replyBye);
      return PublicChatbotBotReply(strings.replyFallback(message));
    }

    if (hasAny(const ['hi', 'hello', 'salam']))
      return PublicChatbotBotReply(strings.replySalam);
    if (hasAny(const ['about', 'ministry', 'institution']))
      return PublicChatbotBotReply(strings.replyAbout);
    if (hasAny(const ['service', 'services', 'e-service']))
      return PublicChatbotBotReply(strings.replyServices);
    if (hasAny(const ['faq', 'question']))
      return PublicChatbotBotReply(strings.replyFaq);
    if (hasAny(const ['prayer', 'adhan']))
      return PublicChatbotBotReply(strings.replyPrayerTimes);
    if (hasAny(const ['zakat']))
      return PublicChatbotBotReply(strings.replyZakat);
    if (hasAny(const ['mosque', 'nearest mosque']))
      return PublicChatbotBotReply(strings.replyNearestMosque);
    if (hasAny(const ['link', 'form', 'download']))
      return PublicChatbotBotReply(strings.replyForms);
    if (hasAny(const ['unit', 'directorate']))
      return PublicChatbotBotReply(strings.replyUnits);
    if (hasAny(const ['contact', 'phone', 'email', 'address']))
      return PublicChatbotBotReply(strings.replyContact);
    if (hasAny(const ['thanks', 'thank you']))
      return PublicChatbotBotReply(strings.replyThanks);
    if (hasAny(const ['bye', 'goodbye']))
      return PublicChatbotBotReply(strings.replyBye);

    return PublicChatbotBotReply(strings.replyFallback(message));
  }
}
