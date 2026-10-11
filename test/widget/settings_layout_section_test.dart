import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/settings/screens/settings_screen.dart';

import '../helpers/app_lock_fakes.dart';

// The release guide's "Set it up myself" opens Settings > Your layout
// (release-guides.feature, #145): Settings opens scrolled to that section.
// One Isar-backed pump per file: see settings_backup_encryption_test.dart.

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [ProfileIsarSchema, AppSettingsSchema],
      directory: '',
      name: 'settings_layout_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  testWidgets('Settings opened at Your layout shows that section', (
    tester,
  ) async {
    // A short phone: Your layout starts well below the fold.
    tester.view.physicalSize = const Size(1080, 1500);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          featureFlagsProvider.overrideWithValue(
            const FeatureFlags(trackAndCare: true),
          ),
          ...appLockOverrides(
            auth: FakeDeviceAuth(),
            store: MemoryAppLockStore(),
            window: FakeSecureWindow(),
            clock: FakeClock(),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen(section: 'layout')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final header = find.text('Your layout');
    expect(header, findsOneWidget);
    final y = tester.getTopLeft(header).dy;
    expect(y, greaterThanOrEqualTo(0));
    expect(y, lessThan(500 / 2), reason: 'scrolled to near the top');
    expect(find.text('Bottom bar'), findsOneWidget);
  });
}
