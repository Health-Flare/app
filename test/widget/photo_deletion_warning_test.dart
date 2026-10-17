// #105: deleting a photo is said before it happens. Photos are kept in
// the app's own folder and deleted with their entry, so one that isn't
// saved anywhere else is lost (meals.feature, profiles.feature).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/files/photo_store.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/meals/screens/meal_entry_form_screen.dart';
import 'package:health_flare/features/profiles/widgets/add_profile_sheet.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/profile.dart';

import '../helpers/no_flares.dart';

class _FakeMealList extends MealEntryListNotifier {
  @override
  List<MealEntry> build() => const [];
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  _FakeActiveProfile(this.id);
  final int? id;
  @override
  int? build() => id;
}

class _FakeProfileList extends ProfileListNotifier {
  _FakeProfileList(this.profiles);
  final List<Profile> profiles;
  @override
  List<Profile> build() => profiles;
}

// A 1x1 PNG.
const _png = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

const _stored = '0123456789abcdef0123456789abcdef.png';

MealEntry _meal({String? photoPath}) => MealEntry(
  id: 1,
  profileId: 1,
  description: 'Avocado toast',
  photoPath: photoPath,
  hasReaction: false,
  loggedAt: DateTime(2026, 2, 16, 8),
  createdAt: DateTime(2026, 2, 16, 8),
);

Widget _form(MealEntry entry) => ProviderScope(
  overrides: [
    noFlares,
    mealEntryListProvider.overrideWith(_FakeMealList.new),
    activeProfileProvider.overrideWith(() => _FakeActiveProfile(1)),
    profileListProvider.overrideWith(
      () => _FakeProfileList([Profile(id: 1, name: 'Sarah')]),
    ),
    activeProfileDataProvider.overrideWith(
      (ref) => Profile(id: 1, name: 'Sarah'),
    ),
  ],
  child: MaterialApp(home: MealEntryFormScreen(entry: entry)),
);

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('hf_photo_warn_');
    PhotoStore.init(root.path);
    Directory(PhotoStore.dirPath).createSync(recursive: true);
    File('${PhotoStore.dirPath}/$_stored').writeAsBytesSync(_png);
  });

  tearDown(() {
    PhotoStore.reset();
    root.deleteSync(recursive: true);
  });

  group('deleting a meal', () {
    testWidgets('with a photo, says the photo goes too', (tester) async {
      await tester.pumpWidget(_form(_meal(photoPath: _stored)));
      await tester.pump();
      await tester.tap(find.byTooltip('Delete entry'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'This will permanently remove this meal entry and its photo. '
          "If the photo isn't saved anywhere else, it will be lost.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('without a photo, says nothing about photos', (tester) async {
      await tester.pumpWidget(_form(_meal()));
      await tester.pump();
      await tester.tap(find.byTooltip('Delete entry'));
      await tester.pumpAndSettle();

      expect(
        find.text('This will permanently remove this meal entry.'),
        findsOneWidget,
      );
    });
  });

  group('removing a saved photo', () {
    Future<void> tapRemove(WidgetTester tester) async {
      await tester.pumpWidget(_form(_meal(photoPath: _stored)));
      await tester.pump();
      final remove = find.widgetWithText(TextButton, 'Remove');
      await tester.ensureVisible(remove);
      await tester.tap(remove);
      await tester.pumpAndSettle();
    }

    testWidgets('asks first, and says it may be lost', (tester) async {
      await tapRemove(tester);

      expect(find.text('Remove photo?'), findsOneWidget);
      expect(
        find.text(
          'The photo is deleted when you save. '
          "If it isn't saved anywhere else, it will be lost.",
        ),
        findsOneWidget,
      );
    });

    testWidgets('Cancel keeps the photo', (tester) async {
      await tapRemove(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(TextButton, 'Cancel'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Change photo'), findsOneWidget);
    });

    testWidgets('Remove takes it off the form', (tester) async {
      await tapRemove(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Remove'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Change photo'), findsNothing);
      expect(find.text('Add photo'), findsOneWidget);
    });
  });

  testWidgets('deleting a profile says its photos go too', (tester) async {
    final sarah = Profile(id: 1, name: 'Sarah');
    final dad = Profile(id: 2, name: 'Dad');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileListProvider.overrideWith(
            () => _FakeProfileList([sarah, dad]),
          ),
          activeProfileProvider.overrideWith(() => _FakeActiveProfile(1)),
        ],
        child: MaterialApp(
          home: Scaffold(body: AddProfileSheet(existing: dad)),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'All health data recorded for Dad, including photos, will be '
        'permanently removed from this device. Photos not saved anywhere '
        'else will be lost. This cannot be undone.',
      ),
      findsOneWidget,
    );
  });
}
