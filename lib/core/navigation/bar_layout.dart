import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';

// Bottom bar choice and default-layout versions (#137).
// Spec: navigation-customization.feature ("Later updates") and
// release-guides.feature ("Every change to the default bar comes with a
// guide"). Nobody's bar changes without them being told: a database
// records which default it last showed, and an update that changes the
// default is explained from there.

/// The bar every release up to 1.9.1 had, and the version a database
/// without one recorded is on.
const kLegacyBarVersion = 1;

/// Every default bar there has been, by layout version. Never edit or
/// remove one: an update explains what changed from the version someone
/// last saw. A new default is a new version, with a release guide (#140).
const defaultBarVersions = <int, List<String>>{
  1: [
    'dashboard',
    'track',
    'care.medications',
    'track.meals',
    'journal',
    'track.sleep',
  ],
  2: ['dashboard', 'track', 'care', 'journal'],
};

/// The release guide (`guideId` in assets/whats_new/releases.json) that
/// explains each default bar after 1.9.1. Every version in
/// [defaultBarVersions] above 1 must have one; a test enforces it. The
/// release that turns a version on must carry that guide (#145).
const defaultBarGuideIds = <int, String>{2: 'track-and-care'};

/// The default bar this build shows.
int currentDefaultBarVersion(FeatureFlags flags) =>
    flags.trackAndCare ? 2 : kLegacyBarVersion;

/// What's stored on this device: [storedBar] null means "use the default",
/// [seenVersion] null means 1.9.1 or earlier.
@immutable
class BarRecord {
  const BarRecord({this.storedBar, this.seenVersion});
  final List<String>? storedBar;
  final int? seenVersion;

  @override
  bool operator ==(Object other) =>
      other is BarRecord &&
      listEquals(other.storedBar, storedBar) &&
      other.seenVersion == seenVersion;

  @override
  int get hashCode => Object.hash(Object.hashAll(storedBar ?? []), seenVersion);

  @override
  String toString() => 'BarRecord($storedBar, v$seenVersion)';
}

/// A default-bar change someone hasn't been shown yet.
class BarChange {
  const BarChange({
    required this.fromVersion,
    required this.toVersion,
    required this.customized,
    required this.before,
    required this.newDefault,
  });

  /// The default they last saw, and the default now.
  final int fromVersion;
  final int toVersion;

  /// Their bar is their own and was kept ("Yours has been kept").
  final bool customized;

  /// The bar they had: their own if [customized], otherwise the default
  /// of [fromVersion].
  final List<String> before;

  final List<String> newDefault;
}

List<String> _defaultFor(int version, Map<int, List<String>> defaults) =>
    defaults[version] ?? defaults[kLegacyBarVersion]!;

/// The bar to show: the stored one resolved (merged ids followed, unknown
/// ids dropped), or the current default.
List<String> barFor(
  BarRecord record, {
  required int current,
  Map<int, List<String>> defaults = defaultBarVersions,
}) =>
    resolveBarIds(record.storedBar, defaultBar: _defaultFor(current, defaults));

/// The change to show, or null. No version recorded means 1.9.1 or
/// earlier, which only had the legacy bar. Never looks back: a downgrade,
/// or a build with the flag off, shows nothing.
BarChange? pendingBarChange(
  BarRecord record, {
  required int current,
  Map<int, List<String>> defaults = defaultBarVersions,
}) {
  final from = record.seenVersion ?? kLegacyBarVersion;
  if (from >= current) return null;
  final stored = record.storedBar;
  return BarChange(
    fromVersion: from,
    toVersion: current,
    customized: stored != null,
    before: stored != null
        ? barFor(record, current: current, defaults: defaults)
        : List.of(_defaultFor(from, defaults)),
    newDefault: List.of(_defaultFor(current, defaults)),
  );
}

/// Called when the change has been shown (#145). Never moves back.
BarRecord markBarChangeSeen(BarRecord record, int version) {
  final seen = record.seenVersion;
  if (seen != null && seen >= version) return record;
  return BarRecord(storedBar: record.storedBar, seenVersion: version);
}

/// At launch, before onboarding: a fresh install (nothing recorded, no
/// profiles) starts on the current default with nothing to explain. An
/// update from 1.9.1 or earlier has profiles, and is left unrecorded so
/// the change is shown.
BarRecord settleBarLaunch(
  BarRecord record, {
  required int current,
  required bool hasProfiles,
}) {
  if (record.seenVersion != null || hasProfiles) return record;
  return BarRecord(storedBar: record.storedBar, seenVersion: current);
}

/// The person chose [bar] (null is "Use default"), on the [current]
/// default. A copy of the default is stored as "default", so it follows
/// the next one (rule 4).
BarRecord chooseBar(
  BarRecord record,
  List<String>? bar, {
  required int current,
  Map<int, List<String>> defaults = defaultBarVersions,
}) {
  final isDefault =
      bar == null || listEquals(bar, _defaultFor(current, defaults));
  final seen = record.seenVersion;
  return BarRecord(
    storedBar: isDefault ? null : List.unmodifiable(bar),
    seenVersion: seen != null && seen > current ? seen : current,
  );
}
