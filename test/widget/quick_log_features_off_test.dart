// Quick Log with a feature turned off (#142).
// Spec: navigation-customization.feature, "Quick Log still logs a
// turned-off feature, and says so".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/features/quick_log/widgets/quick_log_sheet.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';
import 'package:health_flare/models/weather_snapshot.dart';

final _meals = <String>[];
final _journal = <String>[];
final _profileUpdates = <Profile>[];

class _Active extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _Profiles extends ProfileListNotifier {
  _Profiles(this._start);
  final Profile _start;

  @override
  List<Profile> build() => [_start];

  @override
  Future<void> update(Profile updated) async {
    _profileUpdates.add(updated);
    state = [updated];
  }
}

class _Meals extends MealEntryListNotifier {
  @override
  List<MealEntry> build() => [];

  @override
  Future<int> add({
    required int profileId,
    required String description,
    String? notes,
    String? photoPath,
    required bool hasReaction,
    required DateTime loggedAt,
    int? flareIsarId,
    WeatherSnapshot? weatherSnapshot,
  }) async {
    _meals.add(description);
    return 1;
  }
}

class _Journal extends JournalEntryListNotifier {
  @override
  List<JournalEntry> build() => [];

  @override
  Future<int> add({
    required int profileId,
    required DateTime createdAt,
    required JournalSnapshot firstSnapshot,
    int? mood,
    int? energyLevel,
    WeatherSnapshot? weatherSnapshot,
  }) async {
    _journal.add(firstSnapshot.body);
    return 1;
  }
}

class _Symptoms extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => [];
}

class _Appointments extends AppointmentListNotifier {
  @override
  List<Appointment> build() => [];
}

class _Conditions extends ConditionCatalogNotifier {
  @override
  List<Condition> build() => [];
}

class _UserConditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => [];
}

class _SymptomCatalog extends SymptomCatalogNotifier {
  @override
  List<Symptom> build() => [];
}

class _UserSymptoms extends UserSymptomListNotifier {
  @override
  List<UserSymptom> build() => [];
}

Widget _sheet({List<String> off = const [], bool flag = true}) {
  final sarah = Profile(id: 1, name: 'Sarah', disabledFeatureIds: off);
  return ProviderScope(
    overrides: [
      featureFlagsProvider.overrideWithValue(FeatureFlags(trackAndCare: flag)),
      activeProfileProvider.overrideWith(_Active.new),
      profileListProvider.overrideWith(() => _Profiles(sarah)),
      activeProfileDataProvider.overrideWith(
        (ref) => ref.watch(profileListProvider).first,
      ),
      mealEntryListProvider.overrideWith(_Meals.new),
      journalEntryListProvider.overrideWith(_Journal.new),
      symptomEntryListProvider.overrideWith(_Symptoms.new),
      appointmentListProvider.overrideWith(_Appointments.new),
      activeProfileAppointmentsProvider.overrideWith((ref) => []),
      upcomingAppointmentsProvider.overrideWith((ref) => []),
      activeProfileMedicationsProvider.overrideWith((ref) => []),
      conditionCatalogProvider.overrideWith(_Conditions.new),
      userConditionListProvider.overrideWith(_UserConditions.new),
      symptomCatalogProvider.overrideWith(_SymptomCatalog.new),
      userSymptomListProvider.overrideWith(_UserSymptoms.new),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showQuickLogSheet(ctx),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

const _warning =
    'Meals is turned off for Sarah. This meal will be saved and shown in '
    'recent activity, but not in Track until Meals is back on.';

Future<void> _type(WidgetTester tester, Widget app, String text) async {
  await tester.pumpWidget(app);
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _meals.clear();
    _journal.clear();
    _profileUpdates.clear();
  });

  group('Quick Log still logs a turned-off feature, and says so', () {
    testWidgets('the Meals chip is still offered and selected, with the '
        'warning', (tester) async {
      await _type(
        tester,
        _sheet(off: ['track.meals']),
        'Toast and eggs for breakfast',
      );
      expect(find.text('Meal'), findsOneWidget);
      expect(find.text(_warning), findsOneWidget);
      expect(find.text('Turn Meals on'), findsOneWidget);
      expect(find.text('Save as a journal note too'), findsOneWidget);
    });

    testWidgets('saving saves a meal with the text as typed, and no journal '
        'note unless ticked', (tester) async {
      await _type(
        tester,
        _sheet(off: ['track.meals']),
        'Toast and eggs for breakfast',
      );
      await _save(tester);
      expect(_meals, ['Toast and eggs for breakfast']);
      expect(_journal, isEmpty);
    });

    testWidgets('ticked, a journal note is saved too', (tester) async {
      await _type(
        tester,
        _sheet(off: ['track.meals']),
        'Toast and eggs for breakfast',
      );
      await tester.tap(find.text('Save as a journal note too'));
      await tester.pumpAndSettle();
      await _save(tester);
      expect(_meals, ['Toast and eggs for breakfast']);
      expect(_journal, ['Toast and eggs for breakfast']);
    });

    testWidgets('"Turn Meals on" turns it on and the warning goes', (
      tester,
    ) async {
      await _type(
        tester,
        _sheet(off: ['track.meals']),
        'Toast and eggs for breakfast',
      );
      await tester.tap(find.text('Turn Meals on'));
      await tester.pumpAndSettle();
      expect(_profileUpdates.single.disabledFeatureIds, isEmpty);
      expect(find.text(_warning), findsNothing);
      expect(find.text('Save as a journal note too'), findsNothing);
    });
  });

  testWidgets('no warning when Meals is on', (tester) async {
    await _type(tester, _sheet(), 'Toast and eggs for breakfast');
    expect(find.text(_warning), findsNothing);
    expect(find.text('Save as a journal note too'), findsNothing);
  });

  testWidgets('no warning with Track and Care off, whatever is stored', (
    tester,
  ) async {
    await _type(
      tester,
      _sheet(off: ['track.meals'], flag: false),
      'Toast and eggs for breakfast',
    );
    expect(find.text(_warning), findsNothing);
  });
}
