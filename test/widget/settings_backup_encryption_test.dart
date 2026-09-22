import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/settings/screens/settings_screen.dart';

// ---------------------------------------------------------------------------
// Widget-level tests for issue #30 / docs/features/encrypted-backup.feature
//
// Nothing under test here exists yet in lib/ — these are the failing
// ("red") tests the project's BDD workflow calls for ahead of
// implementation. They pin the UI contract for the export sheet's
// encryption toggle and for two new BackupResult states expected on
// BackupNotifier (lib/core/providers/backup_provider.dart):
//
//   enum PendingImportAction { overwrite, merge, selective }
//
//   class ImportPasswordRequired extends BackupResult {
//     const ImportPasswordRequired({required this.filePath, required this.action});
//     final String filePath;
//     final PendingImportAction action;
//   }
//
// ...plus two new BackupNotifier methods: exportWithPassword(String) and
// submitImportPassword(String), mirroring the existing export()/mergeRestore()
// shape. File-picker-driven parts of import (selecting a file at all) are
// deliberately not exercised here — there's no picker abstraction in the
// codebase to fake yet, so that stays covered at the service level in
// test/unit/database/backup_encryption_test.dart instead. These tests only
// cover what's reachable through local widget state and provider overrides.
// ---------------------------------------------------------------------------

Future<Isar> _openIsar(String name) {
  return Isar.open(
    [ProfileIsarSchema, AppSettingsSchema],
    directory: '',
    name: name,
  );
}

Widget _buildSettings(Isar isar, {BackupNotifier Function()? notifier}) {
  return ProviderScope(
    overrides: [
      isarProvider.overrideWithValue(isar),
      if (notifier != null) backupProvider.overrideWith(notifier),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

/// Enters [password] and [confirm] into the export sheet's two password
/// fields. Assumes the "Encrypt with a password" toggle is already on.
Future<void> _enterPasswords(
  WidgetTester tester, {
  required String password,
  required String confirm,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Confirm password'),
    confirm,
  );
  await tester.pump();
}

Future<void> _openExportSheet(WidgetTester tester) async {
  await tester.tap(find.text('Export backup'));
  await tester.pumpAndSettle();
}

Future<void> _turnOnEncryption(WidgetTester tester) async {
  await tester.tap(
    find.widgetWithText(SwitchListTile, 'Encrypt with a password'),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  tearDown(() async {
    for (final isar
        in Isar.instanceNames.map(Isar.getInstance).whereType<Isar>()) {
      if (isar.isOpen) await isar.close();
    }
  });

  // ---------------------------------------------------------------------
  // Scenario: "Encryption is off by default on export"
  // Scenario: "Turning on encryption reveals password fields"
  // ---------------------------------------------------------------------
  group('Export sheet — encryption opt-in', () {
    testWidgets(
      'the encryption toggle is off by default, with no password fields shown',
      (tester) async {
        final isar = await _openIsar('settings_default_off');
        await tester.pumpWidget(_buildSettings(isar));
        await tester.pump();

        await _openExportSheet(tester);

        final toggle = tester.widget<SwitchListTile>(
          find.widgetWithText(SwitchListTile, 'Encrypt with a password'),
        );
        expect(toggle.value, isFalse);
        expect(find.widgetWithText(TextFormField, 'Password'), findsNothing);
        expect(
          find.widgetWithText(TextFormField, 'Confirm password'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'turning the toggle on reveals both password fields and the loss warning',
      (tester) async {
        final isar = await _openIsar('settings_toggle_on');
        await tester.pumpWidget(_buildSettings(isar));
        await tester.pump();

        await _openExportSheet(tester);
        await _turnOnEncryption(tester);

        expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'Confirm password'),
          findsOneWidget,
        );
        expect(find.textContaining("can't be recovered"), findsWidgets);
      },
    );
  });

  // ---------------------------------------------------------------------
  // Scenario: "A password shorter than the minimum length is rejected"
  // Scenario: "Mismatched password confirmation is rejected"
  // Scenario: "A valid, matching password enables the export"
  // Scenario: "The user must acknowledge the loss-of-password warning"
  // ---------------------------------------------------------------------
  group('Export sheet — password validation', () {
    testWidgets(
      'a password shorter than 8 characters shows an inline error and '
      'keeps Export disabled',
      (tester) async {
        final isar = await _openIsar('settings_short_password');
        await tester.pumpWidget(_buildSettings(isar));
        await tester.pump();

        await _openExportSheet(tester);
        await _turnOnEncryption(tester);
        await _enterPasswords(tester, password: 'abc123', confirm: 'abc123');

        expect(find.textContaining('at least 8 characters'), findsOneWidget);
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Export'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'mismatched password confirmation shows an inline error and keeps '
      'Export disabled',
      (tester) async {
        final isar = await _openIsar('settings_mismatched_password');
        await tester.pumpWidget(_buildSettings(isar));
        await tester.pump();

        await _openExportSheet(tester);
        await _turnOnEncryption(tester);
        await _enterPasswords(
          tester,
          password: 'correcthorsebattery',
          confirm: 'correcthorsebatteri',
        );

        expect(find.textContaining("don't match"), findsOneWidget);
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Export'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('a valid, matching, acknowledged password enables Export', (
      tester,
    ) async {
      final isar = await _openIsar('settings_valid_password');
      await tester.pumpWidget(_buildSettings(isar));
      await tester.pump();

      await _openExportSheet(tester);
      await _turnOnEncryption(tester);
      await _enterPasswords(
        tester,
        password: 'correcthorsebattery',
        confirm: 'correcthorsebattery',
      );
      await tester.tap(
        find.widgetWithText(
          CheckboxListTile,
          "I understand this password can't be recovered",
        ),
      );
      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Export'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets(
      'a valid, matching but unacknowledged password keeps Export disabled',
      (tester) async {
        final isar = await _openIsar('settings_unacknowledged');
        await tester.pumpWidget(_buildSettings(isar));
        await tester.pump();

        await _openExportSheet(tester);
        await _turnOnEncryption(tester);
        await _enterPasswords(
          tester,
          password: 'correcthorsebattery',
          confirm: 'correcthorsebattery',
        );
        // Warning checkbox deliberately left unchecked.

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Export'),
        );
        expect(
          button.onPressed,
          isNull,
          reason:
              'export must not proceed until the user acknowledges the '
              "password can't be recovered if lost",
        );
      },
    );
  });

  // ---------------------------------------------------------------------
  // Scenario: "The export screen explains data ownership before the user
  // shares anything". Exact copy is intentionally not pinned here (the spec
  // notes it's still to be written) — only that a dedicated, keyed notice
  // exists and that it isn't the vague reassurance CLAUDE.md rules out.
  // ---------------------------------------------------------------------
  group('Export sheet — data ownership messaging', () {
    testWidgets(
      'shows a dedicated ownership notice and never the vague "we value '
      'your privacy" reassurance',
      (tester) async {
        final isar = await _openIsar('settings_ownership_notice');
        await tester.pumpWidget(_buildSettings(isar));
        await tester.pump();

        await _openExportSheet(tester);

        expect(
          find.byKey(const Key('export_ownership_notice')),
          findsOneWidget,
        );
        expect(find.textContaining('we value your privacy'), findsNothing);
      },
    );
  });

  // ---------------------------------------------------------------------
  // Scenario: "Selecting an encrypted file prompts for its password"
  // Driven through a fixed-state fake notifier rather than a real file
  // pick, since BackupNotifier calls FilePicker directly and there's no
  // seam to fake that yet — see the file-level note above.
  // ---------------------------------------------------------------------
  group('Import — password prompt for an encrypted file', () {
    testWidgets(
      'an ImportPasswordRequired state shows a password prompt before any '
      'preview, merge, or staging UI',
      (tester) async {
        final isar = await _openIsar('settings_import_password_prompt');
        await tester.pumpWidget(
          _buildSettings(
            isar,
            notifier: () => _FixedStateBackupNotifier(
              const ImportPasswordRequired(
                filePath: '/tmp/fake-backup.hfbackup',
                action: PendingImportAction.merge,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Unlock'), findsOneWidget);
      },
    );

    testWidgets(
      'submitting the password prompt calls notifier.submitImportPassword',
      (tester) async {
        final isar = await _openIsar('settings_import_password_submit');
        final spy = _SpyBackupNotifier(
          const ImportPasswordRequired(
            filePath: '/tmp/fake-backup.hfbackup',
            action: PendingImportAction.merge,
          ),
        );
        await tester.pumpWidget(_buildSettings(isar, notifier: () => spy));
        await tester.pump();
        await tester.pump();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'correcthorsebattery',
        );
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
        await tester.pump();

        expect(spy.submittedPassword, 'correcthorsebattery');
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Fake notifiers — same technique as test/widget_test.dart's _Fake* classes:
// subclass the real Notifier and override build() to skip its normal
// (FilePicker/Isar-driven) startup logic.
// ---------------------------------------------------------------------------

class _FixedStateBackupNotifier extends BackupNotifier {
  _FixedStateBackupNotifier(this._initial);
  final BackupResult _initial;

  @override
  BackupResult build() => _initial;
}

class _SpyBackupNotifier extends BackupNotifier {
  _SpyBackupNotifier(this._initial);
  final BackupResult _initial;
  String? submittedPassword;

  @override
  BackupResult build() => _initial;

  @override
  Future<void> submitImportPassword(String password) async {
    submittedPassword = password;
  }
}
