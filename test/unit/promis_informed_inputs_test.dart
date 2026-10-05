import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/citations/symptom_sources.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/features/reports/services/csv_report_service.dart';
import 'package:health_flare/models/interference.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';

// PROMIS-informed inputs (#89, #90, #91). The ideas come from Dr Cat Hicks's
// Informed Patient method; see lib/core/citations/symptom_sources.dart.

Future<Isar> _openIsar() => Isar.open(
  [SymptomEntryIsarSchema, SleepEntryIsarSchema],
  directory: '',
  name: 'promis_inputs_${DateTime.now().microsecondsSinceEpoch}',
);

ReportData _report({
  List<SymptomEntry> symptoms = const [],
  List<SleepEntry> sleep = const [],
}) => ReportData(
  profileName: 'Sarah',
  start: DateTime(2026, 9, 1),
  end: DateTime(2026, 9, 30),
  symptoms: symptoms,
  vitals: const [],
  doseLogs: const [],
  medications: const [],
  meals: const [],
  journal: const [],
  sleep: sleep,
  checkins: const [],
  appointments: const [],
  activities: const [],
);

SymptomEntry _symptom(
  int id,
  String name, {
  int severity = 5,
  int? interference,
  String? impact,
}) => SymptomEntry(
  id: id,
  profileId: 1,
  name: name,
  severity: severity,
  loggedAt: DateTime(2026, 9, 10, 9, id),
  createdAt: DateTime(2026, 9, 10),
  interference: interference,
  impact: impact,
);

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  group('Interference labels', () {
    test('five steps in order', () {
      expect(Interference.labels, [
        'Not at all',
        'A little',
        'Somewhat',
        'Quite a bit',
        'Very much',
      ]);
    });

    test('null is "not recorded", never "Not at all"', () {
      expect(Interference.label(null), isNull);
      expect(Interference.label(1), 'Not at all');
      expect(Interference.label(0), isNull);
      expect(Interference.label(6), isNull);
    });
  });

  group('Symptom entries (real Isar)', () {
    late Isar isar;
    late ProviderContainer container;

    setUp(() async {
      isar = await _openIsar();
      container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
    });

    tearDown(() async {
      container.dispose();
      await isar.close(deleteFromDisk: true);
    });

    test('saves interference and impact verbatim', () async {
      final id = await container
          .read(symptomEntryListProvider.notifier)
          .add(
            profileId: 1,
            name: 'Joint pain',
            severity: 6,
            loggedAt: DateTime(2026, 9, 10),
            interference: 4,
            impact: "Couldn't open jars or grip the steering wheel",
          );
      final row = (await isar.symptomEntryIsars.get(id))!;
      expect(row.severity, 6);
      expect(row.interference, 4);
      expect(row.impact, "Couldn't open jars or grip the steering wheel");
    });

    test('name + intensity only still saves, with nothing guessed', () async {
      final id = await container
          .read(symptomEntryListProvider.notifier)
          .add(
            profileId: 1,
            name: 'Headache',
            severity: 4,
            loggedAt: DateTime(2026, 9, 10),
          );
      final row = (await isar.symptomEntryIsars.get(id))!;
      expect(row.interference, isNull);
      expect(row.impact, isNull);
    });

    test('low intensity with high interference is stored as given', () async {
      final id = await container
          .read(symptomEntryListProvider.notifier)
          .add(
            profileId: 1,
            name: 'Brain fog',
            severity: 3,
            loggedAt: DateTime(2026, 9, 10),
            interference: 5,
          );
      final row = (await isar.symptomEntryIsars.get(id))!;
      expect(row.severity, 3);
      expect(row.interference, 5);
    });

    test('move to another profile keeps interference and impact', () async {
      final notifier = container.read(symptomEntryListProvider.notifier);
      final id = await notifier.add(
        profileId: 1,
        name: 'Fatigue',
        severity: 5,
        loggedAt: DateTime(2026, 9, 10),
        interference: 3,
        impact: 'Cancelled dinner',
      );
      await notifier.moveToProfile(id, 2);
      final row = (await isar.symptomEntryIsars.get(id))!;
      expect(row.profileId, 2);
      expect(row.interference, 3);
      expect(row.impact, 'Cancelled dinner');
    });

    test('editing can clear interference and impact', () async {
      final e = _symptom(1, 'Fatigue', interference: 3, impact: 'x');
      final cleared = e.copyWith(clearInterference: true, clearImpact: true);
      expect(cleared.interference, isNull);
      expect(cleared.impact, isNull);
      expect(cleared.severity, e.severity);
    });

    test('sleep saves woke rested, null when not answered', () async {
      final notifier = container.read(sleepEntryListProvider.notifier);
      await notifier.add(
        profileId: 1,
        bedtime: DateTime(2026, 9, 9, 23),
        wakeTime: DateTime(2026, 9, 10, 7),
        qualityRating: 4,
        wokeRested: 1,
      );
      await notifier.add(
        profileId: 1,
        bedtime: DateTime(2026, 9, 10, 23),
        wakeTime: DateTime(2026, 9, 11, 7),
      );
      final rows = await isar.sleepEntryIsars.where().findAll();
      expect(rows.map((r) => r.wokeRested), [1, null]);
    });
  });

  group('CSV report', () {
    List<List<dynamic>> rows(ReportData d) =>
        Csv().decode(CsvReportService.generate(d));

    test('appends "Got in the way" and "Impact" after the old columns', () {
      final header = rows(_report()).first;
      expect(header, [
        'Date',
        'Type',
        'Name / Title',
        'Detail',
        'Notes',
        'Got in the way',
        'Impact',
      ]);
    });

    test('writes labels, leaves unrecorded interference empty', () {
      final r = rows(
        _report(
          symptoms: [
            _symptom(1, 'Fatigue', interference: 4, impact: 'Missed work'),
            _symptom(2, 'Headache'),
          ],
        ),
      );
      final fatigue = r.firstWhere((row) => row[2] == 'Fatigue');
      final headache = r.firstWhere((row) => row[2] == 'Headache');
      expect(fatigue[5], 'Quite a bit');
      expect(fatigue[6], 'Missed work');
      expect(headache[5], '');
      expect(headache[6], '');
      expect(fatigue[3], 'Severity 5/10', reason: 'existing column unchanged');
    });

    test('impact is formula-escaped like other free text (#108)', () {
      final r = rows(
        _report(symptoms: [_symptom(1, 'Fatigue', impact: '=1+1')]),
      );
      expect(r[1][6], "'=1+1");
    });

    test('sleep row carries woke rested next to quality', () {
      final r = rows(
        _report(
          sleep: [
            SleepEntry(
              id: 1,
              profileId: 1,
              bedtime: DateTime(2026, 9, 9, 23),
              wakeTime: DateTime(2026, 9, 10, 7),
              qualityRating: 4,
              wokeRested: 1,
              createdAt: DateTime(2026, 9, 10),
            ),
          ],
        ),
      );
      expect(r[1][3], 'Quality 4/5  ·  Woke rested: No');
    });
  });

  group('Credit and sources', () {
    test('credits Dr Cat Hicks and Informed Patient', () {
      expect(SymptomSources.credit, contains('Dr Cat Hicks'));
      expect(SymptomSources.credit, contains('Informed Patient'));
      expect(SymptomSources.credit, contains('CC BY 4.0'));
      expect(SymptomSources.informedPatient, contains('CC BY 4.0'));
    });

    test('lists the four verified PMIDs', () {
      expect(SymptomSources.all.map((s) => s.pmid), [
        '20685078',
        '11690728',
        '8616351',
        '22152166',
      ]);
    });

    test('never claims to administer or be endorsed by PROMIS', () {
      final text = [
        SymptomSources.credit,
        SymptomSources.promisNote,
        for (final s in SymptomSources.all) s.usedFor,
      ].join(' ').toLowerCase();
      expect(text, contains('informed by promis research'));
      expect(text, isNot(contains('uses promis')));
      expect(text, isNot(contains('promis-certified')));
      expect(text, contains('not promis questionnaires'));
    });
  });
}
