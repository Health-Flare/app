// Track and Care with features turned off (#142). Tab bodies are
// placeholders, as in track_and_care_test.dart.
// Spec: docs/features/navigation-customization.feature.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/sections/section_screen.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/features/shell/app_shell.dart';
import 'package:health_flare/models/profile.dart';

final _saved = <Profile>[];

class _Active extends ActiveProfileNotifier {
  _Active(this._id);
  final int _id;

  @override
  int? build() => _id;

  void switchTo(int id) => state = id;
}

class _Profiles extends ProfileListNotifier {
  _Profiles(this._start);
  final List<Profile> _start;

  @override
  List<Profile> build() => _start;

  @override
  Future<void> update(Profile updated) async {
    _saved.add(updated);
    state = [for (final p in state) p.id == updated.id ? updated : p];
  }
}

TabContent _fake(String id) => TabContent(
  body: (_) => Center(child: Text('$id list')),
  addTooltip: 'Add',
  addTarget: Provider((ref) => const AddTarget('/')),
);

Widget _app({
  required List<Profile> profiles,
  int active = 1,
  String initial = AppRoutes.dashboard,
}) {
  final listPaths = {
    for (final s in navSections)
      for (final t in s.tabs) Uri.parse(tabLocation(t.id)).path,
  };
  return ProviderScope(
    overrides: [
      featureFlagsProvider.overrideWithValue(
        const FeatureFlags(trackAndCare: true),
      ),
      tabContentProvider.overrideWithValue({
        for (final s in navSections)
          for (final t in s.tabs) t.id: _fake(t.id),
      }),
      activeProfileProvider.overrideWith(() => _Active(active)),
      profileListProvider.overrideWith(() => _Profiles(profiles)),
      activeProfileDataProvider.overrideWith((ref) {
        final id = ref.watch(activeProfileProvider);
        return ref
            .watch(profileListProvider)
            .where((p) => p.id == id)
            .firstOrNull;
      }),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: initial,
        routes: [
          ShellRoute(
            builder: (context, state, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (_, _) =>
                    const Scaffold(body: Center(child: Text('Dashboard'))),
              ),
              for (final path in listPaths)
                GoRoute(path: path, pageBuilder: (_, s) => sectionPage(s)),
            ],
          ),
        ],
      ),
    ),
  );
}

Finder _bar(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

List<String> _tabLabels(WidgetTester tester) => [
  for (final t in tester.widget<TabBar>(find.byType(TabBar)).tabs)
    (t as Tab).text!,
];

Profile _sarah({List<String> off = const []}) =>
    Profile(id: 1, name: 'Sarah', disabledFeatureIds: off);

void main() {
  setUp(_saved.clear);

  testWidgets('Turning a feature off removes it from everyday use: the '
      'Meals tab is not shown in Track', (tester) async {
    await tester.pumpWidget(
      _app(
        profiles: [
          _sarah(off: ['track.meals']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_bar('Track'));
    await tester.pumpAndSettle();
    expect(_tabLabels(tester), ['Symptoms', 'Vitals', 'Sleep', 'Activity']);
  });

  testWidgets('Features in use is per profile', (tester) async {
    await tester.pumpWidget(
      _app(
        profiles: [
          _sarah(),
          Profile(id: 2, name: 'Dad', disabledFeatureIds: ['track.meals']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_bar('Track'));
    await tester.pumpAndSettle();
    expect(_tabLabels(tester), contains('Meals'));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TabBar)),
    );
    (container.read(activeProfileProvider.notifier) as _Active).switchTo(2);
    await tester.pumpAndSettle();
    expect(_tabLabels(tester), isNot(contains('Meals')));
  });

  testWidgets('A section with every tab turned off leaves the bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        profiles: [
          _sarah(off: ['journal.entries', 'journal.checkins']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      [for (final d in bar.destinations) (d as NavigationDestination).label],
      ['Dashboard', 'Track', 'Care'],
    );
  });

  testWidgets('A section with one tab left shows no tab row', (tester) async {
    await tester.pumpWidget(
      _app(
        profiles: [
          _sarah(off: ['journal.checkins']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_bar('Journal'));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('journal.entries list'), findsOneWidget);
  });

  testWidgets('Care with only Conditions left shows no tab row', (
    tester,
  ) async {
    // Conditions can't be turned off, so it is the one left in Care. (The
    // scenario's "only Medications" can't happen: Conditions is always on.)
    await tester.pumpWidget(
      _app(
        profiles: [
          _sarah(off: ['care.medications', 'care.appointments', 'care.flares']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_bar('Care'));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('care.conditions list'), findsOneWidget);
  });

  testWidgets('a section opens on its first tab that is on', (tester) async {
    await tester.pumpWidget(
      _app(
        profiles: [
          _sarah(off: ['care.medications']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(_bar('Care'));
    await tester.pumpAndSettle();
    expect(find.text('care.appointments list'), findsOneWidget);
  });

  group("A turned-off feature's list opened directly still shows", () {
    testWidgets('with a line at the top and a Turn on button', (tester) async {
      await tester.pumpWidget(
        _app(
          profiles: [
            _sarah(off: ['track.meals']),
          ],
          initial: '/meals',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('track.meals list'), findsOneWidget);
      expect(find.text('Meals is turned off for Sarah'), findsOneWidget);

      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();
      expect(_saved.single.disabledFeatureIds, isEmpty);
      expect(find.text('Meals is turned off for Sarah'), findsNothing);
      expect(_tabLabels(tester), contains('Meals'));
    });

    testWidgets('Meals is in the tab row only while it is open', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          profiles: [
            _sarah(off: ['track.meals']),
          ],
          initial: '/meals',
        ),
      );
      await tester.pumpAndSettle();
      expect(_tabLabels(tester), contains('Meals'));
      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text('Sleep')),
      );
      await tester.pumpAndSettle();
      expect(_tabLabels(tester), isNot(contains('Meals')));
    });
  });
}
