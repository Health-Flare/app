import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/backup_summary.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';

// docs/features/datastore.feature (#104):
//   "Add missing data" says what it will add before adding it
//   A backup with nothing new says so
//   "Replace everything" says what will replace what

class _FakePathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.root);
  final Directory root;

  @override
  Future<String?> getApplicationDocumentsPath() async => root.path;
  @override
  Future<String?> getTemporaryPath() async => root.path;
  @override
  Future<String?> getApplicationSupportPath() async => root.path;
  @override
  Future<String?> getLibraryPath() async => root.path;
  @override
  Future<String?> getExternalStoragePath() async => null;
  @override
  Future<List<String>?> getExternalCachePaths() async => [];
  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => [];
  @override
  Future<String?> getDownloadsPath() async => null;
  @override
  Future<String?> getApplicationCachePath() async => root.path;
}

void main() {
  late Directory root;
  var n = 0;

  Future<Isar> openDb(String name) async {
    final isar = await Isar.open(
      appSchemas,
      directory: root.path,
      name: '${name}_${n++}',
      inspector: false,
      maxSizeMiB: 64,
    );
    await isar.writeTxn(() => isar.appSettings.put(AppSettings()..id = 1));
    return isar;
  }

  Future<int> addProfile(Isar isar, String name) =>
      isar.writeTxn(() => isar.profileIsars.put(ProfileIsar()..name = name));

  Future<void> addJournal(Isar isar, int profileId, List<int> days) =>
      isar.writeTxn(() async {
        for (final d in days) {
          await isar.journalEntryIsars.put(
            JournalEntryIsar()
              ..profileId = profileId
              ..createdAt = DateTime(2026, 9, d)
              ..snapshots = [
                JournalSnapshotIsar()
                  ..body = 'Day $d'
                  ..savedAt = DateTime(2026, 9, d),
              ],
          );
        }
      });

  Future<void> addSleep(Isar isar, int profileId, List<int> days) =>
      isar.writeTxn(() async {
        for (final d in days) {
          await isar.sleepEntryIsars.put(
            SleepEntryIsar()
              ..profileId = profileId
              ..bedtime = DateTime(2026, 9, d, 23)
              ..wakeTime = DateTime(2026, 9, d + 1, 7)
              ..isNap = false
              ..createdAt = DateTime(2026, 9, d + 1),
          );
        }
      });

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_summary_');
    PathProviderPlatform.instance = _FakePathProvider(root);
  });

  tearDown(() async {
    final open = [
      for (final name in Isar.instanceNames)
        if (Isar.getInstance(name) case final Isar isar) isar,
    ];
    for (final isar in open) {
      if (isar.isOpen) await isar.close(deleteFromDisk: true);
    }
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('ImportService.summarize', () {
    late Isar live;
    late String backupPath;

    setUp(() async {
      // The app: Sarah with journal days 1-2, Leo with journal day 1.
      live = await openDb('live');
      final sarah = await addProfile(live, 'Sarah');
      final leo = await addProfile(live, 'Leo');
      await addJournal(live, sarah, [1, 2]);
      await addJournal(live, leo, [1]);

      // The backup: Sarah has 2 more journal days and 3 nights of sleep,
      // Leo has only what the app has, Mia isn't in the app.
      final source = await openDb('source');
      final bSarah = await addProfile(source, 'Sarah');
      final bLeo = await addProfile(source, 'Leo');
      final bMia = await addProfile(source, 'Mia');
      await addJournal(source, bSarah, [1, 2, 3, 4]);
      await addSleep(source, bSarah, [1, 2, 3]);
      await addJournal(source, bLeo, [1]);
      await addJournal(source, bMia, [5, 6]);
      backupPath = await BackupService.export(source);
    });

    BackupProfileSummary named(BackupSummary s, String name) =>
        s.profiles.firstWhere((p) => p.name == name);

    test('lists every profile in the backup, in its order', () async {
      final s = await ImportService.summarize(backupPath, live);
      expect(s.profiles.map((p) => p.name), ['Sarah', 'Leo', 'Mia']);
    });

    test('counts only what is not already in the app', () async {
      final s = await ImportService.summarize(backupPath, live);
      final sarah = named(s, 'Sarah');
      expect(sarah.isNew, isFalse);
      expect(sarah.newCounts, {
        ImportCategoryId.journal: 2,
        ImportCategoryId.sleep: 3,
      });
    });

    test('a profile with everything already here has nothing new', () async {
      final s = await ImportService.summarize(backupPath, live);
      expect(named(s, 'Leo').hasNothingNew, isTrue);
    });

    test(
      "a profile the app doesn't have is new, with all its entries",
      () async {
        final s = await ImportService.summarize(backupPath, live);
        final mia = named(s, 'Mia');
        expect(mia.isNew, isTrue);
        expect(mia.newCounts, {ImportCategoryId.journal: 2});
      },
    );

    test('gives each profile its total entries, for Replace', () async {
      final s = await ImportService.summarize(backupPath, live);
      expect(named(s, 'Sarah').entryCount, 7);
      expect(named(s, 'Leo').entryCount, 1);
      expect(named(s, 'Mia').entryCount, 2);
    });

    test('changes nothing in the app', () async {
      await ImportService.summarize(backupPath, live);
      expect(await live.profileIsars.count(), 2);
      expect(await live.journalEntryIsars.count(), 3);
      expect(await live.sleepEntryIsars.count(), 0);
    });

    test('a backup of what the app already has has nothing new', () async {
      // export writes to one temp name: clear the setUp's file first.
      File(backupPath).deleteSync();
      final copy = await BackupService.export(live);
      final s = await ImportService.summarize(copy, live);
      expect(s.profiles, hasLength(2));
      expect(s.hasNothingNew, isTrue);
    });
  });

  group('confirmation lines', () {
    test('lists what would be added, short nouns', () {
      expect(
        backupAddLine(
          const BackupProfileSummary(
            name: 'Sarah',
            newCounts: {
              ImportCategoryId.symptomEntries: 12,
              ImportCategoryId.doseLogs: 3,
            },
          ),
        ),
        'Sarah: 12 symptoms, 3 doses',
      );
    });

    test('one of something is singular', () {
      expect(
        backupAddLine(
          const BackupProfileSummary(
            name: 'Sarah',
            newCounts: {ImportCategoryId.doseLogs: 1},
          ),
        ),
        'Sarah: 1 dose',
      );
    });

    test('says when a profile has nothing new', () {
      expect(
        backupAddLine(const BackupProfileSummary(name: 'Leo')),
        'Leo: nothing new',
      );
    });

    test('marks a profile the app does not have yet', () {
      expect(
        backupAddLine(
          const BackupProfileSummary(
            name: 'Mia',
            isNew: true,
            newCounts: {ImportCategoryId.journal: 2},
          ),
        ),
        'Mia (new profile): 2 journal entries',
      );
    });

    test('Replace gives the entry count', () {
      expect(
        backupEntriesLine(
          const BackupProfileSummary(name: 'Sarah', entryCount: 15),
        ),
        'Sarah: 15 entries',
      );
      expect(
        backupEntriesLine(
          const BackupProfileSummary(name: 'Leo', entryCount: 1),
        ),
        'Leo: 1 entry',
      );
    });
  });
}
