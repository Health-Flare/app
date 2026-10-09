import 'package:flutter/foundation.dart'
    show LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/core/security/secure_window.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/core/widgets/startup_notice.dart';
import 'package:health_flare/data/database/app_database.dart';
import 'package:health_flare/features/app_lock/app_lock_gate.dart';

void main() async {
  // Required before any async work that touches Flutter bindings.
  WidgetsFlutterBinding.ensureInitialized();

  _registerBundledFontLicenses();

  // Open the database and run migrations. Completes before any UI is shown.
  final isar = await IsarService.open();
  final startupNotice = IsarService.lastMigration.startupNotice;

  // Pre-load startup data before runApp so providers have real values on the
  // first frame. This eliminates the async race where activeProfileProvider
  // starts as null and the journal list filters to empty.
  final startup = await IsarService.readStartupData(isar);

  // App lock (#100) and hide in app switcher (#101) apply before the first
  // frame: a locked app never shows a health screen, even for one frame.
  final appLock = await IsarAppLockStore(isar).read();
  final lockSupported = appLockSupported();
  final hasScreenLock = lockSupported && appLock.enabled
      ? await LocalDeviceAuth().hasScreenLock()
      : true;
  if (lockSupported && appLock.hideInAppSwitcher) {
    await const PlatformSecureWindow().setHidden(true);
  }

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        // Seed providers with persisted values so the first frame is correct.
        profileListProvider.overrideWith(
          () => ProfileListNotifier()..preload(startup.profiles),
        ),
        activeProfileProvider.overrideWith(
          () => ActiveProfileNotifier()..preload(startup.activeProfileId),
        ),
        appLockProvider.overrideWith(
          () => AppLockNotifier()
            ..preload(
              lockSupported ? appLock : const AppLockSettings(),
              hasScreenLock: hasScreenLock,
            ),
        ),
      ],
      child: HealthFlareApp(startupNotice: startupNotice),
    ),
  );
}

/// Registers the SIL OFL license text for the bundled font families
/// (DM Sans, DM Mono, Fraunces) so they appear in the licenses page shown
/// by `showLicensePage`, alongside the licenses Flutter collects
/// automatically from pub dependencies.
void _registerBundledFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    final dmSans = await rootBundle.loadString('assets/fonts/DMSans-OFL.txt');
    yield LicenseEntryWithLineBreaks(['DM Sans'], dmSans);

    final dmMono = await rootBundle.loadString('assets/fonts/DMMono-OFL.txt');
    yield LicenseEntryWithLineBreaks(['DM Mono'], dmMono);

    final fraunces = await rootBundle.loadString(
      'assets/fonts/Fraunces-OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['Fraunces'], fraunces);
  });
}

/// Root application widget.
///
/// Wires together [AppTheme] and [appRouterProvider] from Riverpod.
/// All navigation is handled declaratively via go_router.
class HealthFlareApp extends ConsumerStatefulWidget {
  const HealthFlareApp({super.key, this.startupNotice});

  /// Shown once in a banner on the first screen, e.g. when a data upgrade
  /// was skipped or failed at startup (#110). Null shows nothing.
  final String? startupNotice;

  @override
  ConsumerState<HealthFlareApp> createState() => _HealthFlareAppState();
}

class _HealthFlareAppState extends ConsumerState<HealthFlareApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final activeProfile = ref.watch(activeProfileDataProvider);

    return StartupNotice(
      notice: widget.startupNotice,
      messengerKey: _messengerKey,
      child: MaterialApp.router(
        title: 'Health Flare',
        theme: AppTheme.forSeed(activeProfile?.colorSeed),
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: router,
        scaffoldMessengerKey: _messengerKey,
        debugShowCheckedModeBanner: false,
        // Above the router so the lock keeps every screen's state (#100).
        builder: (context, child) =>
            AppLockGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
