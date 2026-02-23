import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';

/// Runs any pending data migrations after the Isar database is opened.
///
/// Schema v1 = initial Isar schema (this release).
///
/// How to add a future migration:
///   1. Increment [_targetVersion].
///   2. Add an `if (currentVersion < N)` block inside [run].
///   3. Update [AppSettings.schemaVersion] at the end of each block.
///   4. Each block should be idempotent — it only writes what has changed.
///
/// Isar automatically handles structural changes (adding/removing fields and
/// collections). [MigrationRunner] is for data migrations: transforming
/// existing values, backfilling new fields, or splitting/merging records.
class MigrationRunner {
  MigrationRunner._();

  static const int _targetVersion = 1;

  /// Run all pending migrations and update [AppSettings.schemaVersion].
  ///
  /// Called by [IsarService.open] before returning the [Isar] instance.
  static Future<void> run(Isar isar) async {
    final settings = await isar.appSettings.get(1);
    final currentVersion = settings?.schemaVersion ?? 0;

    if (currentVersion >= _targetVersion) return;

    // ── v0 → v1: initialise AppSettings singleton ─────────────────────────
    // v0 = pre-Isar (in-memory only). No existing data to migrate.
    // This block creates the AppSettings document for the first time.
    if (currentVersion < 1) {
      await isar.writeTxn(() async {
        final s = AppSettings()
          ..id = 1
          ..schemaVersion = 1;
        await isar.appSettings.put(s);
      });
    }

    // ── Future migrations ──────────────────────────────────────────────────
    // if (currentVersion < 2) { ... }
  }
}
