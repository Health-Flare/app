// The live bottom bar with a stored choice (#143): pins, More, per profile,
// large text. Tab bodies are placeholders.
// Spec: docs/features/navigation-customization.feature.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/sections/more_screen.dart';
import 'package:health_flare/features/sections/section_screen.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/features/shell/app_shell.dart';
import 'package:health_flare/models/profile.dart';

class _Active extends ActiveProfileNotifier {
  _Active(this._id);
  final int _id;

  @override
  int? build() => _id;

  void switchTo(int id) => state = id;
}

class _Profiles extends ProfileListNotifier {
  _Profiles(this._ps);
  final List<Profile> _ps;

  @override
  List<Profile> build() => _ps;
}

TabContent _fake(String id) => TabContent(
  body: (_) => Center(child: Text('$id list')),
  addTooltip: 'Add',
  addTarget: Provider((ref) => const AddTarget('/')),
);

final _stores = <BarRecord>[];

Widget _app(
  List<String> stored, {
  List<Profile>? profiles,
  String initial = AppRoutes.dashboard,
  double textScale = 1,
}) {
  final listPaths = {
    for (final s in navSections)
      for (final t in s.tabs) Uri.parse(tabLocation(t.id)).path,
  };
  final ps = profiles ?? [Profile(id: 1, name: 'Sarah')];
  return ProviderScope(
    overrides: [
      featureFlagsProvider.overrideWithValue(
        const FeatureFlags(trackAndCare: true),
      ),
      tabContentProvider.overrideWithValue({
        for (final s in navSections)
          for (final t in s.tabs) t.id: _fake(t.id),
      }),
      activeProfileProvider.overrideWith(() => _Active(1)),
      profileListProvider.overrideWith(() => _Profiles(ps)),
      activeProfileDataProvider.overrideWith((ref) {
        final id = ref.watch(activeProfileProvider);
        return ref
            .watch(profileListProvider)
            .where((p) => p.id == id)
            .firstOrNull;
      }),
      barChoiceProvider.overrideWith(
        () =>
            BarChoiceNotifier()
              ..preload(BarRecord(storedBar: stored, seenVersion: 2)),
      ),
      barStoreProvider.overrideWithValue((r) async => _stores.add(r)),
    ],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
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
                GoRoute(
                  path: moreLocation,
                  pageBuilder: (_, s) => NoTransitionPage(
                    key: s.pageKey,
                    child: const MoreScreen(),
                  ),
                ),
                for (final path in listPaths)
                  GoRoute(path: path, pageBuilder: (_, s) => sectionPage(s)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

List<String> _barLabels(WidgetTester tester) => [
  for (final d
      in tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations)
    (d as NavigationDestination).label,
];

String _selected(WidgetTester tester) {
  final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
  return (bar.destinations[bar.selectedIndex] as NavigationDestination).label;
}

Finder _bar(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

const _default = ['dashboard', 'track', 'care', 'journal'];

void main() {
  setUp(_stores.clear);

  testWidgets('Pin a screen to the bar: it opens the Medications tab in '
      'Care, and Care is not highlighted', (tester) async {
    await tester.pumpWidget(_app([..._default, 'care.medications']));
    await tester.pumpAndSettle();
    expect(_barLabels(tester), [
      'Dashboard',
      'Track',
      'Care',
      'Journal',
      'Medications',
    ]);
    await tester.tap(_bar('Medications'));
    await tester.pumpAndSettle();
    expect(find.text('care.medications list'), findsOneWidget);
    expect(_selected(tester), 'Medications');
  });

  testWidgets('A section left out of the bar goes into More, a real screen '
      'listing Journal with its tabs', (tester) async {
    await tester.pumpWidget(_app(['dashboard', 'track', 'care']));
    await tester.pumpAndSettle();
    expect(_barLabels(tester), ['Dashboard', 'Track', 'Care', 'More']);
    await tester.tap(_bar('More'));
    await tester.pumpAndSettle();
    expect(find.text('Journal'), findsOneWidget);
    expect(find.text('Entries'), findsOneWidget);
    expect(find.text('Check-ins'), findsOneWidget);

    await tester.tap(find.text('Check-ins'));
    await tester.pumpAndSettle();
    expect(find.text('journal.checkins list'), findsOneWidget);
    expect(_selected(tester), 'More');
  });

  testWidgets('More only appears when it has something in it', (tester) async {
    await tester.pumpWidget(_app(_default));
    await tester.pumpAndSettle();
    expect(_barLabels(tester), isNot(contains('More')));
  });

  testWidgets('Pinned screens for a turned-off feature drop out quietly, '
      'and come back', (tester) async {
    await tester.pumpWidget(
      _app(
        [..._default, 'track.meals'],
        profiles: [
          Profile(id: 1, name: 'Sarah'),
          Profile(id: 2, name: 'Dad', disabledFeatureIds: ['track.meals']),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(_barLabels(tester), contains('Meals'));

    final c = ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
    );
    (c.read(activeProfileProvider.notifier) as _Active).switchTo(2);
    await tester.pumpAndSettle();
    expect(_barLabels(tester), isNot(contains('Meals')));

    (c.read(activeProfileProvider.notifier) as _Active).switchTo(1);
    await tester.pumpAndSettle();
    expect(_barLabels(tester), contains('Meals'));
    expect(_stores, isEmpty, reason: 'the stored bar is not changed');
  });

  testWidgets("An id the app doesn't recognise is skipped safely, and not "
      'rewritten', (tester) async {
    await tester.pumpWidget(
      _app(['dashboard', 'track.water', 'track', 'care']),
    );
    await tester.pumpAndSettle();
    expect(_barLabels(tester), ['Dashboard', 'Track', 'Care', 'More']);
    expect(_stores, isEmpty);
  });

  group('Bar labels stay readable with large text', () {
    testWidgets('icons only at 200%, labels read and shown on long press', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app([..._default, 'care.medications'], textScale: 2),
      );
      await tester.pumpAndSettle();
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysHide);
      expect(find.bySemanticsLabel(RegExp('Medications')), findsWidgets);

      for (final d in bar.destinations) {
        final size = tester.getSize(find.byWidget(d));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }

      await tester.longPress(find.byIcon(Icons.medication_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(Tooltip), findsWidgets);
      expect(find.text('Medications'), findsWidgets);
      handle.dispose();
    });

    testWidgets('icons only from 150%, labels at 130%', (tester) async {
      await tester.pumpWidget(_app(_default, textScale: 1.5));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior,
        NavigationDestinationLabelBehavior.alwaysHide,
      );
      await tester.pumpWidget(_app(_default, textScale: 1.3));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior,
        isNot(NavigationDestinationLabelBehavior.alwaysHide),
      );
    });

    testWidgets('labels shown at normal size', (tester) async {
      await tester.pumpWidget(_app(_default));
      await tester.pumpAndSettle();
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(
        bar.labelBehavior,
        isNot(NavigationDestinationLabelBehavior.alwaysHide),
      );
    });
  });
}
