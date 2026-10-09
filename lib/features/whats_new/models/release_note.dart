import 'dart:convert';

/// One plain-language highlight in a release: a short title and a sentence
/// or two saying what it means for the person using the app.
class ReleaseHighlight {
  const ReleaseHighlight({required this.title, required this.body});

  final String title;
  final String body;

  factory ReleaseHighlight.fromJson(Map<String, dynamic> json) =>
      ReleaseHighlight(
        title: json['title'] as String,
        body: json['body'] as String,
      );
}

/// One release in What's new, read from the bundled
/// `assets/whats_new/releases.json` (docs/features/whats-new.feature).
///
/// [highlights] are the 2 to 4 notes worth a dashboard card; a release with
/// none (fixes only) is listed in history but never gets a card. [changes]
/// is the full list, shown collapsed under "All changes". [guideId] names a
/// release guide (#145) for releases that move things.
class ReleaseNote {
  const ReleaseNote({
    required this.version,
    this.date,
    this.highlights = const [],
    this.changes = const [],
    this.guideId,
  });

  final String version;

  /// Release date. Null for a release that is being written and hasn't
  /// shipped yet.
  final DateTime? date;
  final List<ReleaseHighlight> highlights;
  final List<String> changes;
  final String? guideId;

  bool get hasHighlights => highlights.isNotEmpty;

  factory ReleaseNote.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String?;
    return ReleaseNote(
      version: json['version'] as String,
      date: date == null ? null : DateTime.parse(date),
      highlights: [
        for (final h in (json['highlights'] as List? ?? const []))
          ReleaseHighlight.fromJson(h as Map<String, dynamic>),
      ],
      changes: [
        for (final c in (json['changes'] as List? ?? const [])) c as String,
      ],
      guideId: json['guideId'] as String?,
    );
  }

  /// Parses the bundled file: `{"releases": [ ... ]}`.
  static List<ReleaseNote> listFromJson(String source) {
    final root = jsonDecode(source) as Map<String, dynamic>;
    return [
      for (final r in root['releases'] as List)
        ReleaseNote.fromJson(r as Map<String, dynamic>),
    ];
  }
}
