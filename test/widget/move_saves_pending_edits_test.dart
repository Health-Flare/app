import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/features/activity/screens/activity_entry_form_screen.dart';
import 'package:health_flare/features/sleep/screens/sleep_entry_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptom_entry_form_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/vital_entry_form_screen.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';

// Moving an entry from an edit screen must not lose unsaved edits: they are
// saved first, then the entry moves (#77 follow-up). Each fake records the
// order of calls so the test can check save-then-move.

final _calls = <String>[];

class _Symptoms extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => [];
  @override
  Future<void> update(SymptomEntry updated) async =>
      _calls.add('update:${updated.notes}');
  @override
  Future<void> moveToProfile(int id, int newProfileId) async =>
      _calls.add('move:$newProfileId');
}

class _Vitals extends VitalEntryListNotifier {
  @override
  List<VitalEntry> build() => [];
  @override
  Future<void> update(VitalEntry updated) async =>
      _calls.add('update:${updated.notes}');
  @override
  Future<void> moveToProfile(int id, int newProfileId) async =>
      _calls.add('move:$newProfileId');
}

class _Sleep extends SleepEntryListNotifier {
  @override
  List<SleepEntry> build() => [];
  @override
  Future<void> update(SleepEntry updated) async =>
      _calls.add('update:${updated.notes}');
  @override
  Future<void> moveToProfile(int id, int newProfileId) async =>
      _calls.add('move:$newProfileId');
}

class _Activity extends ActivityEntryListNotifier {
  @override
  List<ActivityEntry> build() => [];
  @override
  Future<void> update(ActivityEntry entry) async =>
      _calls.add('update:${entry.notes}');
  @override
  Future<void> moveToProfile(int id, int newProfileId) async =>
      _calls.add('move:$newProfileId');
}

class _Active extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _Profiles extends ProfileListNotifier {
  @override
  List<Profile> build() => [
    Profile(id: 1, name: 'Sarah'),
    Profile(id: 2, name: 'Dad'),
  ];
}

final _t = DateTime(2026, 7, 1, 8);

Widget _app(Widget screen) {
  final router = GoRouter(
    initialLocation: '/edit',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Root')),
        routes: [GoRoute(path: 'edit', builder: (_, _) => screen)],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      symptomEntryListProvider.overrideWith(_Symptoms.new),
      vitalEntryListProvider.overrideWith(_Vitals.new),
      sleepEntryListProvider.overrideWith(_Sleep.new),
      activityEntryListProvider.overrideWith(_Activity.new),
      activeProfileProvider.overrideWith(_Active.new),
      profileListProvider.overrideWith(_Profiles.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      activeSleepEntriesProvider.overrideWith((ref) => []),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _editNotesThenMove(
  WidgetTester tester,
  Widget screen,
  Finder notesField,
) async {
  await tester.pumpWidget(_app(screen));
  await tester.pumpAndSettle();
  await tester.enterText(notesField, 'edited before moving');
  await tester.tap(find.byTooltip('Move to another profile'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Dad'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Move'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(_calls.clear);

  const saveThenMove = ['update:edited before moving', 'move:2'];

  testWidgets('symptom: unsaved edits are saved, then moved', (tester) async {
    await _editNotesThenMove(
      tester,
      SymptomEntryFormScreen(
        entry: SymptomEntry(
          id: 1,
          profileId: 1,
          name: 'Joint pain',
          severity: 5,
          loggedAt: _t,
          createdAt: _t,
        ),
      ),
      find.byKey(const Key('symptom_notes_field')),
    );
    expect(_calls, saveThenMove);
  });

  testWidgets('vital: unsaved edits are saved, then moved', (tester) async {
    await _editNotesThenMove(
      tester,
      VitalEntryFormScreen(
        entry: VitalEntry(
          id: 1,
          profileId: 1,
          vitalType: VitalType.heartRate,
          value: 72,
          unit: VitalType.heartRate.defaultUnit,
          loggedAt: _t,
          createdAt: _t,
        ),
      ),
      find.byKey(const Key('vital_notes_field')),
    );
    expect(_calls, saveThenMove);
  });

  testWidgets('sleep: unsaved edits are saved, then moved', (tester) async {
    await _editNotesThenMove(
      tester,
      SleepEntryScreen(
        entry: SleepEntry(
          id: 1,
          profileId: 1,
          bedtime: DateTime(2026, 6, 30, 23),
          wakeTime: _t,
          createdAt: _t,
        ),
      ),
      find.byKey(const Key('sleep_notes_field')),
    );
    expect(_calls, saveThenMove);
  });

  testWidgets('activity: unsaved edits are saved, then moved', (tester) async {
    await _editNotesThenMove(
      tester,
      ActivityEntryFormScreen(
        entry: ActivityEntry(
          id: 1,
          profileId: 1,
          description: 'Short walk',
          loggedAt: _t,
          createdAt: _t,
        ),
      ),
      find.byKey(const Key('activity_notes_field')),
    );
    expect(_calls, saveThenMove);
  });

  testWidgets('symptom: an invalid edit blocks the move', (tester) async {
    await tester.pumpWidget(
      _app(
        SymptomEntryFormScreen(
          entry: SymptomEntry(
            id: 1,
            profileId: 1,
            name: 'Joint pain',
            severity: 5,
            loggedAt: _t,
            createdAt: _t,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('symptom_name_field')), '');
    await tester.tap(find.byTooltip('Move to another profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move'));
    await tester.pumpAndSettle();

    expect(_calls, isEmpty, reason: 'nothing saved, nothing moved');
    expect(find.text('Root'), findsNothing, reason: 'screen stays open');
  });

  testWidgets('symptom: a flare link being dropped is called out', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        SymptomEntryFormScreen(
          entry: SymptomEntry(
            id: 1,
            profileId: 1,
            name: 'Joint pain',
            severity: 5,
            loggedAt: _t,
            createdAt: _t,
            flareIsarId: 3,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Move to another profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dad'));
    await tester.pumpAndSettle();

    expect(
      find.text("It will no longer be part of Sarah's flare."),
      findsOneWidget,
    );
  });
}
