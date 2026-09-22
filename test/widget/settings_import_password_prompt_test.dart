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
// — the password prompt shown when a picked backup file is encrypted.
//
// Split out from settings_backup_encryption_test.dart because a *second*
// real, Isar-backed SettingsScreen pump in the same test file reliably
// hangs in this environment — see that file's header comment for the
// repro details. Driven through a fixed-state/spy fake notifier rather
// than a real file pick, since BackupNotifier calls FilePicker directly
// and there's no picker abstraction in the codebase to fake yet — that
// stays covered at the service level in
// test/unit/database/backup_encryption_test.dart instead.
// ---------------------------------------------------------------------------

Future<Isar> _openIsar(String name) {
  return Isar.open(
    [ProfileIsarSchema, AppSettingsSchema],
    directory: '',
    name: name,
  );
}

Widget _buildSettings(
  Isar isar, {
  required BackupNotifier Function() notifier,
}) {
  return ProviderScope(
    overrides: [
      isarProvider.overrideWithValue(isar),
      backupProvider.overrideWith(notifier),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await _openIsar(
      'settings_import_pw_test_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  // ---------------------------------------------------------------------
  // Scenario: "Selecting an encrypted file prompts for its password"
  // ---------------------------------------------------------------------
  testWidgets('an ImportPasswordRequired state shows a password prompt, and '
      'submitting it calls notifier.submitImportPassword', (tester) async {
    final spy = _SpyBackupNotifier(
      const ImportPasswordRequired(
        filePath: '/tmp/fake-backup.hfbackup',
        action: PendingImportAction.merge,
      ),
    );
    await tester.pumpWidget(_buildSettings(isar, notifier: () => spy));
    // Two pumps: the first renders SettingsScreen and schedules the
    // password dialog via a post-frame callback (see
    // _BackupTilesState.build); the second renders the dialog itself.
    await tester.pump();
    await tester.pump();

    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Unlock'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'correcthorsebattery',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pump();

    expect(spy.submittedPassword, 'correcthorsebattery');
  });
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
