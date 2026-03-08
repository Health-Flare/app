import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/main.dart';
import 'package:health_flare/models/profile.dart';

/// A test-friendly version of [HealthFlareApp] that can be configured
/// with custom provider overrides and initial state.
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    this.overrides = const [],
    this.initialRoute,
  });

  final List<Override> overrides;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: _TestAppContent(initialRoute: initialRoute),
    );
  }
}

class _TestAppContent extends ConsumerWidget {
  const _TestAppContent({this.initialRoute});

  final String? initialRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Health Flare Test',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Use light mode for consistent testing
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Builder for creating test app configurations with a fluent API.
class TestAppBuilder {
  TestAppBuilder();

  final List<Override> _overrides = [];
  String? _initialRoute;
  Isar? _isar;
  List<Profile>? _profiles;
  int? _activeProfileId;

  /// Set the Isar database instance for testing.
  TestAppBuilder withIsar(Isar isar) {
    _isar = isar;
    return this;
  }

  /// Pre-populate the app with profiles.
  TestAppBuilder withProfiles(List<Profile> profiles) {
    _profiles = profiles;
    return this;
  }

  /// Set the active profile ID.
  TestAppBuilder withActiveProfileId(int? id) {
    _activeProfileId = id;
    return this;
  }

  /// Set the initial route.
  TestAppBuilder withInitialRoute(String route) {
    _initialRoute = route;
    return this;
  }

  /// Add custom provider overrides.
  TestAppBuilder withOverrides(List<Override> overrides) {
    _overrides.addAll(overrides);
    return this;
  }

  /// Add a single provider override.
  TestAppBuilder withOverride(Override override) {
    _overrides.add(override);
    return this;
  }

  /// Build the test app widget.
  Widget build() {
    final allOverrides = <Override>[..._overrides];

    if (_isar != null) {
      allOverrides.add(isarProvider.overrideWithValue(_isar!));
    }

    if (_profiles != null) {
      allOverrides.add(
        profileListProvider.overrideWith(
          () => ProfileListNotifier()..preload(_profiles!),
        ),
      );
    }

    if (_activeProfileId != null) {
      allOverrides.add(
        activeProfileProvider.overrideWith(
          () => ActiveProfileNotifier()..preload(_activeProfileId),
        ),
      );
    }

    return TestApp(
      overrides: allOverrides,
      initialRoute: _initialRoute,
    );
  }
}
