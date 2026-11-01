// Issue #83: per-profile temperature unit (display only).
// Specs: docs/features/profiles.feature, symptoms_and_vitals.feature,
// reports.feature ("Temperature unit" scenarios).
import '../helpers/no_flares.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/features/dashboard/widgets/dashboard_activity_feed.dart';
import 'package:health_flare/models/activity_item.dart';
import 'package:health_flare/features/profiles/widgets/add_profile_sheet.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptoms_vitals_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/vital_entry_form_screen.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _RecordingProfileList extends ProfileListNotifier {
  _RecordingProfileList(this.profiles, this.updates);
  final List<Profile> profiles;
  final List<Profile> updates;

  @override
  List<Profile> build() => profiles;

  @override
  Future<void> update(Profile updated) async => updates.add(updated);
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  _FakeActiveProfile(this.id);
  final int? id;

  @override
  int? build() => id;
}

class _FakeVitalList extends VitalEntryListNotifier {
  _FakeVitalList({this.entries = const []});
  final List<VitalEntry> entries;

  @override
  List<VitalEntry> build() => entries;
}

class _FakeSymptomList extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => const [];
}

VitalEntry _temp(double value, String unit) => VitalEntry(
  id: 1,
  profileId: 1,
  vitalType: VitalType.temperature,
  value: value,
  unit: unit,
  loggedAt: DateTime(2026, 9, 20, 8),
  createdAt: DateTime(2026, 9, 20, 8),
);

VitalEntry _height(double value, String unit) => VitalEntry(
  id: 2,
  profileId: 1,
  vitalType: VitalType.height,
  value: value,
  unit: unit,
  loggedAt: DateTime(2026, 9, 20, 8),
  createdAt: DateTime(2026, 9, 20, 8),
);

// ---------------------------------------------------------------------------
// Builders
// ---------------------------------------------------------------------------

Widget _editSheet(Profile sarah, List<Profile> updates) => ProviderScope(
  overrides: [
    noFlares,
    profileListProvider.overrideWith(
      () => _RecordingProfileList([sarah], updates),
    ),
    activeProfileProvider.overrideWith(() => _FakeActiveProfile(sarah.id)),
  ],
  child: MaterialApp(
    home: Scaffold(body: AddProfileSheet(existing: sarah)),
  ),
);

Widget _vitalForm(Profile sarah) => ProviderScope(
  overrides: [
    noFlares,
    vitalEntryListProvider.overrideWith(_FakeVitalList.new),
    activeProfileProvider.overrideWith(() => _FakeActiveProfile(sarah.id)),
    profileListProvider.overrideWith(() => _RecordingProfileList([sarah], [])),
    activeProfileDataProvider.overrideWith((ref) => sarah),
  ],
  child: const MaterialApp(home: VitalEntryFormScreen()),
);

Widget _vitalsList(Profile sarah, List<VitalEntry> vitals) => ProviderScope(
  overrides: [
    noFlares,
    symptomEntryListProvider.overrideWith(_FakeSymptomList.new),
    vitalEntryListProvider.overrideWith(() => _FakeVitalList(entries: vitals)),
    activeProfileProvider.overrideWith(() => _FakeActiveProfile(sarah.id)),
    profileListProvider.overrideWith(() => _RecordingProfileList([sarah], [])),
    activeProfileDataProvider.overrideWith((ref) => sarah),
    activeProfileSymptomEntriesProvider.overrideWith((ref) => const []),
    activeProfileVitalEntriesProvider.overrideWith((ref) => vitals),
  ],
  child: const MaterialApp(home: SymptomsVitalsScreen()),
);

Future<void> _selectTemperature(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('vital_type_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Temperature').last);
  await tester.pumpAndSettle();
}

Future<void> _selectHeight(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('vital_type_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Height').last);
  await tester.pumpAndSettle();
}

Future<void> _openVitals(WidgetTester tester) async {
  await tester.tap(find.text('Vitals'));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

String? _unitShown(WidgetTester tester) {
  final dropdown = find.byKey(const Key('vital_unit_dropdown'));
  for (final u in ['°C', '°F', 'cm', 'in']) {
    if (find
        .descendant(of: dropdown, matching: find.text(u))
        .evaluate()
        .isNotEmpty) {
      return u;
    }
  }
  return null;
}

void main() {
  // -------------------------------------------------------------------------
  // Profile model
  // -------------------------------------------------------------------------

  group('Profile.temperatureUnit', () {
    test('defaults to null ("As logged")', () {
      expect(Profile(id: 1, name: 'Sarah').temperatureUnit, isNull);
    });

    test('copyWith sets the unit', () {
      final p = Profile(id: 1, name: 'Sarah').copyWith(temperatureUnit: '°F');
      expect(p.temperatureUnit, '°F');
    });

    test('copyWith keeps the unit when not given', () {
      final p = Profile(
        id: 1,
        name: 'Sarah',
        temperatureUnit: '°C',
      ).copyWith(name: 'Sarah B');
      expect(p.temperatureUnit, '°C');
    });

    test('copyWith can clear back to "As logged"', () {
      final p = Profile(
        id: 1,
        name: 'Sarah',
        temperatureUnit: '°C',
      ).copyWith(clearTemperatureUnit: true);
      expect(p.temperatureUnit, isNull);
    });

    test('height unit defaults to "As logged" and can be cleared', () {
      expect(Profile(id: 1, name: 'Sarah').heightUnit, isNull);
      final p = Profile(
        id: 1,
        name: 'Sarah',
        heightUnit: 'in',
      ).copyWith(heightUnit: 'cm');
      expect(p.heightUnit, 'cm');
      expect(p.copyWith(clearHeightUnit: true).heightUnit, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // VitalEntry.displayValueIn
  // -------------------------------------------------------------------------

  group('VitalEntry.displayValueIn', () {
    test('converts °F to °C with one decimal', () {
      expect(
        _temp(100.4, '°F').displayValueIn(temperatureUnit: '°C'),
        '38.0 °C',
      );
    });

    test('converts °C to °F with one decimal', () {
      expect(_temp(37, '°C').displayValueIn(temperatureUnit: '°F'), '98.6 °F');
    });

    test('null shows the reading as logged', () {
      expect(_temp(100.4, '°F').displayValueIn(), '100.4 °F');
    });

    test('same unit shows the reading as logged', () {
      expect(
        _temp(100.4, '°F').displayValueIn(temperatureUnit: '°F'),
        '100.4 °F',
      );
    });

    test('same temperature unit preserves integer display', () {
      expect(_temp(100, '°F').displayValueIn(temperatureUnit: '°F'), '100 °F');
    });

    test('non-temperature vitals are not touched', () {
      final hr = VitalEntry(
        id: 2,
        profileId: 1,
        vitalType: VitalType.heartRate,
        value: 72,
        unit: 'BPM',
        loggedAt: DateTime(2026, 9, 20),
        createdAt: DateTime(2026, 9, 20),
      );
      expect(hr.displayValueIn(temperatureUnit: '°F'), '72 BPM');
    });

    test('height converts to inches with one decimal place', () {
      expect(_height(170, 'cm').displayValueIn(heightUnit: 'in'), '66.9 in');
    });

    test('height converted to cm is shown as a whole number', () {
      expect(_height(66.9, 'in').displayValueIn(heightUnit: 'cm'), '170 cm');
    });

    test('height already in cm keeps its logged precision, not rounded', () {
      // Profile prefers cm and the reading was already logged in cm: no
      // conversion happens, so this must show exactly as logged, not run
      // through convert+round to a whole number.
      expect(_height(170.8, 'cm').displayValueIn(heightUnit: 'cm'), '170.8 cm');
    });

    test('height already in the profile unit shows as logged (in)', () {
      expect(_height(66.9, 'in').displayValueIn(heightUnit: 'in'), '66.9 in');
    });

    test('height stays as logged when no profile unit is chosen', () {
      expect(_height(66.9, 'in').displayValueIn(), '66.9 in');
    });
  });

  // -------------------------------------------------------------------------
  // Profile edit sheet
  // -------------------------------------------------------------------------

  group('AddProfileSheet temperature unit', () {
    testWidgets('shows the setting with "As logged" selected by default', (
      tester,
    ) async {
      await tester.pumpWidget(_editSheet(Profile(id: 1, name: 'Sarah'), []));
      await tester.pump();

      expect(find.text('Temperature unit'), findsOneWidget);
      final seg = tester.widget<SegmentedButton<String>>(
        find.byKey(const Key('temperature_unit_preference')),
      );
      expect(seg.selected, {'As logged'});
    });

    for (final (choice, saved) in [
      ('°C', '°C'),
      ('°F', '°F'),
      ('As logged', null),
    ]) {
      testWidgets('choosing "$choice" saves $saved', (tester) async {
        final updates = <Profile>[];
        final start = choice == 'As logged' ? '°F' : null;
        await tester.pumpWidget(
          _editSheet(
            Profile(id: 1, name: 'Sarah', temperatureUnit: start),
            updates,
          ),
        );
        await tester.pump();

        final option = find.descendant(
          of: find.byKey(const Key('temperature_unit_preference')),
          matching: find.text(choice),
        );
        await tester.scrollUntilVisible(
          option,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(option);
        await tester.pump();
        await tester.tap(find.text('Save changes'));
        await tester.pump();

        expect(updates, hasLength(1));
        expect(updates.single.temperatureUnit, saved);
      });
    }

    testWidgets('shows the height setting with "As logged" by default', (
      tester,
    ) async {
      await tester.pumpWidget(_editSheet(Profile(id: 1, name: 'Sarah'), []));
      await tester.pump();

      expect(find.text('Height unit'), findsOneWidget);
      final seg = tester.widget<SegmentedButton<String>>(
        find.byKey(const Key('height_unit_preference')),
      );
      expect(seg.selected, {'As logged'});
    });

    for (final (choice, saved) in [
      ('cm', 'cm'),
      ('in', 'in'),
      ('As logged', null),
    ]) {
      testWidgets('choosing height "$choice" saves $saved', (tester) async {
        final updates = <Profile>[];
        await tester.pumpWidget(
          _editSheet(
            Profile(
              id: 1,
              name: 'Sarah',
              heightUnit: choice == 'As logged' ? 'in' : null,
            ),
            updates,
          ),
        );
        await tester.pump();

        await tester.scrollUntilVisible(
          find.descendant(
            of: find.byKey(const Key('height_unit_preference')),
            matching: find.text(choice),
          ),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(
          find.descendant(
            of: find.byKey(const Key('height_unit_preference')),
            matching: find.text(choice),
          ),
        );
        await tester.pump();
        await tester.scrollUntilVisible(
          find.text('Save changes'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Save changes'));
        await tester.pump();

        expect(updates, hasLength(1));
        expect(updates.single.heightUnit, saved);
      });
    }
  });

  // -------------------------------------------------------------------------
  // Vital entry form
  // -------------------------------------------------------------------------

  group('VitalEntryFormScreen temperature unit', () {
    testWidgets('new temperature starts in the profile unit', (tester) async {
      await tester.pumpWidget(
        _vitalForm(Profile(id: 1, name: 'Sarah', temperatureUnit: '°F')),
      );
      await tester.pump();

      await _selectTemperature(tester);

      expect(_unitShown(tester), '°F');
    });

    testWidgets('"As logged" starts temperature in °C', (tester) async {
      await tester.pumpWidget(_vitalForm(Profile(id: 1, name: 'Sarah')));
      await tester.pump();

      await _selectTemperature(tester);

      expect(_unitShown(tester), '°C');
    });

    testWidgets('new height starts in the profile unit', (tester) async {
      await tester.pumpWidget(
        _vitalForm(Profile(id: 1, name: 'Sarah', heightUnit: 'in')),
      );
      await tester.pump();

      await _selectHeight(tester);

      expect(_unitShown(tester), 'in');
    });

    testWidgets('"As logged" starts height in cm', (tester) async {
      await tester.pumpWidget(_vitalForm(Profile(id: 1, name: 'Sarah')));
      await tester.pump();

      await _selectHeight(tester);

      expect(_unitShown(tester), 'cm');
    });
  });

  // -------------------------------------------------------------------------
  // Dashboard activity feed
  // -------------------------------------------------------------------------

  group('DashboardActivityFeed temperature unit', () {
    Widget feed({String? unit}) => MaterialApp(
      home: Scaffold(
        body: DashboardActivityFeed(
          items: [
            VitalActivityItem(
              timestamp: DateTime(2026, 9, 20, 8),
              entry: _temp(100.4, '°F'),
            ),
          ],
          temperatureUnit: unit,
        ),
      ),
    );

    testWidgets('shows the reading in the profile unit', (tester) async {
      await tester.pumpWidget(feed(unit: '°C'));
      expect(find.textContaining('38.0 °C'), findsOneWidget);
    });

    testWidgets('shows the reading as logged by default', (tester) async {
      await tester.pumpWidget(feed());
      expect(find.textContaining('100.4 °F'), findsOneWidget);
    });
  });

  group('DashboardActivityFeed height unit', () {
    testWidgets('shows height in the profile unit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardActivityFeed(
              items: [
                VitalActivityItem(
                  timestamp: DateTime(2026, 9, 20, 8),
                  entry: _height(170, 'cm'),
                ),
              ],
              heightUnit: 'in',
            ),
          ),
        ),
      );
      expect(find.textContaining('66.9 in'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Vitals list
  // -------------------------------------------------------------------------

  group('Vitals list temperature unit', () {
    testWidgets('shows the reading in the profile unit', (tester) async {
      await tester.pumpWidget(
        _vitalsList(Profile(id: 1, name: 'Sarah', temperatureUnit: '°C'), [
          _temp(100.4, '°F'),
        ]),
      );
      await tester.pump();
      await _openVitals(tester);

      expect(find.text('38.0 °C'), findsOneWidget);
    });

    testWidgets('shows the reading as logged by default', (tester) async {
      await tester.pumpWidget(
        _vitalsList(Profile(id: 1, name: 'Sarah'), [_temp(100.4, '°F')]),
      );
      await tester.pump();
      await _openVitals(tester);

      expect(find.text('100.4 °F'), findsOneWidget);
    });
  });

  group('Vitals list height unit', () {
    testWidgets('shows height in the profile unit', (tester) async {
      await tester.pumpWidget(
        _vitalsList(Profile(id: 1, name: 'Sarah', heightUnit: 'in'), [
          _height(170, 'cm'),
        ]),
      );
      await tester.pump();
      await _openVitals(tester);

      expect(find.text('66.9 in'), findsOneWidget);
    });

    testWidgets('shows height as logged by default', (tester) async {
      await tester.pumpWidget(
        _vitalsList(Profile(id: 1, name: 'Sarah'), [_height(170, 'cm')]),
      );
      await tester.pump();
      await _openVitals(tester);

      expect(find.text('170 cm'), findsOneWidget);
    });
  });
}
