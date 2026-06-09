import 'package:flutter/material.dart';

import '../theme/chat_palette.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.hintText,
    this.allowVoiceInteraction = false,
    this.voiceEnabled = false,
    this.ttsEnabled = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.onToggleVoice,
    this.onToggleTts,
    this.onStartListening,
    this.onStopListening,
    this.onStopSpeaking,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: ChatPalette.borderFor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: ChatPalette.borderFor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: ChatPalette.royalRed,
                  width: 1.5,
                ),
              ),
              fillColor: ChatPalette.surfaceFor(context),
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (allowVoiceInteraction) ...[
          _CircleActionButton(
            tooltip: voiceEnabled ? 'إيقاف الصوت' : 'تشغيل الصوت',
            color: voiceEnabled
                ? ChatPalette.royalRed
                : ChatPalette.surfaceFor(context),
            borderColor: ChatPalette.borderFor(context),
            icon: Icons.record_voice_over_rounded,
            iconColor: voiceEnabled
                ? Colors.white
                : Theme.of(context).iconTheme.color,
            onTap: () async => onToggleVoice?.call(),
          ),
          const SizedBox(width: 10),
          _CircleActionButton(
            tooltip: isListening ? 'إيقاف الاستماع' : 'بدء الاستماع',
            color: isListening
                ? ChatPalette.royalRed
                : ChatPalette.surfaceFor(context),
            borderColor: ChatPalette.borderFor(context),
            icon: isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
            iconColor: isListening
                ? Colors.white
                : Theme.of(context).iconTheme.color,
            onTap: () async {
              if (isListening) {
                await onStopListening?.call();
              } else {
                await onStartListening?.call();
              }
            },
          ),
          const SizedBox(width: 10),
          _CircleActionButton(
            tooltip: ttsEnabled ? 'إيقاف النطق' : 'تشغيل النطق',
            color: ttsEnabled
                ? ChatPalette.royalRed
                : ChatPalette.surfaceFor(context),
            borderColor: ChatPalette.borderFor(context),
            icon: ttsEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            iconColor: ttsEnabled
                ? Colors.white
                : Theme.of(context).iconTheme.color,
            onTap: () async => onToggleTts?.call(),
          ),
          if (isSpeaking) ...[
            const SizedBox(width: 10),
            _CircleActionButton(
              tooltip: 'إيقاف الصوت الحالي',
              color: ChatPalette.surfaceFor(context),
              borderColor: ChatPalette.borderFor(context),
              icon: Icons.stop_circle_outlined,
              iconColor: Theme.of(context).iconTheme.color,
              onTap: () async => onStopSpeaking?.call(),
            ),
          ],
          const SizedBox(width: 10),
        ],
        SizedBox(
          width: 50,
          height: 50,
          child: Material(
            color: ChatPalette.royalRed,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.tooltip,
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String tooltip;
  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color? iconColor;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: color,
          shape: CircleBorder(side: BorderSide(color: borderColor)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap == null ? null : () => onTap!(),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
