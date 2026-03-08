import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/profiles/widgets/add_profile_sheet.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fake notifiers — skip Isar
// ---------------------------------------------------------------------------

class _FakeProfileList extends ProfileListNotifier {
  _FakeProfileList(this.profiles);
  final List<Profile> profiles;

  @override
  List<Profile> build() => profiles;
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  _FakeActiveProfile(this.id);
  final int? id;

  @override
  int? build() => id;
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget buildEditSheet(Profile editing, List<Profile> allProfiles) {
  return ProviderScope(
    overrides: [
      profileListProvider.overrideWith(() => _FakeProfileList(allProfiles)),
      activeProfileProvider.overrideWith(() => _FakeActiveProfile(editing.id)),
    ],
    child: MaterialApp(
      home: Scaffold(body: AddProfileSheet(existing: editing)),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AddProfileSheet — delete button guard', () {
    testWidgets('delete button is hidden when only one profile exists', (
      tester,
    ) async {
      final sarah = Profile(id: 1, name: 'Sarah');
      await tester.pumpWidget(buildEditSheet(sarah, [sarah]));
      await tester.pump();

      expect(
        find.byIcon(Icons.delete_outline_rounded),
        findsNothing,
        reason:
            'Delete button must not be shown when Sarah is the only profile',
      );
    });

    testWidgets('delete button is visible when multiple profiles exist', (
      tester,
    ) async {
      final sarah = Profile(id: 1, name: 'Sarah');
      final dad = Profile(id: 2, name: 'Dad');
      await tester.pumpWidget(buildEditSheet(dad, [sarah, dad]));
      await tester.pump();

      expect(
        find.byIcon(Icons.delete_outline_rounded),
        findsOneWidget,
        reason:
            'Delete button must be visible when editing one of many profiles',
      );
    });
  });
}
