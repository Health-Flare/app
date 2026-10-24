// #173: storage for "which flare an entry is part of".
// - v23 clears stored flare links that only repeat what the rule gives, so
//   those entries follow their flare's dates from now on. Links that
//   differ are kept as pins.
// - "Taken out of its flare" survives "Add missing data" on every kind.
// Spec: docs/features/flare.feature, "Which flare an entry is part of".
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';

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

Future<Isar> _open(String dir, {String name = 'healthflare'}) =>
    Isar.open(appSchemas, directory: dir, name: name);

final _start = DateTime(2026, 3, 3, 9);
final _end = DateTime(2026, 3, 10, 18);
final _during = DateTime(2026, 3, 5, 12);
final _before = DateTime(2026, 2, 1, 12);

Future<void> _seed(Isar isar, {required int version}) async {
  await isar.writeTxn(() async {
    await isar.appSettings.put(
      AppSettings()
        ..id = 1
        ..schemaVersion = version
        ..lastProfileId = 1,
    );
    await isar.profileIsars.put(
      ProfileIsar()
        ..id = 1
        ..name = 'Sarah',
    );
    await isar.flareIsars.put(
      FlareIsar()
        ..id = 1
        ..profileId = 1
        ..startedAt = _start
        ..endedAt = _end
        ..createdAt = _start,
    );
  });
}

SymptomEntryIsar _symptom(int id, DateTime at, {int? flare}) =>
    SymptomEntryIsar()
      ..id = id
      ..profileId = 1
      ..name = 'Joint pain'
      ..severity = 6
      ..loggedAt = at
      ..createdAt = at
      ..flareIsarId = flare;

void main() {
  late Directory root;
  late Directory docs;
  late Directory tmp;

  setUpAll(() async => initializeIsarCoreForTests());

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_flare_membership_');
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

  group('v23', () {
    test('clears a stored link that only repeats the rule', () async {
      final isar = await _open(docs.path);
      await _seed(isar, version: 22);
      await isar.writeTxn(() async {
        await isar.symptomEntryIsars.put(_symptom(1, _during, flare: 1));
        await isar.doseLogIsars.put(
          DoseLogIsar()
            ..profileId = 1
            ..medicationIsarId = 1
            ..loggedAt = _during
            ..createdAt = _during
            ..amount = 1
            ..unit = 'tablet'
            ..status = 'taken'
            ..flareIsarId = 1,
        );
      });

      await MigrationRunner.run(isar);

      expect((await isar.symptomEntryIsars.get(1))!.flareIsarId, isNull);
      expect(
        (await isar.doseLogIsars.where().findFirst())!.flareIsarId,
        isNull,
      );
      expect((await isar.appSettings.get(1))!.schemaVersion, 24);
    });

    test('keeps a link the rule would not give, as a pin', () async {
      final isar = await _open(docs.path);
      await _seed(isar, version: 22);
      await isar.writeTxn(() async {
        await isar.symptomEntryIsars.put(_symptom(1, _before, flare: 1));
      });

      await MigrationRunner.run(isar);

      expect((await isar.symptomEntryIsars.get(1))!.flareIsarId, 1);
    });

    test('nothing is taken out of a flare', () async {
      final isar = await _open(docs.path);
      await _seed(isar, version: 22);
      await isar.writeTxn(() async {
        await isar.symptomEntryIsars.put(_symptom(1, _during));
      });

      await MigrationRunner.run(isar);

      expect((await isar.symptomEntryIsars.get(1))!.flareDetached, isFalse);
    });
  });

  test('"Add missing data" keeps every kind taken out of its flare', () async {
    final source = await _open(tmp.path, name: 'other_phone');
    await _seed(source, version: MigrationRunner.targetVersion);
    await source.writeTxn(() async {
      await source.medicationIsars.put(
        MedicationIsar()
          ..id = 1
          ..profileId = 1
          ..name = 'Ibuprofen'
          ..medicationType = 'medication'
          ..doseAmount = 200
          ..doseUnit = 'mg'
          ..frequency = 'as_needed'
          ..startDate = _start
          ..createdAt = _start,
      );
      await source.symptomEntryIsars.put(
        _symptom(1, _during)..flareDetached = true,
      );
      await source.vitalEntryIsars.put(
        VitalEntryIsar()
          ..profileId = 1
          ..vitalType = 'temperature'
          ..value = 38.1
          ..unit = '°C'
          ..loggedAt = _during
          ..createdAt = _during
          ..flareDetached = true,
      );
      await source.mealEntryIsars.put(
        MealEntryIsar()
          ..profileId = 1
          ..description = 'Soup'
          ..hasReaction = false
          ..loggedAt = _during
          ..createdAt = _during
          ..flareDetached = true,
      );
      await source.doseLogIsars.put(
        DoseLogIsar()
          ..profileId = 1
          ..medicationIsarId = 1
          ..loggedAt = _during
          ..createdAt = _during
          ..amount = 1
          ..unit = 'tablet'
          ..status = 'taken'
          ..flareDetached = true,
      );
      await source.activityEntryIsars.put(
        ActivityEntryIsar()
          ..profileId = 1
          ..description = 'Walk'
          ..loggedAt = _during
          ..createdAt = _during
          ..flareDetached = true,
      );
    });
    final exported = await BackupService.export(source);
    await source.close();

    final live = await _open(docs.path);
    await _seed(live, version: MigrationRunner.targetVersion);
    await ImportService.mergeAll(exported, live, report: ImportReport());

    expect(
      {
        'symptom':
            (await live.symptomEntryIsars.where().findFirst())?.flareDetached,
        'vital':
            (await live.vitalEntryIsars.where().findFirst())?.flareDetached,
        'meal': (await live.mealEntryIsars.where().findFirst())?.flareDetached,
        'dose': (await live.doseLogIsars.where().findFirst())?.flareDetached,
        'activity':
            (await live.activityEntryIsars.where().findFirst())?.flareDetached,
      },
      {
        'symptom': true,
        'vital': true,
        'meal': true,
        'dose': true,
        'activity': true,
      },
    );
  });
}
