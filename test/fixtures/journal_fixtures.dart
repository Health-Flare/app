import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/models/journal_entry.dart';

/// Test fixtures for JournalEntry-related data.
class JournalFixtures {
  JournalFixtures._();

  static JournalSnapshot _snapshot(String body, DateTime savedAt) =>
      JournalSnapshot(body: body, savedAt: savedAt);

  static JournalSnapshotIsar _snapshotIsar(String body, DateTime savedAt) =>
      JournalSnapshotIsar()
        ..body = body
        ..savedAt = savedAt;

  /// A simple journal entry with minimal data.
  static JournalEntry get simple => JournalEntry(
        id: 1,
        profileId: 1,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        snapshots: [_snapshot('Feeling okay today.', DateTime(2024, 1, 15, 10, 30))],
      );

  /// A complete journal entry with all fields.
  static JournalEntry get complete => JournalEntry(
        id: 2,
        profileId: 1,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        snapshots: [
          _snapshot('Had a great day! Energy levels were high.', DateTime(2024, 1, 15, 10, 30)),
          _snapshot('Had a great day! Energy levels were high. Updated.', DateTime(2024, 1, 15, 14, 0)),
        ],
        mood: 4,
        energyLevel: 5,
      );

  /// Multiple entries for testing lists and filtering.
  static List<JournalEntry> get multipleEntries => [
        JournalEntry(
          id: 1,
          profileId: 1,
          createdAt: DateTime(2024, 1, 15, 8, 0),
          snapshots: [_snapshot('Morning entry.', DateTime(2024, 1, 15, 8, 0))],
          mood: 3,
        ),
        JournalEntry(
          id: 2,
          profileId: 1,
          createdAt: DateTime(2024, 1, 15, 14, 0),
          snapshots: [_snapshot('Afternoon entry.', DateTime(2024, 1, 15, 14, 0))],
          mood: 4,
          energyLevel: 4,
        ),
        JournalEntry(
          id: 3,
          profileId: 1,
          createdAt: DateTime(2024, 1, 15, 20, 0),
          snapshots: [_snapshot('Evening entry.', DateTime(2024, 1, 15, 20, 0))],
          mood: 5,
          energyLevel: 3,
        ),
      ];

  /// Entries for different profiles.
  static List<JournalEntry> get multiProfileEntries => [
        JournalEntry(
          id: 1,
          profileId: 1,
          createdAt: DateTime(2024, 1, 15, 10, 0),
          snapshots: [_snapshot('Sarah entry 1.', DateTime(2024, 1, 15, 10, 0))],
        ),
        JournalEntry(
          id: 2,
          profileId: 1,
          createdAt: DateTime(2024, 1, 16, 10, 0),
          snapshots: [_snapshot('Sarah entry 2.', DateTime(2024, 1, 16, 10, 0))],
        ),
        JournalEntry(
          id: 3,
          profileId: 2,
          createdAt: DateTime(2024, 1, 15, 11, 0),
          snapshots: [_snapshot('Dad entry 1.', DateTime(2024, 1, 15, 11, 0))],
        ),
      ];

  /// Journal entry Isar models for database seeding.
  static JournalEntryIsar get simpleIsar => JournalEntryIsar()
    ..id = 1
    ..profileId = 1
    ..createdAt = DateTime(2024, 1, 15, 10, 30)
    ..snapshots = [_snapshotIsar('Feeling okay today.', DateTime(2024, 1, 15, 10, 30))];

  static List<JournalEntryIsar> get multipleEntriesIsar => [
        JournalEntryIsar()
          ..id = 1
          ..profileId = 1
          ..createdAt = DateTime(2024, 1, 15, 8, 0)
          ..snapshots = [_snapshotIsar('Morning entry.', DateTime(2024, 1, 15, 8, 0))]
          ..mood = 3,
        JournalEntryIsar()
          ..id = 2
          ..profileId = 1
          ..createdAt = DateTime(2024, 1, 15, 14, 0)
          ..snapshots = [_snapshotIsar('Afternoon entry.', DateTime(2024, 1, 15, 14, 0))]
          ..mood = 4
          ..energyLevel = 4,
        JournalEntryIsar()
          ..id = 3
          ..profileId = 1
          ..createdAt = DateTime(2024, 1, 15, 20, 0)
          ..snapshots = [_snapshotIsar('Evening entry.', DateTime(2024, 1, 15, 20, 0))]
          ..mood = 5
          ..energyLevel = 3,
      ];
}
