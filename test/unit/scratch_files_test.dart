import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/core/files/scratch_files.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/models/profile_isar.dart';

// Issue #102: plain backups, PDF/CSV reports (named after the profile) and
// decrypted copies of encrypted backups were left in the temp directory.
// On a shared desktop account, or if the app died mid-import, anything that
// could read that folder could read the user's health data.

class _FakePathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.root);
  final Directory root;

  @override
  Future<String?> getTemporaryPath() async => '${root.path}/tmp';
  @override
  Future<String?> getApplicationDocumentsPath() async => '${root.path}/docs';
  @override
  Future<String?> getApplicationSupportPath() async => '${root.path}/support';
  @override
  Future<String?> getApplicationCachePath() async => '${root.path}/tmp';
  @override
  Future<String?> getLibraryPath() async => null;
  @override
  Future<String?> getExternalStoragePath() async => null;
  @override
  Future<List<String>?> getExternalCachePaths() async => null;
  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => null;
  @override
  Future<String?> getDownloadsPath() async => null;
}

void main() {
  late Directory root;
  late Directory tmp;

  setUpAll(() async {
    await Isar.initializeIsarCore();
  });

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_scratch_test_');
    tmp = Directory('${root.path}/tmp')..createSync();
    Directory('${root.path}/docs').createSync();
    PathProviderPlatform.instance = _FakePathProvider(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  File touch(String relative) => File('${tmp.path}/$relative')
    ..createSync(recursive: true)
    ..writeAsStringSync('health data');

  group('ScratchFiles.directory', () {
    test('is a Health Flare folder inside the temp directory', () async {
      final dir = await ScratchFiles.directory();
      expect(dir.path, '${tmp.path}/${ScratchFiles.folderName}');
      expect(dir.existsSync(), isTrue);
    });
  });

  group('ScratchFiles.sweep (at startup)', () {
    test('empties the scratch folder', () async {
      touch('${ScratchFiles.folderName}/Sarah_2026-10-04.pdf');
      touch('${ScratchFiles.folderName}/healthflare_decrypted_1.isar');
      touch('${ScratchFiles.folderName}/import_preview.isar');

      await ScratchFiles.sweep(appPrivateTemp: true);

      final left = Directory('${tmp.path}/${ScratchFiles.folderName}');
      expect(left.existsSync() ? left.listSync() : const [], isEmpty);
    });

    test('removes files earlier versions left loose in temp', () async {
      final legacy = [
        touch('healthflare_backup_20261001_0930.isar'),
        touch('healthflare_backup_20261001_0930.hfbackup'),
        touch('healthflare_decrypted_1727000000000.isar'),
        touch('import_preview.isar'),
        touch('import_preview.isar.lock'),
        touch('Sarah_2026-10-03.pdf'),
        touch('Ethan_2026-10-03.csv'),
      ];

      await ScratchFiles.sweep(appPrivateTemp: true);

      for (final f in legacy) {
        expect(f.existsSync(), isFalse, reason: '${f.path} should be gone');
      }
    });

    test('clears the copy share_plus keeps on Android', () async {
      final copy = touch('share_plus/Sarah_2026-10-03.pdf');
      await ScratchFiles.sweep(appPrivateTemp: true);
      expect(copy.existsSync(), isFalse);
    });

    test('in a shared temp folder (Windows, Linux) never touches files that '
        'could belong to another app', () async {
      final notOurs = [
        touch('Quarterly_2026-10-03.csv'),
        touch('Invoice_2026-10-03.pdf'),
        touch('share_plus/other.txt'),
        touch('notes.txt'),
      ];
      final ours = [
        touch('${ScratchFiles.folderName}/Sarah_2026-10-04.pdf'),
        touch('healthflare_backup_20261001_0930.isar'),
        touch('healthflare_decrypted_1727000000000.isar'),
      ];

      await ScratchFiles.sweep(appPrivateTemp: false);

      for (final f in notOurs) {
        expect(f.existsSync(), isTrue, reason: '${f.path} is not ours');
      }
      for (final f in ours) {
        expect(f.existsSync(), isFalse, reason: '${f.path} should be gone');
      }
    });

    test('leaves everything else in temp alone', () async {
      final other = touch('some_cache/thing.bin');
      final similar = touch('healthflare_settings.json');
      await ScratchFiles.sweep(appPrivateTemp: true);
      expect(other.existsSync(), isTrue);
      expect(similar.existsSync(), isTrue);
    });

    test('does not throw when temp is empty or missing', () async {
      tmp.deleteSync(recursive: true);
      await ScratchFiles.sweep(appPrivateTemp: true);
    });
  });

  group('ScratchFiles.shareThenDelete', () {
    test('deletes the file after a share on phones', () async {
      final f = touch('${ScratchFiles.folderName}/Sarah_2026-10-04.csv');
      var shared = false;

      await ScratchFiles.shareThenDelete(
        f.path,
        () async => shared = true,
        deleteNow: true,
      );

      expect(shared, isTrue);
      expect(f.existsSync(), isFalse);
    });

    test('deletes the file even when the share fails', () async {
      final f = touch('${ScratchFiles.folderName}/Sarah_2026-10-04.csv');

      await expectLater(
        ScratchFiles.shareThenDelete(
          f.path,
          () async => throw Exception('share failed'),
          deleteNow: true,
        ),
        throwsException,
      );

      expect(f.existsSync(), isFalse);
    });

    test('keeps the file on desktop, where the share target may still be '
        'reading it; the next launch sweeps it', () async {
      final f = touch('${ScratchFiles.folderName}/Sarah_2026-10-04.csv');

      await ScratchFiles.shareThenDelete(f.path, () async {}, deleteNow: false);

      expect(f.existsSync(), isTrue);
    });
  });

  group('writers use the scratch folder', () {
    test('a plain backup export is written there', () async {
      final isar = await Isar.open(
        [ProfileIsarSchema, AppSettingsSchema],
        directory: '',
        name: 'scratch_export_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(() => isar.appSettings.put(AppSettings()));

      final path = await BackupService.export(isar);

      expect(path, startsWith('${tmp.path}/${ScratchFiles.folderName}/'));
    });

    test('nothing else in lib/ writes to the temp directory directly', () {
      // Every short-lived file with user data must go through ScratchFiles
      // so the startup sweep removes it. A new getTemporaryDirectory() call
      // elsewhere would bring #102 back.
      final offenders = [
        for (final f in Directory('lib').listSync(recursive: true))
          if (f is File &&
              f.path.endsWith('.dart') &&
              !f.path.endsWith('core/files/scratch_files.dart') &&
              f.readAsStringSync().contains('getTemporaryDirectory('))
            f.path,
      ];
      expect(offenders, isEmpty);
    });
  });
}
