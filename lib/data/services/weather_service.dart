import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:health_flare/models/weather_snapshot.dart';

class WeatherService {
  WeatherService._();

  static Future<WeatherSnapshot?> fetch() async {
    try {
      // Check/request location permission.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get coarse position (faster; sufficient for city-level weather).
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Fetch weather from Open-Meteo (no API key required).
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&current=temperature_2m,relative_humidity_2m,weather_code,surface_pressure,wind_speed_10m'
        '&forecast_days=1',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;

      return WeatherSnapshot(
        temperatureCelsius: (current['temperature_2m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        pressureHPa: (current['surface_pressure'] as num).toDouble(),
        humidityPercent: (current['relative_humidity_2m'] as num).toInt(),
        windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
        capturedAt: DateTime.now(),
      );
    } on SocketException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
