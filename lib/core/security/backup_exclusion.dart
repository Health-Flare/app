import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native channel that marks files as excluded from iCloud backup on iOS.
/// Registered in ios/Runner/AppDelegate.swift.
const backupExclusionChannel = MethodChannel(
  'org.healthflare.app/backup_exclusion',
);

/// Marks [path] (a file or a directory, and everything inside it) as excluded
/// from iCloud and Finder backups on iOS.
///
/// The health database is not encrypted at rest, so an OS backup is a full
/// readable copy held by Apple and reachable by anyone with the Apple ID.
/// Data leaves the device only through the explicit export in Settings.
///
/// Android is handled by the manifest (`allowBackup="false"` plus
/// `res/xml/data_extraction_rules.xml`), so this is a no-op there.
///
/// Never throws: failing to set the flag must not stop the database opening.
/// Returns whether the flag was set.
Future<bool> excludeFromBackup(String path) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
  try {
    final ok = await backupExclusionChannel.invokeMethod<bool>(
      'excludeFromBackup',
      {'path': path},
    );
    return ok ?? false;
  } on MissingPluginException {
    // No native handler (tests, or an embedding without it).
    return false;
  } on PlatformException {
    // Setting the resource value failed. Keep the app usable; the next
    // launch tries again.
    debugPrint('Health Flare: could not exclude data from iCloud backup.');
    return false;
  }
}
