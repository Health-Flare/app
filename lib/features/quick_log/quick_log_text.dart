/// Word-boundary helpers for the offline quick-log classifier and parser.
///
/// A keyword matches at a word start, plus a short inflection suffix
/// (`s`, `es`, `d`, `ed`), so "ache" matches "aches" and "tablet" matches
/// "tablets" without "ate" matching "late" or "grateful".
abstract final class QuickLogText {
  static const _suffix = '(?:s|es|d|ed)?';

  static bool mentions(String text, String keyword) {
    final pattern = _pattern(keyword);
    if (pattern == null) return false;
    return RegExp(pattern, caseSensitive: false).hasMatch(text);
  }

  static bool mentionsAny(String text, Iterable<String> keywords) =>
      keywords.any((keyword) => mentions(text, keyword));

  /// True when [keyword] is negated within about three words before it
  /// ("no pain", "not feeling dizzy", "without any nausea", "didn't take").
  static bool isNegated(String text, String keyword) {
    final body = _body(keyword);
    if (body == null) return false;
    return RegExp(
      "\\b(?:no|not|without|zero|never|didn'?t|don'?t|wasn'?t|isn'?t|"
      "haven'?t|hasn'?t|hadn'?t|free\\s+of)\\b"
      '(?:\\s+\\w+){0,3}\\s+$body$_suffix\\b',
      caseSensitive: false,
    ).hasMatch(text);
  }

  /// A mention that is present and not negated.
  static bool mentionsAffirmative(String text, String keyword) =>
      mentions(text, keyword) && !isNegated(text, keyword);

  static bool mentionsAnyAffirmative(String text, Iterable<String> keywords) =>
      keywords.any((keyword) => mentionsAffirmative(text, keyword));

  static String? _pattern(String keyword) {
    final body = _body(keyword);
    if (body == null) return null;
    return '\\b$body$_suffix\\b';
  }

  static String? _body(String keyword) {
    final trimmed = keyword.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    return trimmed.split(RegExp(r'\s+')).map(RegExp.escape).join(r'\s+');
  }
}
