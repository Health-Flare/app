import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String? _path;

/// Gives this test file its own temp directory for Isar databases (#208).
///
/// Call once at the top of `main()`, then open Isar with
/// `directory: isarTestDir`. The directory is created before the file's
/// first test and deleted, with every database in it, after its last one.
///
/// `directory: ''` resolves to the working directory, which is the repo
/// root under `flutter test`. Databases opened there were never deleted,
/// and a checkout collected over a thousand of them.
///
/// Tests that reopen a database under the same name (to simulate an app
/// restart) still work: the directory lasts for the whole file.
void useIsarTestDirectory() {
  setUpAll(() {
    _path = Directory.systemTemp.createTempSync('hf_isar_test_').path;
  });
  tearDownAll(() {
    final path = _path;
    _path = null;
    if (path == null) return;
    try {
      Directory(path).deleteSync(recursive: true);
    } on FileSystemException {
      // A database still open on a platform that refuses to delete open
      // files. The OS clears its temp directory; don't fail the run.
    }
  });
}

/// The directory to pass to `Isar.open` in tests. See [useIsarTestDirectory].
String get isarTestDir =>
    _path ??
    (throw StateError(
      'Call useIsarTestDirectory() at the top of main() before opening Isar.',
    ));
