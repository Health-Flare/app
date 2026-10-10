import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build flags (#136): unfinished work merges to main switched off, and is
/// switched on for a build with `--dart-define`:
///
///   flutter run --dart-define=TRACK_AND_CARE=true
///
/// Read once at startup. Tests override [featureFlagsProvider] instead of
/// passing defines. A flag is deleted, with its off path, in the release
/// that turns it on for good. Docs: docs/feature-releases.md.
class FeatureFlags {
  const FeatureFlags({this.trackAndCare = false});

  /// From the build's `--dart-define`s.
  factory FeatureFlags.fromEnvironment() =>
      const FeatureFlags(trackAndCare: bool.fromEnvironment('TRACK_AND_CARE'));

  /// Layout v2: Track and Care sections with tabs, Your layout, and the
  /// release guide (#135). Ships when #145 turns it on.
  final bool trackAndCare;
}

final featureFlagsProvider = Provider<FeatureFlags>(
  (ref) => FeatureFlags.fromEnvironment(),
);
