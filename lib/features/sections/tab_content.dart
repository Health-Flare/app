import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/activity/screens/activity_list_screen.dart';
import 'package:health_flare/features/appointments/screens/appointment_list_screen.dart';
import 'package:health_flare/features/daily_checkin/screens/checkin_history_screen.dart';
import 'package:health_flare/features/flare/screens/flare_history_screen.dart';
import 'package:health_flare/features/journal/screens/journal_list_screen.dart';
import 'package:health_flare/features/meals/screens/meals_screen.dart';
import 'package:health_flare/features/medications/screens/medications_screen.dart';
import 'package:health_flare/features/sleep/screens/sleep_list_screen.dart';
import 'package:health_flare/features/tracking/screens/tracking_screen.dart';

/// Where a tab's add button goes.
class AddTarget {
  const AddTarget(this.location, {this.extra});
  final String location;
  final Object? extra;
}

/// What a tab shows inside its section (#141): the list, its add button
/// and any top-bar actions of its own.
class TabContent {
  const TabContent({
    required this.body,
    required this.addTooltip,
    required this.addTarget,
    this.addIcon = Icons.add,
    this.actions = const [],
  });

  final WidgetBuilder body;
  final String addTooltip;
  final IconData addIcon;
  final ProviderListenable<AddTarget> addTarget;

  /// Shown before Reports, Settings and the profile button.
  final List<Widget> actions;
}

Provider<AddTarget> _to(String location) =>
    Provider((ref) => AddTarget(location));

/// Today's check-in, opened to edit if it's already done (#141 review).
final _checkinTarget = Provider<AddTarget>((ref) {
  final today = ref.watch(todayCheckinProvider);
  return today == null
      ? const AddTarget(AppRoutes.checkinNew)
      : AddTarget(AppRoutes.checkinEdit(today.id), extra: today);
});

final _contents = <String, TabContent>{
  'track.symptoms': TabContent(
    body: (_) => const SymptomListBody(),
    addTooltip: 'Log symptom',
    addTarget: _to(AppRoutes.symptomsNew),
  ),
  'track.vitals': TabContent(
    body: (_) => const VitalListBody(),
    addTooltip: 'Log vital',
    addTarget: _to(AppRoutes.vitalsNew),
  ),
  'track.meals': TabContent(
    body: (_) => const MealsBody(),
    addTooltip: 'Log meal',
    addTarget: _to(AppRoutes.mealsNew),
  ),
  'track.sleep': TabContent(
    body: (_) => const SleepListBody(),
    addTooltip: 'Log sleep',
    addTarget: _to(AppRoutes.sleepNew),
  ),
  'track.activity': TabContent(
    body: (_) => const ActivityListBody(),
    addTooltip: 'Log activity',
    addTarget: _to(AppRoutes.activityNew),
  ),
  'care.medications': TabContent(
    body: (_) => const MedicationsBody(),
    addTooltip: 'Add medication',
    addTarget: _to(AppRoutes.medicationsNew),
  ),
  'care.appointments': TabContent(
    body: (_) => const AppointmentListBody(),
    addTooltip: 'New appointment',
    addIcon: Icons.add_rounded,
    addTarget: _to(AppRoutes.appointmentNew),
  ),
  'care.conditions': TabContent(
    body: (_) => const ConditionListBody(),
    addTooltip: 'Add condition',
    addTarget: _to(AppRoutes.illness),
  ),
  'care.flares': TabContent(
    body: (_) => const FlareHistoryBody(canAdd: true),
    addTooltip: 'Record a flare',
    addTarget: _to(AppRoutes.flareNew),
  ),
  'journal.entries': TabContent(
    body: (_) => const JournalEntriesBody(showSearchField: true),
    addTooltip: 'New journal entry',
    addIcon: Icons.edit_rounded,
    addTarget: _to(AppRoutes.journalNew),
    actions: const [JournalSearchAction()],
  ),
  'journal.checkins': TabContent(
    body: (_) => const CheckInHistoryBody(),
    addTooltip: "Today's check-in",
    addIcon: Icons.add_rounded,
    addTarget: _checkinTarget,
  ),
};

/// Every tab's content, by tab id. A provider so Features in use (#142)
/// can leave tabs out and tests can swap in placeholders.
final tabContentProvider = Provider<Map<String, TabContent>>(
  (ref) => _contents,
);
