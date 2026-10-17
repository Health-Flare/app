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
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';

abstract final class PhotoStore {
  static String? _docs;

  /// Called once the documents directory is known, before migrations run.
  static void init(String documentsDir) => _docs = documentsDir;

  @visibleForTesting
  static void reset() => _docs = null;

  static bool get isReady => _docs != null;

  static String get dirPath {
    final docs = _docs;
    if (docs == null) throw StateError('PhotoStore.init has not been called');
    return '$docs/photos';
  }

  static final _managed = RegExp(r'^[0-9a-f]{32}\.(jpg|png|heic)$');

  /// A name the app gave a photo: 32 hex characters and an image extension.
  static bool isManaged(String? stored) =>
      stored != null && _managed.hasMatch(stored);

  /// The file for a stored photo, or null when there isn't one to show.
  /// Anything but one of our names (an absolute path, `../`) is never read.
  static File? resolve(String? stored) {
    if (_docs == null || !isManaged(stored)) return null;
    final f = File('$dirPath/$stored');
    return f.existsSync() ? f : null;
  }

  /// Copies the image at [sourcePath] into the photos folder and returns
  /// its stored name. A name that's already managed is returned as it is.
  /// Null when the file is missing or isn't a JPEG, PNG or HEIC image.
  static Future<String?> adopt(String? sourcePath) async {
    if (sourcePath == null) return null;
    if (isManaged(sourcePath)) return sourcePath;
    final src = File(sourcePath);
    if (!src.existsSync()) return null;
    final ext = await _imageExtension(src);
    if (ext == null) return null;
    final dir = Directory(dirPath);
    if (!dir.existsSync()) await dir.create(recursive: true);
    final name = '${_randomHex()}.$ext';
    await src.copy('${dir.path}/$name');
    return name;
  }

  /// Deletes photos no profile or meal points at. Files changed in the last
  /// [grace] are left alone: a photo is copied in just before its row is
  /// written. Only our own names are touched. Returns how many were deleted.
  static Future<int> sweep(
    Isar isar, {
    Duration grace = const Duration(minutes: 1),
    DateTime? now,
  }) async {
    if (_docs == null) return 0;
    final dir = Directory(dirPath);
    if (!dir.existsSync()) return 0;
    final inUse = <String>{
      for (final p in await isar.profileIsars.where().findAll())
        if (p.avatarPath != null) p.avatarPath!,
      for (final m in await isar.mealEntryIsars.where().findAll())
        if (m.photoPath != null) m.photoPath!,
    };
    final cutoff = (now ?? DateTime.now()).subtract(grace);
    var deleted = 0;
    for (final f in dir.listSync().whereType<File>()) {
      final name = f.uri.pathSegments.last;
      if (!isManaged(name) || inUse.contains(name)) continue;
      if (f.lastModifiedSync().isAfter(cutoff)) continue;
      try {
        f.deleteSync();
        deleted++;
      } on FileSystemException {
        // Gone already, or busy: the next sweep tries again.
      }
    }
    return deleted;
  }

  static Future<String?> _imageExtension(File f) async {
    final raf = await f.open();
    try {
      final head = await raf.read(12);
      if (head.length >= 3 &&
          head[0] == 0xFF &&
          head[1] == 0xD8 &&
          head[2] == 0xFF) {
        return 'jpg';
      }
      const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      if (head.length >= 8 && listEquals(head.sublist(0, 8), png)) {
        return 'png';
      }
      // ISO base media: "ftyp" at 4, then a HEIF brand.
      if (head.length >= 12 &&
          String.fromCharCodes(head.sublist(4, 8)) == 'ftyp') {
        const heif = {'heic', 'heix', 'hevc', 'heim', 'heis', 'mif1', 'msf1'};
        if (heif.contains(String.fromCharCodes(head.sublist(8, 12)))) {
          return 'heic';
        }
      }
      return null;
    } finally {
      await raf.close();
    }
  }

  static final _random = Random.secure();

  static String _randomHex() => [
    for (var i = 0; i < 16; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}
