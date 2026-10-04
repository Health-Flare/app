import 'dart:io';

import 'package:health_flare/data/database/import_service.dart';

/// Size limit for any file picked for import or restore (#104).
///
/// Import used to read whatever file the user picked. An encrypted backup
/// is read whole into memory and copied to a background isolate, so a
/// multi-GB file crashed the app; a plain one went straight to Isar's
/// native code. Anything over [maxBytes] is now refused before a byte of it
/// is read. Only the file's size is looked up.
abstract final class BackupLimits {
  /// 256 MB. The heaviest realistic database measured (#111: four profiles,
  /// five years, many entries a day each) is about 30 MB, so a real backup
  /// has roughly 8x headroom. Decrypting holds about three copies in memory
  /// at once, so this also keeps the peak well under what phones allow.
  static const maxBytes = 256 * 1024 * 1024;

  /// Throws [BackupTooLargeException] if the file at [path] is over
  /// [maxBytes]. A missing file is left for the caller's own checks.
  static Future<void> check(String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    if (await file.length() > maxBytes) {
      throw const BackupTooLargeException();
    }
  }
}

/// The picked file is too big to be a Health Flare backup.
///
/// A kind of [InvalidBackupException], so every import and restore path
/// that already reports "not a backup" reports this too, with its own
/// message.
class BackupTooLargeException extends InvalidBackupException {
  const BackupTooLargeException();

  @override
  String get message => 'This file is too big to be a Health Flare backup.';
}
