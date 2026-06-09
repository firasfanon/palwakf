import 'package:flutter/material.dart';

import '../../data/models/chat_experience_mode.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/feature_card_item.dart';
import '../../data/models/quick_action_item.dart';
import '../services/voice/voice_service.dart';
import '../theme/chat_palette.dart';
import 'chat_header.dart';
import 'chat_input_bar.dart';
import 'chat_message_bubble.dart';
import 'features_grid.dart';
import 'quick_actions_bar.dart';

class ChatShell extends StatefulWidget {
  const ChatShell({
    super.key,
    required this.pageTitle,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.headerIcon,
    required this.mode,
    required this.messages,
    required this.isBotTyping,
    required this.inputHint,
    required this.onSend,
    required this.onQuickAction,
    required this.quickActions,
    required this.featureItems,
    this.onFeatureTap,
    this.errorMessage,
    this.topContent,
    this.bottomContent,
    this.controller,
    this.embedInParent = false,
    this.allowVoiceInteraction = false,
    this.showHeader = true,
  });

  final String pageTitle;
  final String headerTitle;
  final String headerSubtitle;
  final IconData headerIcon;
  final ChatExperienceMode mode;
  final List<ChatMessage> messages;
  final bool isBotTyping;
  final String inputHint;
  final Future<void> Function(String text) onSend;
  final void Function(QuickActionItem action) onQuickAction;
  final List<QuickActionItem> quickActions;
  final List<FeatureCardItem> featureItems;
  final void Function(FeatureCardItem item)? onFeatureTap;
  final String? errorMessage;
  final Widget? topContent;
  final Widget? bottomContent;
  final TextEditingController? controller;
  final bool embedInParent;
  final bool allowVoiceInteraction;
  final bool showHeader;

  @override
  State<ChatShell> createState() => _ChatShellState();
}

class _ChatShellState extends State<ChatShell> {
  late final ScrollController _scrollController;
  late final TextEditingController _inputController;
  late final VoiceService _voice;

  bool _ttsEnabled = false;
  bool _voiceEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _voiceError;
  String? _lastSpokenMessageId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _inputController = widget.controller ?? TextEditingController();
    _voice = createVoiceService();
  }

  @override
  void didUpdateWidget(covariant ChatShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length ||
        oldWidget.isBotTyping != widget.isBotTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    if (widget.allowVoiceInteraction &&
        _voiceEnabled &&
        _ttsEnabled &&
        widget.messages.isNotEmpty &&
        oldWidget.messages.length != widget.messages.length) {
      final last = widget.messages.last;
      if (last.isBot && last.id != _lastSpokenMessageId) {
        _lastSpokenMessageId = last.id;
        _speak(last.text);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (widget.controller == null) {
      _inputController.dispose();
    }
    if (widget.allowVoiceInteraction) {
      _voice.stopListening();
      _voice.stopSpeaking();
    }
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    FocusScope.of(context).unfocus();
    await widget.onSend(text);
  }

  String _languageTag(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    if (locale == null) return 'ar-PS';
    try {
      final tag = (locale as dynamic).toLanguageTag() as String?;
      if (tag != null && tag.isNotEmpty) return tag;
    } catch (_) {
      // ignore
    }
    return locale.languageCode;
  }

  Future<void> _toggleVoice() async {
    if (!widget.allowVoiceInteraction) return;
    final enabled = !_voiceEnabled;
    setState(() {
      _voiceEnabled = enabled;
      _ttsEnabled = enabled
          ? (_ttsEnabled || _voice.isTextToSpeechSupported)
          : false;
      _voiceError = null;
    });
    if (!enabled) {
      await _stopListening();
      await _stopSpeaking();
    }
  }

  Future<void> _toggleTts() async {
    if (!widget.allowVoiceInteraction) return;
    setState(() {
      _ttsEnabled = !_ttsEnabled;
      _voiceError = null;
    });
    if (!_ttsEnabled) {
      await _stopSpeaking();
    }
  }

  Future<void> _startListening() async {
    if (!widget.allowVoiceInteraction) return;
    if (!_voice.isSpeechRecognitionSupported) {
      setState(
        () => _voiceError = 'التعرّف على الصوت غير مدعوم في هذا المتصفح.',
      );
      return;
    }
    final lang = _languageTag(context);
    setState(() {
      _voiceEnabled = true;
      _ttsEnabled = _ttsEnabled || _voice.isTextToSpeechSupported;
      _voiceError = null;
      _isListening = true;
    });
    await _voice.startListening(
      languageTag: lang,
      onPartial: (partial) {
        _inputController.value = TextEditingValue(
          text: partial,
          selection: TextSelection.collapsed(offset: partial.length),
        );
      },
      onFinal: (finalText) {
        _inputController.value = TextEditingValue(
          text: finalText,
          selection: TextSelection.collapsed(offset: finalText.length),
        );
        Future.microtask(() async {
          if (!mounted) return;
          if (finalText.trim().isEmpty) {
            setState(() => _isListening = false);
            return;
          }
          await _stopListening();
          await _handleSend();
        });
      },
      onError: (_) {
        setState(() {
          _voiceError = 'تعذر تشغيل الصوت. تأكد من إذن الميكروفون.';
          _isListening = false;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    if (!widget.allowVoiceInteraction) return;
    await _voice.stopListening();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _speak(String text) async {
    if (!widget.allowVoiceInteraction) return;
    if (!_voice.isTextToSpeechSupported) return;
    final lang = _languageTag(context);
    setState(() {
      _isSpeaking = true;
      _voiceEnabled = true;
    });
    await _voice.speak(text: text, languageTag: lang);
    if (mounted) {
      setState(() => _isSpeaking = _voice.isSpeaking);
    }
  }

  Future<void> _stopSpeaking() async {
    if (!widget.allowVoiceInteraction) return;
    await _voice.stopSpeaking();
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, widget.embedInParent ? 24 : 20, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHeader)
                ChatHeader(
                  title: widget.headerTitle,
                  subtitle: widget.headerSubtitle,
                  icon: widget.headerIcon,
                  mode: widget.mode,
                ),
              if (widget.topContent != null)
                _PanelSection(noTopRadius: true, child: widget.topContent!),
              if (widget.errorMessage != null)
                _PanelSection(
                  noTopRadius: widget.topContent != null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ChatPalette.surfaceFor(context),
                      border: Border.all(color: ChatPalette.royalRed),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ChatPalette.royalRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (_voiceError != null)
                _PanelSection(
                  noTopRadius:
                      widget.topContent != null || widget.errorMessage != null,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ChatPalette.surfaceFor(context),
                      border: Border.all(color: ChatPalette.borderFor(context)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _voiceError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              _ChatPanel(
                messages: widget.messages,
                isBotTyping: widget.isBotTyping,
                scrollController: _scrollController,
              ),
              _InputPanel(
                inputController: _inputController,
                inputHint: widget.inputHint,
                onSend: _handleSend,
                onQuickAction: widget.onQuickAction,
                quickActions: widget.quickActions,
                allowVoiceInteraction: widget.allowVoiceInteraction,
                voiceEnabled: _voiceEnabled,
                ttsEnabled: _ttsEnabled,
                isListening: _isListening,
                isSpeaking: _isSpeaking,
                onToggleVoice: _toggleVoice,
                onToggleTts: _toggleTts,
                onStartListening: _startListening,
                onStopListening: _stopListening,
                onStopSpeaking: _stopSpeaking,
              ),
              if (widget.bottomContent != null) ...[
                const SizedBox(height: 20),
                widget.bottomContent!,
              ],
              const SizedBox(height: 24),
              FeaturesGrid(
                items: widget.featureItems,
                onTap: widget.onFeatureTap,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedInParent) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.pageTitle)),
      body: body,
    );
  }
}

class _PanelSection extends StatelessWidget {
  const _PanelSection({required this.child, this.noTopRadius = false});

  final Widget child;
  final bool noTopRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: ChatPalette.surfaceFor(context),
        border: Border(
          left: BorderSide(color: ChatPalette.borderFor(context)),
          right: BorderSide(color: ChatPalette.borderFor(context)),
        ),
        borderRadius: noTopRadius
            ? null
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    );
  }
}

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.messages,
    required this.isBotTyping,
    required this.scrollController,
  });

  final List<ChatMessage> messages;
  final bool isBotTyping;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).width < 900 ? 420 : 520,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ChatPalette.panelFor(context),
        border: Border(
          left: BorderSide(color: ChatPalette.borderFor(context)),
          right: BorderSide(color: ChatPalette.borderFor(context)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bubbleMaxWidth = constraints.maxWidth * 0.82;

          return ListView.separated(
            controller: scrollController,
            itemCount: messages.length + (isBotTyping ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (isBotTyping && index == messages.length) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ChatPalette.bubbleBotFor(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(5),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: const _TypingDots(),
                  ),
                );
              }

              final message = messages[index];
              return ChatMessageBubble(
                message: message,
                maxWidth: bubbleMaxWidth,
              );
            },
          );
        },
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  const _InputPanel({
    required this.inputController,
    required this.inputHint,
    required this.onSend,
    required this.onQuickAction,
    required this.quickActions,
    required this.allowVoiceInteraction,
    required this.voiceEnabled,
    required this.ttsEnabled,
    required this.isListening,
    required this.isSpeaking,
    this.onToggleVoice,
    this.onToggleTts,
    this.onStartListening,
    this.onStopListening,
    this.onStopSpeaking,
  });

  final TextEditingController inputController;
  final String inputHint;
  final VoidCallback onSend;
  final void Function(QuickActionItem action) onQuickAction;
  final List<QuickActionItem> quickActions;
  final bool allowVoiceInteraction;
  final bool voiceEnabled;
  final bool ttsEnabled;
  final bool isListening;
  final bool isSpeaking;
  final Future<void> Function()? onToggleVoice;
  final Future<void> Function()? onToggleTts;
  final Future<void> Function()? onStartListening;
  final Future<void> Function()? onStopListening;
  final Future<void> Function()? onStopSpeaking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ChatPalette.surfaceFor(context),
        border: Border.all(color: ChatPalette.borderFor(context)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          ChatInputBar(
            controller: inputController,
            onSend: onSend,
            hintText: inputHint,
            allowVoiceInteraction: allowVoiceInteraction,
            voiceEnabled: voiceEnabled,
            ttsEnabled: ttsEnabled,
            isListening: isListening,
            isSpeaking: isSpeaking,
            onToggleVoice: onToggleVoice,
            onToggleTts: onToggleTts,
            onStartListening: onStartListening,
            onStopListening: onStopListening,
            onStopSpeaking: onStopSpeaking,
          ),
          const SizedBox(height: 14),
          QuickActionsBar(actions: quickActions, onTap: onQuickAction),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = (_controller.value * 3).floor() % 3;
        final dots = value == 0 ? '.' : (value == 1 ? '..' : '...');
        return Text(dots, style: textStyle);
      },
    );
  }
}
