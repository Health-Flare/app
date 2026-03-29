import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/backup_service.dart';
import 'package:health_flare/data/database/import_service.dart';

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

/// Restore was staged (overwrite mode) — user must restart to apply it.
class BackupRestoreStaged extends BackupResult {
  const BackupRestoreStaged();
}

/// Merge or selective import complete.
class ImportComplete extends BackupResult {
  const ImportComplete(this.recordsAdded);
  final int recordsAdded;
}

/// Selective import: backup opened, category preview ready for user to review.
class ImportPreviewReady extends BackupResult {
  const ImportPreviewReady({required this.filePath, required this.categories});
  final String filePath;
  final List<ImportCategoryInfo> categories;
}

/// The user cancelled the file picker.
class BackupCancelled extends BackupResult {
  const BackupCancelled();
}

class BackupError extends BackupResult {
  const BackupError(this.message);
  final String message;
}

/// Manages database export and all three restore modes.
///
/// **Export** — calls [BackupService.export], then opens the OS share sheet.
///
/// **Overwrite** (staged restore) — copies a user-chosen `.isar` file to the
/// pending-restore slot; [IsarService.open] applies it on next app launch.
///
/// **Merge** — opens the backup inline as a secondary Isar instance and
/// imports records that are not already in the main database. No restart needed.
///
/// **Selective** — same as merge but the user first previews which categories
/// are available and picks what to import.
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

  /// Opens the file picker and stages the chosen backup for a full overwrite.
  ///
  /// The restore is applied on the next app launch. Returns false if the user
  /// cancelled without selecting a file.
  Future<bool> stageRestore() async {
    if (state is BackupInProgress) return false;
    state = const BackupInProgress();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
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

  /// Opens the file picker and merges all data from the chosen backup,
  /// skipping records that already exist in the main database.
  Future<void> mergeRestore() async {
    if (state is BackupInProgress) return;
    state = const BackupInProgress();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        state = const BackupCancelled();
        return;
      }

      final path = result.files.single.path;
      if (path == null) {
        state = const BackupError('Could not read the selected file.');
        return;
      }

      final isar = ref.read(isarProvider);
      final added = await ImportService.mergeAll(path, isar);
      state = ImportComplete(added);
    } catch (e) {
      state = BackupError('Import failed: $e');
    }
  }

  /// Opens the file picker, then sets state to [ImportPreviewReady] so the
  /// UI can show the user a category picker before committing the import.
  Future<void> startSelectiveImport() async {
    if (state is BackupInProgress) return;
    state = const BackupInProgress();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        state = const BackupCancelled();
        return;
      }

      final path = result.files.single.path;
      if (path == null) {
        state = const BackupError('Could not read the selected file.');
        return;
      }

      final isar = ref.read(isarProvider);
      final categories = await ImportService.preview(path, isar);

      if (categories.isEmpty) {
        // Nothing new to import — treat as done with 0 records.
        state = const ImportComplete(0);
        return;
      }

      state = ImportPreviewReady(filePath: path, categories: categories);
    } catch (e) {
      state = BackupError('Preview failed: $e');
    }
  }

  /// Commits the selective import using the categories the user has selected.
  ///
  /// Must only be called while state is [ImportPreviewReady].
  Future<void> commitSelectiveImport(Set<String> selectedCategoryIds) async {
    final current = state;
    if (current is! ImportPreviewReady) return;
    state = const BackupInProgress();

    try {
      final isar = ref.read(isarProvider);
      final added = await ImportService.mergeSelected(
        current.filePath,
        isar,
        selectedCategoryIds,
      );
      state = ImportComplete(added);
    } catch (e) {
      state = BackupError('Import failed: $e');
    }
  }

  void reset() => state = const BackupIdle();
}

final backupProvider = NotifierProvider<BackupNotifier, BackupResult>(
  BackupNotifier.new,
);
