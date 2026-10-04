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
/// Used for the pre-upgrade safety copies (`snapshots/`), not the database:
/// the database stays in phone backups on purpose (#96, #97, #99). Several
/// copies of it would multiply the backup size for no gain.
///
/// Android is handled by `res/xml/backup_rules.xml` and
/// `res/xml/data_extraction_rules.xml`, so this is a no-op there.
///
/// Never throws: failing to set the flag must not stop the app opening.
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
    debugPrint('Health Flare: could not exclude snapshots from iCloud backup.');
    return false;
  }
}
