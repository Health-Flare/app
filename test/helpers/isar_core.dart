import 'dart:ffi';
import 'dart:io';

import 'package:isar_community/isar.dart';

/// Loads the Isar native library for a test file, downloading it once per
/// checkout if needed. Use in every test that opens real Isar, instead of
/// calling `Isar.initializeIsarCore` directly.
///
/// Calling `Isar.initializeIsarCore(download: true)` from each file raced in
/// two ways under `flutter test`, which runs test files in parallel:
///
/// - Isar writes the download straight to `<repo>/libisar.*`, so a file
///   starting a moment later found it half-written and failed to load it
///   ("slice extends beyond end of file", "not a mach-o").
/// - The widget test binding answers every HTTP request with 400, so a
///   widget test file could only pass if another file had already finished
///   the download ("Could not download IsarCore library").
///
/// Here the library is downloaded to a private temp folder with real HTTP,
/// loaded from there, and then moved into the shared path in one rename, so
/// the shared file is only ever complete.
Future<void> initializeIsarCoreForTests() async {
  final shared = File('${Directory.current.path}/${_libraryName()}');
  if (shared.existsSync()) {
    try {
      await Isar.initializeIsarCore(libraries: {Abi.current(): shared.path});
      return;
    } catch (_) {
      // Unusable (e.g. left over from an older Isar): download a fresh one.
    }
  }

  final private = File(
    '${Directory.systemTemp.createTempSync('isar_core_').path}/'
    '${_libraryName()}',
  );
  final previous = HttpOverrides.current;
  HttpOverrides.global = null;
  try {
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): private.path},
      download: true,
    );
  } finally {
    HttpOverrides.global = previous;
  }

  // Share it with the files that run after this one. Another file may be
  // doing the same: both renames are of complete files, so either wins.
  try {
    final staged = private.copySync('${shared.path}.$pid.tmp');
    staged.renameSync(shared.path);
  } on FileSystemException {
    // Best effort: the next file downloads its own copy.
  }
}

String _libraryName() {
  if (Platform.isMacOS) return 'libisar.dylib';
  if (Platform.isWindows) return 'libisar.dll';
  return 'libisar.so';
}
