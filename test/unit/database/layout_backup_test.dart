import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';

import '../../helpers/isar_core.dart';

// Backups of layout settings (#144).
// Spec: docs/features/navigation-customization.feature ("Backups") and
// docs/features/whats-new.feature (backups).

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

const _mine = ['dashboard', 'track', 'care', 'care.medications'];
const _theirs = ['dashboard', 'track', 'care.medications', 'track.meals'];

var _n = 0;

Future<Isar> _open(String dir, {String name = 'healthflare'}) =>
    Isar.open(appSchemas, directory: dir, name: name);

/// A database on the current schema with [profiles] (name -> features off)
/// and this bar.
Future<void> _seed(
  Isar isar, {
  Map<String, List<String>> profiles = const {'Sarah': []},
  List<String>? bar,
  bool highlightsOff = false,
  String? lastSeen,
}) async {
  await isar.writeTxn(() async {
    await isar.appSettings.put(
      AppSettings()
        ..id = 1
        ..schemaVersion = 21
        ..lastProfileId = 1
        ..bottomBarIds = bar
        ..bottomBarLayoutVersion = 2
        ..updateHighlightsOff = highlightsOff
        ..lastSeenWhatsNewVersion = lastSeen,
    );
    var id = 1;
    for (final e in profiles.entries) {
      await isar.profileIsars.put(
        ProfileIsar()
          ..id = id++
          ..name = e.key
          ..disabledFeatureIds = e.value,
      );
    }
  });
}

Future<List<String>> _off(Isar isar, String name) async =>
    (await isar.profileIsars.filter().nameEqualTo(name).findFirst())!
        .disabledFeatureIds;

void main() {
  late Directory root;
  late Directory docs;
  late Directory tmp;

  setUpAll(() async => initializeIsarCoreForTests());

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_layout_backup_test_');
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

  /// A backup made elsewhere with [bar] and these profiles.
  Future<String> backupWith({
    List<String>? bar,
    Map<String, List<String>> profiles = const {'Sarah': []},
    bool highlightsOff = false,
    String? lastSeen,
  }) async {
    final source = await _open(tmp.path, name: 'other_phone_${_n++}');
    await _seed(
      source,
      profiles: profiles,
      bar: bar,
      highlightsOff: highlightsOff,
      lastSeen: lastSeen,
    );
    final exported = await BackupService.export(source);
    await source.close();
    // Exports are named by the second; two in one test would collide.
    return (await File(exported).rename('${tmp.path}/backup_$_n.isar')).path;
  }

  group('Replace everything', () {
    Future<Isar> restore(String backup) async {
      final live = await _open(docs.path);
      await _seed(live, profiles: {'Mia': []});
      await live.close();
      await BackupService.stagePendingRestore(backup);
      await BackupService.applyPendingRestoreIfNeeded(docs.path);
      return _open(docs.path);
    }

    test('Replace everything restores layout and features in use', () async {
      final restored = await restore(
        await backupWith(
          bar: _theirs,
          profiles: {
            'Sarah': ['track.meals'],
          },
        ),
      );
      expect((await BarLayoutStore.read(restored)).storedBar, _theirs);
      expect(await _off(restored, 'Sarah'), ['track.meals']);
    });

    test('"Show update highlights" is part of backups', () async {
      final restored = await restore(await backupWith(highlightsOff: true));
      expect((await restored.appSettings.get(1))!.updateHighlightsOff, isTrue);
    });

    test(
      "Restoring onto a newer version still shows that version's card",
      () async {
        final restored = await restore(await backupWith(lastSeen: '1.10.0'));
        final settings = (await restored.appSettings.get(1))!;
        final releases = [
          _release('1.10.0'),
          _release('1.11.0', highlights: false),
          _release('1.12.0'),
        ];
        final record = settleLaunch(
          record: WhatsNewRecord(
            lastSeenVersion: settings.lastSeenWhatsNewVersion,
            highlightsOff: settings.updateHighlightsOff,
          ),
          releases: releases,
          installed: '1.12.0',
          hasProfiles: true,
        );
        final card = cardReleases(
          releases: releases,
          lastSeen: record.lastSeenVersion!,
          installed: '1.12.0',
        );
        expect([for (final r in card) r.version], ['1.12.0']);
      },
    );
  });

  group('Add missing data', () {
    test("keeps this device's bar if it was customized", () async {
      final live = await _open(docs.path);
      await _seed(live, bar: _mine);
      final report = ImportReport();
      await ImportService.mergeAll(
        await backupWith(bar: _theirs),
        live,
        report: report,
      );
      expect((await BarLayoutStore.read(live)).storedBar, _mine);
      expect(report.barImported, isFalse);
    });

    test("takes the backup's bar onto a default device, and says so", () async {
      final live = await _open(docs.path);
      await _seed(live);
      final report = ImportReport();
      await ImportService.mergeAll(
        await backupWith(bar: _theirs),
        live,
        report: report,
      );
      expect(
        await BarLayoutStore.read(live),
        const BarRecord(storedBar: _theirs, seenVersion: 2),
      );
      expect(report.barImported, isTrue);
      expect(
        importCompleteMessage(0, barImported: true),
        'Bottom bar restored from the backup. Change it in Settings > '
        'Your layout.',
      );
      expect(
        importCompleteMessage(3, barImported: true),
        'Added 3 records. Bottom bar restored from the backup. Change it in '
        'Settings > Your layout.',
      );
    });

    test('a backup on the default bar changes nothing', () async {
      final live = await _open(docs.path);
      await _seed(live);
      final report = ImportReport();
      await ImportService.mergeAll(await backupWith(), live, report: report);
      expect((await BarLayoutStore.read(live)).storedBar, isNull);
      expect(report.barImported, isFalse);
    });

    test('Features in use travel with their profile', () async {
      final live = await _open(docs.path);
      await _seed(live);
      await ImportService.mergeAll(
        await backupWith(
          profiles: {
            'Sarah': [],
            'Dad': ['track.meals'],
          },
        ),
        live,
      );
      expect(await _off(live, 'Dad'), ['track.meals']);
    });

    test(
      "A profile that exists on both keeps this device's switches",
      () async {
        final live = await _open(docs.path);
        await _seed(live);
        await ImportService.mergeAll(
          await backupWith(
            profiles: {
              'Sarah': ['track.meals'],
            },
          ),
          live,
        );
        expect(await _off(live, 'Sarah'), isEmpty);
      },
    );

    test('the highlights setting stays this device\'s', () async {
      final live = await _open(docs.path);
      await _seed(live);
      await ImportService.mergeAll(await backupWith(highlightsOff: true), live);
      expect((await live.appSettings.get(1))!.updateHighlightsOff, isFalse);
    });
  });

  group('Choose what to import lists layout as its own item', () {
    ImportCategoryInfo? layoutIn(List<ImportCategoryInfo> cats) =>
        cats.where((c) => c.id == ImportCategoryId.layout).firstOrNull;

    test('listed, with the bar it would bring, unticked when this device '
        'has its own bar', () async {
      final live = await _open(docs.path);
      await _seed(live, bar: _mine);
      final cats = await ImportService.preview(
        await backupWith(bar: _theirs),
        live,
      );
      final layout = layoutIn(cats)!;
      expect(layout.label, 'Bottom bar and layout');
      expect(layout.selected, isFalse);
      expect(layout.detail, 'Dashboard, Track, Medications, Meals');
    });

    test('ticked on a device with the default bar', () async {
      final live = await _open(docs.path);
      await _seed(live);
      final cats = await ImportService.preview(
        await backupWith(bar: _theirs),
        live,
      );
      expect(layoutIn(cats)!.selected, isTrue);
    });

    test(
      'not listed when the backup has the default bar, or the same one',
      () async {
        final live = await _open(docs.path);
        await _seed(live, bar: _theirs);
        expect(
          layoutIn(await ImportService.preview(await backupWith(), live)),
          isNull,
        );
        expect(
          layoutIn(
            await ImportService.preview(await backupWith(bar: _theirs), live),
          ),
          isNull,
        );
      },
    );

    test("ticked, the backup's bar replaces this device's", () async {
      final live = await _open(docs.path);
      await _seed(live, bar: _mine);
      final report = ImportReport();
      await ImportService.mergeSelected(await backupWith(bar: _theirs), live, {
        ImportCategoryId.layout,
      }, report: report);
      expect((await BarLayoutStore.read(live)).storedBar, _theirs);
      expect(report.barImported, isTrue);
    });

    test("unticked, this device's bar stays, even on the default", () async {
      final live = await _open(docs.path);
      await _seed(live);
      await ImportService.mergeSelected(await backupWith(bar: _theirs), live, {
        ImportCategoryId.profiles,
      });
      expect((await BarLayoutStore.read(live)).storedBar, isNull);
    });
  });

  test(
    'A backup from a newer version with unknown ids still imports',
    () async {
      final live = await _open(docs.path);
      await _seed(live);
      final newer = ['dashboard', 'track.water', 'track', 'care'];
      await ImportService.mergeAll(await backupWith(bar: newer), live);
      final record = await BarLayoutStore.read(live);
      // Stored as it came, so a later version that knows the id can show it;
      // shown by the "id the app doesn't recognise" rule.
      expect(record.storedBar, newer);
      expect(barFor(record, current: 2), ['dashboard', 'track', 'care']);
    },
  );
}

ReleaseNote _release(String version, {bool highlights = true}) =>
    ReleaseNote.fromJson({
      'version': version,
      'date': '2026-10-01',
      'highlights': highlights
          ? [
              {'title': 'Something new in $version', 'body': 'Details.'},
            ]
          : <Object>[],
    });
