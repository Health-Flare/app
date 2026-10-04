import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/profiles/widgets/add_profile_sheet.dart';
import 'package:health_flare/models/profile.dart';

final _navKey = GlobalKey<NavigatorState>();

/// Simulates the real add(): while the save is in flight, the new profile
/// becomes active and the dashboard pushes the post-setup flow on top.
class _RacingProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [
    Profile(id: 1, name: 'A'),
    Profile(id: 2, name: 'B'),
    Profile(id: 3, name: 'C'),
  ];

  @override
  Future<void> add({
    required String name,
    DateTime? dateOfBirth,
    String? avatarPath,
  }) async {
    _navKey.currentState!.push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const Scaffold(body: Text('Post-setup flow')),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('sheet closes itself even if a route is pushed over it '
      'during save', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileListProvider.overrideWith(_RacingProfileList.new)],
        child: MaterialApp(
          navigatorKey: _navKey,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showAddOrEditProfileSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'D');
    await tester.tap(find.text('Add profile').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // Not pumpAndSettle: a stuck save spinner never settles.
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Post-setup flow'),
      findsOneWidget,
      reason: 'the prompt pushed during save must stay on screen',
    );
    expect(
      find.byType(AddProfileSheet),
      findsNothing,
      reason: 'the sheet must close after a successful add',
    );
  });
}
