import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/chat_message.dart';
import '../theme/chat_palette.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.maxWidth,
  });

  final ChatMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    final bubbleBg = isBot
        ? ChatPalette.bubbleBotFor(context)
        : ChatPalette.bubbleUserFor(context);

    final alignment = isBot ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isBot ? 20 : 5),
      bottomRight: Radius.circular(isBot ? 5 : 20),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: isBot
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: bubbleBg, borderRadius: radius),
              child: _RichTextMarkdownLinks(
                text: message.text,
                style: Theme.of(context).textTheme.bodyMedium,
                linkStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ChatPalette.royalRed,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w700,
                ),
                onLinkTap: (url) => _handleLink(context, url),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: const Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static void _handleLink(BuildContext context, String url) {
    if (url.startsWith('/')) {
      context.go(url);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(url)));
  }
}

class _RichTextMarkdownLinks extends StatelessWidget {
  const _RichTextMarkdownLinks({
    required this.text,
    required this.style,
    required this.linkStyle,
    required this.onLinkTap,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;
  final void Function(String url) onLinkTap;

  static final RegExp _mdLink = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];

    int cursor = 0;
    final matches = _mdLink.allMatches(text).toList();
    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      final label = match.group(1) ?? '';
      final url = match.group(2) ?? '';
      spans.add(
        TextSpan(
          text: label,
          style: linkStyle,
          recognizer: TapGestureRecognizer()..onTap = () => onLinkTap(url),
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    final raw = spans.isEmpty ? [TextSpan(text: text, style: style)] : spans;

    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(style: style, children: raw),
    );
  }
}
