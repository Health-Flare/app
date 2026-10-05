import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/profiles/widgets/add_profile_sheet.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fake notifiers: skip Isar
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
  group('AddProfileSheet: delete button guard', () {
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

  // Show all symptom options (profiles.feature). Credit for the symptom
  // add-ons: Dr Cat Hicks, Informed Patient.
  group('AddProfileSheet: Show all symptom options', () {
    Future<void> pumpTall(WidgetTester tester, Widget w) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(w);
      await tester.pump();
    }

    SwitchListTile tile(WidgetTester tester) => tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Show all symptom options'),
    );

    testWidgets('off by default', (tester) async {
      final sarah = Profile(id: 1, name: 'Sarah');
      await pumpTall(tester, buildEditSheet(sarah, [sarah]));
      expect(tile(tester).value, isFalse);
    });

    testWidgets('shows the saved value', (tester) async {
      final sarah = Profile(id: 1, name: 'Sarah', showAllSymptomOptions: true);
      await pumpTall(tester, buildEditSheet(sarah, [sarah]));
      expect(tile(tester).value, isTrue);
    });
  });
}
