import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver entry-point for screenshot capture.
///
/// Run via scripts/take_screenshots.sh or:
///
///   flutter drive
///     --driver=test_driver/integration_test.dart
///     --target=integration_test/screenshot_test.dart
///     -d DEVICE_ID
///
/// Screenshots are written to screenshots/NAME.png.
Future<void> main() => integrationDriver(
  // Save screenshots even when individual tests fail.
  writeResponseOnFailure: true,
  // onScreenshot is called once per takeScreenshot() call with name + bytes.
  onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
    final dir = Directory('screenshots');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('screenshots/$name.png').writeAsBytesSync(bytes);
    // ignore: avoid_print
    print('  saved  screenshots/$name.png');
    return true;
  },
);
