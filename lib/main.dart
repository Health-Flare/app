import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/data/database/app_database.dart';

void main() async {
  // Required before any async work that touches Flutter bindings.
  WidgetsFlutterBinding.ensureInitialized();

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

/// Root application widget.
///
/// Wires together [AppTheme] and [appRouterProvider] from Riverpod.
/// All navigation is handled declaratively via go_router.
class HealthFlareApp extends ConsumerWidget {
  const HealthFlareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Health Flare',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
