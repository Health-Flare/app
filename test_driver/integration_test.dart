import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver entry-point for screenshot capture.
///
/// Run via scripts/take_screenshots.sh (recommended — sweeps every required
/// App Store device class into its own subdirectory) or directly:
///
///   SCREENSHOT_DIR=screenshots/adhoc flutter drive \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/screenshot_test.dart \
///     -d DEVICE_ID
///
/// Screenshots are written to $SCREENSHOT_DIR/NAME.png (default: screenshots/).
Future<void> main() => integrationDriver(
  // Save screenshots even when individual tests fail.
  writeResponseOnFailure: true,
  // onScreenshot is called once per takeScreenshot() call with name + bytes.
  onScreenshot:
      (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final outDir = Platform.environment['SCREENSHOT_DIR'] ?? 'screenshots';
        final dir = Directory(outDir);
        if (!dir.existsSync()) dir.createSync(recursive: true);
        File('$outDir/$name.png').writeAsBytesSync(bytes);
        // ignore: avoid_print
        print('  saved  $outDir/$name.png');
        return true;
      },
);
