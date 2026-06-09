import 'package:flutter/foundation.dart';

enum AssistantKnowledgeScope { public, internal, restricted, uncertain }

@immutable
class AssistantKnowledgeSource {
  const AssistantKnowledgeSource({
    required this.id,
    required this.labelAr,
    required this.labelEn,
    required this.owner,
    required this.scope,
    required this.isTrusted,
    required this.directAnswerAllowed,
  });

  final String id;
  final String labelAr;
  final String labelEn;
  final String owner;
  final AssistantKnowledgeScope scope;
  final bool isTrusted;
  final bool directAnswerAllowed;
}
