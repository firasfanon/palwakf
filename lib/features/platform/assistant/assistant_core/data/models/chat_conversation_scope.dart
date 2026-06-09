import 'package:flutter/foundation.dart';

import 'chat_experience_mode.dart';

@immutable
class ChatConversationScope {
  const ChatConversationScope({
    required this.mode,
    required this.unitId,
    this.adminUserId,
    this.publicSessionId,
    this.systemKey,
    this.title,
  });

  final ChatExperienceMode mode;
  final String unitId;
  final String? adminUserId;
  final String? publicSessionId;
  final String? systemKey;
  final String? title;

  String get storageKey {
    final identity = adminUserId ?? publicSessionId ?? 'anonymous';
    final system = systemKey ?? 'general';
    return '${mode.name}::$unitId::$identity::$system';
  }
}
