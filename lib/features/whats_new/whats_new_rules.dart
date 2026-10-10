import 'package:health_flare/features/whats_new/models/release_note.dart';

/// The rules for when a What's new card shows. Pure functions, so every
/// caller (dashboard, settings, startup) agrees.
/// Spec: docs/features/whats-new.feature.

/// A card nobody opens or dismisses goes away after this many app opens
/// where it was actually shown.
const kReleaseCardMaxOpens = 5;

/// Version used as the starting point when nothing was ever recorded.
const kNoVersion = '0.0.0';

/// Compares `major.minor.patch` versions, ignoring any `+build` or
/// `-pre` suffix. Missing parts count as 0.
int compareVersions(String a, String b) {
  List<int> parts(String v) {
    final core = v.split('+').first.split('-').first.trim();
    final nums = [for (final p in core.split('.')) int.tryParse(p) ?? 0];
    while (nums.length < 3) {
      nums.add(0);
    }
    return nums;
  }

  final pa = parts(a);
  final pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final c = pa[i].compareTo(pb[i]);
    if (c != 0) return c;
  }
  return 0;
}

String _newer(String a, String b) => compareVersions(a, b) >= 0 ? a : b;

/// Releases up to and including [installed], newest first. A bundled entry
/// for a version that hasn't shipped yet is never listed.
List<ReleaseNote> releasesUpTo(List<ReleaseNote> releases, String installed) {
  return [
    for (final r in releases)
      if (compareVersions(r.version, installed) <= 0) r,
  ]..sort((a, b) => compareVersions(b.version, a.version));
}

/// Releases with highlights newer than [lastSeen] and no newer than
/// [installed], newest first. Empty means no card.
List<ReleaseNote> cardReleases({
  required List<ReleaseNote> releases,
  required String lastSeen,
  required String installed,
}) {
  return [
    for (final r in releasesUpTo(releases, installed))
      if (r.hasHighlights && compareVersions(r.version, lastSeen) > 0) r,
  ];
}

/// What is stored on this device about What's new (AppSettings).
class WhatsNewRecord {
  const WhatsNewRecord({
    this.lastSeenVersion,
    this.highlightsOff = false,
    this.cardVersion,
    this.cardShownCount = 0,
  });

  /// Newest version whose card was dismissed, opened, expired or skipped.
  /// Null until the first launch that has What's new.
  final String? lastSeenVersion;
  final bool highlightsOff;

  /// Newest version the pending card covers, so the open count resets when
  /// a newer release joins the card.
  final String? cardVersion;
  final int cardShownCount;

  WhatsNewRecord copyWith({
    String? lastSeenVersion,
    bool? highlightsOff,
    String? cardVersion,
    bool clearCardVersion = false,
    int? cardShownCount,
  }) => WhatsNewRecord(
    lastSeenVersion: lastSeenVersion ?? this.lastSeenVersion,
    highlightsOff: highlightsOff ?? this.highlightsOff,
    cardVersion: clearCardVersion ? null : (cardVersion ?? this.cardVersion),
    cardShownCount: cardShownCount ?? this.cardShownCount,
  );

  @override
  bool operator ==(Object other) =>
      other is WhatsNewRecord &&
      other.lastSeenVersion == lastSeenVersion &&
      other.highlightsOff == highlightsOff &&
      other.cardVersion == cardVersion &&
      other.cardShownCount == cardShownCount;

  @override
  int get hashCode =>
      Object.hash(lastSeenVersion, highlightsOff, cardVersion, cardShownCount);

  @override
  String toString() =>
      'WhatsNewRecord(lastSeen: $lastSeenVersion, off: $highlightsOff, '
      'card: $cardVersion, shown: $cardShownCount)';
}

/// Settles the stored record at app launch:
///
/// - First launch with What's new: a fresh install ([hasProfiles] false)
///   starts at [installed], so it never gets a card. Someone who used the
///   app before starts at the previous bundled release, so they get one
///   card for this version's highlights.
/// - Highlights off: everything up to [installed] counts as seen, so
///   turning them back on never brings back a missed card.
/// - A card shown on [kReleaseCardMaxOpens] opens expires.
/// - Installing an older version never moves [WhatsNewRecord.lastSeenVersion]
///   back.
WhatsNewRecord settleLaunch({
  required WhatsNewRecord record,
  required List<ReleaseNote> releases,
  required String installed,
  required bool hasProfiles,
}) {
  var r = record;

  if (r.lastSeenVersion == null) {
    String start = installed;
    if (hasProfiles) {
      final older = [
        for (final n in releasesUpTo(releases, installed))
          if (compareVersions(n.version, installed) < 0) n.version,
      ];
      start = older.isEmpty ? kNoVersion : older.first;
    }
    r = r.copyWith(lastSeenVersion: start);
  }

  if (r.highlightsOff) return markSeen(r, installed);

  final pending = cardReleases(
    releases: releases,
    lastSeen: r.lastSeenVersion!,
    installed: installed,
  );
  if (pending.isEmpty) {
    return r.cardVersion == null && r.cardShownCount == 0
        ? r
        : r.copyWith(clearCardVersion: true, cardShownCount: 0);
  }

  final newest = pending.first.version;
  if (r.cardVersion != newest) {
    return r.copyWith(cardVersion: newest, cardShownCount: 0);
  }
  if (r.cardShownCount >= kReleaseCardMaxOpens) return markSeen(r, installed);
  return r;
}

/// The record after the card is dismissed or opened: final for every
/// release up to [installed].
WhatsNewRecord markSeen(WhatsNewRecord record, String installed) {
  final last = record.lastSeenVersion;
  return record.copyWith(
    lastSeenVersion: last == null ? installed : _newer(last, installed),
    clearCardVersion: true,
    cardShownCount: 0,
  );
}
