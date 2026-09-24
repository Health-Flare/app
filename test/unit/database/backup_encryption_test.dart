import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_encryption.dart';
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

// ---------------------------------------------------------------------------
// Tests for issue #30 / docs/features/encrypted-backup.feature
//
// Written ahead of the implementation (BDD red step); they pin the
// contract of lib/data/database/backup_encryption.dart:
//
//   abstract final class EncryptedBackupFormat {
//     static const extension = '.hfbackup';
//   }
//
//   class BackupEncryptionException implements Exception { ... }
//
//   class EncryptedBackupCodec {
//     static Future<bool> isEncrypted(String path);
//     static Future<String> encryptFile({
//       required String plainPath,
//       required String outPath,
//       required String password,
//     });
//     static Future<String> decryptFile({
//       required String encryptedPath,
//       required String outPath,
//       required String password,
//     });
//   }
//
// ...plus one new method on the existing BackupService:
//
//   static Future<String> exportEncrypted(Isar isar, String password);
//
// ImportService itself needs no new API: it already takes a raw file path,
// so an encrypted backup is decrypted to a temp path first and fed into the
// existing mergeAll/preview/mergeSelected exactly like a plain backup.
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Fake path_provider: resolves to real, writable directories under a
// per-test temp root, so BackupService/ImportService's real file I/O
// (getTemporaryDirectory, getApplicationDocumentsDirectory) works under
// `flutter test`, which has no platform plugin registered.
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

// ---------------------------------------------------------------------------
// Helper: open a fresh Isar instance with the full production schema list.
// ---------------------------------------------------------------------------

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

/// Opens a database shaped like a real app database: with the AppSettings
/// singleton [MigrationRunner] writes on first launch, which import/restore
/// validation requires.
Future<Isar> _openIsar(String name, {String directory = ''}) async {
  final isar = await Isar.open(_schemas, directory: directory, name: name);
  if (await isar.appSettings.get(1) == null) {
    await isar.writeTxn(() => isar.appSettings.put(AppSettings()));
  }
  return isar;
}

/// A fresh suffix per call so instance names never collide with a
/// leftover `.isar` file from a previous local test run: `directory: ''`
/// resolves to the working directory, which isn't cleaned between runs the
/// way a real CI checkout would be. Matches the pattern already used by
/// migration_test.dart/move_to_profile_test.dart.
String _uid() => '${DateTime.now().microsecondsSinceEpoch}';

const _password = 'correcthorsebattery';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  tearDown(() async {
    for (final isar
        in Isar.instanceNames.map(Isar.getInstance).whereType<Isar>()) {
      if (isar.isOpen) await isar.close();
    }
  });

  // ---------------------------------------------------------------------
  // EncryptedBackupCodec: pure file-to-file encryption, no Isar involved.
  // Covers: "Encryption uses vetted, authenticated cryptography",
  // "The password is never written to disk", "The app detects file type
  // automatically", "An incorrect password is rejected...", "A corrupted
  // or tampered backup cannot be distinguished from a wrong password".
  // ---------------------------------------------------------------------
  group('EncryptedBackupCodec', () {
    late Directory tmp;

    setUp(() => tmp = Directory.systemTemp.createTempSync('hf_codec_test_'));
    tearDown(() {
      if (tmp.existsSync()) tmp.deleteSync(recursive: true);
    });

    test(
      'round trip: the correct password recovers the exact original bytes',
      () async {
        final plainPath = '${tmp.path}/plain.isar';
        final original = Uint8List.fromList(List.generate(512, (i) => i % 256));
        await File(plainPath).writeAsBytes(original);

        final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
        await EncryptedBackupCodec.encryptFile(
          plainPath: plainPath,
          outPath: encPath,
          password: _password,
        );

        final decPath = '${tmp.path}/decrypted.isar';
        await EncryptedBackupCodec.decryptFile(
          encryptedPath: encPath,
          outPath: decPath,
          password: _password,
        );

        expect(await File(decPath).readAsBytes(), equals(original));
      },
    );

    test('the ciphertext does not contain the plaintext content', () async {
      const marker = 'HEALTHFLARE_PLAINTEXT_MARKER_0123456789';
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString(marker * 20);

      final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: _password,
      );

      final cipherAsText = utf8.decode(
        await File(encPath).readAsBytes(),
        allowMalformed: true,
      );
      expect(cipherAsText, isNot(contains(marker)));
    });

    test('the password itself never appears in the encrypted file', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString('some backup content');

      final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: _password,
      );

      final cipherAsText = utf8.decode(
        await File(encPath).readAsBytes(),
        allowMalformed: true,
      );
      expect(cipherAsText, isNot(contains(_password)));
    });

    test('encrypting identical content twice produces different ciphertext '
        '(fresh salt/nonce per export)', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString('identical content, twice');

      final encPath1 = '${tmp.path}/out1${EncryptedBackupFormat.extension}';
      final encPath2 = '${tmp.path}/out2${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath1,
        password: _password,
      );
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath2,
        password: _password,
      );

      expect(
        await File(encPath1).readAsBytes(),
        isNot(equals(await File(encPath2).readAsBytes())),
      );
    });

    test(
      'decrypting with the wrong password fails and leaves no output file',
      () async {
        final plainPath = '${tmp.path}/plain.isar';
        await File(plainPath).writeAsString('secret health data');
        final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
        await EncryptedBackupCodec.encryptFile(
          plainPath: plainPath,
          outPath: encPath,
          password: _password,
        );

        final decPath = '${tmp.path}/decrypted.isar';
        await expectLater(
          EncryptedBackupCodec.decryptFile(
            encryptedPath: encPath,
            outPath: decPath,
            password: 'the wrong password',
          ),
          throwsA(isA<BackupEncryptionException>()),
        );
        expect(File(decPath).existsSync(), isFalse);
      },
    );

    test(
      'a tampered file fails decryption the same way a wrong password does',
      () async {
        final plainPath = '${tmp.path}/plain.isar';
        await File(plainPath).writeAsString('secret health data');
        final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
        await EncryptedBackupCodec.encryptFile(
          plainPath: plainPath,
          outPath: encPath,
          password: _password,
        );

        // Flip one byte in the middle of the ciphertext to simulate tampering.
        final bytes = Uint8List.fromList(await File(encPath).readAsBytes());
        bytes[bytes.length ~/ 2] ^= 0xFF;
        await File(encPath).writeAsBytes(bytes);

        // Same password that produced the file: only the file changed.
        await expectLater(
          EncryptedBackupCodec.decryptFile(
            encryptedPath: encPath,
            outPath: '${tmp.path}/decrypted.isar',
            password: _password,
          ),
          throwsA(isA<BackupEncryptionException>()),
        );
      },
    );

    test('wrong password and tampering produce the identical error, so the '
        'UI cannot (and does not) distinguish them', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString('secret health data');
      final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: _password,
      );

      Future<String> failureMessage(String path, String password) async {
        try {
          await EncryptedBackupCodec.decryptFile(
            encryptedPath: path,
            outPath: '${tmp.path}/decrypted.isar',
            password: password,
          );
        } on BackupEncryptionException catch (e) {
          return e.message;
        }
        fail('decryption unexpectedly succeeded');
      }

      final wrongPassword = await failureMessage(encPath, 'not the password');

      final bytes = Uint8List.fromList(await File(encPath).readAsBytes());
      bytes[bytes.length - 1] ^= 0x01;
      final tamperedPath = '${tmp.path}/tampered.hfbackup';
      await File(tamperedPath).writeAsBytes(bytes);
      final tampered = await failureMessage(tamperedPath, _password);

      expect(tampered, wrongPassword);
    });

    test('altering the unencrypted header (salt) is detected too', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString('secret health data');
      final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: _password,
      );

      // Byte 8 is the first salt byte, right after the 8-byte magic.
      final bytes = Uint8List.fromList(await File(encPath).readAsBytes());
      bytes[8] ^= 0xFF;
      await File(encPath).writeAsBytes(bytes);

      final decPath = '${tmp.path}/decrypted.isar';
      await expectLater(
        EncryptedBackupCodec.decryptFile(
          encryptedPath: encPath,
          outPath: decPath,
          password: _password,
        ),
        throwsA(isA<BackupEncryptionException>()),
      );
      expect(File(decPath).existsSync(), isFalse);
    });

    test('a truncated file fails cleanly with the same exception', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString('secret health data');
      final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: _password,
      );

      // Keep the header (so it's still detected as encrypted) but cut off
      // the nonce/MAC/ciphertext, e.g. an interrupted download.
      final bytes = await File(encPath).readAsBytes();
      await File(encPath).writeAsBytes(bytes.sublist(0, 30));

      expect(await EncryptedBackupCodec.isEncrypted(encPath), isTrue);
      await expectLater(
        EncryptedBackupCodec.decryptFile(
          encryptedPath: encPath,
          outPath: '${tmp.path}/decrypted.isar',
          password: _password,
        ),
        throwsA(isA<BackupEncryptionException>()),
      );
    });

    test('isEncrypted is true for an encrypted file', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsString('data');
      final encPath = '${tmp.path}/out${EncryptedBackupFormat.extension}';
      await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: _password,
      );

      expect(await EncryptedBackupCodec.isEncrypted(encPath), isTrue);
    });

    test('isEncrypted is false for a plain, unencrypted backup file', () async {
      final plainPath = '${tmp.path}/plain.isar';
      await File(plainPath).writeAsBytes(Uint8List.fromList([0, 1, 2, 3, 4]));

      expect(await EncryptedBackupCodec.isEncrypted(plainPath), isFalse);
    });
  });

  // ---------------------------------------------------------------------
  // BackupService.exportEncrypted: real Isar + real (faked-path) file I/O.
  // Covers: "An encrypted export produces a distinct, locked file",
  // "No unencrypted intermediate file is left behind".
  // ---------------------------------------------------------------------
  group('BackupService.exportEncrypted', () {
    late Directory tempRoot;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('hf_export_test_');
      final docsDir = Directory('${tempRoot.path}/docs')..createSync();
      PathProviderPlatform.instance = _FakePathProvider(
        tempDir: tempRoot,
        docsDir: docsDir,
      );
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test('produces a file with the .hfbackup extension', () async {
      final isar = await _openIsar('export_enc_extension_${_uid()}');
      await isar.writeTxn(
        () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
      );

      final path = await BackupService.exportEncrypted(isar, _password);

      expect(path.endsWith(EncryptedBackupFormat.extension), isTrue);
      expect(File(path).existsSync(), isTrue);
    });

    test(
      'the exported file is not readable as a plain Isar database',
      () async {
        final isar = await _openIsar('export_enc_not_plain_${_uid()}');
        await isar.writeTxn(
          () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
        );

        final path = await BackupService.exportEncrypted(isar, _password);

        expect(await EncryptedBackupCodec.isEncrypted(path), isTrue);
      },
    );

    test(
      'no unencrypted intermediate copy of the backup survives on disk',
      () async {
        final isar = await _openIsar('export_enc_no_leftover_${_uid()}');
        await isar.writeTxn(
          () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
        );

        await BackupService.exportEncrypted(isar, _password);

        final leftoverPlaintext = tempRoot
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.contains('healthflare_backup') &&
                  f.path.endsWith('.isar'),
            );
        expect(
          leftoverPlaintext,
          isEmpty,
          reason:
              'a plaintext copy of the backup must not remain on disk '
              'after an encrypted export completes',
        );
      },
    );
  });

  // ---------------------------------------------------------------------
  // Importing an encrypted backup: decrypt once, then reuse the existing,
  // unmodified ImportService/BackupService API exactly as with a plain
  // backup. Covers: "The correct password unlocks the backup for import",
  // and all three restore-mode scenarios ("Replace everything", "Add
  // missing data", "Choose what to import"), plus the interoperability
  // scenario for pre-encryption plain backups.
  // ---------------------------------------------------------------------
  group('Importing an encrypted backup', () {
    late Directory tempRoot;
    late Directory docsDir;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync('hf_import_test_');
      docsDir = Directory('${tempRoot.path}/docs')..createSync();
      PathProviderPlatform.instance = _FakePathProvider(
        tempDir: tempRoot,
        docsDir: docsDir,
      );
    });

    tearDown(() {
      if (tempRoot.existsSync()) tempRoot.deleteSync(recursive: true);
    });

    test(
      'merge: decrypting then importing adds the same records as a plain backup',
      () async {
        final source = await _openIsar('import_merge_source_${_uid()}');
        await source.writeTxn(
          () => source.profileIsars.put(ProfileIsar()..name = 'Sarah'),
        );
        final encPath = await BackupService.exportEncrypted(source, _password);
        await source.close();

        final decPath = '${tempRoot.path}/decrypted_for_merge.isar';
        await EncryptedBackupCodec.decryptFile(
          encryptedPath: encPath,
          outPath: decPath,
          password: _password,
        );

        final main = await _openIsar('import_merge_main_${_uid()}');
        final added = await ImportService.mergeAll(decPath, main);

        expect(added, 1);
        final profiles = await main.profileIsars.where().findAll();
        expect(profiles.single.name, 'Sarah');
      },
    );

    test(
      'selective: decrypting once is enough for both preview and the commit',
      () async {
        final source = await _openIsar('import_selective_source_${_uid()}');
        await source.writeTxn(() async {
          await source.profileIsars.put(ProfileIsar()..name = 'Sarah');
        });
        final encPath = await BackupService.exportEncrypted(source, _password);
        await source.close();

        // Decrypt exactly once: both calls below reuse this same path,
        // mirroring "the user is not asked for the password again when
        // confirming which categories to import".
        final decPath = '${tempRoot.path}/decrypted_for_selective.isar';
        await EncryptedBackupCodec.decryptFile(
          encryptedPath: encPath,
          outPath: decPath,
          password: _password,
        );

        final main = await _openIsar('import_selective_main_${_uid()}');
        final categories = await ImportService.preview(decPath, main);
        expect(
          categories.any((c) => c.id == ImportCategoryId.profiles),
          isTrue,
        );

        final added = await ImportService.mergeSelected(decPath, main, {
          ImportCategoryId.profiles,
        });
        expect(added, 1);
      },
    );

    test(
      'overwrite: a decrypted backup can be staged and applied like a plain one',
      () async {
        // Existing "live" database with data that should be replaced.
        final live = await _openIsar('healthflare', directory: docsDir.path);
        await live.writeTxn(
          () => live.profileIsars.put(ProfileIsar()..name = 'OldData'),
        );
        await live.close();

        // A separate encrypted backup with different data.
        final source = await _openIsar('import_overwrite_source_${_uid()}');
        await source.writeTxn(
          () => source.profileIsars.put(ProfileIsar()..name = 'NewData'),
        );
        final encPath = await BackupService.exportEncrypted(source, _password);
        await source.close();

        final decPath = '${tempRoot.path}/decrypted_for_overwrite.isar';
        await EncryptedBackupCodec.decryptFile(
          encryptedPath: encPath,
          outPath: decPath,
          password: _password,
        );

        await BackupService.stagePendingRestore(decPath);
        await BackupService.applyPendingRestoreIfNeeded(docsDir.path);

        final reopened = await _openIsar(
          'healthflare',
          directory: docsDir.path,
        );
        final profiles = await reopened.profileIsars.where().findAll();
        expect(profiles.single.name, 'NewData');
      },
    );

    test(
      'a plain, pre-encryption .isar backup is never routed through decryption',
      () async {
        final source = await _openIsar('import_legacy_source_${_uid()}');
        await source.writeTxn(
          () => source.profileIsars.put(ProfileIsar()..name = 'Dad'),
        );
        final plainPath = await BackupService.export(source); // today's export
        await source.close();

        expect(await EncryptedBackupCodec.isEncrypted(plainPath), isFalse);

        final main = await _openIsar('import_legacy_main_${_uid()}');
        final added = await ImportService.mergeAll(plainPath, main);
        expect(added, 1);
      },
    );
  });
}
