/// A point-in-time snapshot of a journal entry's text content.
///
/// Every autosave appends a new snapshot. This gives the user an undo
/// history without a separate version-management system.
///
/// MVP: stored in-memory as part of [JournalEntry.snapshots].
/// When the Isar data layer is added, snapshots will be stored as an
/// embedded list (Isar supports embedded objects) or a related collection.
class JournalSnapshot {
  JournalSnapshot({
    required this.body,
    required this.savedAt,
    this.title,
  });

  /// The body text at the time of this save.
  final String body;

  /// The title at the time of this save (null if no title was set).
  final String? title;

  /// When this snapshot was saved.
  final DateTime savedAt;
}

// ---------------------------------------------------------------------------
// Journal entry
// ---------------------------------------------------------------------------

/// A qualitative, freeform health journal entry for a [Profile].
///
/// Content is stored as an append-only list of [JournalSnapshot] objects.
/// The current content is always [snapshots.last]. Undo steps back through
/// the list. This design means the user can never lose text — every autosave
/// is preserved and navigable.
///
/// MVP: plain Dart class, held in memory via [JournalEntryListNotifier].
/// When the Isar data layer is added this will gain `@Collection()`,
/// `@Id()` on [id], and `@Index()` on [profileId] and [createdAt].
/// Field names and types are chosen to be Isar-compatible from the start.
class JournalEntry {
  JournalEntry({
    required this.id,
    required this.profileId,
    required this.createdAt,
    required this.snapshots,
    this.mood,
    this.energyLevel,
  }) : assert(snapshots.isNotEmpty, 'snapshots must not be empty');

  /// Stable local identifier. Isar auto-id when DB is wired.
  final int id;

  /// Foreign key to the owning profile's id.
  final int profileId;

  /// When the entry was first created. Never mutated after initial save.
  final DateTime createdAt;

  /// Ordered list of snapshots, oldest first. Always at least one element.
  ///
  /// New snapshots are appended on each autosave. Undo removes the last
  /// snapshot (never below one). The entry is deleted only by explicit
  /// user action — not by having an empty body.
  final List<JournalSnapshot> snapshots;

  /// Optional mood at time of writing.
  /// Stored as the index of a [JournalMood] value for Isar compatibility.
  final int? mood;

  /// Optional energy level: 1 (exhausted) to 5 (good energy).
  final int? energyLevel;

  // ── Derived from latest snapshot ─────────────────────────────────────────

  /// The current body text (latest snapshot).
  String get body => snapshots.last.body;

  /// The current title (latest snapshot).
  String? get title => snapshots.last.title;

  /// When the content was last saved.
  DateTime get lastSavedAt => snapshots.last.savedAt;

  /// True if the entry has been edited (more than one snapshot exists, or
  /// the single snapshot's savedAt differs from createdAt).
  bool get wasEdited =>
      snapshots.length > 1 ||
      snapshots.first.savedAt != createdAt;

  /// Returns the mood as a typed enum, or null if none was set.
  JournalMood? get moodValue =>
      mood != null ? JournalMood.values[mood!] : null;

  /// Returns the first non-empty line of [body], truncated to 80 characters.
  String get previewText {
    final first = body.split('\n').firstWhere(
      (l) => l.trim().isNotEmpty,
      orElse: () => '',
    );
    if (first.length <= 80) return first;
    return '${first.substring(0, 77)}…';
  }

  /// The display title used in list items.
  String get displayTitle =>
      (title != null && title!.trim().isNotEmpty) ? title! : previewText;

  // ── Snapshot management ───────────────────────────────────────────────────

  /// Returns a new entry with [snapshot] appended to the snapshot list.
  JournalEntry withSnapshot(JournalSnapshot snapshot) {
    return JournalEntry(
      id: id,
      profileId: profileId,
      createdAt: createdAt,
      snapshots: [...snapshots, snapshot],
      mood: mood,
      energyLevel: energyLevel,
    );
  }

  /// Returns a new entry with the last snapshot removed, unless only one
  /// remains (the first snapshot is always preserved).
  ///
  /// Used by the undo action in the composer.
  JournalEntry withUndo() {
    if (snapshots.length <= 1) return this;
    return JournalEntry(
      id: id,
      profileId: profileId,
      createdAt: createdAt,
      snapshots: snapshots.sublist(0, snapshots.length - 1),
      mood: mood,
      energyLevel: energyLevel,
    );
  }

  /// Returns whether an undo is available (more than one snapshot).
  bool get canUndo => snapshots.length > 1;

  // ── Metadata updates ─────────────────────────────────────────────────────

  /// Returns a new entry with only the mood/energy updated (no snapshot change).
  JournalEntry withEnrichment({
    int? mood,
    int? energyLevel,
    bool clearMood = false,
    bool clearEnergyLevel = false,
  }) {
    return JournalEntry(
      id: id,
      profileId: profileId,
      createdAt: createdAt,
      snapshots: snapshots,
      mood: clearMood ? null : (mood ?? this.mood),
      energyLevel: clearEnergyLevel ? null : (energyLevel ?? this.energyLevel),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'JournalEntry(id: $id, profileId: $profileId, snapshots: ${snapshots.length})';
}

// ---------------------------------------------------------------------------
// Mood scale
// ---------------------------------------------------------------------------

/// Five-point mood scale for journal entries.
///
/// Stored as the enum index (int) for Isar compatibility.
enum JournalMood {
  great,     // index 0
  okay,      // index 1
  notGreat,  // index 2
  rough,     // index 3
  terrible,  // index 4
}

extension JournalMoodDisplay on JournalMood {
  String get emoji {
    switch (this) {
      case JournalMood.great:    return '😊';
      case JournalMood.okay:     return '🙂';
      case JournalMood.notGreat: return '😐';
      case JournalMood.rough:    return '😔';
      case JournalMood.terrible: return '😞';
    }
  }

  String get label {
    switch (this) {
      case JournalMood.great:    return 'Great';
      case JournalMood.okay:     return 'Okay';
      case JournalMood.notGreat: return 'Not great';
      case JournalMood.rough:    return 'Rough';
      case JournalMood.terrible: return 'Terrible';
    }
  }
}

// ---------------------------------------------------------------------------
// Id generator
// ---------------------------------------------------------------------------

/// Simple counter for generating unique in-memory ids.
/// Replaced by Isar auto-increment when the database layer is added.
class JournalEntryIdGenerator {
  JournalEntryIdGenerator._();
  static int _next = 1;
  static int next() => _next++;
}
