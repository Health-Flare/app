// ignore_for_file: avoid_print
//
// Upgrade fixture seed for 1.10.0 (#181): seed_release_test.dart, plus what
// a real 1.10.0 user has. They've seen the Track and Care guide (bottom bar
// layout version 2), and there are no rows left over from a deleted profile:
// since 1.10.0 (v18) deleting a profile removes all of its data.
//
// Upgrade fixture seed (#181). NOT run from this checkout: scripts/
// upgrade_fixture.sh copies it into a worktree at a release tag, as
// test/zz_upgrade_seed_test.dart, and runs it there, so the database is
// written by that release's own code (its models, migrations and catalogue
// seeding). It must compile against every release it's used for; if a
// release's models differ, copy it to seed_<version>_test.dart and adjust.
//
// Writes <FIXTURE_OUT>/healthflare.isar and manifest.json. The manifest
// says what's in it; test/unit/database/upgrade_from_releases_test.dart
// checks every item after upgrading.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_database.dart';
import 'package:health_flare/data/database/app_settings.dart';
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

final _t = DateTime.utc(2026, 9, 14, 8, 30);

void main() {
  test('seed an upgrade fixture', () async {
    final out = Platform.environment['FIXTURE_OUT'];
    if (out == null) fail('Set FIXTURE_OUT (see scripts/upgrade_fixture.sh)');
    final dir = Directory(out)..createSync(recursive: true);
    for (final f in dir.listSync()) {
      f.deleteSync(recursive: true);
    }
    await Isar.initializeIsarCore(download: true);
    PathProviderPlatform.instance = _Docs(dir.path);

    // The release's own startup: migrations, catalogue seeding.
    final isar = await IsarService.open();

    await isar.writeTxn(() async {
      await isar.profileIsars.putAll([
        ProfileIsar()
          ..id = 1
          ..name = 'Sarah'
          ..firstLogShown = true
          ..weatherOptInShown = true,
        ProfileIsar()
          ..id = 2
          ..name = 'Leo'
          ..firstLogShown = true
          ..weatherOptInShown = true,
      ]);
      final s = await isar.appSettings.get(1) ?? AppSettings();
      s.activeProfileId = 1;
      // Saw the 1.10.0 guide and kept the default bar.
      s.bottomBarLayoutVersion = 2;
      await isar.appSettings.put(s);

      final arthritis = await isar.userConditionIsars.put(
        UserConditionIsar()
          ..profileId = 1
          ..conditionId = 1
          ..conditionName = 'Rheumatoid arthritis'
          ..trackedSince = _t
          ..diagnosedAt = DateTime.utc(2021, 6, 15)
          ..status = 'inRecovery'
          ..statusHistory = [
            ConditionStatusEventIsar()
              ..eventType = 'recovery'
              ..date = DateTime.utc(2025, 4, 20),
          ],
      );

      final flare = await isar.flareIsars.put(
        FlareIsar()
          ..profileId = 1
          ..startedAt = _t
          ..endedAt = _t.add(const Duration(days: 3))
          ..conditionIsarIds = [arthritis]
          ..initialSeverity = 6
          ..createdAt = _t,
      );

      await isar.symptomEntryIsars.put(
        SymptomEntryIsar()
          ..profileId = 1
          ..name = 'Joint pain'
          ..severity = 7
          ..locations = ['hands', 'knees']
          ..loggedAt = _t
          ..createdAt = _t
          ..flareIsarId = flare,
      );
      await isar.vitalEntryIsars.put(
        VitalEntryIsar()
          ..profileId = 1
          ..vitalType = 'temperature'
          ..value = 99.1
          ..unit = '°F'
          ..loggedAt = _t
          ..createdAt = _t,
      );
      final med = await isar.medicationIsars.put(
        MedicationIsar()
          ..profileId = 1
          ..name = 'Hydroxychloroquine'
          ..medicationType = 'medication'
          ..doseAmount = 200
          ..doseUnit = 'mg'
          ..frequency = 'twice_daily'
          ..startDate = DateTime.utc(2024, 6, 1)
          ..createdAt = _t,
      );
      await isar.doseLogIsars.putAll([
        DoseLogIsar()
          ..profileId = 1
          ..medicationIsarId = med
          ..loggedAt = _t
          ..createdAt = _t
          ..amount = 200
          ..unit = 'mg'
          ..status = 'taken',
        DoseLogIsar()
          ..profileId = 1
          ..medicationIsarId = med
          ..loggedAt = _t.add(const Duration(hours: 12))
          ..createdAt = _t
          ..amount = 200
          ..unit = 'mg'
          ..status = 'missed'
          ..reason = 'Forgot',
      ]);
      await isar.mealEntryIsars.put(
        MealEntryIsar()
          ..profileId = 1
          ..description = 'Porridge with blueberries'
          ..hasReaction = false
          ..loggedAt = _t
          ..createdAt = _t,
      );
      await isar.sleepEntryIsars.put(
        SleepEntryIsar()
          ..profileId = 1
          ..bedtime = _t.subtract(const Duration(hours: 9))
          ..wakeTime = _t
          ..qualityRating = 3
          ..isNap = false
          ..createdAt = _t,
      );
      await isar.activityEntryIsars.put(
        ActivityEntryIsar()
          ..profileId = 1
          ..description = 'Short walk'
          ..durationMinutes = 20
          ..loggedAt = _t
          ..createdAt = _t,
      );
      await isar.dailyCheckinIsars.put(
        DailyCheckinIsar()
          ..profileId = 1
          ..checkinDate = _t
          ..wellbeing = 4
          ..createdAt = _t,
      );
      await isar.appointmentIsars.put(
        AppointmentIsar()
          ..profileId = 1
          ..title = 'Rheumatology follow-up'
          ..scheduledAt = _t.add(const Duration(days: 7))
          ..status = 'scheduled'
          ..questions = [
            AppointmentQuestionIsar()
              ..questionId = 'q1'
              ..question = 'Can I lower the dose?',
          ]
          ..createdAt = _t,
      );
      await isar.journalEntryIsars.putAll([
        JournalEntryIsar()
          ..profileId = 1
          ..createdAt = _t
          ..snapshots = [
            JournalSnapshotIsar()
              ..title = 'Rough day'
              ..body = 'Fatigue hit hard after lunch.'
              ..savedAt = _t,
          ],
        JournalEntryIsar()
          ..profileId = 2
          ..createdAt = _t
          ..snapshots = [
            JournalSnapshotIsar()
              ..body = 'Leo slept well.'
              ..savedAt = _t,
          ],
      ]);
    });

    final settings = (await isar.appSettings.get(1))!;
    final manifest = {
      'release': Platform.environment['FIXTURE_RELEASE'] ?? 'unknown',
      'schemaVersion': settings.schemaVersion,
      'activeProfileId': settings.activeProfileId,
      'profiles': {'1': 'Sarah', '2': 'Leo'},
      'deletedProfileLeftovers': <String, int>{},
      // Already on the current bar: no guide card after updating.
      'expectGuide': false,
      // Body areas arrived in 1.9.1.
      'symptomLocations': ['hands', 'knees'],
      // Rows that belong to existing profiles: all must survive.
      'kept': {
        'journalEntries': 2,
        'userConditions': 1,
        'flares': 1,
        'symptomEntries': 1,
        'vitalEntries': 1,
        'medications': 1,
        'doseLogs': 2,
        'mealEntries': 1,
        'sleepEntries': 1,
        'activityEntries': 1,
        'dailyCheckins': 1,
        'appointments': 1,
      },
      'catalogue': {
        'conditions': await isar.conditionIsars.count(),
        'symptoms': await isar.symptomIsars.count(),
      },
    };
    await isar.close();
    File(
      '${dir.path}/manifest.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
    for (final f in dir.listSync()) {
      if (f.path.endsWith('-lck') || f.path.endsWith('.lock')) {
        f.deleteSync();
      }
    }
    print('Fixture: ${dir.path}');
  });
}
