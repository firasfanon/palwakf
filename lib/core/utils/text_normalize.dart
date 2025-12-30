/// Normalizes content coming from the database that may include HTML entities,
/// BOM markers or bidi control characters.
///
/// الهدف: منع ظهور "أحرف غريبة" في الواجهة (خاصة على الويب) عند عرض النصوص.
import 'dart:convert';

String normalizeRichText(String input) {
  var s = input;

  // Heuristic: fix common mojibake where UTF-8 bytes were stored/displayed as Latin-1.
  // Example symptoms: "Ø§Ù„..." or "Ã" sequences.
  s = _tryFixMojibake(s);

  // BOM / encoding leftovers
  s = s.replaceAll('ï»¿', '');

  // NBSP (actual char)
  s = s.replaceAll('\u00A0', ' ');

  // Common HTML entities
  s = s.replaceAll('&nbsp;', ' ');
  s = s.replaceAll('&amp;', '&');
  s = s.replaceAll('&quot;', '"');
  s = s.replaceAll('&#39;', "'");
  s = s.replaceAll('&lt;', '<');
  s = s.replaceAll('&gt;', '>');

  // Numeric entities: &#160;
  s = s.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
    final code = int.tryParse(m.group(1) ?? '');
    return code == null ? m.group(0)! : String.fromCharCode(code);
  });

  // Remove HTML tags (keep text only)
  s = s.replaceAll(RegExp(r'<[^>]+>'), ' ');

  // Bidi / zero-width marks
  s = s.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069]'), '');

  // Normalize whitespace
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

String _tryFixMojibake(String s) {
  // Quick check to avoid unnecessary work
  final looksLikeMojibake = RegExp(r'[ÃÂØÙ]').hasMatch(s);
  if (!looksLikeMojibake) return s;

  try {
    final bytes = latin1.encode(s);
    final decoded = utf8.decode(bytes, allowMalformed: true);

    // Prefer the decoded string if it has noticeably more Arabic characters
    final a1 = _arabicCount(s);
    final a2 = _arabicCount(decoded);
    if (a2 > a1) return decoded;
  } catch (_) {
    // ignore
  }

  return s;
}

int _arabicCount(String s) {
  var count = 0;
  for (final rune in s.runes) {
    if (rune >= 0x0600 && rune <= 0x06FF) count++;
  }
  return count;
}
