// Photos the app keeps: profile pictures and meal photos (#105).
//
// Picked images used to be stored as whatever path the picker returned: a
// temp or cache file the OS can purge, never deleted with its entry, and a
// backup could point an avatar at any file the app can read. Now every
// photo is copied into <documents>/photos/ under a random name, and only
// that bare name is stored. Only such names are ever shown or deleted.
//
// Backups: in the iOS backup and Android phone-to-phone transfer; left out
// of Android cloud backup (25 MB quota, #111). See the Android backup xml.

import 'dart:io';

import 'package:isar_community/isar.dart';

abstract final class PhotoStore {
  static String? _docs;

  /// Called once the documents directory is known, before migrations run.
  static void init(String documentsDir) => _docs = documentsDir;

  /// For tests.
  static void reset() => _docs = null;

  static bool get isReady => _docs != null;

  static String get dirPath => '$_docs/photos';

  /// A name the app gave a photo: 32 hex characters and an image extension.
  static bool isManaged(String? stored) => false; // TODO(#105): red stub

  /// The file for a stored photo, or null when there isn't one to show.
  static File? resolve(String? stored) {
    // TODO(#105): red stub: today's behaviour, any path.
    if (stored == null) return null;
    final f = File(stored);
    return f.existsSync() ? f : null;
  }

  /// Copies the image at [sourcePath] into the photos folder and returns
  /// its stored name. A name that's already managed is returned as it is.
  /// Null when the file is missing or isn't a JPEG, PNG or HEIC image.
  static Future<String?> adopt(String? sourcePath) async =>
      sourcePath; // TODO(#105): red stub

  /// Deletes photos no profile or meal points at. Files changed in the last
  /// [grace] are left alone: a photo is copied in just before its row is
  /// written. Returns how many were deleted.
  static Future<int> sweep(
    Isar isar, {
    Duration grace = const Duration(minutes: 1),
    DateTime? now,
  }) async => 0; // TODO(#105): red stub
}
