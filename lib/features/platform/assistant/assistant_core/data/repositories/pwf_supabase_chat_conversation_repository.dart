import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_conversation_scope.dart';
import '../models/chat_message.dart';
import 'chat_conversation_repository.dart';

/// Supabase-backed persistence for PalWakf assistant conversations.
///
/// Design:
/// - INTERNAL assistant persists (admin_user_id = auth.uid)
/// - PUBLIC chatbot falls back to in-memory by default (no unsafe anon persistence)
///
/// Tables expected (see sql/pwf_assistant_chat_schema.sql):
/// - public.assistant_conversations
/// - public.assistant_messages
class PwfSupabaseChatConversationRepository
    implements ChatConversationRepository {
  PwfSupabaseChatConversationRepository({
    required SupabaseClient client,
    ChatConversationRepository? fallback,
  }) : _client = client,
       _fallback = fallback ?? InMemoryChatConversationRepository.instance;

  final SupabaseClient _client;
  final ChatConversationRepository _fallback;

  static const String conversationsTable = 'assistant_conversations';
  static const String messagesTable = 'assistant_messages';

  bool _shouldPersist(ChatConversationScope scope) {
    // Persist only when we have a trusted authenticated identity.
    // Public chatbot can still work via in-memory without weakening RLS.
    return scope.adminUserId != null && scope.adminUserId!.trim().isNotEmpty;
  }

  @override
  Future<String> getOrCreateConversationId({
    required ChatConversationScope scope,
  }) async {
    if (!_shouldPersist(scope)) {
      return _fallback.getOrCreateConversationId(scope: scope);
    }

    final scopeKey = scope.storageKey;

    final existing = await _client
        .from(conversationsTable)
        .select('id')
        .eq('scope_key', scopeKey)
        .maybeSingle();

    if (existing != null && existing['id'] != null) {
      return existing['id'].toString();
    }

    final inserted = await _client
        .from(conversationsTable)
        .insert({
          'scope_key': scopeKey,
          'mode': scope.mode.name,
          'unit_id': scope.unitId,
          'admin_user_id': scope.adminUserId,
          'public_session_id': scope.publicSessionId,
          'system_key': scope.systemKey,
          'title': scope.title,
        })
        .select('id')
        .single();

    return inserted['id'].toString();
  }

  @override
  Future<List<ChatMessage>> listMessages({
    required String conversationId,
  }) async {
    // If the id looks like our in-memory ids, delegate.
    if (conversationId.startsWith('conversation_')) {
      return _fallback.listMessages(conversationId: conversationId);
    }

    final rows = await _client
        .from(messagesTable)
        .select('id, role, content, created_at')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return rows
        .map<ChatMessage>((row) {
          final role = (row['role'] ?? '').toString();
          final createdRaw = row['created_at'];
          final createdAt = createdRaw is String
              ? DateTime.tryParse(createdRaw)
              : (createdRaw is DateTime ? createdRaw : null);
          return ChatMessage(
            id: row['id'].toString(),
            sender: role == 'assistant' ? ChatSender.bot : ChatSender.user,
            text: (row['content'] ?? '').toString(),
            createdAt: createdAt ?? DateTime.now(),
          );
        })
        .toList(growable: false);
  }

  @override
  Future<ChatMessage> insertMessage({
    required ChatConversationScope scope,
    required String conversationId,
    required String role,
    required String content,
  }) async {
    if (!_shouldPersist(scope) || conversationId.startsWith('conversation_')) {
      return _fallback.insertMessage(
        scope: scope,
        conversationId: conversationId,
        role: role,
        content: content,
      );
    }

    final row = await _client
        .from(messagesTable)
        .insert({
          'conversation_id': conversationId,
          'role': role,
          'content': content,
        })
        .select('id, role, content, created_at')
        .single();

    final createdRaw = row['created_at'];
    final createdAt = createdRaw is String
        ? DateTime.tryParse(createdRaw)
        : (createdRaw is DateTime ? createdRaw : null);

    return ChatMessage(
      id: row['id'].toString(),
      sender: role == 'assistant' ? ChatSender.bot : ChatSender.user,
      text: (row['content'] ?? '').toString(),
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

/// Helper override provider.
///
/// Usage (in main.dart or app root):
/// ProviderScope(
///   overrides: [pwfChatConversationRepositoryOverride],
///   child: MyApp(),
/// )
Override get pwfChatConversationRepositoryOverride =>
    chatConversationRepositoryProvider.overrideWithValue(
      PwfSupabaseChatConversationRepository(client: Supabase.instance.client),
    );
