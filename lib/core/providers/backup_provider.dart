import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/backup_service.dart';

/// The result of a backup or restore operation.
sealed class BackupResult {
  const BackupResult();
}

class BackupIdle extends BackupResult {
  const BackupIdle();
}

class BackupInProgress extends BackupResult {
  const BackupInProgress();
}

/// Export succeeded — the share sheet was shown.
class BackupExportDone extends BackupResult {
  const BackupExportDone();
}

/// Restore was staged — the user needs to restart to apply it.
class BackupRestoreStaged extends BackupResult {
  const BackupRestoreStaged();
}

/// The user cancelled the file picker.
class BackupCancelled extends BackupResult {
  const BackupCancelled();
}

class BackupError extends BackupResult {
  const BackupError(this.message);

  final String message;
}

/// Manages one-tap database export and staged restore.
///
/// Export:
///   Calls [BackupService.export] to create a compact snapshot via Isar's
///   hot-backup API, then opens the system share sheet so the user can save
///   the file to Files, AirDrop it, email it, etc.
///
/// Restore:
///   Opens the system file picker filtered to `.isar` files, then calls
///   [BackupService.stagePendingRestore] to copy the file to the pending-
///   restore slot. [IsarService.open] applies it on the next app launch.
class BackupNotifier extends Notifier<BackupResult> {
  @override
  BackupResult build() => const BackupIdle();

  /// Exports the current database and opens the share sheet.
  Future<void> export() async {
    if (state is BackupInProgress) return;
    state = const BackupInProgress();

    try {
      final isar = ref.read(isarProvider);
      final backupPath = await BackupService.export(isar);
      await Share.shareXFiles([
        XFile(backupPath),
      ], subject: 'Health Flare backup');
      state = const BackupExportDone();
    } catch (e) {
      state = BackupError('Export failed: $e');
    }
  }

  /// Opens the file picker and stages the chosen backup for restore.
  ///
  /// The restore is applied on the next app launch. Returns false if the
  /// user cancelled without selecting a file.
  Future<bool> stageRestore() async {
    if (state is BackupInProgress) return false;
    state = const BackupInProgress();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['isar'],
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        state = const BackupCancelled();
        return false;
      }

      final path = result.files.single.path;
      if (path == null) {
        state = const BackupError('Could not read the selected file.');
        return false;
      }

      await BackupService.stagePendingRestore(path);
      state = const BackupRestoreStaged();
      return true;
    } catch (e) {
      state = BackupError('Restore failed: $e');
      return false;
    }
  }

  void reset() => state = const BackupIdle();
}

final backupProvider = NotifierProvider<BackupNotifier, BackupResult>(
  BackupNotifier.new,
);
