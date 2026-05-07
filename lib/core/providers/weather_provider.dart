import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/services/weather_service.dart';
import 'package:health_flare/models/weather_snapshot.dart';

/// Persists the last successfully fetched snapshot alongside the fetch time.
/// Not autoDispose — survives form open/close cycles within the same session.
final _weatherCacheProvider = StateProvider<(WeatherSnapshot, DateTime)?>(
  (_) => null,
);

/// Fetches the current weather if the active profile has weather tracking
/// enabled. Returns null if disabled, permission denied, or no connectivity.
///
/// Snapshots captured within the last 30 minutes are reused from the in-memory
/// cache to avoid redundant API calls when multiple entries are logged in quick
/// succession.
final currentWeatherProvider = FutureProvider.autoDispose<WeatherSnapshot?>((
  ref,
) async {
  final profile = ref.watch(activeProfileDataProvider);
  if (profile == null || !profile.weatherTrackingEnabled) return null;

  final cached = ref.read(_weatherCacheProvider);
  if (cached != null) {
    final age = DateTime.now().difference(cached.$2);
    if (age.inMinutes < 30) return cached.$1;
  }

  final snapshot = await WeatherService.fetch();
  if (snapshot != null) {
    ref.read(_weatherCacheProvider.notifier).state = (snapshot, DateTime.now());
  }
  return snapshot;
});
