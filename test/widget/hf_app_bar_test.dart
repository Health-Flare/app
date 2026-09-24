import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';
import 'package:health_flare/features/shell/widgets/profile_icon_button.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [
    Profile(id: 1, name: 'Sarah'),
    Profile(id: 2, name: 'Dad'),
  ];
}

final _profileOverrides = [
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  profileListProvider.overrideWith(_FakeProfileList.new),
  activeProfileDataProvider.overrideWith(
    (ref) => Profile(id: 1, name: 'Sarah'),
  ),
];

Widget _buildScaffold({
  List<Widget> actions = const [],
  bool showSettingsButton = true,
}) {
  return ProviderScope(
    overrides: _profileOverrides,
    child: MaterialApp(
      home: Scaffold(
        appBar: HFAppBar(
          title: const Text('Screen title'),
          actions: actions,
          showSettingsButton: showSettingsButton,
        ),
        body: const SizedBox.expand(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests: implement the ui-patterns.feature app-bar scenarios:
// the profile icon is always visible, always rightmost, and never clipped
// by utility actions.
// ---------------------------------------------------------------------------

void main() {
  group('HFAppBar profile icon placement', () {
    testWidgets('profile icon is present with no utility actions', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScaffold());
      await tester.pump();

      expect(find.byType(ProfileIconButton), findsOneWidget);
    });

    testWidgets(
      'profile icon and all utility actions are simultaneously visible',
      (tester) async {
        await tester.pumpWidget(
          _buildScaffold(
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search entries',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter entries',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete entry',
                onPressed: () {},
              ),
            ],
          ),
        );
        await tester.pump();

        // All hit-testable: nothing is clipped or hidden behind another
        // element. An app bar overflow would have thrown during layout.
        expect(find.byIcon(Icons.search).hitTestable(), findsOneWidget);
        expect(find.byIcon(Icons.filter_list).hitTestable(), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline).hitTestable(), findsOneWidget);
        expect(find.byType(ProfileIconButton).hitTestable(), findsOneWidget);
      },
    );

    testWidgets('profile icon is the rightmost element in the app bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildScaffold(
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search entries',
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter entries',
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.pump();

      final profileIconCenter = tester.getCenter(
        find.byType(ProfileIconButton),
      );
      final searchCenter = tester.getCenter(find.byIcon(Icons.search));
      final filterCenter = tester.getCenter(find.byIcon(Icons.filter_list));

      expect(
        profileIconCenter.dx,
        greaterThan(searchCenter.dx),
        reason: 'utility actions must appear to the left of the profile icon',
      );
      expect(profileIconCenter.dx, greaterThan(filterCenter.dx));
    });
  });

  // -------------------------------------------------------------------------
  // ui-patterns.feature: "A Settings button is always available immediately
  // left of the profile icon" / "The Settings screen does not show its own
  // Settings button"
  // -------------------------------------------------------------------------
  group('HFAppBar settings button', () {
    testWidgets('is shown by default, even with no utility actions', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScaffold());
      await tester.pump();

      expect(find.byType(SettingsIconButton).hitTestable(), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('sits directly left of the profile icon, with utility '
        'actions further left', (tester) async {
      await tester.pumpWidget(
        _buildScaffold(
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search entries',
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter entries',
              onPressed: () {},
            ),
          ],
        ),
      );
      await tester.pump();

      final profile = tester.getRect(find.byType(ProfileIconButton));
      final settings = tester.getRect(find.byType(SettingsIconButton));
      final filter = tester.getRect(
        find.widgetWithIcon(IconButton, Icons.filter_list),
      );

      expect(settings.center.dx, lessThan(profile.center.dx));
      expect(filter.center.dx, lessThan(settings.center.dx));
      // Adjacent and not overlapping.
      expect(settings.overlaps(profile), isFalse);
      expect(settings.overlaps(filter), isFalse);
      expect(find.byType(SettingsIconButton).hitTestable(), findsOneWidget);
      expect(find.byType(ProfileIconButton).hitTestable(), findsOneWidget);
    });

    testWidgets('can be hidden (Settings screen); the profile icon stays', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScaffold(showSettingsButton: false));
      await tester.pump();

      expect(find.byType(SettingsIconButton), findsNothing);
      expect(find.byType(ProfileIconButton), findsOneWidget);
    });

    testWidgets('tapping it opens the Settings route', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              appBar: HFAppBar(title: Text('Home')),
              body: SizedBox.expand(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('settings route'))),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _profileOverrides,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(SettingsIconButton));
      await tester.pumpAndSettle();

      expect(find.text('settings route'), findsOneWidget);
    });
  });
}
