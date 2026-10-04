import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/security/backup_exclusion.dart' as backup;
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';

/// What happened to the data migrations at startup.
enum MigrationOutcome {
  /// Fresh install, or the database was already on the current version.
  /// No snapshot was taken.
  upToDate,

  /// A snapshot was taken (or reused) and every migration ran.
  migrated,

  /// The snapshot couldn't be written, so no migration ran. The database is
  /// unchanged and the next launch tries again.
  skippedNoSnapshot,

  /// A snapshot was taken, then a migration threw. The snapshot is kept and
  /// the next launch tries again.
  failed,
}

/// Result of [PreMigrationSnapshot.migrate].
class MigrationResult {
  const MigrationResult(this.outcome, {this.snapshotPath, this.error});

  final MigrationOutcome outcome;

  /// The snapshot taken (or reused) before migrating, if any.
  final String? snapshotPath;

  /// The error that stopped the snapshot or the migration, if any.
  final Object? error;

  /// Message shown to the user on the first screen, or null when there is
  /// nothing to say.
  String? get startupNotice => switch (outcome) {
    MigrationOutcome.upToDate || MigrationOutcome.migrated => null,
    MigrationOutcome.skippedNoSnapshot =>
      "Health Flare couldn't save a safety copy of your data, so it "
          "didn't update it. Your data is unchanged. It will try again next "
          'time you open the app. If this keeps happening, free up some '
          'storage on your phone.',
    MigrationOutcome.failed =>
      "Health Flare couldn't finish updating your data. A copy of your "
          'data from before the update is saved on this phone. It will try '
          'again next time you open the app. To be safe, export a backup '
          'from Settings.',
  };
}

/// Writes a copy of [isar] to [path]. Production uses [Isar.copyToFile];
/// tests inject a writer that throws.
typedef SnapshotWriter = Future<void> Function(Isar isar, String path);

/// Takes a copy of the database before data migrations change it (#110).
///
/// Migrations run on the only copy of a family's records, and some of them
/// delete rows (v18). So before [MigrationRunner.run] does any work on
/// existing data, the live database is copied to
/// `<documents>/snapshots/healthflare_pre_v<from>_<UTC stamp>.isar`.
///
/// Rules:
/// - Only when there is existing data and a migration is pending
///   ([MigrationRunner.needsMigration]). Fresh installs and up-to-date
///   databases take no snapshot.
/// - No snapshot, no migration. The database opens unchanged and the next
///   launch tries again.
/// - A failed migration keeps its snapshot and the app still opens. The
///   snapshot is a normal Isar file, restorable with
///   `BackupService.stagePendingRestore`.
/// - A retry after a failed migration reuses the first snapshot instead of
///   copying the half-migrated database, which would also push the real
///   pre-upgrade copy out of the newest [keep].
/// - After a successful migration only the newest [keep] snapshots are kept.
/// - The snapshots folder is kept out of phone backups: iOS via
///   [backup.excludeFromBackup], Android via the backup rules xml.
class PreMigrationSnapshot {
  PreMigrationSnapshot._();

  /// Folder under the app documents directory that holds the snapshots.
  static const directoryName = 'snapshots';

  /// How many snapshots to keep.
  static const keep = 3;

  /// Records the snapshot taken for a migration that hasn't finished yet.
  /// Holds `<from version>\n<snapshot file name>`. Deleted when the
  /// migration succeeds or a restore replaces the database.
  static const pendingMarkerName = '.pending_migration';

  static final _namePattern = RegExp(
    r'^healthflare_pre_v(\d+)_(\d{8}T\d{6}Z)\.isar$',
  );

  /// Path of the snapshots folder under [documentsDir].
  static String directoryPath(String documentsDir) =>
      '$documentsDir/$directoryName';

  /// Forgets any unfinished migration's snapshot. Called when a restore
  /// replaces the live database: the next migration must copy the restored
  /// data, not reuse a snapshot of the old one.
  static Future<void> clearPendingMarker(String documentsDir) async {
    final marker = File('${directoryPath(documentsDir)}/$pendingMarkerName');
    if (marker.existsSync()) await marker.delete();
  }

  /// Takes a snapshot if one is needed, then runs the data migrations.
  ///
  /// Never throws for a snapshot or migration failure: the outcome says what
  /// happened, so startup can open the app and tell the user.
  static Future<MigrationResult> migrate(
    Isar isar, {
    required String documentsDir,
    SnapshotWriter? writer,
    Future<void> Function(Isar isar)? migrate,
    DateTime Function()? now,
    Future<bool> Function(String path)? excludeFromBackup,
  }) async {
    final runMigrations = migrate ?? MigrationRunner.run;

    if (!await MigrationRunner.needsMigration(isar)) {
      // Fresh install (seeds the catalogue) or already up to date (no-op).
      // Nothing to protect, so no snapshot.
      await runMigrations(isar);
      return const MigrationResult(MigrationOutcome.upToDate);
    }

    final settings = await isar.appSettings.get(1);
    final from = settings!.schemaVersion;
    final dir = Directory(directoryPath(documentsDir));
    final marker = File('${dir.path}/$pendingMarkerName');

    String snapshotPath;
    try {
      if (!dir.existsSync()) await dir.create(recursive: true);
      await (excludeFromBackup ?? backup.excludeFromBackup)(dir.path);

      final reused = _pendingSnapshot(marker, from, dir.path);
      if (reused != null) {
        snapshotPath = reused;
      } else {
        snapshotPath = await _write(
          isar,
          dir.path,
          from,
          (now ?? DateTime.now)().toUtc(),
          writer ?? (db, path) => db.copyToFile(path),
        );
        await marker.writeAsString('$from\n${_fileName(snapshotPath)}');
      }
    } catch (e) {
      debugPrint('Health Flare: no snapshot, migration skipped: $e');
      return MigrationResult(MigrationOutcome.skippedNoSnapshot, error: e);
    }

    try {
      await runMigrations(isar);
    } catch (e, st) {
      debugPrint('Health Flare: migration from v$from failed: $e\n$st');
      return MigrationResult(
        MigrationOutcome.failed,
        snapshotPath: snapshotPath,
        error: e,
      );
    }

    // Success: the snapshot is now a plain "before" copy. Prune old ones.
    try {
      if (marker.existsSync()) await marker.delete();
      await _prune(dir);
    } catch (e) {
      // Housekeeping only. The data is migrated and the snapshot is kept.
      debugPrint('Health Flare: snapshot cleanup failed: $e');
    }
    return MigrationResult(
      MigrationOutcome.migrated,
      snapshotPath: snapshotPath,
    );
  }

  /// The snapshot recorded by an unfinished migration from [from], if it is
  /// still on disk.
  static String? _pendingSnapshot(File marker, int from, String dir) {
    if (!marker.existsSync()) return null;
    final lines = marker.readAsLinesSync();
    if (lines.length < 2 || int.tryParse(lines[0]) != from) return null;
    if (!_namePattern.hasMatch(lines[1])) return null;
    final file = File('$dir/${lines[1]}');
    if (!file.existsSync()) return null;
    return file.path;
  }

  static Future<String> _write(
    Isar isar,
    String dir,
    int from,
    DateTime utc,
    SnapshotWriter writer,
  ) async {
    final path = '$dir/healthflare_pre_v${from}_${_stamp(utc)}.isar';
    final file = File(path);
    // copyToFile refuses to overwrite.
    if (file.existsSync()) await file.delete();
    try {
      await writer(isar, path);
      if (!file.existsSync() || file.lengthSync() == 0) {
        throw FileSystemException('Snapshot was not written', path);
      }
    } catch (_) {
      // Don't leave a partial copy that looks like a good one.
      if (file.existsSync()) await file.delete();
      rethrow;
    }
    return path;
  }

  /// Deletes all but the newest [keep] snapshots. Files that don't match
  /// the snapshot name pattern are left alone.
  static Future<void> _prune(Directory dir) async {
    final snapshots =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => _namePattern.hasMatch(_fileName(f.path)))
            .toList()
          ..sort((a, b) => _sortKey(b).compareTo(_sortKey(a)));
    for (final old in snapshots.skip(keep)) {
      await old.delete();
    }
  }

  static String _sortKey(File f) {
    final m = _namePattern.firstMatch(_fileName(f.path))!;
    return '${m.group(2)}_${m.group(1)!.padLeft(6, '0')}';
  }

  static String _fileName(String path) => path.split('/').last;

  static String _stamp(DateTime utc) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}'
        'T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }
}
