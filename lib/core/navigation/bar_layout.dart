import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:health_flare/core/feature_flags.dart';

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

int currentDefaultBarVersion(FeatureFlags flags) =>
    throw UnimplementedError('#137');

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

class BarChange {
  const BarChange({
    required this.fromVersion,
    required this.toVersion,
    required this.customized,
    required this.before,
    required this.newDefault,
  });
  final int fromVersion;
  final int toVersion;
  final bool customized;
  final List<String> before;
  final List<String> newDefault;
}

List<String> barFor(
  BarRecord record, {
  required int current,
  Map<int, List<String>> defaults = defaultBarVersions,
}) => throw UnimplementedError('#137');

BarChange? pendingBarChange(
  BarRecord record, {
  required int current,
  Map<int, List<String>> defaults = defaultBarVersions,
}) => throw UnimplementedError('#137');

BarRecord markBarChangeSeen(BarRecord record, int version) =>
    throw UnimplementedError('#137');

BarRecord settleBarLaunch(
  BarRecord record, {
  required int current,
  required bool hasProfiles,
}) => throw UnimplementedError('#137');

BarRecord chooseBar(
  BarRecord record,
  List<String>? bar, {
  required int current,
  Map<int, List<String>> defaults = defaultBarVersions,
}) => throw UnimplementedError('#137');
