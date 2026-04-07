import 'package:isar_community/isar.dart';

part 'journal_entry_isar.g.dart';

/// Isar-annotated storage representation of a [JournalSnapshot].
///
/// Stored inline (embedded) within [JournalEntryIsar] — there is no
/// separate Isar collection for snapshots. Isar @embedded requires a
/// default constructor with no required parameters.
@embedded
class JournalSnapshotIsar {
  JournalSnapshotIsar();

  late String body;
  String? title;
  late DateTime savedAt;

}

/// Isar-annotated storage representation of a [JournalEntry].
///
/// The [snapshots] list is an embedded list — all snapshots are
/// serialised inline with the entry. This gives each entry a full
/// autosave history without a separate collection.
///
/// Indexes on [profileId] and [createdAt] support the primary query:
/// load all entries for a profile, sorted reverse-chronologically.
@collection
class JournalEntryIsar {
  /// Auto-increment id assigned by Isar on first [put()].
  Id id = Isar.autoIncrement;

  /// Foreign key to the owning profile's id.
  @Index()
  late int profileId;

  /// When the entry was first created. Never mutated after initial save.
  @Index()
  late DateTime createdAt;

  /// All snapshots, oldest first. Always at least one element.
  late List<JournalSnapshotIsar> snapshots;

  /// Optional mood index (matches [JournalMood.index]).
  int? mood;

  /// Optional energy level: 1 (exhausted) to 5 (good energy).
  int? energyLevel;

}
