// Settings > Your layout > Bottom bar (#143). The store is faked; real
// saving is covered by bar_choice_test.dart.
// Spec: docs/features/navigation-customization.feature.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/settings/screens/bottom_bar_screen.dart';
import 'package:health_flare/features/settings/widgets/your_layout_tiles.dart';
import 'package:health_flare/models/profile.dart';

final _announced = <String>[];

class _Active extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _Profiles extends ProfileListNotifier {
  _Profiles(this._p);
  final Profile _p;

  @override
  List<Profile> build() => [_p];
}

List<Override> _overrides(BarRecord start, {List<String> off = const []}) {
  final sarah = Profile(id: 1, name: 'Sarah', disabledFeatureIds: off);
  return [
    featureFlagsProvider.overrideWithValue(
      const FeatureFlags(trackAndCare: true),
    ),
    activeProfileProvider.overrideWith(_Active.new),
    profileListProvider.overrideWith(() => _Profiles(sarah)),
    activeProfileDataProvider.overrideWith((ref) => sarah),
    barChoiceProvider.overrideWith(() => BarChoiceNotifier()..preload(start)),
    barStoreProvider.overrideWithValue((record) async {}),
    announcerProvider.overrideWithValue(
      (context, message) => _announced.add(message),
    ),
  ];
}

Widget _editor({
  BarRecord start = const BarRecord(seenVersion: 2),
  List<String> off = const [],
}) => ProviderScope(
  overrides: _overrides(start, off: off),
  child: const MaterialApp(home: BottomBarScreen()),
);

List<String> _stored(WidgetTester tester) {
  final c = ProviderScope.containerOf(
    tester.element(find.byType(BottomBarScreen)),
  );
  return c.read(barChoiceProvider.notifier).shownIds;
}

/// The "In the bar" row for [label].
Finder _row(String label) => find.byKey(ValueKey('bar-row-$label'));

Future<void> _tapIn(WidgetTester tester, String row, String tooltip) async {
  await tester.tap(
    find.descendant(of: _row(row), matching: find.byTooltip(tooltip)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(_announced.clear);

  // A phone-sized screen, so the whole editor is laid out.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1179, 4200);
    view.devicePixelRatio = 3;
  });
  tearDown(
    () => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
        .reset(),
  );

  testWidgets('The bottom bar screen shows the current bar', (tester) async {
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bar-preview')), findsOneWidget);
    for (final label in ['Dashboard', 'Track', 'Care', 'Journal']) {
      expect(_row(label), findsOneWidget, reason: label);
    }
    expect(find.text('Can be added'), findsOneWidget);
    expect(find.byKey(const ValueKey('add-Medications')), findsOneWidget);
  });

  testWidgets('Dashboard is always first, with no remove or move control', (
    tester,
  ) async {
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: _row('Dashboard'), matching: find.byType(IconButton)),
      findsNothing,
    );
  });

  testWidgets('Pin a screen to the bar', (tester) async {
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-Medications')));
    await tester.pumpAndSettle();
    expect(_stored(tester), [
      'dashboard',
      'track',
      'care',
      'journal',
      'care.medications',
    ]);
    expect(_row('Medications'), findsOneWidget);
  });

  testWidgets('A section left out of the bar goes into More', (tester) async {
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    await _tapIn(tester, 'Journal', 'Remove Journal');
    expect(_stored(tester), ['dashboard', 'track', 'care']);
    expect(find.text('More: Journal'), findsOneWidget);
  });

  group('The bar holds three to five items', () {
    testWidgets("can't remove an item when three are left, and says why", (
      tester,
    ) async {
      await tester.pumpWidget(
        _editor(
          start: const BarRecord(
            storedBar: ['dashboard', 'track', 'care'],
            seenVersion: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final remove = tester.widget<IconButton>(
        find.descendant(
          of: _row('Care'),
          matching: find.widgetWithIcon(
            IconButton,
            Icons.remove_circle_outline,
          ),
        ),
      );
      expect(remove.onPressed, isNull);
      expect(find.textContaining('at least three'), findsOneWidget);
    });

    testWidgets("can't add an item when five are in the bar, and says why", (
      tester,
    ) async {
      await tester.pumpWidget(
        _editor(
          start: const BarRecord(
            storedBar: [
              'dashboard',
              'track',
              'care',
              'journal',
              'care.medications',
            ],
            seenVersion: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final add = tester.widget<IconButton>(
        find.byKey(const ValueKey('add-Meals')),
      );
      expect(add.onPressed, isNull);
      expect(find.textContaining('holds five'), findsOneWidget);
    });
  });

  testWidgets('Reorder without dragging, announced', (tester) async {
    await tester.pumpWidget(
      _editor(
        start: const BarRecord(
          storedBar: [
            'dashboard',
            'track',
            'care',
            'journal',
            'care.medications',
          ],
          seenVersion: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapIn(tester, 'Medications', 'Move Medications up');
    await _tapIn(tester, 'Medications', 'Move Medications up');
    expect(_stored(tester), [
      'dashboard',
      'track',
      'care.medications',
      'care',
      'journal',
    ]);
    expect(_announced.last, 'Medications, position 3 of 5');
    // Track can't move above Dashboard.
    final up = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Move Track up'),
        matching: find.byType(IconButton),
      ),
    );
    expect(up.onPressed, isNull);
    // Dragging also works.
    expect(find.byType(ReorderableListView), findsOneWidget);
  });

  testWidgets('Changes apply straight away and can be undone', (tester) async {
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    await _tapIn(tester, 'Journal', 'Remove Journal');
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_stored(tester), ['dashboard', 'track', 'care', 'journal']);
  });

  testWidgets('Reset to the default, after asking', (tester) async {
    await tester.pumpWidget(
      _editor(
        start: const BarRecord(
          storedBar: ['dashboard', 'track', 'care'],
          seenVersion: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use default'));
    await tester.pumpAndSettle();
    expect(find.text('Go back to the default bar?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(_stored(tester), ['dashboard', 'track', 'care']);

    await tester.tap(find.text('Use default'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Use default'));
    await tester.pumpAndSettle();
    expect(_stored(tester), ['dashboard', 'track', 'care', 'journal']);
  });

  testWidgets('The bar can be set up close to the old one', (tester) async {
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Like before'));
    await tester.pumpAndSettle();
    expect(_stored(tester), likeBeforePreset);
    expect(find.text(likeBeforeNote), findsOneWidget);
    expect(find.text('Change it'), findsOneWidget);
    expect(find.text('More: Care, Journal'), findsOneWidget);
  });

  testWidgets('a turned-off feature is not listed to add', (tester) async {
    await tester.pumpWidget(_editor(off: ['track.meals']));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('add-Meals')), findsNothing);
    expect(find.byKey(const ValueKey('add-Sleep')), findsOneWidget);
  });

  testWidgets('The settings screens work with a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_editor());
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel('Bottom bar: Dashboard, Track, Care, Journal'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Track, position 2 of 4')),
      findsOneWidget,
    );
    handle.dispose();
  });

  group('Layout settings are in Settings', () {
    Widget tiles(BarRecord start) => ProviderScope(
      overrides: _overrides(start),
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  Scaffold(body: ListView(children: const [YourLayoutTiles()])),
            ),
            GoRoute(
              path: AppRoutes.bottomBar,
              builder: (_, _) => const Text('Bottom bar screen'),
            ),
          ],
        ),
      ),
    );

    testWidgets('"Bottom bar" reads "Default" until the bar is changed', (
      tester,
    ) async {
      await tester.pumpWidget(tiles(const BarRecord(seenVersion: 2)));
      await tester.pumpAndSettle();
      expect(find.text('Features in use'), findsOneWidget);
      expect(find.text('Bottom bar'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      await tester.tap(find.text('Bottom bar'));
      await tester.pumpAndSettle();
      expect(find.text('Bottom bar screen'), findsOneWidget);
    });

    testWidgets('then "Customized"', (tester) async {
      await tester.pumpWidget(
        tiles(
          const BarRecord(
            storedBar: ['dashboard', 'track', 'care'],
            seenVersion: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Customized'), findsOneWidget);
    });
  });
}
