import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/settings/screens/settings_screen.dart';
import 'package:health_flare/features/settings/widgets/privacy_settings_section.dart';

import '../helpers/app_lock_fakes.dart';

// docs/features/app-lock.feature: the lock lives in Settings > Privacy
// (#100). One Isar-backed pump per file: see the note in
// settings_backup_encryption_test.dart.

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [ProfileIsarSchema, AppSettingsSchema],
      directory: '',
      name: 'settings_privacy_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  // Not closed: closing an Isar instance after a widget pump hangs here,
  // as in settings_backup_encryption_test.dart. Each run uses a fresh name.

  testWidgets('Settings has a Privacy section above Data & backup', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          ...appLockOverrides(
            auth: FakeDeviceAuth(),
            store: MemoryAppLockStore(),
            window: FakeSecureWindow(),
            clock: FakeClock(),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PrivacySettingsSection), findsOneWidget);
    expect(find.text('App lock'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Privacy')).dy,
      lessThan(tester.getTopLeft(find.text('Data & backup')).dy),
    );
  });
}
