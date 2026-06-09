import 'package:flutter/material.dart';

class ChatPalette {
  const ChatPalette._();

  static const Color primary = Color(0xFF0D3C61);
  static const Color secondary = Color(0xFFC19A50);
  static const Color royalRed = Color(0xFFB22222);

  static const Color botBubbleBg = Color(0xFFF0F7FF);
  static const Color userBubbleBg = Color(0xFFE3F2FD);
  static const Color panelBg = Color(0xFFF8F9FA);

  static LinearGradient headerGradient() => const LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0D3C61), Color(0xFF1A4D7C)],
  );

  static Color surfaceFor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF0F141A)
        : Colors.white;
  }

  static Color panelFor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? const Color(0xFF121A22) : panelBg;
  }

  static Color bubbleBotFor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF132233)
        : botBubbleBg;
  }

  static Color bubbleUserFor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF0F273A)
        : userBubbleBg;
  }

  static Color borderFor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF263241)
        : const Color(0xFFDDDDDD);
  }

  static Color textOnHeader() => Colors.white;
}
