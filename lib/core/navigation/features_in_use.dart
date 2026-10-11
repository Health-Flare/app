import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
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

// ---------------------------------------------------------------------------
// The active profile (#142)
// ---------------------------------------------------------------------------

/// Whether [featureId] is on for the active profile. Always on with Track
/// and Care off: nothing can turn a feature off until it ships.
final featureOnProvider = Provider.family<bool, String>((ref, featureId) {
  if (!ref.watch(featureFlagsProvider).trackAndCare) return true;
  for (final f in navFeatures) {
    if (f.id == featureId && !f.canTurnOff) return true;
  }
  return !ref.watch(activeDisabledFeaturesProvider).contains(featureId);
});

/// The active profile's turned-off features. Watches the profile list as
/// well as the active profile: `Profile ==` compares ids only, so
/// [activeProfileDataProvider] on its own doesn't tell watchers when a
/// profile's settings change (Riverpod 3 drops updates that compare
/// equal, #160). Reading it after the list changes gives the new profile.
final activeDisabledFeaturesProvider = Provider<List<String>>((ref) {
  ref.watch(profileListProvider);
  return ref.watch(activeProfileDataProvider)?.disabledFeatureIds ?? const [];
});

/// A section's tabs whose feature is on for the active profile, in order.
final visibleTabsProvider = Provider.family<List<NavTab>, String>((
  ref,
  sectionId,
) {
  final section = navSections.firstWhere((s) => s.id == sectionId);
  return [
    for (final t in section.tabs)
      if (ref.watch(featureOnProvider(t.featureId))) t,
  ];
});

/// The sections in the bar: a section with every tab turned off leaves it.
/// Track and Care never do (Symptoms and Conditions are always on).
final visibleSectionsProvider = Provider<List<NavSection>>(
  (ref) => [
    for (final s in navSections)
      if (s.tabs.isEmpty || ref.watch(visibleTabsProvider(s.id)).isNotEmpty) s,
  ],
);

/// Turns [featureId] on or off for [profile]. Changes only the switch:
/// nothing logged is touched (rule 5).
Future<void> setFeatureOn(
  ProfileListNotifier profiles,
  Profile profile,
  String featureId, {
  required bool on,
}) {
  final off = [
    for (final id in profile.disabledFeatureIds)
      if (id != featureId) id,
    if (!on) featureId,
  ];
  return profiles.update(profile.copyWith(disabledFeatureIds: off));
}

// ---------------------------------------------------------------------------
// What the app says
// ---------------------------------------------------------------------------

NavFeature navFeature(String id) => navFeatures.firstWhere((f) => f.id == id);

/// How each feature's entries are counted in messages: (one, many).
const featureEntryNouns = <String, (String, String)>{
  'track.symptoms': ('symptom', 'symptoms'),
  'track.vitals': ('vital reading', 'vital readings'),
  'track.meals': ('meal', 'meals'),
  'track.sleep': ('sleep entry', 'sleep entries'),
  'track.activity': ('activity', 'activities'),
  'care.medications': ('medication', 'medications'),
  'care.appointments': ('appointment', 'appointments'),
  'care.conditions': ('condition', 'conditions'),
  'care.flares': ('flare', 'flares'),
  'journal.entries': ('journal entry', 'journal entries'),
  'journal.checkins': ('check-in', 'check-ins'),
};

/// The active profile's entries for [featureId], for "Sarah's 40 meals are
/// kept".
final featureEntryCountProvider = Provider.family<int, String>((ref, id) {
  return switch (id) {
    'track.vitals' => ref.watch(activeProfileVitalEntriesProvider).length,
    'track.meals' => ref.watch(activeProfileMealEntriesProvider).length,
    'track.sleep' => ref.watch(activeSleepEntriesProvider).length,
    'track.activity' => ref.watch(activeProfileActivityEntriesProvider).length,
    'care.medications' => ref.watch(activeProfileMedicationsProvider).length,
    'care.appointments' => ref.watch(activeProfileAppointmentsProvider).length,
    'care.flares' => ref.watch(activeProfileFlaresProvider).length,
    'journal.entries' => ref.watch(activeProfileJournalProvider).length,
    'journal.checkins' => ref.watch(activeProfileCheckinsProvider).length,
    _ => 0,
  };
});

/// Said when a feature is turned off: its data is kept.
String featureKeptMessage({
  required String profileName,
  required String featureId,
  required int count,
}) {
  final label = navFeature(featureId).label;
  if (count == 0) {
    return '$label is off for $profileName. Turn it back on any time.';
  }
  final (one, many) = featureEntryNouns[featureId]!;
  return count == 1
      ? "$profileName's 1 $one is kept. Turn $label back on any time to see it."
      : "$profileName's $count $many are kept. Turn $label back on any time "
            'to see them.';
}
