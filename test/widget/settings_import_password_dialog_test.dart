import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/settings/screens/settings_screen.dart';

// ---------------------------------------------------------------------------
// Import password dialog lifecycle (issue #30,
// docs/features/encrypted-backup.feature): retrying after a wrong password,
// cancelling, and handing off to the selective-import category sheet.
//
// Settings is pushed on top of a home route so a dialog that closes by
// popping the wrong route (the Settings screen itself, or the category
// sheet pushed over it) is caught. Kept to a single testWidgets for the
// reason given in settings_backup_encryption_test.dart's header: repeated
// Isar-backed SettingsScreen pumps in one file hang in this environment.
// ---------------------------------------------------------------------------

/// Scripted notifier: [submitImportPassword] moves to whatever the test
/// queued in [nextAfterSubmit].
class _ScriptedBackupNotifier extends BackupNotifier {
  BackupResult Function(String password)? nextAfterSubmit;
  final submitted = <String>[];

  @override
  BackupResult build() => const BackupIdle();

  void emit(BackupResult result) => state = result;

  @override
  Future<void> submitImportPassword(String password) async {
    submitted.add(password);
    state = nextAfterSubmit!(password);
  }

  @override
  void reset() => state = const BackupIdle();
}

const _pending = ImportPasswordRequired(
  filePath: '/picked/backup.hfbackup',
  action: PendingImportAction.selective,
);

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [ProfileIsarSchema, AppSettingsSchema],
      directory: '',
      name: 'settings_pw_dialog_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  testWidgets('password dialog: wrong password retries in place, cancel '
      'closes only the dialog, and unlocking hands off to the category '
      'sheet', (tester) async {
    final notifier = _ScriptedBackupNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          backupProvider.overrideWith(() => notifier),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
                child: const Text('open settings'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    final passwordField = find.widgetWithText(TextFormField, 'Password');
    final unlock = find.widgetWithText(FilledButton, 'Unlock');

    // -- Wrong password: error shown inline, dialog stays, no re-pick. -----
    notifier.emit(_pending);
    await tester.pumpAndSettle();
    expect(find.text('Enter password'), findsOneWidget);

    notifier.nextAfterSubmit = (_) => const ImportPasswordRequired(
      filePath: '/picked/backup.hfbackup',
      action: PendingImportAction.selective,
      errorMessage: 'Incorrect password, or the file is damaged.',
    );
    await tester.enterText(passwordField, 'wrong password');
    await tester.tap(unlock);
    await tester.pumpAndSettle();

    expect(notifier.submitted, ['wrong password']);
    expect(find.text('Enter password'), findsOneWidget);
    expect(
      find.text('Incorrect password, or the file is damaged.'),
      findsOneWidget,
    );

    // -- Cancel: the dialog closes, the Settings screen stays. -------------
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Enter password'), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('open settings'), findsNothing);

    // -- Unlock: the category sheet opens and stays; the dialog is gone. ---
    notifier.emit(_pending);
    await tester.pumpAndSettle();
    expect(find.text('Enter password'), findsOneWidget);

    notifier.nextAfterSubmit = (_) => const ImportPreviewReady(
      filePath: '/tmp/healthflare_decrypted_1.isar',
      categories: [
        ImportCategoryInfo(
          id: ImportCategoryId.profiles,
          label: 'Profiles',
          count: 1,
        ),
      ],
    );
    await tester.enterText(passwordField, 'correcthorsebattery');
    await tester.tap(unlock);
    await tester.pumpAndSettle();

    expect(find.text('Enter password'), findsNothing);
    expect(find.text('Profiles'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
