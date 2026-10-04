import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/backup_encryption.dart';
import 'package:health_flare/data/database/backup_limits.dart';
import 'package:health_flare/data/database/import_service.dart';

// Issue #104: import read whatever file the user picked. An encrypted
// backup was read whole into memory and copied to an isolate, so a
// multi-GB file crashed the app; a plain one went straight to Isar's
// native code. Anything over the cap is now refused before it is read.

void main() {
  late Directory dir;

  setUpAll(() async {
    await Isar.initializeIsarCore();
  });

  setUp(() => dir = Directory.systemTemp.createTempSync('hf_limit_test_'));
  tearDown(() => dir.deleteSync(recursive: true));

  /// A sparse file of [bytes] length: takes no real disk space.
  File sized(String name, int bytes) {
    final f = File('${dir.path}/$name');
    final raf = f.openSync(mode: FileMode.write);
    raf.setPositionSync(bytes - 1);
    raf.writeByteSync(0);
    raf.closeSync();
    return f;
  }

  group('BackupLimits.check', () {
    test('accepts a file at the cap', () async {
      final f = sized('ok.isar', BackupLimits.maxBytes);
      await BackupLimits.check(f.path);
    });

    test('refuses a file one byte over the cap', () async {
      final f = sized('big.isar', BackupLimits.maxBytes + 1);
      await expectLater(
        BackupLimits.check(f.path),
        throwsA(isA<BackupTooLargeException>()),
      );
    });

    test('the message says what is wrong in plain words', () {
      expect(
        const BackupTooLargeException().message,
        'This file is too big to be a Health Flare backup.',
      );
    });

    test('is a kind of InvalidBackupException, so every existing import and '
        'restore path already treats it as "not a backup"', () {
      expect(const BackupTooLargeException(), isA<InvalidBackupException>());
    });
  });

  group('every entry point refuses an oversized file before reading it', () {
    test('ImportService.validate (restore and pending-restore)', () async {
      final f = sized('big.isar', BackupLimits.maxBytes + 1);
      await expectLater(
        ImportService.validate(f.path),
        throwsA(isA<BackupTooLargeException>()),
      );
    });

    test('EncryptedBackupCodec.decryptFile', () async {
      final f = sized('big.hfbackup', BackupLimits.maxBytes + 1);
      final out = '${dir.path}/out.isar';
      await expectLater(
        EncryptedBackupCodec.decryptFile(
          encryptedPath: f.path,
          outPath: out,
          password: 'correct horse battery staple',
        ),
        throwsA(isA<BackupTooLargeException>()),
      );
      expect(File(out).existsSync(), isFalse);
    });
  });
}
