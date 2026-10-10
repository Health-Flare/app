import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/models/profile.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';
import 'package:health_flare/core/files/scratch_files.dart';

/// Startup data read before [runApp] so providers have real values on
/// the first frame: avoids blank-frame flashes from async loads.
class StartupData {
  const StartupData({required this.profiles, required this.activeProfileId});

  final List<Profile> profiles;
  final int? activeProfileId;
}

/// Opens and initialises the Isar database for the lifetime of the app.
class IsarService {
  IsarService._();

  /// What happened to the data migrations during the last [open]. Read by
  /// [main] to tell the user about a skipped or failed upgrade.
  static MigrationResult lastMigration = const MigrationResult(
    MigrationOutcome.upToDate,
  );

  /// Opens the Isar database, runs schema migrations, and returns the instance.
  ///
  /// Must be called after [WidgetsFlutterBinding.ensureInitialized].
  /// Calling this a second time (e.g. after a hot restart) returns the
  /// existing open instance without re-opening.
  static Future<Isar> open() async {
    // On web, Isar uses IndexedDB and doesn't need a directory path.
    // On all other platforms, path_provider gives the app documents directory.
    final String? directory;
    if (kIsWeb) {
      directory = null;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      directory = dir.path;
      // Remove backups, reports and decrypted copies a previous run left in
      // temp (#102). Nothing can be using them yet.
      await ScratchFiles.sweep();
      // Apply any pending restore before opening: replaces the database file
      // while Isar is still closed, so no live instance juggling is required.
      await BackupService.applyPendingRestoreIfNeeded(directory);
    }

    final isar = await Isar.open(
      appSchemas,
      directory: directory ?? '',
      name: 'healthflare',
    );

    // Data migrations. On device, a copy of existing data is taken first and
    // no migration runs without one (#110). A snapshot or migration failure
    // doesn't stop the app opening: the result is shown to the user and the
    // next launch tries again. Web has no file system to copy to.
    if (directory != null) {
      lastMigration = await PreMigrationSnapshot.migrate(
        isar,
        documentsDir: directory,
      );
    } else {
      await MigrationRunner.run(isar);
    }

    return isar;
  }

  /// Reads profiles and active profile id before [runApp].
  ///
  /// Called in [main] after [open]. Because this file already imports the
  /// generated schema files, the Isar collection extension methods are
  /// visible here without extra imports in [main].
  static Future<StartupData> readStartupData(Isar isar) async {
    final profileRows = await isar.profileIsars.where().findAll();
    final settings = await isar.appSettings.get(1);
    return StartupData(
      profiles: profileRows.map((r) => r.toDomain()).toList(),
      activeProfileId: settings?.activeProfileId,
    );
  }
}
