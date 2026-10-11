import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/models/profile.dart';

/// Whether [featureId] is on for [profile] (#137). Only what's turned off
/// is stored, so a feature added in a later version is on. Symptoms and
/// Conditions can't be turned off, whatever is stored.
bool featureInUse(Profile profile, String featureId) {
  for (final f in navFeatures) {
    if (f.id == featureId && !f.canTurnOff) return true;
  }
  return !profile.disabledFeatureIds.contains(featureId);
}

// TODO(#142): stubs.
final featureOnProvider = Provider.family<bool, String>(
  (ref, id) => throw UnimplementedError('#142'),
);

final visibleTabsProvider = Provider.family<List<NavTab>, String>(
  (ref, sectionId) => throw UnimplementedError('#142'),
);

final visibleSectionsProvider = Provider<List<NavSection>>(
  (ref) => throw UnimplementedError('#142'),
);

final featureEntryCountProvider = Provider.family<int, String>(
  (ref, id) => throw UnimplementedError('#142'),
);

String featureKeptMessage({
  required String profileName,
  required String featureId,
  required int count,
}) => throw UnimplementedError('#142');
