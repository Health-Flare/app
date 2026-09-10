import 'package:flutter/foundation.dart'
    show LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/data/database/app_database.dart';

void main() async {
  // Required before any async work that touches Flutter bindings.
  WidgetsFlutterBinding.ensureInitialized();

  _registerBundledFontLicenses();

  // Open the database and run migrations. Completes before any UI is shown.
  final isar = await IsarService.open();

  // Pre-load startup data before runApp so providers have real values on the
  // first frame. This eliminates the async race where activeProfileProvider
  // starts as null and the journal list filters to empty.
  final startup = await IsarService.readStartupData(isar);

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
      ],
      child: const HealthFlareApp(),
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
class HealthFlareApp extends ConsumerWidget {
  const HealthFlareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final activeProfile = ref.watch(activeProfileDataProvider);

    return MaterialApp.router(
      title: 'Health Flare',
      theme: AppTheme.forSeed(activeProfile?.colorSeed),
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
