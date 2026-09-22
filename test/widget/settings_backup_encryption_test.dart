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
// — the export sheet's encryption toggle, its ownership notice, and its
// password validation.
//
// NOTE on test structure: each scenario group below is consolidated into a
// single testWidgets pumping the tree once, then stepping through several
// related assertions in sequence, rather than one testWidgets per Gherkin
// scenario. This isn't just style — pumping a *second* real, Isar-backed
// SettingsScreen tree in the same test file reliably hangs in this
// environment (reproduced with a minimal repro: bare Isar.open() plus a
// widget pump, no health_flare UI code involved — the third such pump in
// one file hangs every time, regardless of whether earlier instances are
// closed). Import-password-prompt coverage that needs its own separate
// notifier override lives in settings_import_password_prompt_test.dart
// instead of a third test here.
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
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await _openIsar(
      'settings_backup_test_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  // ---------------------------------------------------------------------
  // Scenario: "Encryption is off by default on export"
  // Scenario: "Turning on encryption reveals password fields"
  // Scenario: "The export screen explains data ownership before the user
  // shares anything" (exact copy intentionally not pinned — the spec notes
  // it's still to be written; only that a dedicated, keyed notice exists
  // and it isn't the vague reassurance CLAUDE.md rules out).
  // ---------------------------------------------------------------------
  testWidgets(
    'export sheet: ownership notice, and the encryption toggle default/reveal',
    (tester) async {
      await tester.pumpWidget(_buildSettings(isar));
      await tester.pump();
      await _openExportSheet(tester);

      // Ownership notice — always present, regardless of the toggle.
      expect(find.byKey(const Key('export_ownership_notice')), findsOneWidget);
      expect(find.textContaining('we value your privacy'), findsNothing);

      // Off by default, no password fields shown.
      final toggle = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Encrypt with a password'),
      );
      expect(toggle.value, isFalse);
      expect(find.widgetWithText(TextFormField, 'Password'), findsNothing);
      expect(
        find.widgetWithText(TextFormField, 'Confirm password'),
        findsNothing,
      );

      // Turning it on reveals both fields and the loss warning.
      await _turnOnEncryption(tester);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Confirm password'),
        findsOneWidget,
      );
      expect(find.textContaining("can't be recovered"), findsWidgets);
    },
  );

  // ---------------------------------------------------------------------
  // Scenario: "A password shorter than the minimum length is rejected"
  // Scenario: "Mismatched password confirmation is rejected"
  // Scenario: "The user must acknowledge the loss-of-password warning"
  // Scenario: "A valid, matching password enables the export"
  // ---------------------------------------------------------------------
  testWidgets('export sheet: password validation gates the Export button', (
    tester,
  ) async {
    await tester.pumpWidget(_buildSettings(isar));
    await tester.pump();
    await _openExportSheet(tester);
    await _turnOnEncryption(tester);

    // Too short.
    await _enterPasswords(tester, password: 'abc123', confirm: 'abc123');
    expect(find.textContaining('at least 8 characters'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Export'))
          .onPressed,
      isNull,
    );

    // Valid length, but mismatched confirmation.
    await _enterPasswords(
      tester,
      password: 'correcthorsebattery',
      confirm: 'correcthorsebatteri',
    );
    expect(find.textContaining("don't match"), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Export'))
          .onPressed,
      isNull,
    );

    // Valid and matching, but the loss-of-password warning isn't
    // acknowledged yet.
    await _enterPasswords(
      tester,
      password: 'correcthorsebattery',
      confirm: 'correcthorsebattery',
    );
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Export'))
          .onPressed,
      isNull,
      reason:
          'export must not proceed until the user acknowledges the '
          "password can't be recovered if lost",
    );

    // Acknowledging it enables Export.
    await tester.tap(
      find.widgetWithText(
        CheckboxListTile,
        "I understand this password can't be recovered",
      ),
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Export'))
          .onPressed,
      isNotNull,
    );
  });
}
