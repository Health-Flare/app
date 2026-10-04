import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Where Health Flare writes short-lived files that hold the user's data:
/// plain backup exports, PDF/CSV reports, decrypted copies of encrypted
/// backups, and the import preview database (#102).
///
/// They used to be written loose in the temp directory and never removed.
/// Report file names include the profile's name, and on a shared desktop
/// account another program could read them days later. If the app died
/// mid-import, a plaintext copy of an encrypted backup stayed on disk.
///
/// Now they all go in one folder, which is:
/// - emptied at every launch ([sweep]), before the database opens, and
/// - cleaned file by file after each share on phones ([shareThenDelete]).
abstract final class ScratchFiles {
  static const folderName = 'healthflare_scratch';

  /// File name patterns earlier versions wrote loose in the temp directory.
  /// These names are specific to Health Flare.
  static final _legacyOwnNames = RegExp(
    r'^(healthflare_backup_\d{8}_\d{4}\.(isar|hfbackup)'
    r'|healthflare_decrypted_\d+\.isar'
    r'|import_preview\.isar(\.lock)?)$',
  );

  /// Reports from earlier versions: `profile_yyyy-MM-dd.pdf` or `.csv`. The
  /// name alone could match another app's file, so these are only removed
  /// when temp belongs to this app alone.
  static final _legacyReports = RegExp(r'^\w+_\d{4}-\d{2}-\d{2}\.(pdf|csv)$');

  /// The scratch folder, created if needed.
  static Future<Directory> directory() async {
    final tmp = await getTemporaryDirectory();
    final dir = Directory('${tmp.path}/$folderName');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Whether the OS temp directory belongs to this app alone. It does on
  /// Android, iOS and sandboxed macOS. On Windows and Linux it is shared
  /// with every other program the user runs.
  static bool get _tempIsAppPrivate =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  /// Removes every leftover file that holds the user's data. Call once at
  /// startup, before the database opens, when no import or share can be in
  /// progress. Never throws: a failed sweep must not stop the app opening.
  ///
  /// [appPrivateTemp] overrides the platform check, for tests.
  static Future<void> sweep({bool? appPrivateTemp}) async {
    if (kIsWeb) return;
    final private = appPrivateTemp ?? _tempIsAppPrivate;
    try {
      final tmp = await getTemporaryDirectory();
      if (!tmp.existsSync()) return;

      final scratch = Directory('${tmp.path}/$folderName');
      if (scratch.existsSync()) await scratch.delete(recursive: true);

      for (final entity in tmp.listSync(followLinks: false)) {
        if (entity is! File) continue;
        final name = entity.uri.pathSegments.last;
        if (_legacyOwnNames.hasMatch(name) ||
            (private && _legacyReports.hasMatch(name))) {
          await _tryDelete(entity);
        }
      }

      // share_plus on Android copies each shared file into cache/share_plus
      // and only clears it at the start of the next share. On Android the
      // temp directory is the app's cache directory.
      final sharePlus = Directory('${tmp.path}/share_plus');
      if (private && sharePlus.existsSync()) {
        await sharePlus.delete(recursive: true);
      }
    } on FileSystemException {
      // Best effort: the next launch tries again.
    }
  }

  /// Runs [share] for the file at [path], then deletes it.
  ///
  /// On Android and iOS the share sheet has handed the file over (Android
  /// copies it first; iOS has finished with it) by the time the share call
  /// returns, so it is deleted straight away. On desktop the target app may
  /// still be reading it after the call returns, so it is left for the next
  /// launch's [sweep].
  ///
  /// [deleteNow] overrides the platform check, for tests.
  static Future<void> shareThenDelete(
    String path,
    Future<void> Function() share, {
    bool? deleteNow,
  }) async {
    final now = deleteNow ?? (Platform.isAndroid || Platform.isIOS);
    try {
      await share();
    } finally {
      if (now) await _tryDelete(File(path));
    }
  }

  static Future<void> _tryDelete(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // Best effort: the next sweep removes it.
    }
  }
}
