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
