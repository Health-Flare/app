// Track and Care sections with tabs (#141), with the trackAndCare flag on.
// Spec: docs/features/navigation.feature. Tab bodies are placeholders here
// (tabContentProvider is faked); the real bodies are covered by
// track_and_care_bodies_test.dart and each screen's own tests.
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

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

Widget _page(String text) => Scaffold(body: Center(child: Text(text)));

/// A long list per tab, so scrolling can be checked.
TabContent _fakeContent(String tabId) => TabContent(
  body: (context) => ListView.builder(
    itemCount: 60,
    itemBuilder: (context, i) =>
        SizedBox(height: 56, child: Text('$tabId item $i')),
  ),
  addTooltip: 'Add to $tabId',
  addTarget: Provider((ref) => AddTarget('/add?tab=$tabId')),
);

GoRouter _router(String initial) {
  final listPaths = {
    for (final s in navSections)
      for (final t in s.tabs) Uri.parse(tabLocation(t.id)).path,
  };
  return GoRouter(
    initialLocation: initial,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, _) => _page('Dashboard screen'),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (_, _) => _page('Reports screen'),
          ),
          GoRoute(
            path: '/add',
            builder: (_, state) =>
                _page('Add form for ${state.uri.queryParameters['tab']}'),
          ),
          for (final path in listPaths)
            GoRoute(path: path, pageBuilder: (_, state) => sectionPage(state)),
        ],
      ),
    ],
  );
}

Widget _app({String initial = AppRoutes.dashboard, double textScale = 1}) =>
    ProviderScope(
      overrides: [
        featureFlagsProvider.overrideWithValue(
          const FeatureFlags(trackAndCare: true),
        ),
        tabContentProvider.overrideWithValue({
          for (final s in navSections)
            for (final t in s.tabs) t.id: _fakeContent(t.id),
        }),
        activeProfileProvider.overrideWith(_FakeActiveProfile.new),
        profileListProvider.overrideWith(_FakeProfileList.new),
        activeProfileDataProvider.overrideWith(
          (ref) => Profile(id: 1, name: 'Sarah'),
        ),
      ],
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp.router(routerConfig: _router(initial)),
      ),
    );

Finder _barItem(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Finder _tab(String label) =>
    find.descendant(of: find.byType(TabBar), matching: find.text(label));

/// The label of the selected tab in the section's tab row.
String? _selectedTab(WidgetTester tester) {
  final bar = tester.widget<TabBar>(find.byType(TabBar));
  final index =
      bar.controller?.index ??
      DefaultTabController.of(tester.element(find.byType(TabBar))).index;
  return (bar.tabs[index] as Tab).text;
}

String _selectedSection(WidgetTester tester) {
  final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
  final d = bar.destinations[bar.selectedIndex] as NavigationDestination;
  return d.label;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('The primary navigation has four sections', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      [for (final d in bar.destinations) (d as NavigationDestination).label],
      ['Dashboard', 'Track', 'Care', 'Journal'],
    );
  });

  group('Each section opens with its first tab selected', () {
    for (final (section, tabs, first) in [
      (
        'Track',
        ['Symptoms', 'Vitals', 'Meals', 'Sleep', 'Activity'],
        'Symptoms',
      ),
      (
        'Care',
        ['Medications', 'Appointments', 'Conditions', 'Flares'],
        'Medications',
      ),
      ('Journal', ['Entries', 'Check-ins'], 'Entries'),
    ]) {
      testWidgets(section, (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _tap(tester, _barItem(section));

        final bar = tester.widget<TabBar>(find.byType(TabBar));
        expect([for (final t in bar.tabs) (t as Tab).text], tabs);
        expect(_selectedTab(tester), first);
        expect(_selectedSection(tester), section);
        expect(find.text(section), findsWidgets);
      });
    }
  });

  testWidgets('The section remembers the last tab used', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _tap(tester, _barItem('Care'));
    await _tap(tester, _tab('Appointments'));
    await _tap(tester, _barItem('Dashboard'));
    await _tap(tester, _barItem('Care'));

    expect(_selectedTab(tester), 'Appointments');
    expect(find.text('care.appointments item 0'), findsOneWidget);
  });

  testWidgets('Remembered tabs reset when the app is closed', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _tap(tester, _barItem('Care'));
    await _tap(tester, _tab('Appointments'));

    // A new ProviderScope is a fresh launch: nothing remembered is stored.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await _tap(tester, _barItem('Care'));

    expect(_selectedTab(tester), 'Medications');
  });

  group('Old links still open the right screen', () {
    for (final (link, section, tab) in [
      ('/medications', 'Care', 'Medications'),
      ('/sleep', 'Track', 'Sleep'),
      ('/checkin', 'Journal', 'Check-ins'),
      ('/tracking?tab=conditions', 'Care', 'Conditions'),
    ]) {
      testWidgets('$link opens $section > $tab', (tester) async {
        await tester.pumpWidget(_app(initial: link));
        await tester.pumpAndSettle();
        expect(_selectedSection(tester), section);
        expect(_selectedTab(tester), tab);
      });
    }
  });

  testWidgets('Every list screen can be reached in two taps or fewer', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    for (final s in navSections.where((s) => s.tabs.isNotEmpty)) {
      for (final t in s.tabs) {
        await _tap(tester, _barItem('Dashboard'));
        var taps = 0;
        await _tap(tester, _barItem(s.label));
        taps++;
        if (_selectedTab(tester) != t.label) {
          await _tap(tester, _tab(t.label));
          taps++;
        }
        expect(find.text('${t.id} item 0'), findsOneWidget, reason: t.id);
        expect(taps, lessThanOrEqualTo(2));
      }
    }
  });

  group('Reports is in every section\'s top bar', () {
    for (final section in ['Track', 'Care', 'Journal']) {
      testWidgets(section, (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _tap(tester, _barItem(section));
        await _tap(tester, find.byTooltip('Reports'));
        expect(find.text('Reports screen'), findsOneWidget);
      });
    }
  });

  testWidgets('Switching tabs does not lose scroll position', (tester) async {
    await tester.pumpWidget(_app(initial: '/tracking'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('track.symptoms item 0'), findsNothing);
    final visible = find.text('track.symptoms item 25');
    expect(visible, findsOneWidget);
    final y = tester.getTopLeft(visible).dy;

    await _tap(tester, _tab('Vitals'));
    expect(find.text('track.vitals item 0'), findsOneWidget);
    await _tap(tester, _tab('Symptoms'));

    expect(find.text('track.symptoms item 0'), findsNothing);
    expect(tester.getTopLeft(find.text('track.symptoms item 25')).dy, y);
  });

  group("A section's add button follows the selected tab", () {
    for (final (section, tab, id) in [
      ('Track', 'Meals', 'track.meals'),
      ('Care', 'Flares', 'care.flares'),
      ('Journal', 'Check-ins', 'journal.checkins'),
    ]) {
      testWidgets('$section > $tab', (tester) async {
        await tester.pumpWidget(_app());
        await tester.pumpAndSettle();
        await _tap(tester, _barItem(section));
        await _tap(tester, _tab(tab));
        await _tap(tester, find.byType(FloatingActionButton));
        expect(find.text('Add form for $id'), findsOneWidget);
      });
    }
  });

  testWidgets('Section tabs stay usable with large text', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(initial: '/tracking', textScale: 2));
    await tester.pumpAndSettle();

    final bar = tester.widget<TabBar>(find.byType(TabBar));
    expect(bar.isScrollable, isTrue, reason: 'scrolls sideways, not cut off');
    for (final label in ['Symptoms', 'Vitals', 'Meals', 'Sleep', 'Activity']) {
      final tab = find.ancestor(of: _tab(label), matching: find.byType(Tab));
      await tester.ensureVisible(tab);
      await tester.pumpAndSettle();
      final size = tester.getSize(tab);
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
      expect(size.width, greaterThanOrEqualTo(48), reason: label);
      final text = tester.widget<Text>(_tab(label));
      expect(text.overflow, isNot(TextOverflow.ellipsis));
      expect(text.maxLines, isNot(1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('with the flag off the bar is unchanged', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: AppRoutes.dashboard,
            routes: [
              ShellRoute(
                builder: (context, state, child) => AppShell(child: child),
                routes: [
                  GoRoute(
                    path: AppRoutes.dashboard,
                    builder: (_, _) => _page('Dashboard screen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      [for (final d in bar.destinations) (d as NavigationDestination).label],
      [for (final i in legacyBar) i.label],
    );
  });
}
