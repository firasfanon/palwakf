import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assistant_core/data/models/chat_conversation_scope.dart';
import '../../../assistant_core/data/models/chat_experience_mode.dart';
import '../../../assistant_core/data/models/chat_message.dart';
import '../../../assistant_core/data/repositories/chat_conversation_repository.dart';
import '../../data/services/public_chatbot_public_knowledge_service.dart';
import '../../data/services/public_chatbot_rules_service.dart';
import '../i18n/public_chatbot_i18n.dart';

class PublicChatbotState {
  const PublicChatbotState({
    required this.messages,
    required this.isBotTyping,
    required this.isLoading,
    required this.conversationId,
    required this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isBotTyping;
  final bool isLoading;
  final String? conversationId;
  final String? errorMessage;

  PublicChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isBotTyping,
    bool? isLoading,
    String? conversationId,
    String? errorMessage,
  }) {
    return PublicChatbotState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      errorMessage: errorMessage,
    );
  }

  static const empty = PublicChatbotState(
    messages: <ChatMessage>[],
    isBotTyping: false,
    isLoading: false,
    conversationId: null,
    errorMessage: null,
  );
}

final publicChatbotProvider =
    StateNotifierProvider.autoDispose<
      PublicChatbotNotifier,
      PublicChatbotState
    >((ref) {
      return PublicChatbotNotifier(
        repository: ref.read(chatConversationRepositoryProvider),
        rules: const PublicChatbotRulesService(),
        knowledge: const PublicChatbotPublicKnowledgeService(),
      );
    });

class PublicChatbotNotifier extends StateNotifier<PublicChatbotState> {
  PublicChatbotNotifier({
    required ChatConversationRepository repository,
    required PublicChatbotRulesService rules,
    required PublicChatbotPublicKnowledgeService knowledge,
  }) : _repository = repository,
       _rules = rules,
       _knowledge = knowledge,
       super(PublicChatbotState.empty);

  final ChatConversationRepository _repository;
  final PublicChatbotRulesService _rules;
  final PublicChatbotPublicKnowledgeService _knowledge;

  Timer? _typingTimer;
  int _idSeq = 0;
  ChatConversationScope? _scope;
  String _currentRoute = '/home';
  String _currentUnitSlug = 'home';

  String _nextId() =>
      'public_${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';

  Future<void> ensureBootstrapped(
    BuildContext context, {
    required String unitId,
    String? publicSessionId,
    String? currentRoute,
  }) async {
    _currentUnitSlug = unitId.trim().isEmpty ? 'home' : unitId.trim();
    _currentRoute =
        (currentRoute ??
                '/${_currentUnitSlug == 'home' ? 'home' : _currentUnitSlug}')
            .trim();
    if (_scope != null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final i18n = PublicChatbotI18n.of(context);
    final scope = ChatConversationScope(
      mode: ChatExperienceMode.publicChatbot,
      unitId: _currentUnitSlug,
      publicSessionId: publicSessionId ?? 'guest-session',
      title: i18n.pageTitle,
    );

    _scope = scope;

    try {
      final conversationId = await _repository.getOrCreateConversationId(
        scope: scope,
      );
      var messages = await _repository.listMessages(
        conversationId: conversationId,
      );

      if (messages.isEmpty) {
        final intro = await _repository.insertMessage(
          scope: scope,
          conversationId: conversationId,
          role: 'assistant',
          content: i18n.introMessage,
        );
        messages = [intro];
      }

      state = state.copyWith(
        messages: messages,
        conversationId: conversationId,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> sendUserMessage({
    required BuildContext context,
    required String text,
  }) async {
    final trimmed = text.trim();
    final scope = _scope;
    final conversationId = state.conversationId;
    if (trimmed.isEmpty || scope == null || conversationId == null) return;

    try {
      final userMessage = await _repository.insertMessage(
        scope: scope,
        conversationId: conversationId,
        role: 'user',
        content: trimmed,
      );
      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)..add(userMessage),
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        messages: List<ChatMessage>.from(state.messages)
          ..add(
            ChatMessage(
              id: _nextId(),
              sender: ChatSender.user,
              text: trimmed,
              createdAt: DateTime.now(),
            ),
          ),
        errorMessage: error.toString(),
      );
    }

    _typingTimer?.cancel();
    state = state.copyWith(isBotTyping: true);

    _typingTimer = Timer(const Duration(milliseconds: 900), () async {
      final i18n = PublicChatbotI18n.of(context);
      final strings = PublicChatbotRulesStrings(
        replySalam: i18n.replySalam,
        replyAbout: i18n.replyAbout,
        replyServices: i18n.replyServices,
        replyFaq: i18n.replyFaq,
        replyPrayerTimes: i18n.replyPrayerTimes,
        replyZakat: i18n.replyZakat,
        replyNearestMosque: i18n.replyNearestMosque,
        replyForms: i18n.replyForms,
        replyUnits: i18n.replyUnits,
        replyContact: i18n.replyContact,
        replyThanks: i18n.replyThanks,
        replyBye: i18n.replyBye,
        replyFallback: i18n.replyFallback,
      );

      final knowledgeAnswer = await _knowledge.tryResolve(
        userMessage: trimmed,
        unitSlug: _currentUnitSlug,
        isArabic: i18n.isArabic,
        currentRoute: _currentRoute,
      );
      final reply = knowledgeAnswer == null
          ? _rules
                .reply(
                  userMessage: trimmed,
                  isArabic: i18n.isArabic,
                  strings: strings,
                )
                .text
          : knowledgeAnswer.text;

      try {
        final botMessage = await _repository.insertMessage(
          scope: scope,
          conversationId: conversationId,
          role: 'assistant',
          content: reply,
        );
        state = state.copyWith(
          messages: List<ChatMessage>.from(state.messages)..add(botMessage),
          isBotTyping: false,
        );
      } catch (_) {
        state = state.copyWith(
          messages: List<ChatMessage>.from(state.messages)
            ..add(
              ChatMessage(
                id: _nextId(),
                sender: ChatSender.bot,
                text: reply,
                createdAt: DateTime.now(),
              ),
            ),
          isBotTyping: false,
        );
      }
    });
  }

  Future<void> onQuickAction({
    required BuildContext context,
    required String question,
  }) async {
    await sendUserMessage(context: context, text: question);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
