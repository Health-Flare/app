import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/models/journal_entry.dart';

Future<Isar> _openIsar() async {
  return Isar.open(
    [JournalEntryIsarSchema, SymptomEntryIsarSchema],
    directory: '',
    name: 'move_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  test(
    'moveToProfile reassigns a journal entry, keeping its content',
    () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(journalEntryListProvider.notifier);
      final createdAt = DateTime(2026, 7, 1, 8, 30);
      final id = await notifier.add(
        profileId: 1,
        createdAt: createdAt,
        firstSnapshot: JournalSnapshot(
          body: 'Rough morning for Ethan',
          savedAt: createdAt,
        ),
      );

      await notifier.moveToProfile(id, 2);

      final row = await isar.journalEntryIsars.get(id);
      expect(row, isNotNull);
      expect(row!.profileId, 2);
      expect(row.createdAt, createdAt);
      expect(row.snapshots.single.body, 'Rough morning for Ethan');
    },
  );

  test('moveToProfile clears the flare link on a symptom entry', () async {
    final isar = await _openIsar();
    addTearDown(() => isar.close(deleteFromDisk: true));
    final container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(symptomEntryListProvider.notifier);
    final loggedAt = DateTime(2026, 7, 1, 19, 15);
    final id = await notifier.add(
      profileId: 1,
      name: 'Sore knee after walking',
      severity: 6,
      loggedAt: loggedAt,
      flareIsarId: 42,
    );

    await notifier.moveToProfile(id, 2);

    final row = await isar.symptomEntryIsars.get(id);
    expect(row, isNotNull);
    expect(row!.profileId, 2);
    expect(
      row.flareIsarId,
      isNull,
      reason: 'flares belong to the source profile',
    );
    expect(row.loggedAt, loggedAt);
    expect(row.name, 'Sore knee after walking');
  });

  test('moveToProfile on a missing id is a no-op', () async {
    final isar = await _openIsar();
    addTearDown(() => isar.close(deleteFromDisk: true));
    final container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(journalEntryListProvider.notifier);
    await notifier.moveToProfile(9999, 2);

    expect(await isar.journalEntryIsars.count(), 0);
  });
}
