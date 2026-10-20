// docs/features/datastore.feature, "When an upgrade keeps failing" (#112).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';

import '../../helpers/isar_core.dart';

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

Future<Isar> _open(String dir) =>
    Isar.open(appSchemas, directory: dir, name: 'healthflare');

/// Schema v16 (1.9.1) with Sarah and one journal entry.
Future<void> _seed(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.appSettings.put(
      AppSettings()
        ..id = 1
        ..schemaVersion = 16,
    );
    final id = await isar.profileIsars.put(ProfileIsar()..name = 'Sarah');
    final now = DateTime.utc(2026, 9, 1);
    await isar.journalEntryIsars.put(
      JournalEntryIsar()
        ..profileId = id
        ..createdAt = now
        ..snapshots = [
          JournalSnapshotIsar()
            ..body = 'Rough morning'
            ..savedAt = now,
        ],
    );
  });
}

/// Step v17 commits, then step v18 throws: like a real failure partway.
Future<void> _failAtV18(Isar db) async {
  await db.writeTxn(() async {
    final s = (await db.appSettings.get(1))!..schemaVersion = 17;
    await db.appSettings.put(s);
  });
  throw StateError('v18 broke');
}

void main() {
  late Directory root;
  late Directory docs;
  late Isar isar;
  var now = DateTime.utc(2026, 11, 2, 9, 12);

  setUpAll(() async => initializeIsarCoreForTests());

  setUp(() async {
    root = Directory.systemTemp.createTempSync('hf_failed_upgrade_');
    docs = Directory('${root.path}/docs')..createSync();
    final tmp = Directory('${root.path}/tmp')..createSync();
    PathProviderPlatform.instance = _FakePathProvider(
      tempDir: tmp,
      docsDir: docs,
    );
    now = DateTime.utc(2026, 11, 2, 9, 12);
    isar = await _open(docs.path);
    await _seed(isar);
  });

  tearDown(() async {
    for (final i
        in Isar.instanceNames.map(Isar.getInstance).whereType<Isar>()) {
      if (i.isOpen) await i.close();
    }
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  Future<MigrationResult> launch({
    String app = '1.10.0+42',
    Future<void> Function(Isar)? migrate = _failAtV18,
  }) {
    now = now.add(const Duration(hours: 1));
    return PreMigrationSnapshot.migrate(
      isar,
      documentsDir: docs.path,
      appVersion: app,
      now: () => now,
      migrate: migrate,
    );
  }

  test('A failed upgrade is retried on the next two launches', () async {
    var runs = 0;
    Future<void> counting(Isar db) async {
      runs++;
      await _failAtV18(db);
    }

    final first = await launch(migrate: counting);
    final second = await launch(migrate: counting);
    expect(first.outcome, MigrationOutcome.failed);
    expect(second.outcome, MigrationOutcome.failed);
    expect(second.startupNotice, contains("couldn't finish updating"));
    expect(second.failure!.attempts, 2);
    expect(runs, 2);
  });

  test('After three failures the app stops retrying and says so', () async {
    var runs = 0;
    Future<void> counting(Isar db) async {
      runs++;
      await _failAtV18(db);
    }

    await launch(migrate: counting);
    await launch(migrate: counting);
    final third = await launch(migrate: counting);
    expect(third.outcome, MigrationOutcome.stopped);
    expect(runs, 3);

    final fourth = await launch(migrate: counting);
    expect(fourth.outcome, MigrationOutcome.stopped);
    expect(runs, 3, reason: 'not tried again on the same version');
    // The card, not the one-off message, says so from here.
    expect(fourth.startupNotice, isNull);

    final f = fourth.failure!;
    expect(f.appVersion, '1.10.0+42');
    expect(f.fromVersion, 16);
    expect(f.reachedVersion, 17);
    expect(f.failedStep, 18);
    expect(f.attempts, 3);
    expect(f.error, 'StateError: Bad state: v18 broke');
    expect(f.snapshotPath, isNotNull);
    expect(File(f.snapshotPath!).existsSync(), isTrue);
    expect(f.snapshotTakenAt, DateTime.utc(2026, 11, 2, 10, 12));
  });

  test(
    'A new app version tries the upgrade again, three attempts as before',
    () async {
      for (var i = 0; i < 3; i++) {
        await launch();
      }
      final retry = await launch(app: '1.10.1+43');
      expect(retry.outcome, MigrationOutcome.failed);
      expect(retry.failure!.attempts, 1);

      final fixed = await launch(app: '1.10.1+43', migrate: null);
      expect(fixed.outcome, MigrationOutcome.migrated);
      expect(fixed.failure, isNull);
      expect(FailedUpgrade.read(docs.path), isNull, reason: 'the card goes');
    },
  );

  test('an up-to-date database clears a stale failure record', () async {
    for (var i = 0; i < 3; i++) {
      await launch();
    }
    await launch(app: '1.10.1', migrate: null);
    final again = await launch(app: '1.10.1', migrate: null);
    expect(again.outcome, MigrationOutcome.upToDate);
    expect(again.failure, isNull);
  });

  test('Restoring the safety copy: still no retry on this version', () async {
    MigrationResult stopped = await launch();
    stopped = await launch();
    stopped = await launch();
    expect(stopped.outcome, MigrationOutcome.stopped);

    await isar.close();
    await BackupService.stagePendingRestore(stopped.failure!.snapshotPath!);
    await BackupService.applyPendingRestoreIfNeeded(docs.path);
    isar = await _open(docs.path);
    expect((await isar.appSettings.get(1))!.schemaVersion, 16);

    var runs = 0;
    final after = await launch(
      migrate: (db) async {
        runs++;
        await _failAtV18(db);
      },
    );
    expect(after.outcome, MigrationOutcome.stopped);
    expect(runs, 0);
    expect(after.failure!.snapshotPath, isNotNull);
  });

  test('No restore is offered when the safety copy is gone', () async {
    for (var i = 0; i < 3; i++) {
      await launch();
    }
    final copy = FailedUpgrade.read(docs.path)!.snapshotPath!;
    File(copy).deleteSync();
    final next = await launch();
    expect(next.outcome, MigrationOutcome.stopped);
    expect(next.failure!.snapshotPath, isNull);
  });

  group('Copy details holds what we need and no health data', () {
    late FailedUpgrade f;

    setUp(() async {
      for (var i = 0; i < 3; i++) {
        await launch();
      }
      f = FailedUpgrade.read(docs.path)!;
    });

    test('the fields', () {
      final text = failedUpgradeDetails(f, platform: 'ios 26.0');
      expect(text, contains('Health Flare 1.10.0+42'));
      expect(text, contains('Platform: ios 26.0'));
      expect(
        text,
        contains(
          'Data version: 17 '
          '(updating from 16 to ${MigrationRunner.targetVersion})',
        ),
      );
      expect(text, contains('Failed step: 18'));
      expect(text, contains('Attempts: 3'));
      expect(text, contains('Safety copy: 2026-11-02 10:12 UTC'));
      expect(text, contains('Error: StateError: Bad state: v18 broke'));
    });

    test('no names, entries or notes', () {
      final text = failedUpgradeDetails(f, platform: 'ios');
      expect(text, isNot(contains('Sarah')));
      expect(text, isNot(contains('Rough morning')));
    });

    test('a long or multi-line error is cut to one short line', () {
      final long = FailedUpgrade.fromError(
        StateError('first line\nsecond line ${'x' * 500}'),
      );
      expect(long, isNot(contains('\n')));
      expect(long.length, lessThanOrEqualTo(200));
    });
  });
}
