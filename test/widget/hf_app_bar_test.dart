import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
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

Widget _buildScaffold({List<Widget> actions = const []}) {
  return ProviderScope(
    overrides: [
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: HFAppBar(title: const Text('Screen title'), actions: actions),
        body: const SizedBox.expand(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests — implement the ui-patterns.feature app-bar scenarios:
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

        // All hit-testable — nothing is clipped or hidden behind another
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
}
