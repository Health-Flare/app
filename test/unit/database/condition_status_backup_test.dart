// docs/features/illness.feature, "Recovery and relapse" (#157): a
// condition's status and history survive "Add missing data".
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';

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

Future<Isar> _open(String dir, {String name = 'healthflare'}) =>
    Isar.open(appSchemas, directory: dir, name: name);

Future<void> _seed(Isar isar, {UserConditionIsar? condition}) async {
  await isar.writeTxn(() async {
    await isar.appSettings.put(
      AppSettings()
        ..id = 1
        ..schemaVersion = 22
        ..lastProfileId = 1,
    );
    await isar.profileIsars.put(
      ProfileIsar()
        ..id = 1
        ..name = 'Sarah',
    );
    if (condition != null) await isar.userConditionIsars.put(condition);
  });
}

void main() {
  late Directory root;
  late Directory docs;
  late Directory tmp;

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_condition_status_');
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

  test('a condition in recovery keeps its status and history', () async {
    final source = await _open(tmp.path, name: 'other_phone');
    await _seed(
      source,
      condition: UserConditionIsar()
        ..profileId = 1
        ..conditionId = 7
        ..conditionName = 'Fibromyalgia'
        ..trackedSince = DateTime(2021, 6, 15)
        ..diagnosedAt = DateTime(2021, 6, 15)
        ..status = 'inRecovery'
        ..statusHistory = [
          ConditionStatusEventIsar()
            ..eventType = 'recovery'
            ..date = DateTime(2025, 4, 20),
          ConditionStatusEventIsar()
            ..eventType = 'relapse'
            ..date = DateTime(2025, 5, 1),
          ConditionStatusEventIsar()
            ..eventType = 'recovery'
            ..date = DateTime(2025, 9, 3),
        ],
    );
    final exported = await BackupService.export(source);
    await source.close();

    final live = await _open(docs.path);
    await _seed(live);
    await ImportService.mergeAll(exported, live, report: ImportReport());

    final got = (await live.userConditionIsars.where().findAll()).single;
    expect(got.status, 'inRecovery');
    expect(
      [for (final e in got.statusHistory) (e.eventType, e.date)],
      [
        ('recovery', DateTime(2025, 4, 20)),
        ('relapse', DateTime(2025, 5, 1)),
        ('recovery', DateTime(2025, 9, 3)),
      ],
    );
  });
}
