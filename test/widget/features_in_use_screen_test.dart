// Settings > Your layout > Features in use (#142).
// Spec: docs/features/navigation-customization.feature.
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/settings/screens/features_in_use_screen.dart';
import 'package:health_flare/features/settings/widgets/your_layout_tiles.dart';
import 'package:health_flare/models/profile.dart';

final _saved = <Profile>[];

class _ActiveProfile extends ActiveProfileNotifier {
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
    _saved.add(updated);
    state = [updated];
  }
}

Widget _screen({List<String> off = const [], int meals = 40}) {
  final sarah = Profile(id: 1, name: 'Sarah', disabledFeatureIds: off);
  return ProviderScope(
    overrides: [
      featureFlagsProvider.overrideWithValue(
        const FeatureFlags(trackAndCare: true),
      ),
      activeProfileProvider.overrideWith(_ActiveProfile.new),
      profileListProvider.overrideWith(() => _Profiles(sarah)),
      activeProfileDataProvider.overrideWith(
        (ref) => ref.watch(profileListProvider).first,
      ),
      featureEntryCountProvider.overrideWith(
        (ref, id) => id == 'track.meals' ? meals : 0,
      ),
    ],
    child: const MaterialApp(home: FeaturesInUseScreen()),
  );
}

Finder _switchFor(String label) => find.widgetWithText(SwitchListTile, label);

bool _isOn(WidgetTester tester, String label) =>
    tester.widget<SwitchListTile>(_switchFor(label)).value;

void main() {
  setUp(_saved.clear);

  group('Features in use lists what can be turned off', () {
    testWidgets('a switch for each, in order, all on by default', (
      tester,
    ) async {
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();

      final labels = [
        for (final t in tester.widgetList<SwitchListTile>(
          find.byType(SwitchListTile),
        ))
          ((t.title! as Text).data!),
      ];
      expect(labels, [
        'Vitals',
        'Meals',
        'Sleep',
        'Activity',
        'Medications',
        'Appointments',
        'Flares',
        'Journal',
        'Check-ins',
      ]);
      for (final l in labels) {
        expect(_isOn(tester, l), isTrue, reason: l);
      }
    });

    testWidgets('each switch names its section', (tester) async {
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();
      final meals = tester.widget<SwitchListTile>(_switchFor('Meals'));
      expect((meals.subtitle! as Text).data, 'Track');
      final flares = tester.widget<SwitchListTile>(_switchFor('Flares'));
      expect((flares.subtitle! as Text).data, 'Care');
    });

    testWidgets('Symptoms and Conditions are listed as always on', (
      tester,
    ) async {
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();
      expect(find.text('Symptoms'), findsOneWidget);
      expect(find.text('Conditions'), findsOneWidget);
      expect(find.text('Always on'), findsNWidgets(2));
      expect(_switchFor('Symptoms'), findsNothing);
    });

    testWidgets('the screen says these switches apply to Sarah', (
      tester,
    ) async {
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();
      expect(find.textContaining('These switches apply to Sarah'), findsOne);
    });
  });

  group('Turning a feature off keeps its data', () {
    testWidgets('I am told the meals are kept', (tester) async {
      await tester.pumpWidget(_screen());
      await tester.pumpAndSettle();
      await tester.tap(_switchFor('Meals'));
      await tester.pumpAndSettle();

      expect(_saved.single.disabledFeatureIds, ['track.meals']);
      expect(
        find.text(
          "Sarah's 40 meals are kept. Turn Meals back on any time to see them.",
        ),
        findsOneWidget,
      );
      expect(_isOn(tester, 'Meals'), isFalse);
    });

    testWidgets('Turning off a feature with nothing logged', (tester) async {
      await tester.pumpWidget(_screen(meals: 0));
      await tester.pumpAndSettle();
      await tester.tap(_switchFor('Meals'));
      await tester.pumpAndSettle();
      expect(
        find.text('Meals is off for Sarah. Turn it back on any time.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('Turning a feature back on clears it', (tester) async {
    await tester.pumpWidget(_screen(off: ['track.meals', 'care.flares']));
    await tester.pumpAndSettle();
    expect(_isOn(tester, 'Meals'), isFalse);
    await tester.tap(_switchFor('Meals'));
    await tester.pumpAndSettle();
    expect(_saved.single.disabledFeatureIds, ['care.flares']);
    expect(_isOn(tester, 'Meals'), isTrue);
  });

  testWidgets('The settings screens work with a screen reader: each switch '
      'is read with its state and the profile name', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_screen(off: ['track.meals']));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(_switchFor('Meals'));
    expect(node.label, contains('Meals for Sarah'));
    expect(node.flagsCollection.isToggled, Tristate.isFalse);
    handle.dispose();
  });

  group('Layout settings are in Settings', () {
    Widget settings({required bool flag}) => ProviderScope(
      overrides: [
        featureFlagsProvider.overrideWithValue(
          FeatureFlags(trackAndCare: flag),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  Scaffold(body: ListView(children: const [YourLayoutTiles()])),
            ),
            GoRoute(
              path: AppRoutes.featuresInUse,
              builder: (_, _) => const Text('Features in use screen'),
            ),
          ],
        ),
      ),
    );

    testWidgets('a "Your layout" section with Features in use', (tester) async {
      await tester.pumpWidget(settings(flag: true));
      await tester.pumpAndSettle();
      expect(find.text('Your layout'), findsOneWidget);
      await tester.tap(find.text('Features in use'));
      await tester.pumpAndSettle();
      expect(find.text('Features in use screen'), findsOneWidget);
    });

    testWidgets('not there with Track and Care off', (tester) async {
      await tester.pumpWidget(settings(flag: false));
      await tester.pumpAndSettle();
      expect(find.text('Your layout'), findsNothing);
      expect(find.text('Features in use'), findsNothing);
    });
  });
}
