import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/data/database/backup_summary.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/features/settings/widgets/import_confirm_dialog.dart';

// docs/features/datastore.feature (#104):
//   "Add missing data" says what it will add before adding it
//   "Replace everything" says what will replace what

const _summary = BackupSummary(
  profiles: [
    BackupProfileSummary(
      name: 'Sarah',
      newCounts: {
        ImportCategoryId.symptomEntries: 12,
        ImportCategoryId.doseLogs: 3,
      },
      entryCount: 40,
    ),
    BackupProfileSummary(name: 'Leo', entryCount: 5),
  ],
);

Future<void> _show(WidgetTester tester, Widget dialog) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              showDialog<bool>(context: context, builder: (_) => dialog),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('Add missing data', () {
    const dialog = ImportConfirmDialog.add(summary: _summary);

    testWidgets('lists each profile with what it would add', (tester) async {
      await _show(tester, dialog);
      expect(find.text('Sarah: 12 symptoms, 3 doses'), findsOneWidget);
      expect(find.text('Leo: nothing new'), findsOneWidget);
    });

    testWidgets('says nothing in the app will change', (tester) async {
      await _show(tester, dialog);
      expect(
        find.text('Nothing in the app will be changed or deleted.'),
        findsOneWidget,
      );
    });

    testWidgets('Add pops true, Cancel pops false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showDialog<bool>(
                context: context,
                builder: (_) => dialog,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });
  });

  group('Replace everything', () {
    const dialog = ImportConfirmDialog.replace(
      summary: _summary,
      currentProfiles: ['Sarah', 'Leo', 'Mia'],
    );

    testWidgets('lists the backup profiles with their entry counts', (
      tester,
    ) async {
      await _show(tester, dialog);
      expect(find.text('Sarah: 40 entries'), findsOneWidget);
      expect(find.text('Leo: 5 entries'), findsOneWidget);
    });

    testWidgets('lists the profiles in the app now, which are replaced', (
      tester,
    ) async {
      await _show(tester, dialog);
      expect(find.text('This replaces everything in the app now:'), findsOne);
      expect(find.text('Sarah, Leo, Mia'), findsOneWidget);
    });

    testWidgets('the buttons are Replace and Cancel', (tester) async {
      await _show(tester, dialog);
      expect(find.widgetWithText(FilledButton, 'Replace'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.text('Add'), findsNothing);
    });
  });
}
