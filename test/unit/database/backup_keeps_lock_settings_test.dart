import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';
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

// docs/features/app-lock.feature, "Device-local settings" (#100, #101).
// The app lock and hide in app switcher belong to this phone, not to the
// data: no import or restore turns them on or off.

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

/// A database on the current schema with one profile and these settings.
Future<void> _seed(
  Isar isar, {
  required String profile,
  required bool lock,
  int? relockSeconds,
  required bool hide,
}) async {
  await isar.writeTxn(() async {
    await isar.appSettings.put(
      AppSettings()
        ..id = 1
        ..schemaVersion = 19
        ..lastProfileId = 1
        ..appLockEnabled = lock
        ..appLockRelockSeconds = relockSeconds
        ..hideInAppSwitcher = hide,
    );
    await isar.profileIsars.put(ProfileIsar()..name = profile);
  });
}

Future<AppLockSettings> _lockSettings(Isar isar) async =>
    IsarAppLockStore.fromRow(await isar.appSettings.get(1));

void main() {
  late Directory root;
  late Directory docs;
  late Directory tmp;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_lock_backup_test_');
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

  /// A backup file made on a phone with the lock on and the app hidden.
  Future<String> lockedPhoneBackup() async {
    final source = await _open(tmp.path, name: 'other_phone');
    await _seed(
      source,
      profile: 'Mia',
      lock: true,
      relockSeconds: 0,
      hide: true,
    );
    final path = await BackupService.export(source);
    await source.close();
    return path;
  }

  test('restoring over my data keeps this phone\'s lock settings', () async {
    final live = await _open(docs.path);
    await _seed(live, profile: 'Sarah', lock: false, hide: false);
    final backup = await lockedPhoneBackup();
    await live.close();

    await BackupService.stagePendingRestore(backup);
    await BackupService.applyPendingRestoreIfNeeded(docs.path);

    final restored = await _open(docs.path);
    // The data is the backup's...
    final profiles = await restored.profileIsars.where().findAll();
    expect(profiles.map((p) => p.name), ['Mia']);
    // ...the lock settings are this phone's.
    expect(await _lockSettings(restored), const AppLockSettings());
  });

  test('a restore keeps a lock that was on, with its re-lock time', () async {
    final live = await _open(docs.path);
    await _seed(
      live,
      profile: 'Sarah',
      lock: true,
      relockSeconds: 60,
      hide: true,
    );
    final source = await _open(tmp.path, name: 'unlocked_phone');
    await _seed(source, profile: 'Mia', lock: false, hide: false);
    final backup = await BackupService.export(source);
    await source.close();
    await live.close();

    await BackupService.stagePendingRestore(backup);
    await BackupService.applyPendingRestoreIfNeeded(docs.path);

    final restored = await _open(docs.path);
    expect(
      await _lockSettings(restored),
      const AppLockSettings(
        enabled: true,
        relockAfter: RelockAfter.oneMinute,
        hideInAppSwitcher: true,
      ),
    );
  });

  test('importing records from a backup doesn\'t change them', () async {
    final live = await _open(docs.path);
    await _seed(
      live,
      profile: 'Sarah',
      lock: true,
      relockSeconds: 60,
      hide: true,
    );
    final source = await _open(tmp.path, name: 'unlocked_phone_2');
    await _seed(source, profile: 'Mia', lock: false, hide: false);
    final backup = await BackupService.export(source);
    await source.close();

    await ImportService.mergeAll(backup, live);

    expect(
      await _lockSettings(live),
      const AppLockSettings(
        enabled: true,
        relockAfter: RelockAfter.oneMinute,
        hideInAppSwitcher: true,
      ),
    );
  });

  test(
    'settings saved before the lock existed read as lock off, 15 minutes',
    () async {
      final live = await _open(docs.path);
      await live.writeTxn(
        () => live.appSettings.put(AppSettings()..schemaVersion = 19),
      );
      expect(await _lockSettings(live), const AppLockSettings());
    },
  );
}
