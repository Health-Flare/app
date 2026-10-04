import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/elimination_entry_isar.dart';
import 'package:health_flare/data/models/fluid_intake_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';

// docs/features/datastore.feature, "Safety copy before an upgrade" (#110).

class _FakePathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider({required this.tempDir, required this.docsDir});

  final Directory tempDir;
  final Directory docsDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => docsDir.path;
  @override
  Future<String?> getTemporaryPath() async => tempDir.path;
  @override
  Future<String?> getApplicationSupportPath() async => docsDir.path;
  @override
  Future<String?> getLibraryPath() async => docsDir.path;
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
  Future<String?> getApplicationCachePath() async => tempDir.path;
}

const _schemas = [
  ProfileIsarSchema,
  JournalEntryIsarSchema,
  AppSettingsSchema,
  ConditionIsarSchema,
  UserConditionIsarSchema,
  SymptomIsarSchema,
  UserSymptomIsarSchema,
  SleepEntryIsarSchema,
  SymptomEntryIsarSchema,
  VitalEntryIsarSchema,
  MedicationIsarSchema,
  DoseLogIsarSchema,
  MealEntryIsarSchema,
  FlareIsarSchema,
  DailyCheckinIsarSchema,
  AppointmentIsarSchema,
  ActivityEntryIsarSchema,
  FluidIntakeIsarSchema,
  EliminationEntryIsarSchema,
];

Future<Isar> _open(String dir, {String name = 'healthflare'}) =>
    Isar.open(_schemas, directory: dir, name: name);

/// Puts the database on schema [version] with one profile ("Sarah", one
/// journal entry) and one journal entry left behind by a deleted profile,
/// which the v18 migration removes.
Future<void> _seedOldVersion(Isar isar, {int version = 17}) async {
  await isar.writeTxn(() async {
    await isar.appSettings.put(
      AppSettings()
        ..id = 1
        ..schemaVersion = version,
    );
    final sarah = ProfileIsar()..name = 'Sarah';
    final id = await isar.profileIsars.put(sarah);
    await isar.journalEntryIsars.put(_entry(id, 'Rough morning'));
    await isar.journalEntryIsars.put(_entry(id + 999, 'Orphaned note'));
  });
}

JournalEntryIsar _entry(int profileId, String body) {
  final now = DateTime.utc(2026, 9, 1);
  return JournalEntryIsar()
    ..profileId = profileId
    ..createdAt = now
    ..snapshots = [
      JournalSnapshotIsar()
        ..body = body
        ..savedAt = now,
    ];
}

Future<List<String>> _bodies(Isar isar) async {
  final rows = await isar.journalEntryIsars.where().findAll();
  return rows.map((r) => r.snapshots.last.body).toList()..sort();
}

List<File> _snapshotFiles(String docs) {
  final dir = Directory('$docs/${PreMigrationSnapshot.directoryName}');
  if (!dir.existsSync()) return [];
  return dir
      .listSync()
      .whereType<File>()
      .where((f) => !_name(f).startsWith('.'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String _name(File f) => f.uri.pathSegments.last;

void main() {
  late Directory root;
  late Directory docs;
  late Directory tmp;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_snapshot_test_');
    docs = Directory('${root.path}/docs')..createSync();
    tmp = Directory('${root.path}/tmp')..createSync();
    PathProviderPlatform.instance = _FakePathProvider(
      tempDir: tmp,
      docsDir: docs,
    );
  });

  tearDown(() async {
    for (final isar
        in Isar.instanceNames.map(Isar.getInstance).whereType<Isar>()) {
      if (isar.isOpen) await isar.close();
    }
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  final fixedNow = DateTime.utc(2026, 10, 4, 6, 30, 15);

  group('MigrationRunner.needsMigration', () {
    test('false on a fresh install (no settings yet)', () async {
      final isar = await _open(docs.path);
      expect(await MigrationRunner.needsMigration(isar), isFalse);
    });

    test('true when existing data is on an older version', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      expect(await MigrationRunner.needsMigration(isar), isTrue);
    });

    test('false once the database is up to date', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      await MigrationRunner.run(isar);
      expect(await MigrationRunner.needsMigration(isar), isFalse);
    });
  });

  group('PreMigrationSnapshot.migrate', () {
    test('takes a snapshot of the pre-upgrade data, then migrates', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);

      final result = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        now: () => fixedNow,
      );

      expect(result.outcome, MigrationOutcome.migrated);
      final files = _snapshotFiles(docs.path);
      expect(files, hasLength(1));
      expect(_name(files.single), 'healthflare_pre_v17_20261004T063015Z.isar');
      expect(result.snapshotPath, files.single.path);

      // The live database was migrated: the orphaned entry is gone.
      expect(await _bodies(isar), ['Rough morning']);
      expect((await isar.appSettings.get(1))!.schemaVersion, 19);

      // The snapshot still holds the data exactly as it was before.
      final copy = await Isar.open(
        _schemas,
        directory: files.single.parent.path,
        name: 'healthflare_pre_v17_20261004T063015Z',
      );
      expect(await _bodies(copy), ['Orphaned note', 'Rough morning']);
      expect((await copy.appSettings.get(1))!.schemaVersion, 17);
    });

    test('a fresh install takes no snapshot and still migrates', () async {
      final isar = await _open(docs.path);
      var writes = 0;

      final result = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: (db, path) async => writes++,
      );

      expect(result.outcome, MigrationOutcome.upToDate);
      expect(writes, 0);
      expect(_snapshotFiles(docs.path), isEmpty);
      expect((await isar.appSettings.get(1))!.schemaVersion, 19);
    });

    test('an up-to-date database takes no snapshot', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar, version: 19);
      var writes = 0;

      final result = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: (db, path) async => writes++,
      );

      expect(result.outcome, MigrationOutcome.upToDate);
      expect(writes, 0);
      expect(_snapshotFiles(docs.path), isEmpty);
    });

    test('keeps only the newest 3 snapshots after a good upgrade', () async {
      final dir = Directory(
        '${docs.path}/${PreMigrationSnapshot.directoryName}',
      )..createSync();
      for (final name in [
        'healthflare_pre_v15_20250101T000000Z.isar',
        'healthflare_pre_v16_20250601T000000Z.isar',
        'healthflare_pre_v16_20260101T000000Z.isar',
      ]) {
        File('${dir.path}/$name').writeAsStringSync('old');
      }
      // Not ours: never touched.
      File('${dir.path}/notes.txt').writeAsStringSync('keep me');

      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        now: () => fixedNow,
      );

      expect(_snapshotFiles(docs.path).map(_name), [
        'healthflare_pre_v16_20250601T000000Z.isar',
        'healthflare_pre_v16_20260101T000000Z.isar',
        'healthflare_pre_v17_20261004T063015Z.isar',
        'notes.txt',
      ]);
    });

    test('if the snapshot cannot be written, nothing is migrated', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      var migrations = 0;

      final result = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: (db, path) async {
          // Leave a partial file behind, then fail (e.g. disk full).
          File(path).writeAsStringSync('partial');
          throw const FileSystemException('No space left on device');
        },
        migrate: (db) async => migrations++,
      );

      expect(result.outcome, MigrationOutcome.skippedNoSnapshot);
      expect(result.error, isA<FileSystemException>());
      expect(migrations, 0);
      expect(_snapshotFiles(docs.path), isEmpty, reason: 'partial removed');
      expect((await isar.appSettings.get(1))!.schemaVersion, 17);
      expect(await _bodies(isar), ['Orphaned note', 'Rough morning']);
    });

    test('a writer that leaves no file counts as a failed snapshot', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      var migrations = 0;

      final result = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: (db, path) async {},
        migrate: (db) async => migrations++,
      );

      expect(result.outcome, MigrationOutcome.skippedNoSnapshot);
      expect(migrations, 0);
    });

    test(
      'a migration that fails halfway leaves a restorable snapshot',
      () async {
        final isar = await _open(docs.path);
        await _seedOldVersion(isar);

        final result = await PreMigrationSnapshot.migrate(
          isar,
          documentsDir: docs.path,
          now: () => fixedNow,
          migrate: (db) async {
            // First step commits, second step throws.
            await db.writeTxn(() => db.journalEntryIsars.clear());
            throw StateError('step 2 broke');
          },
        );

        expect(result.outcome, MigrationOutcome.failed);
        expect(result.error, isA<StateError>());
        expect(result.snapshotPath, isNotNull);
        expect(File(result.snapshotPath!).existsSync(), isTrue);
        expect(await _bodies(isar), isEmpty, reason: 'step 1 did commit');

        // Restore through the existing staged-restore path.
        await isar.close();
        await BackupService.stagePendingRestore(result.snapshotPath!);
        await BackupService.applyPendingRestoreIfNeeded(docs.path);

        final restored = await _open(docs.path);
        expect(await _bodies(restored), ['Orphaned note', 'Rough morning']);
        expect((await restored.appSettings.get(1))!.schemaVersion, 17);
        final profiles = await restored.profileIsars.where().findAll();
        expect(profiles.map((p) => p.name), ['Sarah']);

        // The restore forgets the unfinished upgrade, so the next attempt
        // takes a fresh copy of the restored data rather than reusing one.
        final marker = File(
          '${docs.path}/${PreMigrationSnapshot.directoryName}/'
          '${PreMigrationSnapshot.pendingMarkerName}',
        );
        expect(marker.existsSync(), isFalse);
        final retry = await PreMigrationSnapshot.migrate(
          restored,
          documentsDir: docs.path,
          now: () => fixedNow.add(const Duration(hours: 1)),
        );
        expect(retry.outcome, MigrationOutcome.migrated);
        expect(retry.snapshotPath, isNot(result.snapshotPath));
        expect(await _bodies(restored), ['Rough morning']);
      },
    );

    test('a failed migration does not prune older snapshots', () async {
      final dir = Directory(
        '${docs.path}/${PreMigrationSnapshot.directoryName}',
      )..createSync();
      for (final name in [
        'healthflare_pre_v15_20250101T000000Z.isar',
        'healthflare_pre_v16_20250601T000000Z.isar',
        'healthflare_pre_v16_20260101T000000Z.isar',
      ]) {
        File('${dir.path}/$name').writeAsStringSync('old');
      }
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);

      await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        migrate: (db) async => throw StateError('broke'),
      );

      expect(_snapshotFiles(docs.path), hasLength(4));
    });

    test('a retry after a failed upgrade reuses the first snapshot', () async {
      // A second snapshot would capture whatever the failed attempt left
      // behind, and with retries on every launch it would push the real
      // pre-upgrade copy out of the newest 3.
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      var writes = 0;
      Future<void> countingWriter(Isar db, String path) async {
        writes++;
        await db.copyToFile(path);
      }

      final first = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: countingWriter,
        now: () => fixedNow,
        migrate: (db) async => throw StateError('broke'),
      );
      final second = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: countingWriter,
        now: () => fixedNow.add(const Duration(days: 1)),
        migrate: (db) async => throw StateError('broke again'),
      );

      expect(writes, 1);
      expect(second.outcome, MigrationOutcome.failed);
      expect(second.snapshotPath, first.snapshotPath);
      expect(_snapshotFiles(docs.path), hasLength(1));

      // Once an upgrade finally succeeds, the next one takes a new snapshot.
      final third = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: countingWriter,
        now: () => fixedNow.add(const Duration(days: 2)),
      );
      expect(third.outcome, MigrationOutcome.migrated);
      expect(third.snapshotPath, first.snapshotPath);
      expect(writes, 1);

      await isar.writeTxn(() async {
        final s = (await isar.appSettings.get(1))!..schemaVersion = 17;
        await isar.appSettings.put(s);
      });
      final fourth = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        writer: countingWriter,
        now: () => fixedNow.add(const Duration(days: 3)),
      );
      expect(writes, 2);
      expect(fourth.snapshotPath, isNot(first.snapshotPath));
    });

    test('marks the snapshots folder as excluded from backup', () async {
      final isar = await _open(docs.path);
      await _seedOldVersion(isar);
      final excluded = <String>[];

      await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: docs.path,
        excludeFromBackup: (path) async {
          excluded.add(path);
          return true;
        },
      );

      expect(excluded, ['${docs.path}/${PreMigrationSnapshot.directoryName}']);
    });
  });

  group('startupNotice', () {
    test('says nothing when the upgrade went fine', () {
      expect(
        const MigrationResult(MigrationOutcome.migrated).startupNotice,
        isNull,
      );
      expect(
        const MigrationResult(MigrationOutcome.upToDate).startupNotice,
        isNull,
      );
    });

    test('explains a skipped upgrade', () {
      expect(
        const MigrationResult(MigrationOutcome.skippedNoSnapshot).startupNotice,
        "Health Flare couldn't save a safety copy of your data, so it "
        "didn't update it. Your data is unchanged. It will try again next "
        'time you open the app. If this keeps happening, free up some '
        'storage on your phone.',
      );
    });

    test('explains a failed upgrade', () {
      expect(
        const MigrationResult(MigrationOutcome.failed).startupNotice,
        "Health Flare couldn't finish updating your data. A copy of your "
        'data from before the update is saved on this phone. It will try '
        'again next time you open the app. To be safe, export a backup '
        'from Settings.',
      );
    });
  });
}
