// Upgrades from real releases (#181). Each folder in
// test/fixtures/upgrades/ holds a database written by that release's own
// code (scripts/upgrade_fixture.sh) and a manifest of what's in it. Every
// one must upgrade through the real startup path with nothing lost.
// Docs: docs/testing/upgrades.md.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/models/flare_membership.dart';

class _Docs with MockPlatformInterfaceMixin implements PathProviderPlatform {
  _Docs(this.path);
  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
  @override
  Future<String?> getTemporaryPath() async => path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
  @override
  Future<String?> getLibraryPath() async => path;
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
  Future<String?> getApplicationCachePath() async => path;
}

Future<Map<String, int>> _counts(Isar isar, {int? profile}) async {
  Future<int> n(Future<int> Function() all, Future<int> Function() one) =>
      profile == null ? all() : one();
  final p = profile ?? 0;
  return {
    'journalEntries': await n(
      isar.journalEntryIsars.count,
      () => isar.journalEntryIsars.filter().profileIdEqualTo(p).count(),
    ),
    'userConditions': await n(
      isar.userConditionIsars.count,
      () => isar.userConditionIsars.filter().profileIdEqualTo(p).count(),
    ),
    'flares': await n(
      isar.flareIsars.count,
      () => isar.flareIsars.filter().profileIdEqualTo(p).count(),
    ),
    'symptomEntries': await n(
      isar.symptomEntryIsars.count,
      () => isar.symptomEntryIsars.filter().profileIdEqualTo(p).count(),
    ),
    'vitalEntries': await n(
      isar.vitalEntryIsars.count,
      () => isar.vitalEntryIsars.filter().profileIdEqualTo(p).count(),
    ),
    'medications': await n(
      isar.medicationIsars.count,
      () => isar.medicationIsars.filter().profileIdEqualTo(p).count(),
    ),
    'doseLogs': await n(
      isar.doseLogIsars.count,
      () => isar.doseLogIsars.filter().profileIdEqualTo(p).count(),
    ),
    'mealEntries': await n(
      isar.mealEntryIsars.count,
      () => isar.mealEntryIsars.filter().profileIdEqualTo(p).count(),
    ),
    'sleepEntries': await n(
      isar.sleepEntryIsars.count,
      () => isar.sleepEntryIsars.filter().profileIdEqualTo(p).count(),
    ),
    'activityEntries': await n(
      isar.activityEntryIsars.count,
      () => isar.activityEntryIsars.filter().profileIdEqualTo(p).count(),
    ),
    'dailyCheckins': await n(
      isar.dailyCheckinIsars.count,
      () => isar.dailyCheckinIsars.filter().profileIdEqualTo(p).count(),
    ),
    'appointments': await n(
      isar.appointmentIsars.count,
      () => isar.appointmentIsars.filter().profileIdEqualTo(p).count(),
    ),
  };
}

void main() {
  final fixtures =
      Directory('test/fixtures/upgrades')
          .listSync()
          .whereType<Directory>()
          .where((d) => File('${d.path}/manifest.json').existsSync())
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  test('there are fixtures to test', () {
    expect(fixtures, isNotEmpty);
  });

  test('every fixture has its database committed', () {
    for (final f in fixtures) {
      expect(
        File('${f.path}/healthflare.isar').existsSync(),
        isTrue,
        reason:
            '${f.path}/healthflare.isar is missing. Is it ignored by '
            '.gitignore, or not committed?',
      );
    }
  });

  for (final fixture in fixtures) {
    final manifest =
        jsonDecode(File('${fixture.path}/manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final release = manifest['release'] as String;

    group('upgrading from $release', () {
      late Directory root;
      late String docs;
      late Isar isar;
      late MigrationResult result;

      setUp(() async {
        root = Directory.systemTemp.createTempSync('hf_upgrade_$release');
        docs = root.path;
        PathProviderPlatform.instance = _Docs(docs);
        File(
          '${fixture.path}/healthflare.isar',
        ).copySync('$docs/healthflare.isar');
        isar = await Isar.open(
          appSchemas,
          directory: docs,
          name: 'healthflare',
        );
        // The fixture is what its manifest says, before anything runs.
        expect(
          (await isar.appSettings.get(1))!.schemaVersion,
          manifest['schemaVersion'],
        );
        result = await PreMigrationSnapshot.migrate(
          isar,
          documentsDir: docs,
          appVersion: '1.10.0+test',
        );
      });

      tearDown(() async {
        if (isar.isOpen) await isar.close();
        root.deleteSync(recursive: true);
      });

      test(
        'reaches the current version, with a safety copy if it migrated',
        () async {
          expect(
            (await isar.appSettings.get(1))!.schemaVersion,
            MigrationRunner.targetVersion,
          );
          expect(FailedUpgrade.read(docs), isNull);
          if (manifest['schemaVersion'] == MigrationRunner.targetVersion) {
            // Already current (the latest release): opened as it is.
            expect(result.outcome, MigrationOutcome.upToDate);
            expect(result.snapshotPath, isNull);
          } else {
            expect(
              result.outcome,
              MigrationOutcome.migrated,
              reason: '${result.error}',
            );
            expect(result.snapshotPath, isNotNull);
            expect(File(result.snapshotPath!).existsSync(), isTrue);
          }
        },
      );

      test('every profile and everything they logged is kept', () async {
        final profiles = {
          for (final p in await isar.profileIsars.where().findAll())
            '${p.id}': p.name,
        };
        expect(profiles, manifest['profiles']);
        expect(
          (await isar.appSettings.get(1))!.activeProfileId,
          manifest['activeProfileId'],
        );
        final kept = <String, int>{};
        for (final id in (manifest['profiles'] as Map).keys) {
          final c = await _counts(isar, profile: int.parse(id as String));
          c.forEach((k, v) => kept[k] = (kept[k] ?? 0) + v);
        }
        expect(kept, Map<String, int>.from(manifest['kept'] as Map));
      });

      test("a deleted profile's leftovers are gone", () async {
        expect(
          await isar.journalEntryIsars.filter().profileIdEqualTo(3).count(),
          0,
        );
      });

      test('the catalogue is still there', () async {
        final cat = manifest['catalogue'] as Map;
        expect(
          await isar.conditionIsars.count(),
          greaterThanOrEqualTo(cat['conditions'] as int),
        );
        expect(
          await isar.symptomIsars.count(),
          greaterThanOrEqualTo(cat['symptoms'] as int),
        );
      });

      test('values come through as logged', () async {
        final vital = (await isar.vitalEntryIsars.where().findAll()).single;
        expect((vital.value, vital.unit), (99.1, '°F'));

        final doses = await isar.doseLogIsars
            .where()
            .sortByLoggedAt()
            .findAll();
        expect([for (final d in doses) d.status], ['taken', 'missed']);
        expect(doses.last.reason, 'Forgot');

        final flare = (await isar.flareIsars.where().findAll()).single;
        final symptom = (await isar.symptomEntryIsars.where().findAll()).single;
        // Still part of its flare. Since v23 that's worked out from the
        // time (#173): the stored link only repeated it, so it's cleared.
        expect(
          flareFor(
            at: symptom.loggedAt,
            profileId: symptom.profileId,
            flares: [flare.toDomain()],
            pinnedFlareId: symptom.flareIsarId,
            detached: symptom.flareDetached,
          ),
          flare.id,
          reason: 'still part of its flare',
        );
        expect(symptom.locations, manifest['symptomLocations']);

        final condition =
            (await isar.userConditionIsars.where().findAll()).single;
        expect(condition.status, 'inRecovery');
        expect(
          [for (final e in condition.statusHistory) e.eventType],
          ['recovery'],
        );
        expect(flare.conditionIsarIds, [condition.id]);

        final appt = (await isar.appointmentIsars.where().findAll()).single;
        expect(appt.questions.single.question, 'Can I lower the dose?');

        final sarah = await isar.journalEntryIsars
            .filter()
            .profileIdEqualTo(1)
            .findFirst();
        expect(sarah!.snapshots.single.body, 'Fatigue hit hard after lunch.');
        expect(
          (await isar.mealEntryIsars.where().findFirst())!.description,
          'Porridge with blueberries',
        );
        expect(
          (await isar.medicationIsars.where().findFirst())!.name,
          'Hydroxychloroquine',
        );
      });

      test('opening again changes nothing', () async {
        final before = await _counts(isar);
        await isar.close();
        isar = await Isar.open(
          appSchemas,
          directory: docs,
          name: 'healthflare',
        );
        final again = await PreMigrationSnapshot.migrate(
          isar,
          documentsDir: docs,
          appVersion: '1.10.0+test',
        );
        expect(again.outcome, MigrationOutcome.upToDate);
        expect(await _counts(isar), before);
      });
    });
  }
}
