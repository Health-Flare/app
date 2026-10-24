// #105: photos live in <documents>/photos under names the app gave them.
// Only those are shown, a backup can't point one anywhere else, and a
// photo goes when nothing points at it any more.
// Spec: docs/features/meals.feature and profiles.feature, "Photos".
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:health_flare/core/files/photo_store.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import '../../helpers/isar_core.dart';

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

final _jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 0x10, 74, 70]);
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
]);
final _managedName = RegExp(r'^[0-9a-f]{32}\.(jpg|png|heic)$');

void main() {
  late Directory root;
  late Directory docs;
  late Directory tmp;

  /// A file as a picker would hand it over, in temp.
  String picked(String name, Uint8List bytes) =>
      (File('${tmp.path}/$name')..writeAsBytesSync(bytes)).path;

  List<String> photoFiles() {
    final dir = Directory('${docs.path}/photos');
    if (!dir.existsSync()) return [];
    return [
      for (final f in dir.listSync().whereType<File>()) f.uri.pathSegments.last,
    ]..sort();
  }

  Future<Isar> open([String name = 'healthflare', String? dir]) =>
      Isar.open(appSchemas, directory: dir ?? docs.path, name: name);

  Future<void> seed(Isar isar, {int version = 0}) async {
    await isar.writeTxn(() async {
      await isar.appSettings.put(
        AppSettings()
          ..id = 1
          ..schemaVersion = version == 0
              ? MigrationRunner.targetVersion
              : version
          ..lastProfileId = 1
          ..activeProfileId = 1,
      );
      await isar.profileIsars.put(
        ProfileIsar()
          ..id = 1
          ..name = 'Sarah',
      );
    });
  }

  ProviderContainer container(Isar isar) {
    final c = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUpAll(() async => initializeIsarCoreForTests());

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_photos_');
    docs = Directory('${root.path}/docs')..createSync();
    tmp = Directory('${root.path}/tmp')..createSync();
    PathProviderPlatform.instance = _FakePathProvider(
      tempDir: tmp,
      docsDir: docs,
    );
    PhotoStore.init(docs.path);
  });

  tearDown(() async {
    PhotoStore.reset();
    for (final isar
        in Isar.instanceNames.map(Isar.getInstance).whereType<Isar>()) {
      if (isar.isOpen) await isar.close();
    }
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('PhotoStore', () {
    test('adopt copies a picked image in under a new name', () async {
      final src = picked('image_picker_1.jpg', _jpeg);
      final name = await PhotoStore.adopt(src);
      expect(name, matches(_managedName));
      expect(name, endsWith('.jpg'));
      expect(File('${docs.path}/photos/$name').readAsBytesSync(), _jpeg);
      expect(File(src).existsSync(), isTrue, reason: 'the original is left');
    });

    test('adopt names a PNG .png, whatever the source says', () async {
      expect(await PhotoStore.adopt(picked('x.jpg', _png)), endsWith('.png'));
    });

    test('adopt refuses a file that is not an image', () async {
      final notImage = picked(
        'notes.jpg',
        Uint8List.fromList('hello'.codeUnits),
      );
      expect(await PhotoStore.adopt(notImage), isNull);
      expect(photoFiles(), isEmpty);
    });

    test('adopt keeps a name that is already ours', () async {
      final name = await PhotoStore.adopt(picked('a.jpg', _jpeg));
      expect(await PhotoStore.adopt(name), name);
      expect(photoFiles(), hasLength(1));
    });

    test('resolve shows only our own photos', () async {
      final name = await PhotoStore.adopt(picked('a.jpg', _jpeg));
      expect(PhotoStore.resolve(name)?.path, '${docs.path}/photos/$name');
      expect(
        PhotoStore.resolve(picked('elsewhere.jpg', _jpeg)),
        isNull,
        reason: 'an absolute path, even to a real image',
      );
      expect(PhotoStore.resolve('../healthflare.isar'), isNull);
      expect(PhotoStore.resolve('${'0' * 32}.jpg'), isNull, reason: 'missing');
      PhotoStore.reset();
      expect(PhotoStore.resolve(name), isNull, reason: 'not initialised');
    });

    test('sweep deletes photos nothing points at', () async {
      final isar = await open();
      await seed(isar);
      final kept = await PhotoStore.adopt(picked('a.jpg', _jpeg));
      final avatar = await PhotoStore.adopt(picked('b.jpg', _jpeg));
      final orphan = await PhotoStore.adopt(picked('c.jpg', _jpeg));
      File('${docs.path}/photos/notes.txt').writeAsStringSync('not ours');
      await isar.writeTxn(() async {
        await isar.mealEntryIsars.put(
          MealEntryIsar()
            ..profileId = 1
            ..description = 'Soup'
            ..hasReaction = false
            ..photoPath = kept
            ..loggedAt = DateTime(2026)
            ..createdAt = DateTime(2026),
        );
        final p = (await isar.profileIsars.get(1))!..avatarPath = avatar;
        await isar.profileIsars.put(p);
      });

      final later = DateTime.now().add(const Duration(minutes: 5));
      expect(await PhotoStore.sweep(isar, now: later), 1);
      expect(photoFiles(), [avatar!, kept!, 'notes.txt']..sort());
      expect(orphan, isNotNull);
    });

    test('sweep leaves a photo copied in moments ago', () async {
      final isar = await open();
      await seed(isar);
      await PhotoStore.adopt(picked('a.jpg', _jpeg));
      expect(await PhotoStore.sweep(isar), 0);
      expect(photoFiles(), hasLength(1));
    });
  });

  group('meals', () {
    test('a picked photo is stored as ours', () async {
      final isar = await open();
      await seed(isar);
      final c = container(isar);
      final id = await c
          .read(mealEntryListProvider.notifier)
          .add(
            profileId: 1,
            description: 'Soup',
            photoPath: picked('image_picker_9.jpg', _jpeg),
            hasReaction: false,
            loggedAt: DateTime(2026),
          );
      final stored = (await isar.mealEntryIsars.get(id))!.photoPath;
      expect(stored, matches(_managedName));
      expect(photoFiles(), [stored]);
    });

    test("removing a meal's photo, or the meal, deletes the file", () async {
      final isar = await open();
      await seed(isar);
      final c = container(isar);
      final meals = c.read(mealEntryListProvider.notifier);
      final id = await meals.add(
        profileId: 1,
        description: 'Soup',
        photoPath: picked('a.jpg', _jpeg),
        hasReaction: false,
        loggedAt: DateTime(2026),
      );
      final row = (await isar.mealEntryIsars.get(id))!;
      await meals.update(row.toDomain().copyWith(clearPhotoPath: true));
      await PhotoStore.sweep(
        isar,
        now: DateTime.now().add(const Duration(minutes: 5)),
      );
      expect(photoFiles(), isEmpty, reason: 'photo removed from the meal');

      final id2 = await meals.add(
        profileId: 1,
        description: 'Toast',
        photoPath: picked('b.jpg', _jpeg),
        hasReaction: false,
        loggedAt: DateTime(2026),
      );
      expect(photoFiles(), hasLength(1));
      await meals.remove(id2);
      await PhotoStore.sweep(
        isar,
        now: DateTime.now().add(const Duration(minutes: 5)),
      );
      expect(photoFiles(), isEmpty, reason: 'meal deleted');
    });
  });

  group('profiles', () {
    test('a picked avatar is stored as ours', () async {
      final isar = await open();
      await seed(isar);
      final c = container(isar);
      await c
          .read(profileListProvider.notifier)
          .add(name: 'Leo', avatarPath: picked('me.png', _png));
      final leo = (await isar.profileIsars.where().findAll()).last;
      expect(leo.avatarPath, matches(_managedName));
      expect(leo.avatarPath, endsWith('.png'));
    });

    test(
      "deleting a profile deletes its avatar and its meals' photos",
      () async {
        final isar = await open();
        await seed(isar);
        final c = container(isar);
        await c
            .read(profileListProvider.notifier)
            .add(name: 'Leo', avatarPath: picked('me.jpg', _jpeg));
        final leo = (await isar.profileIsars.where().findAll()).last;
        await c
            .read(mealEntryListProvider.notifier)
            .add(
              profileId: leo.id,
              description: 'Soup',
              photoPath: picked('soup.jpg', _jpeg),
              hasReaction: false,
              loggedAt: DateTime(2026),
            );
        expect(photoFiles(), hasLength(2));

        await c.read(profileListProvider.notifier).remove(leo.id);
        await PhotoStore.sweep(
          isar,
          now: DateTime.now().add(const Duration(minutes: 5)),
        );
        expect(photoFiles(), isEmpty);
      },
    );
  });

  test(
    '"Add missing data" drops a photo path the backup points anywhere',
    () async {
      final source = await open('other_phone', tmp.path);
      await seed(source);
      final secret = picked('secret.jpg', _jpeg);
      await source.writeTxn(() async {
        final p = (await source.profileIsars.get(1))!..avatarPath = secret;
        await source.profileIsars.put(p);
        await source.profileIsars.put(
          ProfileIsar()
            ..id = 2
            ..name = 'Leo'
            ..avatarPath = secret,
        );
      });
      final exported = await BackupService.export(source);
      await source.close();

      final live = await open();
      await seed(live);
      await ImportService.mergeAll(exported, live, report: ImportReport());

      final leo = (await live.profileIsars.where().findAll()).firstWhere(
        (p) => p.name == 'Leo',
      );
      expect(leo.avatarPath, isNull);
    },
  );

  group('"Replace everything"', () {
    // Restores the backup at [backupDb] the way the app does: staged, swapped
    // in on the next launch, then upgraded.
    Future<Isar> restore(Isar backupDb) async {
      final exported = await BackupService.export(backupDb);
      await backupDb.close();
      final live = await open();
      await seed(live);
      await live.close();
      await BackupService.stagePendingRestore(exported);
      await BackupService.applyPendingRestoreIfNeeded(docs.path);
      final isar = await open();
      await MigrationRunner.run(isar);
      return isar;
    }

    test(
      'an older backup cannot point a photo at a file on this phone',
      () async {
        final source = await open('other_phone', tmp.path);
        await seed(source, version: 23);
        final secret = picked('secret.jpg', _jpeg);
        await source.writeTxn(() async {
          final p = (await source.profileIsars.get(1))!..avatarPath = secret;
          await source.profileIsars.put(p);
          await source.mealEntryIsars.put(
            MealEntryIsar()
              ..profileId = 1
              ..description = 'Soup'
              ..hasReaction = false
              ..photoPath = secret
              ..loggedAt = DateTime(2026)
              ..createdAt = DateTime(2026),
          );
        });

        final isar = await restore(source);

        expect((await isar.profileIsars.get(1))!.avatarPath, isNull);
        expect(
          (await isar.mealEntryIsars.where().findFirst())!.photoPath,
          isNull,
        );
        expect(photoFiles(), isEmpty);
      },
    );

    test('a backup from this phone keeps the photos that are here', () async {
      // Regression guard: our own names in the backup still show.
      final source = await open('this_phone', tmp.path);
      await seed(source);
      final name = (await PhotoStore.adopt(picked('me.png', _png)))!;
      await source.writeTxn(() async {
        final p = (await source.profileIsars.get(1))!..avatarPath = name;
        await source.profileIsars.put(p);
      });

      final isar = await restore(source);

      expect((await isar.profileIsars.get(1))!.avatarPath, name);
      expect(PhotoStore.resolve(name), isNotNull);
    });
  });

  test(
    '"Add missing data" keeps a meal photo that is in our photos folder',
    () async {
      final source = await open('this_phone', tmp.path);
      await seed(source);
      final name = (await PhotoStore.adopt(picked('soup.jpg', _jpeg)))!;
      await source.writeTxn(() async {
        await source.mealEntryIsars.put(
          MealEntryIsar()
            ..profileId = 1
            ..description = 'Soup'
            ..hasReaction = false
            ..photoPath = name
            ..loggedAt = DateTime(2026)
            ..createdAt = DateTime(2026),
        );
      });
      final exported = await BackupService.export(source);
      await source.close();

      final live = await open();
      await seed(live);
      await ImportService.mergeAll(exported, live, report: ImportReport());

      expect((await live.mealEntryIsars.where().findFirst())!.photoPath, name);
    },
  );

  group('v24 moves photos from before this update', () {
    test('a photo that is still there is copied in under our name', () async {
      final isar = await open();
      await seed(isar, version: 23);
      final legacy = picked('image_picker_ABC.jpg', _jpeg);
      await isar.writeTxn(() async {
        final p = (await isar.profileIsars.get(1))!..avatarPath = legacy;
        await isar.profileIsars.put(p);
      });

      await MigrationRunner.run(isar);

      final stored = (await isar.profileIsars.get(1))!.avatarPath;
      expect(stored, matches(_managedName));
      expect(File('${docs.path}/photos/$stored').readAsBytesSync(), _jpeg);
      expect((await isar.appSettings.get(1))!.schemaVersion, 24);
    });

    test('a photo the OS already cleared is dropped', () async {
      final isar = await open();
      await seed(isar, version: 23);
      await isar.writeTxn(() async {
        await isar.mealEntryIsars.put(
          MealEntryIsar()
            ..profileId = 1
            ..description = 'Soup'
            ..hasReaction = false
            ..photoPath = '${tmp.path}/gone.jpg'
            ..loggedAt = DateTime(2026)
            ..createdAt = DateTime(2026),
        );
      });

      await MigrationRunner.run(isar);

      expect(
        (await isar.mealEntryIsars.where().findFirst())!.photoPath,
        isNull,
      );
    });

    test(
      'a path to something that is not an image is dropped, not copied',
      () async {
        final isar = await open();
        await seed(isar, version: 23);
        await isar.writeTxn(() async {
          final p = (await isar.profileIsars.get(1))!
            ..avatarPath = '${docs.path}/healthflare.isar';
          await isar.profileIsars.put(p);
        });

        await MigrationRunner.run(isar);

        expect((await isar.profileIsars.get(1))!.avatarPath, isNull);
        expect(photoFiles(), isEmpty);
      },
    );
  });
}
