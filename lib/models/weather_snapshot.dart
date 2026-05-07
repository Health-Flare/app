import 'package:flutter/material.dart';

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperatureCelsius,
    required this.weatherCode,
    required this.pressureHPa,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.capturedAt,
  });

  final double temperatureCelsius;
  final int weatherCode;
  final double pressureHPa;
  final int humidityPercent;
  final double windSpeedKmh;
  final DateTime capturedAt;

  String get conditionLabel => _wmoLabel(weatherCode);

  String get displayString =>
      '$conditionLabel, ${temperatureCelsius.round()}°C';

  IconData get icon => _wmoIcon(weatherCode);

  static String _wmoLabel(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 2) return 'Mainly clear';
    if (code == 3) return 'Overcast';
    if (code <= 49) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static IconData _wmoIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 2) return Icons.wb_cloudy_outlined;
    if (code == 3) return Icons.cloud_outlined;
    if (code <= 49) return Icons.foggy;
    if (code <= 77) return Icons.cloudy_snowing;
    if (code <= 82) return Icons.grain;
    if (code <= 99) return Icons.thunderstorm_outlined;
    return Icons.device_thermostat;
  }
}
