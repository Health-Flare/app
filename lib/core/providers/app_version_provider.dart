import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The installed app's version, read from the platform (which gets it from
/// the `version:` line in pubspec.yaml at build time), formatted for the
/// Settings > About section, e.g. "1.2.1 (build 5)".
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return formatAppVersion(info.version, info.buildNumber);
});

/// Formats a version and build number for display. The build number is
/// omitted when the platform doesn't report one.
String formatAppVersion(String version, String buildNumber) {
  final v = version.trim().isEmpty ? 'Unknown' : version.trim();
  final b = buildNumber.trim();
  return b.isEmpty ? v : '$v (build $b)';
}
