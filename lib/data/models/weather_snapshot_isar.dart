import 'package:isar_community/isar.dart';

import 'package:health_flare/models/weather_snapshot.dart';

part 'weather_snapshot_isar.g.dart';

@embedded
class WeatherSnapshotIsar {
  double? temperatureCelsius;
  int? weatherCode;
  double? pressureHPa;
  int? humidityPercent;
  double? windSpeedKmh;
  DateTime? capturedAt;

  WeatherSnapshot? toDomain() {
    if (temperatureCelsius == null ||
        weatherCode == null ||
        pressureHPa == null ||
        humidityPercent == null ||
        windSpeedKmh == null ||
        capturedAt == null) {
      return null;
    }
    return WeatherSnapshot(
      temperatureCelsius: temperatureCelsius!,
      weatherCode: weatherCode!,
      pressureHPa: pressureHPa!,
      humidityPercent: humidityPercent!,
      windSpeedKmh: windSpeedKmh!,
      capturedAt: capturedAt!,
    );
  }

  static WeatherSnapshotIsar fromDomain(WeatherSnapshot w) =>
      WeatherSnapshotIsar()
        ..temperatureCelsius = w.temperatureCelsius
        ..weatherCode = w.weatherCode
        ..pressureHPa = w.pressureHPa
        ..humidityPercent = w.humidityPercent
        ..windSpeedKmh = w.windSpeedKmh
        ..capturedAt = w.capturedAt;
}
