import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptom_entry_form_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/weather_snapshot.dart';

// Optional symptom details offered as add-ons (Option C).
// Spec: docs/features/symptoms_and_vitals.feature, "Optional details: add
// only what helps". Credit: Dr Cat Hicks, Informed Patient.

const _cardText =
    'Tap any of these to add it to this entry. A line about how it affected '
    'your day tells your clinician more than a number.';
const _foldNote =
    "We tucked away Where and Anything else. You haven't used them in your "
    'last 10 entries. They\'re under "2 more" whenever you want them.';

final _saved = <SymptomEntry>[];
final _profileCalls = <String>[];

class _FakeSymptomList extends SymptomEntryListNotifier {
  _FakeSymptomList(this.entries);
  final List<SymptomEntry> entries;

  @override
  List<SymptomEntry> build() => entries;

  @override
  Future<int> add({
    required int profileId,
    required String name,
    required int severity,
    required DateTime loggedAt,
    List<String> locations = const [],
    String? notes,
    int? userSymptomIsarId,
    int? userConditionIsarId,
    int? flareIsarId,
    WeatherSnapshot? weatherSnapshot,
    int? interference,
    String? impact,
  }) async {
    _saved.add(
      SymptomEntry(
        id: 99,
        profileId: profileId,
        name: name,
        severity: severity,
        locations: locations,
        notes: notes,
        interference: interference,
        impact: impact,
        loggedAt: loggedAt,
        createdAt: loggedAt,
      ),
    );
    return 99;
  }
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  _FakeActiveProfile(this.id);
  final int id;

  @override
  int? build() => id;
}

class _FakeProfileList extends ProfileListNotifier {
  _FakeProfileList(this.profiles);
  final List<Profile> profiles;

  @override
  List<Profile> build() => profiles;

  @override
  Future<void> setShowAllSymptomOptions(int id, bool value) async {
    _profileCalls.add('showAll:$id:$value');
  }

  @override
  Future<void> markSymptomFoldNoteShown(int id) async {
    _profileCalls.add('noteShown:$id');
  }
}

var _id = 1;
final _now = DateTime(2026, 10, 4, 12);

SymptomEntry _e(
  String name, {
  int profileId = 1,
  int minutesAgo = 60,
  List<String> locations = const [],
  int? interference,
  String? impact,
  String? notes,
}) {
  final t = _now.subtract(Duration(minutes: minutesAgo));
  return SymptomEntry(
    id: _id++,
    profileId: profileId,
    name: name,
    severity: 5,
    locations: locations,
    interference: interference,
    impact: impact,
    notes: notes,
    loggedAt: t,
    createdAt: t,
  );
}

List<SymptomEntry> _plain(int n, {int profileId = 1}) => [
  for (var i = 0; i < n; i++)
    _e('Headache', profileId: profileId, minutesAgo: 100 + i),
];

Widget _app({
  List<SymptomEntry> entries = const [],
  Profile? profile,
  SymptomEntry? entry,
  String? prefill,
}) {
  final p = profile ?? Profile(id: 1, name: 'Sarah');
  final router = GoRouter(
    initialLocation: '/form',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Root')),
        routes: [
          GoRoute(
            path: 'form',
            builder: (_, _) =>
                SymptomEntryFormScreen(entry: entry, prefillText: prefill),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settingsSources,
        builder: (_, _) =>
            const Scaffold(body: Text('Where our questions come from')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      symptomEntryListProvider.overrideWith(() => _FakeSymptomList(entries)),
      activeProfileProvider.overrideWith(() => _FakeActiveProfile(p.id)),
      profileListProvider.overrideWith(
        () => _FakeProfileList([p, Profile(id: 2, name: 'Dad')]),
      ),
      activeProfileDataProvider.overrideWith((ref) => p),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(800, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

Finder _card() => find.byKey(const Key('add_if_it_helps'));

Finder _offered(String label) =>
    find.descendant(of: _card(), matching: find.text(label));

Future<void> _add(WidgetTester tester, String label) async {
  await tester.tap(_offered(label));
  await tester.pumpAndSettle();
}

Future<void> _name(WidgetTester tester, String name) async {
  await tester.enterText(find.byKey(const Key('symptom_name_field')), name);
  await tester.pumpAndSettle();
}

Future<void> _intensity(WidgetTester tester, int n) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('severity_selector')),
      matching: find.text('$n'),
    ),
  );
  await tester.pumpAndSettle();
}

const _interferenceQ = 'How much did it get in the way?';
const _impactQ = 'What did it stop you doing, or make harder?';
const _notesQ = "Anything else we didn't ask about?";

void main() {
  setUp(() {
    _saved.clear();
    _profileCalls.clear();
  });

  group('Add if it helps', () {
    testWidgets('offers the four add-ons by name, fields closed', (
      tester,
    ) async {
      await _pump(tester, _app());
      expect(_card(), findsOneWidget);
      expect(
        find.descendant(of: _card(), matching: find.text('Add if it helps')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _card(), matching: find.text(_cardText)),
        findsOneWidget,
      );
      final labels = [
        'Where',
        'How much it got in the way',
        'What it stopped you doing',
        'Anything else',
      ];
      final xs = [
        for (final l in labels)
          tester.getTopLeft(_offered(l)).dy * 10000 +
              tester.getTopLeft(_offered(l)).dx,
      ];
      expect(xs, [...xs]..sort(), reason: 'offered in this order');
      expect(find.text(_interferenceQ), findsNothing);
      expect(find.text(_impactQ), findsNothing);
      expect(find.text(_notesQ), findsNothing);
      expect(find.byKey(const Key('symptom_notes_field')), findsNothing);
    });

    testWidgets('required questions come first', (tester) async {
      await _pump(tester, _app());
      final what = tester.getTopLeft(find.text('What are you feeling?')).dy;
      final how = tester.getTopLeft(find.text('How intense was it?')).dy;
      final when = tester.getTopLeft(find.textContaining('Now,')).dy;
      final card = tester.getTopLeft(_card()).dy;
      expect([what, how, when, card], [what, how, when, card]..sort());
    });

    testWidgets('the time line starts with Now and can be changed', (
      tester,
    ) async {
      await _pump(tester, _app());
      expect(find.textContaining('Now,'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Change'), findsOneWidget);
    });

    testWidgets('saves with only a name and an intensity', (tester) async {
      await _pump(tester, _app());
      await _name(tester, 'Headache');
      await _intensity(tester, 4);
      await tester.tap(find.text('Add to profile'));
      await tester.pumpAndSettle();
      expect(_saved, hasLength(1));
      final s = _saved.single;
      expect(s.severity, 4);
      expect(s.locations, isEmpty);
      expect(s.interference, isNull);
      expect(s.impact, isNull);
      expect(s.notes, isNull);
    });

    testWidgets('tapping an add-on opens its question', (tester) async {
      await _pump(tester, _app());
      await _add(tester, 'How much it got in the way');
      expect(find.text(_interferenceQ), findsOneWidget);
      expect(_offered('How much it got in the way'), findsNothing);
    });

    testWidgets('removing an add-on clears it and offers it again', (
      tester,
    ) async {
      await _pump(tester, _app());
      await _name(tester, 'Fatigue');
      await _intensity(tester, 5);
      await _add(tester, 'What it stopped you doing');
      await tester.enterText(
        find.byKey(const Key('symptom_impact_field')),
        'Skipped my walk',
      );
      await tester.tap(find.byKey(const Key('remove_impact')));
      await tester.pumpAndSettle();
      expect(find.text(_impactQ), findsNothing);
      expect(_offered('What it stopped you doing'), findsOneWidget);

      await tester.tap(find.text('Add to profile'));
      await tester.pumpAndSettle();
      expect(_saved.single.impact, isNull);
    });

    testWidgets('the card goes away when every add-on is open', (tester) async {
      await _pump(tester, _app());
      for (final l in [
        'Where',
        'How much it got in the way',
        'What it stopped you doing',
        'Anything else',
      ]) {
        await _add(tester, l);
      }
      expect(_card(), findsNothing);
      expect(find.text(_notesQ), findsOneWidget);
    });

    testWidgets('"Why we ask" opens the sources screen', (tester) async {
      await _pump(tester, _app());
      await tester.tap(find.text('Why we ask'));
      await tester.pumpAndSettle();
      expect(find.text('Where our questions come from'), findsOneWidget);
    });

    testWidgets('the form never says "Patient-Reported Outcomes"', (
      tester,
    ) async {
      await _pump(tester, _app());
      expect(find.textContaining('Patient-Reported'), findsNothing);
      expect(find.textContaining('PROMIS'), findsNothing);
    });

    testWidgets('editing opens the details the entry already has', (
      tester,
    ) async {
      final e = _e('Fatigue', interference: 3);
      await _pump(tester, _app(entry: e, entries: [e]));
      expect(find.text(_interferenceQ), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Somewhat'))
            .selected,
        isTrue,
      );
      expect(_offered('Where'), findsOneWidget);
      expect(_offered('What it stopped you doing'), findsOneWidget);
      expect(_offered('Anything else'), findsOneWidget);
    });

    testWidgets('a quick log with a body part opens Where with it chosen', (
      tester,
    ) async {
      await _pump(tester, _app(prefill: 'sore knees'));
      expect(_offered('Where'), findsNothing);
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'knees'))
            .selected,
        isTrue,
      );
    });
  });

  group('Last time', () {
    testWidgets('logging a symptom again opens what was added last time', (
      tester,
    ) async {
      await _pump(
        tester,
        _app(
          entries: [_e('Fatigue', interference: 4, impact: 'Skipped my walk')],
        ),
      );
      await _name(tester, 'Fatigue');
      expect(find.text(_interferenceQ), findsOneWidget);
      expect(find.text(_impactQ), findsOneWidget);
      expect(
        find.text('Added because you used it last time for Fatigue.'),
        findsNWidgets(2),
      );
      // Opened, not filled in.
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      expect(chips.where((c) => c.selected), isEmpty);
      expect(find.text('Skipped my walk'), findsNothing);
    });

    testWidgets('only the same symptom counts', (tester) async {
      await _pump(
        tester,
        _app(
          entries: [
            _e('Fatigue', minutesAgo: 10, impact: 'Skipped my walk'),
            _e('Headache', minutesAgo: 20),
          ],
        ),
      );
      await _name(tester, 'Headache');
      expect(find.text(_impactQ), findsNothing);
      expect(find.textContaining('Added because'), findsNothing);
    });

    testWidgets('other profiles do not count', (tester) async {
      await _pump(
        tester,
        _app(entries: [_e('Fatigue', profileId: 2, interference: 5)]),
      );
      await _name(tester, 'Fatigue');
      expect(find.text(_interferenceQ), findsNothing);
    });

    testWidgets('changing the name closes unanswered auto-opened add-ons', (
      tester,
    ) async {
      await _pump(
        tester,
        _app(entries: [_e('Fatigue', interference: 2, impact: 'x')]),
      );
      await _name(tester, 'Fatigue');
      await tester.enterText(
        find.byKey(const Key('symptom_impact_field')),
        'Left work early',
      );
      await _name(tester, 'Nausea');
      expect(find.text(_interferenceQ), findsNothing);
      expect(
        find.text(_impactQ),
        findsOneWidget,
        reason: 'already answered, so it stays',
      );
    });

    testWidgets('last time does not apply when editing', (tester) async {
      final older = _e('Fatigue', minutesAgo: 600, impact: 'x');
      final editing = _e('Fatigue', minutesAgo: 10);
      await _pump(tester, _app(entry: editing, entries: [editing, older]));
      expect(find.text(_impactQ), findsNothing);
    });

    testWidgets('last time wins over folding', (tester) async {
      await _pump(
        tester,
        _app(
          entries: [
            ..._plain(10),
            _e('Joint pain', minutesAgo: 900, locations: ['hands']),
          ],
          profile: Profile(id: 1, name: 'Sarah', symptomFoldNoteShown: true),
        ),
      );
      await _name(tester, 'Joint pain');
      expect(
        find.text('Added because you used it last time for Joint pain.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilterChip, 'hands'), findsOneWidget);
    });
  });

  group('Quieting', () {
    testWidgets('Where and Anything else fold after 10 unused entries', (
      tester,
    ) async {
      await _pump(
        tester,
        _app(
          entries: _plain(10),
          profile: Profile(id: 1, name: 'Sarah', symptomFoldNoteShown: true),
        ),
      );
      expect(_offered('Where'), findsNothing);
      expect(_offered('Anything else'), findsNothing);
      expect(_offered('2 more'), findsOneWidget);
      expect(_offered('How much it got in the way'), findsOneWidget);
      expect(_offered('What it stopped you doing'), findsOneWidget);
    });

    testWidgets('folded options are one tap away', (tester) async {
      await _pump(
        tester,
        _app(
          entries: _plain(10),
          profile: Profile(id: 1, name: 'Sarah', symptomFoldNoteShown: true),
        ),
      );
      await _add(tester, '2 more');
      expect(_offered('Where'), findsOneWidget);
      expect(_offered('Anything else'), findsOneWidget);
      expect(_offered('2 more'), findsNothing);
    });

    testWidgets('nothing folds before 10 entries', (tester) async {
      await _pump(tester, _app(entries: _plain(9)));
      expect(_offered('Where'), findsOneWidget);
      expect(_offered('Anything else'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^\d+ more$')), findsNothing);
    });

    testWidgets('the note shows once, and is recorded as seen', (tester) async {
      await _pump(tester, _app(entries: _plain(10)));
      expect(find.text(_foldNote), findsOneWidget);
      expect(_profileCalls, contains('noteShown:1'));
    });

    testWidgets('no note once it has been seen', (tester) async {
      await _pump(
        tester,
        _app(
          entries: _plain(10),
          profile: Profile(id: 1, name: 'Sarah', symptomFoldNoteShown: true),
        ),
      );
      expect(find.text(_foldNote), findsNothing);
    });

    testWidgets('"Keep showing" brings them back and turns on show-all', (
      tester,
    ) async {
      await _pump(tester, _app(entries: _plain(10)));
      await tester.tap(find.text('Keep showing'));
      await tester.pumpAndSettle();
      expect(_offered('Where'), findsOneWidget);
      expect(_offered('Anything else'), findsOneWidget);
      expect(find.text(_foldNote), findsNothing);
      expect(_profileCalls, contains('showAll:1:true'));
    });

    testWidgets('"Show all symptom options" stops folding', (tester) async {
      await _pump(
        tester,
        _app(
          entries: _plain(10),
          profile: Profile(id: 1, name: 'Sarah', showAllSymptomOptions: true),
        ),
      );
      expect(_offered('Where'), findsOneWidget);
      expect(_offered('Anything else'), findsOneWidget);
      expect(find.text(_foldNote), findsNothing);
    });

    testWidgets('folding never hides saved data when editing', (tester) async {
      final old = _e('Joint pain', minutesAgo: 5000, locations: ['knees']);
      await _pump(
        tester,
        _app(
          entry: old,
          entries: [..._plain(10), old],
          profile: Profile(id: 1, name: 'Sarah', symptomFoldNoteShown: true),
        ),
      );
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'knees'))
            .selected,
        isTrue,
      );
      expect(find.text(_foldNote), findsNothing);
    });
  });
}
