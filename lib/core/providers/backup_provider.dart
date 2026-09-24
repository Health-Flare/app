import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/backup_encryption.dart';
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

/// Export succeeded: the share sheet was shown.
class BackupExportDone extends BackupResult {
  const BackupExportDone();
}

/// Restore was staged (overwrite mode): user must restart to apply it.
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

/// Which restore flow to resume once [BackupNotifier.submitImportPassword]
/// unlocks the file the user picked.
enum PendingImportAction { overwrite, merge, selective }

/// The file the user picked for import/restore is encrypted — a password is
/// needed before the overwrite/merge/selective flow named by [action] can
/// proceed. [errorMessage] is set when a previous password attempt for this
/// same file failed, so the UI can show it inline and let the user retry
/// without re-picking the file.
class ImportPasswordRequired extends BackupResult {
  const ImportPasswordRequired({
    required this.filePath,
    required this.action,
    this.errorMessage,
  });
  final String filePath;
  final PendingImportAction action;
  final String? errorMessage;
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
/// **Export**: calls [BackupService.export], then opens the OS share sheet.
///
/// **Overwrite** (staged restore): copies a user-chosen `.isar` file to the
/// pending-restore slot; [IsarService.open] applies it on next app launch.
///
/// **Merge**: opens the backup inline as a secondary Isar instance and
/// imports records that are not already in the main database. No restart needed.
///
/// **Selective**: same as merge but the user first previews which categories
/// are available and picks what to import.
class BackupNotifier extends Notifier<BackupResult> {
  /// The decrypted temp copy currently backing an [ImportPreviewReady] that
  /// started from an encrypted file — deleted by [reset]. Only the
  /// selective-import flow needs this: merge/overwrite delete their
  /// decrypted copy immediately in [submitImportPassword] since there's no
  /// later step that still needs the file.
  String? _pendingDecryptedPath;

  @override
  BackupResult build() => const BackupIdle();

  /// Exports the current database and opens the share sheet.
  Future<void> export() async {
    if (state is BackupInProgress) return;
    state = const BackupInProgress();

    try {
      final isar = ref.read(isarProvider);
      final backupPath = await BackupService.export(isar);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(backupPath)], subject: 'Health Flare backup'),
      );
      state = const BackupExportDone();
    } catch (e) {
      state = BackupError('Export failed: $e');
    }
  }

  /// Exports the current database encrypted with [password] and opens the
  /// share sheet with the resulting `.hfbackup` file.
  Future<void> exportWithPassword(String password) async {
    if (state is BackupInProgress) return;
    state = const BackupInProgress();

    try {
      final isar = ref.read(isarProvider);
      final backupPath = await BackupService.exportEncrypted(isar, password);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(backupPath)], subject: 'Health Flare backup'),
      );
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
      final result = await FilePicker.pickFile(type: FileType.any);

      if (result == null) {
        state = const BackupCancelled();
        return false;
      }

      final path = result.path;
      if (path == null) {
        state = const BackupError('Could not read the selected file.');
        return false;
      }

      if (await EncryptedBackupCodec.isEncrypted(path)) {
        state = ImportPasswordRequired(
          filePath: path,
          action: PendingImportAction.overwrite,
        );
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
      final result = await FilePicker.pickFile(type: FileType.any);

      if (result == null) {
        state = const BackupCancelled();
        return;
      }

      final path = result.path;
      if (path == null) {
        state = const BackupError('Could not read the selected file.');
        return;
      }

      if (await EncryptedBackupCodec.isEncrypted(path)) {
        state = ImportPasswordRequired(
          filePath: path,
          action: PendingImportAction.merge,
        );
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
      final result = await FilePicker.pickFile(type: FileType.any);

      if (result == null) {
        state = const BackupCancelled();
        return;
      }

      final path = result.path;
      if (path == null) {
        state = const BackupError('Could not read the selected file.');
        return;
      }

      if (await EncryptedBackupCodec.isEncrypted(path)) {
        state = ImportPasswordRequired(
          filePath: path,
          action: PendingImportAction.selective,
        );
        return;
      }

      final isar = ref.read(isarProvider);
      final categories = await ImportService.preview(path, isar);

      if (categories.isEmpty) {
        // Nothing new to import: treat as done with 0 records.
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

  /// Unlocks the encrypted file named by an [ImportPasswordRequired] state
  /// with [password] and resumes whichever restore flow was pending.
  ///
  /// On a wrong password (or a corrupted/tampered file — the two are
  /// indistinguishable, see [BackupEncryptionException]), returns to
  /// [ImportPasswordRequired] with [ImportPasswordRequired.errorMessage]
  /// set, so the user can retry without re-picking the file.
  Future<void> submitImportPassword(String password) async {
    final current = state;
    if (current is! ImportPasswordRequired) return;
    state = const BackupInProgress();

    try {
      final tempDir = await getTemporaryDirectory();
      final decryptedPath =
          '${tempDir.path}/healthflare_decrypted_'
          '${DateTime.now().microsecondsSinceEpoch}.isar';
      await EncryptedBackupCodec.decryptFile(
        encryptedPath: current.filePath,
        outPath: decryptedPath,
        password: password,
      );

      switch (current.action) {
        case PendingImportAction.overwrite:
          await BackupService.stagePendingRestore(decryptedPath);
          await _deleteIfExists(decryptedPath);
          state = const BackupRestoreStaged();
        case PendingImportAction.merge:
          final isar = ref.read(isarProvider);
          final added = await ImportService.mergeAll(decryptedPath, isar);
          await _deleteIfExists(decryptedPath);
          state = ImportComplete(added);
        case PendingImportAction.selective:
          final isar = ref.read(isarProvider);
          final categories = await ImportService.preview(decryptedPath, isar);
          if (categories.isEmpty) {
            await _deleteIfExists(decryptedPath);
            state = const ImportComplete(0);
          } else {
            // Kept on disk — commitSelectiveImport still needs it. reset()
            // cleans it up once the selective flow finishes or is cancelled.
            _pendingDecryptedPath = decryptedPath;
            state = ImportPreviewReady(
              filePath: decryptedPath,
              categories: categories,
            );
          }
      }
    } on BackupEncryptionException catch (e) {
      state = ImportPasswordRequired(
        filePath: current.filePath,
        action: current.action,
        errorMessage: e.message,
      );
    } catch (e) {
      state = ImportPasswordRequired(
        filePath: current.filePath,
        action: current.action,
        errorMessage: 'Unlock failed: $e',
      );
    }
  }

  static Future<void> _deleteIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  void reset() {
    final decryptedPath = _pendingDecryptedPath;
    _pendingDecryptedPath = null;
    if (decryptedPath != null) {
      unawaited(_deleteIfExists(decryptedPath));
    }
    state = const BackupIdle();
  }
}

final backupProvider = NotifierProvider<BackupNotifier, BackupResult>(
  BackupNotifier.new,
);
