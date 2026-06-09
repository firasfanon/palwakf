import 'package:flutter/foundation.dart';

enum ChatSender { bot, user }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final ChatSender sender;
  final String text;
  final DateTime createdAt;

  bool get isBot => sender == ChatSender.bot;
}
