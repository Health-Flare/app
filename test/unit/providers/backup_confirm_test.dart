import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
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
import '../../helpers/isar_core.dart';

// BackupNotifier: "Add missing data" and "Replace everything" say what a
// backup holds before merging or staging it (#104,
// docs/features/datastore.feature). Real Isar and file I/O; only the file
// picker is replaced.

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

/// A [BackupNotifier] whose file picker returns [pickedPath] (null means the
/// user cancelled the picker) and counts how often it was opened.
class _PickerStubNotifier extends BackupNotifier {
  String? pickedPath;
  int pickCount = 0;

  /// When set, the picker stays open until this completes.
  Completer<String?>? pickerGate;

  @override
  Future<String?> pickBackupFile() async {
    pickCount++;
    final gate = pickerGate;
    if (gate != null) return gate.future;
    return pickedPath;
  }
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

const _password = 'correcthorsebattery';

String _uid() => '${DateTime.now().microsecondsSinceEpoch}';

/// Opens a database shaped like a real app database: with the AppSettings
/// singleton MigrationRunner writes on first launch, which import/restore
/// validation requires.
/// One test process opens several databases. The 1 GiB default map is what
/// libmdbx faults on (SIGBUS, process exit -7) when CI is already holding
/// other Isar mappings. Tests only store a profile or two.
const _testMaxSizeMiB = 64;

Future<Isar> _openAppDb(
  String directory,
  String name, {
  bool withSettings = true,
}) async {
  final isar = await Isar.open(
    _schemas,
    directory: directory,
    name: name,
    inspector: false,
    maxSizeMiB: _testMaxSizeMiB,
  );
  if (withSettings) {
    await isar.writeTxn(() => isar.appSettings.put(AppSettings()));
  }
  return isar;
}

void main() {
  late Directory tempRoot;
  late Directory docsDir;
  late Isar mainDb;
  late _PickerStubNotifier notifier;
  late ProviderContainer container;

  setUpAll(() async {
    await initializeIsarCoreForTests();
  });

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('hf_confirm_test_');
    docsDir = Directory('${tempRoot.path}/docs')..createSync();
    PathProviderPlatform.instance = _FakePathProvider(
      tempDir: tempRoot,
      docsDir: docsDir,
    );

    mainDb = await _openAppDb(docsDir.path, 'main_${_uid()}');
    await mainDb.writeTxn(() async {
      await mainDb.profileIsars.put(ProfileIsar()..name = 'Sarah');
      await mainDb.profileIsars.put(ProfileIsar()..name = 'Leo');
    });

    notifier = _PickerStubNotifier();
    container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(mainDb),
        backupProvider.overrideWith(() => notifier),
      ],
    );
    container.read(backupProvider);
  });

  tearDown(() async {
    container.dispose();
    final open = [
      for (final name in Isar.instanceNames)
        if (Isar.getInstance(name) case final Isar isar) isar,
    ];
    for (final isar in open) {
      if (isar.isOpen) await isar.close(deleteFromDisk: true);
    }
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  BackupResult state() => container.read(backupProvider);

  /// A backup with the profiles [names]; Sarah's and Leo's are the app's
  /// own (nothing new), any other name is new.
  Future<Isar> sourceWith(List<String> names) async {
    final source = await _openAppDb(docsDir.path, 'source_${_uid()}');
    await source.writeTxn(() async {
      for (final name in names) {
        await source.profileIsars.put(ProfileIsar()..name = name);
      }
    });
    return source;
  }

  Future<String> plainBackupWith(List<String> names) async {
    final source = await sourceWith(names);
    final path = await BackupService.export(source);
    await source.close(deleteFromDisk: true);
    return path;
  }

  Future<String> encryptedBackupWith(List<String> names) async {
    final source = await sourceWith(names);
    final encPath = await BackupService.exportEncrypted(source, _password);
    await source.close(deleteFromDisk: true);
    final picked = Directory('${tempRoot.path}/picked')
      ..createSync(recursive: true);
    return File(encPath).renameSync('${picked.path}/backup.hfbackup').path;
  }

  List<File> decryptedCopies() => tempRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.contains('healthflare_decrypted_'))
      .toList();

  Future<List<String>> mainProfileNames() async =>
      (await mainDb.profileIsars.where().findAll()).map((p) => p.name).toList()
        ..sort();

  // Scenario: "Add missing data" says what it will add before adding it
  group('"Add missing data"', () {
    test(
      'stops at a confirmation listing each profile in the backup',
      () async {
        notifier.pickedPath = await plainBackupWith(['Sarah', 'Mia']);

        await notifier.mergeRestore();

        final s = state();
        expect(s, isA<MergeConfirmRequired>());
        s as MergeConfirmRequired;
        expect(s.summary.profiles.map((p) => p.name), ['Sarah', 'Mia']);
        expect(s.summary.profiles.last.isNew, isTrue);
        // Nothing merged yet.
        expect(await mainProfileNames(), ['Leo', 'Sarah']);
      },
    );

    test('an encrypted backup is confirmed after its password', () async {
      notifier.pickedPath = await encryptedBackupWith(['Mia']);

      await notifier.mergeRestore();
      await notifier.submitImportPassword(_password);

      expect(state(), isA<MergeConfirmRequired>());
      expect(await mainProfileNames(), ['Leo', 'Sarah']);
    });

    test('Add merges', () async {
      notifier.pickedPath = await plainBackupWith(['Mia']);
      await notifier.mergeRestore();

      await notifier.confirmImport();

      expect(state(), isA<ImportComplete>());
      expect(await mainProfileNames(), ['Leo', 'Mia', 'Sarah']);
    });

    test('Add on an encrypted backup deletes its decrypted copy', () async {
      notifier.pickedPath = await encryptedBackupWith(['Mia']);
      await notifier.mergeRestore();
      await notifier.submitImportPassword(_password);

      await notifier.confirmImport();

      expect(await mainProfileNames(), ['Leo', 'Mia', 'Sarah']);
      expect(decryptedCopies(), isEmpty);
    });
  });

  // Scenario: Cancelling leaves everything as it was
  group('Cancel', () {
    test('merges nothing and says so', () async {
      notifier.pickedPath = await plainBackupWith(['Mia']);
      await notifier.mergeRestore();

      await notifier.cancelImport();

      expect(state(), isA<ImportNothingDone>());
      expect(
        (state() as ImportNothingDone).message,
        'Nothing was added from the backup',
      );
      expect(await mainProfileNames(), ['Leo', 'Sarah']);
    });

    test('leaves no decrypted copy of the backup', () async {
      notifier.pickedPath = await encryptedBackupWith(['Mia']);
      await notifier.mergeRestore();
      await notifier.submitImportPassword(_password);
      expect(state(), isA<MergeConfirmRequired>());

      await notifier.cancelImport();

      expect(decryptedCopies(), isEmpty);
      expect(await mainProfileNames(), ['Leo', 'Sarah']);
    });

    test('dismissing the dialog (reset) deletes the decrypted copy', () async {
      notifier.pickedPath = await encryptedBackupWith(['Mia']);
      await notifier.mergeRestore();
      await notifier.submitImportPassword(_password);
      expect(state(), isA<MergeConfirmRequired>());

      notifier.reset();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(await mainProfileNames(), ['Leo', 'Sarah']);
      expect(decryptedCopies(), isEmpty);
    });
  });

  // Scenario: A backup with nothing new says so
  test('a backup with nothing new says so and merges nothing', () async {
    notifier.pickedPath = await plainBackupWith(['Sarah', 'Leo']);

    await notifier.mergeRestore();

    expect(state(), isA<ImportNothingDone>());
    expect(
      (state() as ImportNothingDone).message,
      'Everything in this backup is already here.',
    );
    expect(await mainProfileNames(), ['Leo', 'Sarah']);
  });

  // Scenario: "Replace everything" says what will replace what
  group('"Replace everything"', () {
    test('stops at a confirmation: the backup, and what it replaces', () async {
      notifier.pickedPath = await plainBackupWith(['Mia']);

      final staged = await notifier.stageRestore();

      expect(staged, isFalse);
      final s = state();
      expect(s, isA<ReplaceConfirmRequired>());
      s as ReplaceConfirmRequired;
      expect(s.summary.profiles.map((p) => p.name), ['Mia']);
      expect(s.currentProfiles..sort(), ['Leo', 'Sarah']);
      expect(await BackupService.hasPendingRestore(), isFalse);
    });

    test('even a backup with nothing new is confirmed, not skipped', () async {
      notifier.pickedPath = await plainBackupWith(['Sarah', 'Leo']);

      await notifier.stageRestore();

      expect(state(), isA<ReplaceConfirmRequired>());
    });

    test('Replace stages the restore', () async {
      notifier.pickedPath = await plainBackupWith(['Mia']);
      await notifier.stageRestore();

      await notifier.confirmImport();

      expect(state(), isA<BackupRestoreStaged>());
      expect(await BackupService.hasPendingRestore(), isTrue);
    });

    test('Cancel stages nothing', () async {
      notifier.pickedPath = await encryptedBackupWith(['Mia']);
      await notifier.stageRestore();
      await notifier.submitImportPassword(_password);
      expect(state(), isA<ReplaceConfirmRequired>());

      await notifier.cancelImport();

      expect(await BackupService.hasPendingRestore(), isFalse);
      expect(decryptedCopies(), isEmpty);
    });
  });
}
