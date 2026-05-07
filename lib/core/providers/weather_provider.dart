import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/services/weather_service.dart';
import 'package:health_flare/models/weather_snapshot.dart';

/// Fetches the current weather if the active profile has weather tracking
/// enabled. Returns null if disabled, permission denied, or no connectivity.
///
/// The result is cached for the lifetime of the provider so entry forms
/// across a single session use the same snapshot without re-fetching.
final currentWeatherProvider = FutureProvider.autoDispose<WeatherSnapshot?>((
  ref,
) async {
  final profile = ref.watch(activeProfileDataProvider);
  if (profile == null || !profile.weatherTrackingEnabled) return null;

  return WeatherService.fetch();
});
