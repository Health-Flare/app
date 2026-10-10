import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_encryption.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/database/pre_migration_snapshot.dart';
import 'package:health_flare/core/files/scratch_files.dart';

/// Handles hot-backup export and staged restore for the Isar database.
///
/// ## Export
/// [export] calls [Isar.copyToFile] on the live instance, producing a clean
/// snapshot in the system temp directory. The caller is responsible for sharing
/// or saving the file. [exportEncrypted] does the same but password-locks the
/// result (see [EncryptedBackupCodec]). The plaintext snapshot never leaves
/// the temp directory and is deleted once encryption completes.
///
/// ## Restore
/// [stagePendingRestore] copies a user-supplied file to a well-known
/// "pending" slot in the app documents directory.
/// [IsarService.open] checks for this file at startup: if present it replaces
/// the live database file *before* Isar opens, so no live DB juggling is
/// needed. The pending file is deleted after it is applied.
///
/// The pending-restore slot persists across app process deaths, so even if the
/// user force-quits before restarting the restore is still applied on the
/// next launch.
class BackupService {
  BackupService._();

  static const _pendingRestoreFileName = 'healthflare_pending_restore.isar';
  static const _mainDbName = 'healthflare';

  /// The path used for the pending restore file.
  static Future<String> pendingRestorePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_pendingRestoreFileName';
  }

  /// Returns true if a pending restore is waiting to be applied.
  static Future<bool> hasPendingRestore() async {
    final path = await pendingRestorePath();
    return File(path).existsSync();
  }

  /// Creates a hot backup of [isar] and returns the path to the backup file.
  ///
  /// The file is written to the system temporary directory and named
  /// `healthflare_backup_YYYYMMDD_HHmm.isar`. It is safe to call while the
  /// database is open and being written to.
  static Future<String> export(Isar isar) async {
    final tmp = await ScratchFiles.directory();
    final now = DateTime.now();
    final stamp =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
    final path = '${tmp.path}/healthflare_backup_$stamp.isar';
    await isar.copyToFile(path);
    return path;
  }

  /// Creates a password-encrypted hot backup of [isar] and returns the path
  /// to the resulting `.hfbackup` file.
  ///
  /// Internally calls [export] to build the plaintext snapshot, encrypts it
  /// with [EncryptedBackupCodec.encryptFile], then deletes the plaintext
  /// copy, so only the encrypted file is left on disk.
  static Future<String> exportEncrypted(Isar isar, String password) async {
    final plainPath = await export(isar);
    try {
      final encPath =
          '${plainPath.substring(0, plainPath.length - '.isar'.length)}'
          '${EncryptedBackupFormat.extension}';
      return await EncryptedBackupCodec.encryptFile(
        plainPath: plainPath,
        outPath: encPath,
        password: password,
      );
    } finally {
      final plainFile = File(plainPath);
      if (plainFile.existsSync()) await plainFile.delete();
    }
  }

  /// Copies [sourceFilePath] to the pending restore slot.
  ///
  /// Throws [InvalidBackupException] (and stages nothing) if the file is not
  /// a Health Flare database: Isar would otherwise open it on the next launch
  /// as a fresh, empty database, silently wiping the user's data.
  ///
  /// The restore is applied the next time [IsarService.open] runs (i.e. after
  /// the user restarts the app). The caller should prompt the user to restart.
  static Future<void> stagePendingRestore(String sourceFilePath) async {
    await ImportService.validate(sourceFilePath);
    final path = await pendingRestorePath();
    await File(sourceFilePath).copy(path);
  }

  /// Applies the pending restore by replacing the live database file.
  ///
  /// Must be called *before* Isar is opened. Called by [IsarService.open].
  /// No-op if no pending restore file exists.
  ///
  /// The staged file is validated again before the live database is touched.
  /// If it isn't a Health Flare database (e.g. it was staged by an older app
  /// version that didn't validate), it is discarded and the live database is
  /// kept.
  static Future<void> applyPendingRestoreIfNeeded(String docsDir) async {
    final pendingPath = '$docsDir/$_pendingRestoreFileName';
    final pendingFile = File(pendingPath);
    if (!pendingFile.existsSync()) return;

    try {
      await ImportService.validate(pendingPath);
    } on InvalidBackupException {
      debugPrint('Discarding pending restore: not a Health Flare database.');
      await pendingFile.delete();
      return;
    }

    // The app lock settings belong to this phone, not to the data (#100):
    // carry them over so restoring a file from another phone never turns the
    // lock on or off.
    final mainFile = File('$docsDir/$_mainDbName.isar');
    final deviceSettings = mainFile.existsSync()
        ? await _readDeviceSettings(docsDir)
        : null;

    // Replace the main database file with the backup.
    if (mainFile.existsSync()) {
      await mainFile.delete();
    }
    // Also remove any leftover lock file so Isar opens cleanly.
    final lockFile = File('$docsDir/$_mainDbName.isar.lock');
    if (lockFile.existsSync()) {
      await lockFile.delete();
    }
    await pendingFile.rename(mainFile.path);
    if (deviceSettings != null) {
      await _writeDeviceSettings(docsDir, deviceSettings);
    }
    // The restored database is not the one any unfinished upgrade took its
    // safety copy of. Forget that copy so the next upgrade copies this one.
    await PreMigrationSnapshot.clearPendingMarker(docsDir);
  }

  static Future<Isar> _openMain(String docsDir) =>
      Isar.open(appSchemas, directory: docsDir, name: _mainDbName);

  /// This phone's app lock settings from the live database, or null if it
  /// has none (or can't be read: the restore still goes ahead).
  static Future<_DeviceSettings?> _readDeviceSettings(String docsDir) async {
    try {
      final isar = await _openMain(docsDir);
      try {
        final row = await isar.appSettings.get(1);
        return row == null ? null : _DeviceSettings.from(row);
      } finally {
        await isar.close();
      }
    } on IsarError {
      return null;
    }
  }

  static Future<void> _writeDeviceSettings(
    String docsDir,
    _DeviceSettings settings,
  ) async {
    final isar = await _openMain(docsDir);
    try {
      await isar.writeTxn(() async {
        final row = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
        settings.applyTo(row);
        await isar.appSettings.put(row);
      });
    } finally {
      await isar.close();
    }
  }
}

/// The [AppSettings] fields that belong to the phone rather than the data.
class _DeviceSettings {
  _DeviceSettings.from(AppSettings row)
    : appLockEnabled = row.appLockEnabled,
      appLockRelockSeconds = row.appLockRelockSeconds,
      hideInAppSwitcher = row.hideInAppSwitcher;

  final bool appLockEnabled;
  final int? appLockRelockSeconds;
  final bool hideInAppSwitcher;

  void applyTo(AppSettings row) => row
    ..appLockEnabled = appLockEnabled
    ..appLockRelockSeconds = appLockRelockSeconds
    ..hideInAppSwitcher = hideInAppSwitcher;
}
