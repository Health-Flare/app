import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build flags (#136): unfinished work merges to main switched off, and is
/// switched on for a build with `--dart-define`:
///
///   flutter run --dart-define=SOME_FLAG=true
///
/// Read once at startup. Tests override [featureFlagsProvider] instead of
/// passing defines. A flag is deleted, with its off path, in the release
/// that turns it on for good. Docs: docs/feature-releases.md.
///
/// No flags right now: Track and Care shipped in 1.10.0 and its flag was
/// deleted (#165).
class FeatureFlags {
  const FeatureFlags();

  /// From the build's `--dart-define`s.
  factory FeatureFlags.fromEnvironment() => const FeatureFlags();
}

final featureFlagsProvider = Provider<FeatureFlags>(
  (ref) => FeatureFlags.fromEnvironment(),
);
