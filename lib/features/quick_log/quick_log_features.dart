import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/features/quick_log/quick_log_classifier.dart';

/// The Features in use switch a Quick Log entry type belongs to, or null
/// for types no switch covers (#142). The classifier is unchanged: a
/// turned-off type is still offered and saved, with a warning.
String? quickLogFeatureFor(QuickLogEntryType type) => switch (type) {
  QuickLogEntryType.meal => 'track.meals',
  QuickLogEntryType.vital => 'track.vitals',
  QuickLogEntryType.sleep => 'track.sleep',
  QuickLogEntryType.activity => 'track.activity',
  QuickLogEntryType.medication => 'care.medications',
  QuickLogEntryType.doctorVisit => 'care.appointments',
  QuickLogEntryType.flare => 'care.flares',
  QuickLogEntryType.journal => 'journal.entries',
  QuickLogEntryType.mood || QuickLogEntryType.cycle => 'journal.checkins',
  QuickLogEntryType.symptom ||
  QuickLogEntryType.condition ||
  QuickLogEntryType.hydration ||
  QuickLogEntryType.bowel => null,
};

/// What Quick Log saves for each feature, in "This meal will be saved".
const _savedNoun = {
  'track.vitals': 'reading',
  'track.meals': 'meal',
  'track.sleep': 'sleep entry',
  'track.activity': 'activity',
  'care.medications': 'dose',
  'care.appointments': 'appointment',
  'care.flares': 'flare',
  'journal.entries': 'entry',
  'journal.checkins': 'check-in',
};

/// The warning under the sheet when what's about to be saved belongs to a
/// turned-off feature (navigation-customization.feature).
String quickLogOffWarning({
  required String profileName,
  required String featureId,
}) {
  final label = navFeature(featureId).label;
  final section = sectionOfTab(featureId).label;
  final noun = _savedNoun[featureId] ?? 'entry';
  return '$label is turned off for $profileName. This $noun will be saved '
      'and shown in recent activity, but not in $section until $label is '
      'back on.';
}
