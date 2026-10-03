// Issue #83: vitals (e.g. temperature) never appeared on the insights screen.
// Specs: docs/features/reports.feature, "Vital trends" scenarios.
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/features/reports/services/insights_query_service.dart';
import 'package:health_flare/features/reports/services/vital_units.dart';
import 'package:health_flare/models/vital_type.dart';

Future<Isar> _openIsar() => Isar.open(
  [
    SymptomEntryIsarSchema,
    MealEntryIsarSchema,
    DailyCheckinIsarSchema,
    SleepEntryIsarSchema,
    FlareIsarSchema,
    VitalEntryIsarSchema,
  ],
  directory: '',
  name: 'insights_vitals_${DateTime.now().microsecondsSinceEpoch}',
);

const _sarah = 1;
const _ethan = 2;

// Fixed window: 1–30 Sept 2026.
final _start = DateTime(2026, 9, 1);
final _end = DateTime(2026, 9, 30);

Future<void> _addVital(
  Isar isar, {
  int profileId = _sarah,
  VitalType type = VitalType.temperature,
  required double value,
  double? value2,
  String? unit,
  required DateTime at,
}) async {
  await isar.writeTxn(() async {
    await isar.vitalEntryIsars.put(
      VitalEntryIsar()
        ..profileId = profileId
        ..vitalType = type.name
        ..value = value
        ..value2 = value2
        ..unit = unit ?? type.defaultUnit
        ..loggedAt = at
        ..createdAt = at,
    );
  });
}

Future<InsightData> _query(Isar isar, {int profileId = _sarah}) =>
    InsightsQueryService.query(
      isar: isar,
      profileId: profileId,
      start: _start,
      end: _end,
    );

VitalTrend? _trend(InsightData data, VitalType type) {
  for (final t in data.vitalTrends) {
    if (t.type == type) return t;
  }
  return null;
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  late Isar isar;
  setUp(() async {
    isar = await _openIsar();
  });
  tearDown(() => isar.close(deleteFromDisk: true));

  group('InsightsQueryService vitals', () {
    test('temperature readings appear as a vital trend', () async {
      await _addVital(isar, value: 37.1, at: DateTime(2026, 9, 10, 8));
      await _addVital(isar, value: 38.4, at: DateTime(2026, 9, 11, 8));
      await _addVital(isar, value: 37.6, at: DateTime(2026, 9, 12, 20));

      final data = await _query(isar);

      final temp = _trend(data, VitalType.temperature);
      expect(temp, isNotNull, reason: 'temperature trend missing');
      expect(temp!.unit, '°C');
      expect(temp.points.map((p) => p.value), [37.1, 38.4, 37.6]);
    });

    test('only vital types with readings get a trend', () async {
      await _addVital(isar, value: 37.0, at: DateTime(2026, 9, 10));
      await _addVital(
        isar,
        type: VitalType.weight,
        value: 70,
        at: DateTime(2026, 9, 10),
      );

      final data = await _query(isar);

      expect(data.vitalTrends.map((t) => t.type).toSet(), {
        VitalType.temperature,
        VitalType.weight,
      });
    });

    test('same-day readings stay separate, at their logged time', () async {
      final morning = DateTime(2026, 9, 15, 8);
      final evening = DateTime(2026, 9, 15, 20);
      await _addVital(isar, value: 38.6, at: evening);
      await _addVital(isar, value: 37.2, at: morning);

      final data = await _query(isar);

      final temp = _trend(data, VitalType.temperature)!;
      expect(temp.points, hasLength(2));
      expect(temp.points.map((p) => p.date), [morning, evening]);
      expect(temp.points.map((p) => p.value), [37.2, 38.6]);
    });

    test('mixed units are converted to the most recent reading unit', () async {
      await _addVital(isar, value: 37.0, unit: '°C', at: DateTime(2026, 9, 10));
      await _addVital(
        isar,
        value: 100.4,
        unit: '°F',
        at: DateTime(2026, 9, 11),
      );

      final data = await _query(isar);

      final temp = _trend(data, VitalType.temperature)!;
      expect(temp.unit, '°F');
      expect(temp.points.first.value, closeTo(98.6, 0.01));
      expect(temp.points.last.value, closeTo(100.4, 0.01));
    });

    test('conversion does not rewrite stored readings', () async {
      await _addVital(isar, value: 37.0, unit: '°C', at: DateTime(2026, 9, 10));
      await _addVital(
        isar,
        value: 100.4,
        unit: '°F',
        at: DateTime(2026, 9, 11),
      );

      await _query(isar);

      final rows = await isar.vitalEntryIsars.where().findAll();
      final celsius = rows.firstWhere((r) => r.unit == '°C');
      expect(celsius.value, 37.0);
    });

    test('blood pressure carries diastolic as a second series', () async {
      await _addVital(
        isar,
        type: VitalType.bloodPressure,
        value: 120,
        value2: 80,
        at: DateTime(2026, 9, 10),
      );
      await _addVital(
        isar,
        type: VitalType.bloodPressure,
        value: 135,
        value2: 88,
        at: DateTime(2026, 9, 12),
      );

      final data = await _query(isar);

      final bp = _trend(data, VitalType.bloodPressure)!;
      expect(bp.points.map((p) => p.value), [120, 135]);
      expect(bp.secondaryPoints.map((p) => p.value), [80, 88]);
    });

    test('only the active profile, only inside the window', () async {
      await _addVital(isar, value: 37.5, at: DateTime(2026, 9, 20));
      await _addVital(isar, value: 39.0, at: DateTime(2026, 8, 1));
      await _addVital(
        isar,
        profileId: _ethan,
        value: 38.0,
        at: DateTime(2026, 9, 29),
      );

      final data = await _query(isar);

      final temp = _trend(data, VitalType.temperature)!;
      expect(temp.points.map((p) => p.value), [37.5]);
    });

    test('vitals alone make the insight data non-empty', () async {
      await _addVital(isar, value: 37.5, at: DateTime(2026, 9, 20));

      final data = await _query(isar);

      expect(data.isEmpty, isFalse);
    });
  });

  group('VitalUnits.convert', () {
    test('°C to °F', () {
      expect(VitalUnits.convert(37, from: '°C', to: '°F'), closeTo(98.6, 1e-9));
    });

    test('°F to °C', () {
      expect(
        VitalUnits.convert(100.4, from: '°F', to: '°C'),
        closeTo(38.0, 1e-9),
      );
    });

    test('kg to lbs', () {
      expect(
        VitalUnits.convert(70, from: 'kg', to: 'lbs'),
        closeTo(154.324, 0.001),
      );
    });

    test('mmol/L to mg/dL', () {
      expect(
        VitalUnits.convert(5.5, from: 'mmol/L', to: 'mg/dL'),
        closeTo(99.1, 0.1),
      );
    });

    test('cm to in', () {
      expect(VitalUnits.convert(254, from: 'cm', to: 'in'), closeTo(100, 1e-9));
    });

    test('same unit is unchanged', () {
      expect(VitalUnits.convert(72, from: 'BPM', to: 'BPM'), 72);
    });
  });
}
