import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

/// The file the user picked for import/restore is encrypted: a password is
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
///
/// **Encrypted backups** (docs/features/encrypted-backup.feature):
/// [exportWithPassword] produces a `.hfbackup` file instead of a plain
/// `.isar`. On import, every mode checks the picked file's content and, if
/// it's encrypted, stops at [ImportPasswordRequired] before doing anything
/// else. [submitImportPassword] decrypts it to a temporary plain copy and
/// resumes the same mode against that copy, which is deleted once the mode
/// no longer needs it.
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
  /// The restore is applied on the next app launch. Returns true only if a
  /// restore was staged right away; false if the user cancelled, it failed,
  /// or the file is encrypted and is waiting on [submitImportPassword].
  Future<bool> stageRestore() async {
    await _pickAndRun(PendingImportAction.overwrite);
    return state is BackupRestoreStaged;
  }

  /// Opens the file picker and merges all data from the chosen backup,
  /// skipping records that already exist in the main database.
  Future<void> mergeRestore() => _pickAndRun(PendingImportAction.merge);

  /// Opens the file picker, then sets state to [ImportPreviewReady] so the
  /// UI can show the user a category picker before committing the import.
  Future<void> startSelectiveImport() =>
      _pickAndRun(PendingImportAction.selective);

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
    } finally {
      await _discardDecryptedCopy();
    }
  }

  /// Unlocks the encrypted file named by an [ImportPasswordRequired] state
  /// with [password] and resumes whichever restore flow was pending.
  ///
  /// On a wrong password (or a corrupted/tampered file: the two are
  /// indistinguishable, see [BackupEncryptionException]), returns to
  /// [ImportPasswordRequired] with [ImportPasswordRequired.errorMessage]
  /// set, so the user can retry without re-picking the file. Nothing is
  /// written to the main database or the pending-restore slot in that case.
  ///
  /// Once unlocked, a failure in the restore itself is reported as a
  /// [BackupError] like any plain-backup failure, not as a password error.
  /// The decrypted working copy is deleted as soon as it's no longer needed,
  /// whether the restore succeeded or failed.
  Future<void> submitImportPassword(String password) async {
    final current = state;
    if (current is! ImportPasswordRequired) return;
    state = const BackupInProgress();

    final String decryptedPath;
    try {
      decryptedPath = await _decryptedCopyPath();
      await EncryptedBackupCodec.decryptFile(
        encryptedPath: current.filePath,
        outPath: decryptedPath,
        password: password,
      );
    } on BackupEncryptionException catch (e) {
      state = ImportPasswordRequired(
        filePath: current.filePath,
        action: current.action,
        errorMessage: e.message,
      );
      return;
    } catch (e) {
      state = BackupError('Could not unlock the backup: $e');
      return;
    }

    _heldDecryptedCopy = decryptedPath;
    await _run(current.action, decryptedPath);
  }

  /// Returns to [BackupIdle], deleting any decrypted working copy still held
  /// for an unfinished selective import (e.g. the user dismissed the
  /// category picker).
  void reset() {
    unawaited(_discardDecryptedCopy());
    state = const BackupIdle();
  }

  /// Shows the platform file picker. Returns the picked file's path, or null
  /// if the user cancelled. Throws [FileSystemException] if the platform
  /// returned a file without a readable path.
  ///
  /// Overridable so tests can drive the import flows without a real picker.
  @protected
  Future<String?> pickBackupFile() async {
    // FileType.any: accepts both plain ".isar" and encrypted ".hfbackup"
    // files. Which one it is gets decided from content, not extension.
    final result = await FilePicker.pickFile(type: FileType.any);
    if (result == null) return null;
    final path = result.path;
    if (path == null) {
      throw const FileSystemException('Could not read the selected file.');
    }
    return path;
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  /// Path of a decrypted working copy that still exists on disk, if any.
  /// Only a selective import keeps one past [submitImportPassword] (its
  /// commit step still needs it); every other path deletes it immediately.
  String? _heldDecryptedCopy;

  Future<void> _pickAndRun(PendingImportAction action) async {
    if (state is BackupInProgress) return;
    state = const BackupInProgress();

    final String? path;
    try {
      path = await pickBackupFile();
    } on FileSystemException catch (e) {
      state = BackupError(e.message);
      return;
    } catch (e) {
      state = BackupError('${_failurePrefix(action)}$e');
      return;
    }
    if (path == null) {
      state = const BackupCancelled();
      return;
    }

    try {
      if (await EncryptedBackupCodec.isEncrypted(path)) {
        // Nothing else happens until a password is submitted.
        state = ImportPasswordRequired(filePath: path, action: action);
        return;
      }
    } catch (e) {
      state = BackupError('${_failurePrefix(action)}$e');
      return;
    }

    await _run(action, path);
  }

  /// Runs [action] against the plain (never encrypted) backup at [path].
  Future<void> _run(PendingImportAction action, String path) async {
    var keepDecryptedCopy = false;
    try {
      final isar = ref.read(isarProvider);
      switch (action) {
        case PendingImportAction.overwrite:
          await BackupService.stagePendingRestore(path);
          state = const BackupRestoreStaged();
        case PendingImportAction.merge:
          final added = await ImportService.mergeAll(path, isar);
          state = ImportComplete(added);
        case PendingImportAction.selective:
          final categories = await ImportService.preview(path, isar);
          if (categories.isEmpty) {
            // Nothing new to import: treat as done with 0 records.
            state = const ImportComplete(0);
          } else {
            keepDecryptedCopy = true;
            state = ImportPreviewReady(filePath: path, categories: categories);
          }
      }
    } catch (e) {
      state = BackupError('${_failurePrefix(action)}$e');
    } finally {
      if (!keepDecryptedCopy) await _discardDecryptedCopy();
    }
  }

  static String _failurePrefix(PendingImportAction action) => switch (action) {
    PendingImportAction.overwrite => 'Restore failed: ',
    PendingImportAction.merge => 'Import failed: ',
    PendingImportAction.selective => 'Preview failed: ',
  };

  static Future<String> _decryptedCopyPath() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/healthflare_decrypted_'
        '${DateTime.now().microsecondsSinceEpoch}.isar';
  }

  Future<void> _discardDecryptedCopy() async {
    final path = _heldDecryptedCopy;
    _heldDecryptedCopy = null;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Best effort: the OS clears the temp directory eventually.
    }
  }
}

final backupProvider = NotifierProvider<BackupNotifier, BackupResult>(
  BackupNotifier.new,
);
