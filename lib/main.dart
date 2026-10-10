import 'package:flutter/foundation.dart'
    show LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
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
import 'package:health_flare/features/whats_new/debug/whats_new_preview.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';

void main() async {
  // Required before any async work that touches Flutter bindings.
  WidgetsFlutterBinding.ensureInitialized();

  _registerBundledFontLicenses();

  // Open the database and run migrations. Completes before any UI is shown.
  final isar = await IsarService.open();
  final startupNotice = IsarService.lastMigration.startupNotice;

  // Bottom bar (#137): record which default bar a fresh install starts on,
  // before onboarding (or a preview scenario) can create a profile, so a
  // later change to the default is explained and a fresh install's isn't.
  try {
    await BarLayoutStore.settle(
      isar,
      current: currentDefaultBarVersion(FeatureFlags.fromEnvironment()),
    );
  } catch (e) {
    debugPrint("Bottom bar: couldn't settle layout version: $e");
  }

  // What's new: record where this device starts before onboarding can
  // create a profile, so a fresh install is never shown a card (#139).
  // Never blocks startup: on failure the dashboard simply shows no card.
  // Debug builds only: --dart-define=WHATS_NEW_PREVIEW=<scenario> puts the
  // app straight into a What's new state (docs/testing/whats-new.md).
  final preview = previewScenarioFromEnvironment();
  try {
    if (preview != null) {
      debugPrint("What's new preview: ${preview.name}: ${preview.description}");
      await applyPreviewScenario(isar, preview);
    }
    final fixture = preview?.usesFixture ?? false;
    await WhatsNewStore.settle(
      isar,
      releases: fixture ? previewReleases : await loadBundledReleaseNotes(),
      installed: preview?.installed ?? await readInstalledVersion(),
    );
  } catch (e) {
    debugPrint("What's new: couldn't settle release state: $e");
  }

  // Pre-load startup data before runApp so providers have real values on the
  // first frame. This eliminates the async race where activeProfileProvider
  // starts as null and the journal list filters to empty.
  // Read after What's new: a preview scenario may add a demo profile.
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
        if (preview != null) ...previewOverrides(preview),
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
