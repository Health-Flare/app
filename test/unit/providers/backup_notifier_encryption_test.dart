import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_encryption.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';
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
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';

// ---------------------------------------------------------------------------
// BackupNotifier flows for encrypted backups (issue #30,
// docs/features/encrypted-backup.feature), end to end: real Isar, real
// encryption, real file I/O under a faked path_provider. Only the platform
// file picker is replaced, via the notifier's pickBackupFile() seam.
//
// Covers the import-side scenarios the service-level tests in
// test/unit/database/backup_encryption_test.dart can't: the password prompt
// gating every mode, retrying after a wrong password, "no data in the main
// database is changed", and "The decrypted working copy is always cleaned
// up" across success, failure, and cancellation.
// ---------------------------------------------------------------------------

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

  @override
  Future<String?> pickBackupFile() async {
    pickCount++;
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
];

const _password = 'correcthorsebattery';

String _uid() => '${DateTime.now().microsecondsSinceEpoch}';

void main() {
  late Directory tempRoot;
  late Directory docsDir;
  late Isar mainDb;
  late _PickerStubNotifier notifier;
  late ProviderContainer container;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('hf_notifier_test_');
    docsDir = Directory('${tempRoot.path}/docs')..createSync();
    PathProviderPlatform.instance = _FakePathProvider(
      tempDir: tempRoot,
      docsDir: docsDir,
    );

    mainDb = await Isar.open(
      _schemas,
      directory: docsDir.path,
      name: 'main_${_uid()}',
    );
    await mainDb.writeTxn(
      () => mainDb.profileIsars.put(ProfileIsar()..name = 'Existing'),
    );

    notifier = _PickerStubNotifier();
    container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(mainDb),
        backupProvider.overrideWith(() => notifier),
      ],
    );
    // Instantiate the notifier.
    container.read(backupProvider);
  });

  tearDown(() async {
    container.dispose();
    for (final name in Isar.instanceNames) {
      final isar = Isar.getInstance(name);
      if (isar != null && isar.isOpen) await isar.close();
    }
    if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
  });

  BackupResult state() => container.read(backupProvider);

  /// Writes an encrypted backup containing one profile named [name] into a
  /// separate "outside" directory, like a file the user picked from Files.
  Future<String> encryptedBackupWith(String name) async {
    final source = await Isar.open(
      _schemas,
      directory: docsDir.path,
      name: 'source_${_uid()}',
    );
    await source.writeTxn(
      () => source.profileIsars.put(ProfileIsar()..name = name),
    );
    final encPath = await BackupService.exportEncrypted(source, _password);
    await source.close(deleteFromDisk: true);

    final picked = Directory('${tempRoot.path}/picked')
      ..createSync(recursive: true);
    return File(encPath).renameSync('${picked.path}/backup.hfbackup').path;
  }

  Future<String> plainBackupWith(String name) async {
    final source = await Isar.open(
      _schemas,
      directory: docsDir.path,
      name: 'source_${_uid()}',
    );
    await source.writeTxn(
      () => source.profileIsars.put(ProfileIsar()..name = name),
    );
    final path = await BackupService.export(source);
    await source.close(deleteFromDisk: true);
    return path;
  }

  /// Decrypted working copies still on disk anywhere under the temp root.
  List<File> decryptedCopies() => tempRoot
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.contains('healthflare_decrypted_'))
      .toList();

  Future<List<String>> mainProfileNames() async =>
      (await mainDb.profileIsars.where().findAll()).map((p) => p.name).toList()
        ..sort();

  // -------------------------------------------------------------------------
  // Scenario: Selecting an encrypted file prompts for its password
  // -------------------------------------------------------------------------
  group('picking an encrypted file', () {
    for (final (label, start, action) in [
      (
        'Replace everything',
        (BackupNotifier n) => n.stageRestore(),
        PendingImportAction.overwrite,
      ),
      (
        'Add missing data',
        (BackupNotifier n) => n.mergeRestore(),
        PendingImportAction.merge,
      ),
      (
        'Choose what to import',
        (BackupNotifier n) => n.startSelectiveImport(),
        PendingImportAction.selective,
      ),
    ]) {
      test(
        '$label: asks for the password before doing anything else',
        () async {
          notifier.pickedPath = await encryptedBackupWith('FromBackup');

          await start(notifier);

          final s = state();
          expect(s, isA<ImportPasswordRequired>());
          s as ImportPasswordRequired;
          expect(s.action, action);
          expect(s.filePath, notifier.pickedPath);
          expect(s.errorMessage, isNull);

          // Nothing was merged, staged, or decrypted yet.
          expect(await mainProfileNames(), ['Existing']);
          expect(await BackupService.hasPendingRestore(), isFalse);
          expect(decryptedCopies(), isEmpty);
        },
      );
    }
  });

  // -------------------------------------------------------------------------
  // Scenario: Selecting a plain, unencrypted backup skips the password prompt
  // Scenario: A backup exported before this feature existed still imports
  // -------------------------------------------------------------------------
  test('a plain .isar backup is imported with no password prompt', () async {
    notifier.pickedPath = await plainBackupWith('FromPlain');

    await notifier.mergeRestore();

    expect(state(), isA<ImportComplete>());
    expect((state() as ImportComplete).recordsAdded, 1);
    expect(await mainProfileNames(), ['Existing', 'FromPlain']);
  });

  test('cancelling the file picker leaves nothing pending', () async {
    notifier.pickedPath = null;

    await notifier.mergeRestore();

    expect(state(), isA<BackupCancelled>());
  });

  // -------------------------------------------------------------------------
  // Scenario: An incorrect password is rejected without side effects
  // -------------------------------------------------------------------------
  test('a wrong password shows an error, changes nothing, and can be retried '
      'without re-picking the file', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.mergeRestore();

    await notifier.submitImportPassword('not the password');

    final s = state();
    expect(s, isA<ImportPasswordRequired>());
    s as ImportPasswordRequired;
    expect(s.errorMessage, isNotNull);
    expect(s.errorMessage, contains('Incorrect password'));
    expect(s.filePath, notifier.pickedPath);
    expect(s.action, PendingImportAction.merge);
    expect(await mainProfileNames(), ['Existing']);
    expect(decryptedCopies(), isEmpty);

    // Retry with the right password: no second pick needed.
    await notifier.submitImportPassword(_password);

    expect(notifier.pickCount, 1);
    expect(state(), isA<ImportComplete>());
    expect(await mainProfileNames(), ['Existing', 'FromBackup']);
  });

  // -------------------------------------------------------------------------
  // Scenario: A corrupted or tampered backup cannot be distinguished from a
  // wrong password
  // -------------------------------------------------------------------------
  test('a tampered file gets the same error as a wrong password', () async {
    final path = await encryptedBackupWith('FromBackup');
    notifier.pickedPath = path;

    await notifier.mergeRestore();
    await notifier.submitImportPassword('not the password');
    final wrongPasswordMessage =
        (state() as ImportPasswordRequired).errorMessage;

    final bytes = File(path).readAsBytesSync();
    bytes[bytes.length - 1] ^= 0x01;
    File(path).writeAsBytesSync(bytes);
    await notifier.submitImportPassword(_password);

    expect(state(), isA<ImportPasswordRequired>());
    expect(
      (state() as ImportPasswordRequired).errorMessage,
      wrongPasswordMessage,
    );
    expect(await mainProfileNames(), ['Existing']);
    expect(decryptedCopies(), isEmpty);
  });

  // -------------------------------------------------------------------------
  // Scenario: Encrypted backup with "Add missing data" (merge)
  // Scenario: The decrypted working copy is always cleaned up (finishes)
  // -------------------------------------------------------------------------
  test('merge: the correct password imports the records and the decrypted '
      'copy is deleted', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.mergeRestore();

    await notifier.submitImportPassword(_password);

    expect(state(), isA<ImportComplete>());
    expect((state() as ImportComplete).recordsAdded, 1);
    expect(await mainProfileNames(), ['Existing', 'FromBackup']);
    expect(decryptedCopies(), isEmpty);
  });

  // -------------------------------------------------------------------------
  // Scenario: Encrypted backup with "Replace everything" (staged overwrite)
  // -------------------------------------------------------------------------
  test('overwrite: the decrypted content is staged as a plain Isar database '
      'and the working copy is deleted', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.stageRestore();

    await notifier.submitImportPassword(_password);

    expect(state(), isA<BackupRestoreStaged>());
    final pending = await BackupService.pendingRestorePath();
    expect(File(pending).existsSync(), isTrue);
    expect(await EncryptedBackupCodec.isEncrypted(pending), isFalse);
    expect(decryptedCopies(), isEmpty);
    // Staged only: the live database is untouched until the next launch.
    expect(await mainProfileNames(), ['Existing']);

    // And the staged file really is the backup's content.
    final staged = await ImportService.preview(pending, mainDb);
    expect(staged.map((c) => c.id), contains(ImportCategoryId.profiles));
  });

  // -------------------------------------------------------------------------
  // Scenario: Encrypted backup with "Choose what to import" (selective)
  // -------------------------------------------------------------------------
  test('selective: one password unlocks both the preview and the commit, '
      'and the decrypted copy is deleted after the commit', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.startSelectiveImport();

    await notifier.submitImportPassword(_password);

    final preview = state();
    expect(preview, isA<ImportPreviewReady>());
    preview as ImportPreviewReady;
    expect(
      preview.categories.map((c) => c.id),
      contains(ImportCategoryId.profiles),
    );
    // The preview is built from a decrypted copy, kept only until commit.
    expect(decryptedCopies(), hasLength(1));

    await notifier.commitSelectiveImport({ImportCategoryId.profiles});

    expect(state(), isA<ImportComplete>());
    expect(await mainProfileNames(), ['Existing', 'FromBackup']);
    expect(decryptedCopies(), isEmpty);
  });

  // -------------------------------------------------------------------------
  // Scenario: The decrypted working copy is always cleaned up (cancelled)
  // -------------------------------------------------------------------------
  test('selective: cancelling at the category picker deletes the decrypted '
      'copy', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.startSelectiveImport();
    await notifier.submitImportPassword(_password);
    expect(decryptedCopies(), hasLength(1));

    notifier.reset();
    // reset() deletes in the background; let it finish.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(state(), isA<BackupIdle>());
    expect(decryptedCopies(), isEmpty);
    expect(await mainProfileNames(), ['Existing']);
  });

  test('cancelling at the password prompt returns to idle with nothing '
      'decrypted', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.mergeRestore();

    notifier.reset();

    expect(state(), isA<BackupIdle>());
    expect(decryptedCopies(), isEmpty);
    expect(await mainProfileNames(), ['Existing']);
  });

  // -------------------------------------------------------------------------
  // Scenario: The decrypted working copy is always cleaned up (fails)
  // -------------------------------------------------------------------------
  test('a restore that fails after a successful unlock is reported as an '
      'import error, not a password error, and the copy is deleted', () async {
    notifier.pickedPath = await encryptedBackupWith('FromBackup');
    await notifier.mergeRestore();
    // Make the merge itself fail: the main database is gone by the time the
    // unlocked backup is merged into it.
    await mainDb.close();

    await notifier.submitImportPassword(_password);

    expect(state(), isA<BackupError>());
    expect((state() as BackupError).message, startsWith('Import failed'));
    expect(decryptedCopies(), isEmpty);
  });
}
