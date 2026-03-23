import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Handles hot-backup export and staged restore for the Isar database.
///
/// ## Export
/// [export] calls [Isar.copyToFile] on the live instance, producing a clean
/// snapshot in the system temp directory. The caller is responsible for sharing
/// or saving the file.
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
    final tmp = await getTemporaryDirectory();
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

  /// Copies [sourceFilePath] to the pending restore slot.
  ///
  /// The restore is applied the next time [IsarService.open] runs (i.e. after
  /// the user restarts the app). The caller should prompt the user to restart.
  static Future<void> stagePendingRestore(String sourceFilePath) async {
    final path = await pendingRestorePath();
    await File(sourceFilePath).copy(path);
  }

  /// Applies the pending restore by replacing the live database file.
  ///
  /// Must be called *before* Isar is opened. Called by [IsarService.open].
  /// No-op if no pending restore file exists.
  static Future<void> applyPendingRestoreIfNeeded(String docsDir) async {
    final pendingPath = '$docsDir/$_pendingRestoreFileName';
    final pendingFile = File(pendingPath);
    if (!pendingFile.existsSync()) return;

    // Replace the main database file with the backup.
    final mainFile = File('$docsDir/healthflare.isar');
    if (mainFile.existsSync()) {
      await mainFile.delete();
    }
    // Also remove any leftover lock file so Isar opens cleanly.
    final lockFile = File('$docsDir/healthflare.isar.lock');
    if (lockFile.existsSync()) {
      await lockFile.delete();
    }
    await pendingFile.rename(mainFile.path);
  }
}
