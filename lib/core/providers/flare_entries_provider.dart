// The entries that are part of a flare (#173), worked out with [flareFor].
// The one place a screen asks "what's in this flare" or "which flare is
// this entry part of", so the flare screen, the forms and the move
// warnings always agree.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

class FlareEntries {
  const FlareEntries({
    this.symptoms = const [],
    this.vitals = const [],
    this.meals = const [],
    this.doses = const [],
    this.activities = const [],
  });

  final List<SymptomEntry> symptoms;
  final List<VitalEntry> vitals;
  final List<MealEntry> meals;
  final List<DoseLog> doses;
  final List<ActivityEntry> activities;

  int get total =>
      symptoms.length +
      vitals.length +
      meals.length +
      doses.length +
      activities.length;
}

/// Every entry that is part of flare [flareId], newest first in each kind.
final flareEntriesProvider = Provider.family<FlareEntries, int>((ref, flareId) {
  ref.watch(flareListProvider);
  ref.watch(symptomEntryListProvider);
  ref.watch(vitalEntryListProvider);
  ref.watch(mealEntryListProvider);
  ref.watch(doseLogListProvider);
  ref.watch(activityEntryListProvider);
  return const FlareEntries(); // TODO(#173): red stub
});

/// The flare an entry would be part of: for a form, as it's being edited.
/// Null when no flare covers [at] or it was taken out.
final entryFlareProvider =
    Provider.family<
      Flare?,
      ({int profileId, DateTime at, int? pinnedFlareId, bool detached})
    >((ref, e) {
      ref.watch(flareListProvider);
      return null; // TODO(#173): red stub
    });

/// The flare covering [at] for a profile, ignoring any choice on the
/// entry: what "Add back" would put it in.
final coveringFlareProvider =
    Provider.family<Flare?, ({int profileId, DateTime at})>((ref, e) {
      ref.watch(flareListProvider);
      return null; // TODO(#173): red stub
    });
