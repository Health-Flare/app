import 'package:isar_community/isar.dart';

part 'weather_snapshot_isar.g.dart';

@embedded
class WeatherSnapshotIsar {
  double? temperatureCelsius;
  int? weatherCode;
  double? pressureHPa;
  int? humidityPercent;
  double? windSpeedKmh;
  DateTime? capturedAt;
}
