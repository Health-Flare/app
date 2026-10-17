// #173: taking an entry out of its flare on the form, and putting it back,
// is what gets saved. Spec: docs/features/flare.feature, "Taking an entry
// out of its flare".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptom_entry_form_screen.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';

import '../helpers/no_flares.dart';

final _saved = <SymptomEntry>[];

class _Symptoms extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => [];

  @override
  Future<void> update(SymptomEntry updated) async => _saved.add(updated);
}

class _Active extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _Profiles extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

final _t = DateTime(2026, 7, 1, 8);
final _flare = Flare(
  id: 3,
  profileId: 1,
  startedAt: _t.subtract(const Duration(days: 1)),
  createdAt: _t,
);

Widget _app(SymptomEntry entry) {
  final router = GoRouter(
    initialLocation: '/edit',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Root')),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, _) => SymptomEntryFormScreen(entry: entry),
          ),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      ...withFlares([_flare]),
      symptomEntryListProvider.overrideWith(_Symptoms.new),
      activeProfileProvider.overrideWith(_Active.new),
      profileListProvider.overrideWith(_Profiles.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

SymptomEntry _entry({bool detached = false, int? pinned}) => SymptomEntry(
  id: 1,
  profileId: 1,
  name: 'Joint pain',
  severity: 5,
  loggedAt: _t,
  createdAt: _t,
  flareDetached: detached,
  flareIsarId: pinned,
);

Future<void> _tapAndSave(WidgetTester tester, String button) async {
  await tester.scrollUntilVisible(
    find.text(button),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text(button));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Save changes'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Save changes'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(_saved.clear);

  testWidgets('Remove, then save: taken out of the flare', (tester) async {
    await tester.pumpWidget(_app(_entry()));
    await tester.pumpAndSettle();
    expect(find.text('Part of the flare that started 30 Jun'), findsOneWidget);

    await _tapAndSave(tester, 'Remove');

    expect(_saved.single.flareDetached, isTrue);
  });

  testWidgets('Remove also drops a pin from an older version', (tester) async {
    await tester.pumpWidget(_app(_entry(pinned: 3)));
    await tester.pumpAndSettle();

    await _tapAndSave(tester, 'Remove');

    expect(_saved.single.flareDetached, isTrue);
    expect(_saved.single.flareIsarId, isNull);
  });

  testWidgets('Add back, then save: part of the flare again', (tester) async {
    await tester.pumpWidget(_app(_entry(detached: true)));
    await tester.pumpAndSettle();
    expect(
      find.text('Not part of the flare that started 30 Jun'),
      findsOneWidget,
    );

    await _tapAndSave(tester, 'Add back');

    expect(_saved.single.flareDetached, isFalse);
  });

  testWidgets('saving without touching it keeps a pin', (tester) async {
    await tester.pumpWidget(_app(_entry(pinned: 3)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save changes'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(_saved.single.flareIsarId, 3);
    expect(_saved.single.flareDetached, isFalse);
  });
}
