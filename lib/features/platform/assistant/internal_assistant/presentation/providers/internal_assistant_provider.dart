import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assistant_core/data/models/chat_conversation_scope.dart';
import '../../../assistant_core/data/models/chat_experience_mode.dart';
import '../../../assistant_core/data/models/chat_message.dart';
import '../../../assistant_core/data/repositories/chat_conversation_repository.dart';
import '../../data/models/assistant_context.dart';
import '../../data/services/assistant_context_service.dart';
import '../../data/services/assistant_resume_service.dart';
import '../../data/services/assistant_suggestion_service.dart';
import '../i18n/internal_assistant_i18n.dart';

class InternalAssistantState {
  const InternalAssistantState({
    required this.messages,
    required this.isBotTyping,
    required this.isLoading,
    required this.conversationId,
    required this.errorMessage,
    required this.contextData,
  });

  final List<ChatMessage> messages;
  final bool isBotTyping;
  final bool isLoading;
  final String? conversationId;
  final String? errorMessage;
  final AssistantContext? contextData;

  InternalAssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isBotTyping,
    bool? isLoading,
    String? conversationId,
    String? errorMessage,
    AssistantContext? contextData,
  }) {
    return InternalAssistantState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      errorMessage: errorMessage,
      contextData: contextData ?? this.contextData,
    );
  }

  static const empty = InternalAssistantState(
    messages: <ChatMessage>[],
    isBotTyping: false,
    isLoading: false,
    conversationId: null,
    errorMessage: null,
    contextData: null,
  );
}

final internalAssistantProvider =
    StateNotifierProvider.autoDispose<
      InternalAssistantNotifier,
      InternalAssistantState
    >((ref) {
      return InternalAssistantNotifier(
        repository: ref.read(chatConversationRepositoryProvider),
        contextService: const AssistantContextService(),
        suggestionService: const AssistantSuggestionService(),
        resumeService: const AssistantResumeService(),
      );
    });

class InternalAssistantNotifier extends StateNotifier<InternalAssistantState> {
  InternalAssistantNotifier({
    required ChatConversationRepository repository,
    required AssistantContextService contextService,
    required AssistantSuggestionService suggestionService,
    required AssistantResumeService resumeService,
  }) : _repository = repository,
       _contextService = contextService,
       _suggestionService = suggestionService,
       _resumeService = resumeService,
       super(InternalAssistantState.empty);

  final ChatConversationRepository _repository;
  final AssistantContextService _contextService;
  final AssistantSuggestionService _suggestionService;
  final AssistantResumeService _resumeService;

  Timer? _typingTimer;
  ChatConversationScope? _scope;
  int _idSeq = 0;

  String _nextId() =>
      'internal_${DateTime.now().microsecondsSinceEpoch}_${_idSeq++}';

  Future<void> ensureBootstrapped(
    BuildContext context, {
    AssistantContextSeed? seed,
  }) async {
    if (_scope != null) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    final i18n = InternalAssistantI18n.of(context);
    final contextData = _contextService.resolve(seed: seed);
    final scope = ChatConversationScope(
      mode: ChatExperienceMode.internalAssistant,
      unitId: contextData.unitId ?? 'internal-platform-unit',
      adminUserId: contextData.adminUserId,
      systemKey: contextData.systemKey,
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
          content: _suggestionService.welcomeMessage(
            context: contextData,
            isArabic: i18n.isArabic,
          ),
        );
        messages = [intro];
      }

      state = state.copyWith(
        isLoading: false,
        conversationId: conversationId,
        messages: messages,
        contextData: contextData,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        contextData: contextData,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> sendUserMessage({
    required BuildContext context,
    required String text,
  }) async {
    final trimmed = text.trim();
    final scope = _scope;
    final conversationId = state.conversationId;
    final contextData = state.contextData;
    if (trimmed.isEmpty ||
        scope == null ||
        conversationId == null ||
        contextData == null)
      return;

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

    _typingTimer = Timer(const Duration(milliseconds: 800), () async {
      final i18n = InternalAssistantI18n.of(context);
      final reply = _suggestionService.followupReply(
        context: contextData,
        userMessage: trimmed,
        isArabic: i18n.isArabic,
      );

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

  List<String> resumeHints(BuildContext context) {
    final i18n = InternalAssistantI18n.of(context);
    final contextData = state.contextData;
    if (contextData == null) return const <String>[];
    final item = _resumeService.buildResumeAction(
      contextData,
      isArabic: i18n.isArabic,
    );
    if (item == null) return const <String>[];
    return [item.label];
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
