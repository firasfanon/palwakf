import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_conversation_scope.dart';
import '../models/chat_message.dart';

abstract class ChatConversationRepository {
  Future<String> getOrCreateConversationId({
    required ChatConversationScope scope,
  });

  Future<List<ChatMessage>> listMessages({required String conversationId});

  Future<ChatMessage> insertMessage({
    required ChatConversationScope scope,
    required String conversationId,
    required String role,
    required String content,
  });
}

final chatConversationRepositoryProvider = Provider<ChatConversationRepository>(
  (ref) {
    return InMemoryChatConversationRepository.instance;
  },
);

class InMemoryChatConversationRepository implements ChatConversationRepository {
  InMemoryChatConversationRepository._();

  static final InMemoryChatConversationRepository instance =
      InMemoryChatConversationRepository._();

  static final Map<String, String> _conversationIdsByScope = <String, String>{};
  static final Map<String, List<ChatMessage>> _messagesByConversation =
      <String, List<ChatMessage>>{};

  int _idSeq = 0;

  String _nextId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';

  @override
  Future<String> getOrCreateConversationId({
    required ChatConversationScope scope,
  }) async {
    final existing = _conversationIdsByScope[scope.storageKey];
    if (existing != null) return existing;

    final id = _nextId('conversation');
    _conversationIdsByScope[scope.storageKey] = id;
    _messagesByConversation[id] = <ChatMessage>[];
    return id;
  }

  @override
  Future<List<ChatMessage>> listMessages({
    required String conversationId,
  }) async {
    return List<ChatMessage>.from(
      _messagesByConversation[conversationId] ?? const <ChatMessage>[],
    );
  }

  @override
  Future<ChatMessage> insertMessage({
    required ChatConversationScope scope,
    required String conversationId,
    required String role,
    required String content,
  }) async {
    final message = ChatMessage(
      id: _nextId('message'),
      sender: role == 'assistant' ? ChatSender.bot : ChatSender.user,
      text: content,
      createdAt: DateTime.now(),
    );

    final list = _messagesByConversation.putIfAbsent(
      conversationId,
      () => <ChatMessage>[],
    );
    list.add(message);
    return message;
  }
}
