import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/backup_summary.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/settings/screens/settings_screen.dart';

// Settings shows the #104 confirmation and passes the answer to the
// notifier (docs/features/datastore.feature: "Add missing data" says what
// it will add, Cancelling leaves everything as it was, A backup with
// nothing new says so, "Replace everything" says what will replace what).
//
// One SettingsScreen pump for the whole file: a second Isar-backed pump in
// the same file hangs (see settings_import_password_prompt_test.dart).

const _summary = BackupSummary(
  profiles: [
    BackupProfileSummary(
      name: 'Sarah',
      newCounts: {ImportCategoryId.symptomEntries: 12},
      entryCount: 40,
    ),
  ],
);

void main() {
  late Isar isar;

  setUpAll(() async => Isar.initializeIsarCore(download: true));

  // Opened here, not in the test body: real I/O never completes inside
  // testWidgets' fake-async zone, and the test hangs.
  setUp(() async {
    isar = await Isar.open(
      [ProfileIsarSchema, AppSettingsSchema],
      directory: '',
      name: 'settings_import_confirm_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  testWidgets('the confirmation is shown, and Add, Cancel and Replace reach '
      'the notifier', (tester) async {
    final spy = _SpyBackupNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          backupProvider.overrideWith(() => spy),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();

    // "Add missing data": Add.
    spy.emit(const MergeConfirmRequired(filePath: '/x', summary: _summary));
    await _settle(tester);
    expect(find.text('Sarah: 12 symptoms'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await _settle(tester);
    expect(spy.calls, ['confirm']);

    // "Add missing data": Cancel.
    spy.emit(const MergeConfirmRequired(filePath: '/x', summary: _summary));
    await _settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await _settle(tester);
    expect(spy.calls, ['confirm', 'cancel']);

    // Cancel and "nothing new" are said in a snackbar.
    spy.emit(const ImportNothingDone(ImportNothingDone.cancelled));
    await tester.pump();
    expect(find.text('Nothing was added from the backup'), findsOneWidget);
    await _settle(tester);

    // "Replace everything": what's in the backup and what it replaces.
    spy.emit(
      const ReplaceConfirmRequired(
        filePath: '/x',
        summary: _summary,
        currentProfiles: ['Leo'],
      ),
    );
    await _settle(tester);
    expect(find.text('Sarah: 40 entries'), findsOneWidget);
    expect(find.text('Leo'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
    await _settle(tester);
    expect(spy.calls, ['confirm', 'cancel', 'confirm']);
  });
}

/// SettingsScreen never settles (pumpAndSettle times out): fixed pumps,
/// long enough for a dialog or snackbar to come and go.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _SpyBackupNotifier extends BackupNotifier {
  final calls = <String>[];

  void emit(BackupResult r) => state = r;

  @override
  BackupResult build() => const BackupIdle();

  @override
  Future<void> confirmImport() async {
    calls.add('confirm');
    state = const BackupIdle();
  }

  @override
  Future<void> cancelImport() async {
    calls.add('cancel');
    state = const BackupIdle();
  }
}
