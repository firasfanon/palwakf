import 'package:flutter/foundation.dart';

@immutable
class PublicChatbotKnowledgeAnswer {
  const PublicChatbotKnowledgeAnswer({
    required this.text,
    required this.sourceLabelAr,
    required this.sourceLabelEn,
    this.route,
    this.isTrusted = true,
    this.scopeLabelAr = 'عام',
    this.scopeLabelEn = 'Public',
  });

  final String text;
  final String sourceLabelAr;
  final String sourceLabelEn;
  final String? route;
  final bool isTrusted;
  final String scopeLabelAr;
  final String scopeLabelEn;
}
