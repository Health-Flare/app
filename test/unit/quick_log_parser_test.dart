import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';
import 'package:health_flare/models/vital_type.dart';

Medication _med(int id, String name) => Medication(
  id: id,
  profileId: 1,
  name: name,
  medicationType: 'medication',
  doseAmount: 400,
  doseUnit: 'mg',
  frequency: 'asNeeded',
  startDate: DateTime(2026),
  createdAt: DateTime(2026),
);

Condition _condition(int id, String name, {bool global = true}) =>
    Condition(id: id, name: name, global: global);

Symptom _symptom(int id, String name, {bool global = true}) =>
    Symptom(id: id, name: name, global: global);

UserCondition _trackedCondition(int conditionId, String name) => UserCondition(
  id: conditionId,
  profileId: 1,
  conditionId: conditionId,
  conditionName: name,
  trackedSince: DateTime(2026),
);

UserSymptom _trackedSymptom(int symptomId, String name) => UserSymptom(
  id: symptomId,
  profileId: 1,
  symptomId: symptomId,
  symptomName: name,
  trackedSince: DateTime(2026),
);

void main() {
  group('QuickLogParser.parseVital', () {
    test('parses blood pressure with a slash', () {
      final v = QuickLogParser.parseVital('BP 128/84 this morning')!;
      expect(v.vitalType, VitalType.bloodPressure);
      expect(v.value, 128);
      expect(v.value2, 84);
      expect(v.unit, 'mmHg');
    });

    test('parses blood pressure written as "over"', () {
      final v = QuickLogParser.parseVital(
        'Blood pressure was 128 over 84 this morning',
      )!;
      expect(v.vitalType, VitalType.bloodPressure);
      expect(v.value, 128);
      expect(v.value2, 84);
    });

    test('rejects date-like slash values as blood pressure', () {
      final v = QuickLogParser.parseVital('Appointment on 12/06 went fine');
      expect(v, isNull);
    });

    test('parses heart rate in BPM', () {
      final v = QuickLogParser.parseVital('Resting heart rate 72 bpm')!;
      expect(v.vitalType, VitalType.heartRate);
      expect(v.value, 72);
      expect(v.unit, 'BPM');
    });

    test('parses pulse/heart rate with no explicit bpm unit', () {
      expect(QuickLogParser.parseVital('HR 72')!.value, 72);
      expect(
        QuickLogParser.parseVital('HR 72')!.vitalType,
        VitalType.heartRate,
      );
      expect(QuickLogParser.parseVital('Pulse 72 today')!.value, 72);
      expect(QuickLogParser.parseVital('Pulse was 72 this morning')!.value, 72);
      expect(QuickLogParser.parseVital('72 beats per minute')!.value, 72);
    });

    test('does not read a duration like "2 hr walk" as a heart rate', () {
      expect(
        QuickLogParser.parseHeartRate('walked for 2 hr this morning'),
        isNull,
      );
    });

    test('parses temperature in celsius', () {
      final v = QuickLogParser.parseVital('Temp was 37.8°C tonight')!;
      expect(v.vitalType, VitalType.temperature);
      expect(v.value, 37.8);
      expect(v.unit, '°C');
    });

    test('infers fahrenheit from an implausible celsius value', () {
      final v = QuickLogParser.parseVital('Fever of 101 degrees')!;
      expect(v.vitalType, VitalType.temperature);
      expect(v.unit, '°F');
    });

    test('parses oxygen saturation percentage', () {
      final v = QuickLogParser.parseVital('SpO2 down to 94% after stairs')!;
      expect(v.vitalType, VitalType.oxygenSaturation);
      expect(v.value, 94);
      expect(v.unit, '%');
    });

    test('parses respiratory rate', () {
      final v = QuickLogParser.parseVital('Respiratory rate 18 br/min')!;
      expect(v.vitalType, VitalType.respiratoryRate);
      expect(v.value, 18);
      expect(v.unit, 'br/min');
    });

    test('parses blood glucose in mmol', () {
      final v = QuickLogParser.parseVital('Glucose 5.4 mmol before lunch')!;
      expect(v.vitalType, VitalType.bloodGlucose);
      expect(v.value, 5.4);
      expect(v.unit, 'mmol/L');
    });

    test('parses blood glucose in mg/dL', () {
      final v = QuickLogParser.parseVital('Reading was 98 mg/dl')!;
      expect(v.vitalType, VitalType.bloodGlucose);
      expect(v.value, 98);
      expect(v.unit, 'mg/dL');
    });

    test('parses weight in kg and lbs', () {
      final kg = QuickLogParser.parseVital('Weighed in at 65 kg')!;
      expect(kg.vitalType, VitalType.weight);
      expect(kg.unit, 'kg');

      final lbs = QuickLogParser.parseVital('Weighed in at 143 lbs')!;
      expect(lbs.vitalType, VitalType.weight);
      expect(lbs.unit, 'lbs');
    });

    test('parses height in centimetres', () {
      final v = QuickLogParser.parseVital('157cm height')!;
      expect(v.vitalType, VitalType.height);
      expect(v.value, 157);
      expect(v.unit, 'cm');
    });

    test('parses height written as feet and inches', () {
      final quoted = QuickLogParser.parseVital('4\'8" tall')!;
      expect(quoted.vitalType, VitalType.height);
      expect(quoted.value, 56);
      expect(quoted.unit, 'in');

      final unquoted = QuickLogParser.parseVital("I'm 5'4 these days")!;
      expect(unquoted.vitalType, VitalType.height);
      expect(unquoted.value, 64);
      expect(unquoted.unit, 'in');
    });

    test('parses a short weight-only entry with no other words', () {
      final v = QuickLogParser.parseVital('74kg')!;
      expect(v.vitalType, VitalType.weight);
      expect(v.value, 74);
      expect(v.unit, 'kg');
    });

    test('parses a short height-only entry with no other words', () {
      final v = QuickLogParser.parseVital('144cm')!;
      expect(v.vitalType, VitalType.height);
      expect(v.value, 144);
      expect(v.unit, 'cm');
    });

    test('rejects implausible height values', () {
      expect(QuickLogParser.parseVital('900cm'), isNull);
    });

    test('returns null when no value can be extracted', () {
      expect(QuickLogParser.parseVital('Feeling faint and shaky'), isNull);
      expect(QuickLogParser.parseVital('Checked my blood pressure'), isNull);
    });
  });

  group('QuickLogParser.parseVitals', () {
    test('returns both readings for a combined BP + pulse entry', () {
      final vitals = QuickLogParser.parseVitals('BP 118/76, pulse 68bpm');
      expect(vitals, hasLength(2));
      expect(vitals[0].vitalType, VitalType.bloodPressure);
      expect(vitals[0].value, 118);
      expect(vitals[0].value2, 76);
      expect(vitals[1].vitalType, VitalType.heartRate);
      expect(vitals[1].value, 68);
    });

    test('returns a single reading when only one vital is present', () {
      final vitals = QuickLogParser.parseVitals('157cm height');
      expect(vitals, hasLength(1));
      expect(vitals.single.vitalType, VitalType.height);
    });

    test('returns an empty list when nothing can be extracted', () {
      expect(QuickLogParser.parseVitals('Feeling faint and shaky'), isEmpty);
    });
  });

  group('QuickLogParser.parseBloodPressure', () {
    test('rejects unbounded fractions and typed dates', () {
      expect(
        QuickLogParser.parseBloodPressure('Ate 3/4 of a sandwich'),
        isNull,
      );
      expect(QuickLogParser.parseBloodPressure('chapter 5/10'), isNull);
      expect(QuickLogParser.parseBloodPressure('Appointment on 9/17'), isNull);
    });

    test('accepts a plausible reading written with a slash or "over"', () {
      expect(QuickLogParser.parseBloodPressure('128/84'), (128.0, 84.0));
      expect(QuickLogParser.parseBloodPressure('128 over 84'), (128.0, 84.0));
    });
  });

  group('QuickLogParser.parseSleepDuration', () {
    test('parses whole hours', () {
      expect(
        QuickLogParser.parseSleepDuration(
          'Slept for 6 hours last night, woke up twice',
        ),
        const Duration(hours: 6),
      );
    });

    test('parses fractional hours and short forms', () {
      expect(
        QuickLogParser.parseSleepDuration('About 7.5 hrs of sleep'),
        const Duration(minutes: 450),
      );
      expect(
        QuickLogParser.parseSleepDuration('Managed 8h somehow'),
        const Duration(hours: 8),
      );
    });

    test('returns null without a duration or for implausible values', () {
      expect(
        QuickLogParser.parseSleepDuration('Terrible night, kept waking up'),
        isNull,
      );
      expect(QuickLogParser.parseSleepDuration('Slept 30 hours'), isNull);
    });
  });

  group('QuickLogParser.matchMedication', () {
    test('matches a medication name case-insensitively', () {
      final meds = [_med(1, 'Ibuprofen'), _med(2, 'Methotrexate')];
      final match = QuickLogParser.matchMedication(
        'Took ibuprofen after lunch',
        meds,
      );
      expect(match?.id, 1);
    });

    test('prefers the longest matching name', () {
      final meds = [_med(1, 'Methotrexate'), _med(2, 'Methotrexate injection')];
      final match = QuickLogParser.matchMedication(
        'Did the methotrexate injection tonight',
        meds,
      );
      expect(match?.id, 2);
    });

    test('returns null when nothing matches or names are too short', () {
      final meds = [_med(1, 'Ibuprofen'), _med(2, 'B12')];
      expect(
        QuickLogParser.matchMedication('Took something for the pain', meds),
        isNull,
      );
    });
  });

  group('QuickLogParser.matchCondition', () {
    test('matches a global catalogue condition case-insensitively', () {
      final catalog = [_condition(1, 'Fibromyalgia')];
      final match = QuickLogParser.matchCondition(
        'Just found out I have fibromyalgia',
        catalog,
        const [],
      );
      expect(match?.id, 1);
    });

    test('excludes another profile\'s custom (non-global) catalogue entry', () {
      final catalog = [
        _condition(1, 'Some other custom condition', global: false),
      ];
      final match = QuickLogParser.matchCondition(
        'Dealing with some other custom condition today',
        catalog,
        const [],
      );
      expect(match, isNull);
    });

    test('matches the active profile\'s own tracked custom condition', () {
      final tracked = [_trackedCondition(9, 'Myalgic encephalomyelitis')];
      final match = QuickLogParser.matchCondition(
        'Rough ME day today',
        const [],
        tracked,
      );
      expect(match?.id, 9);
      expect(match?.name, 'Myalgic encephalomyelitis');
    });

    test('prefers the longest matching name', () {
      final catalog = [
        _condition(1, 'Arthritis'),
        _condition(2, 'Rheumatoid Arthritis'),
      ];
      final match = QuickLogParser.matchCondition(
        'Flare of my rheumatoid arthritis today',
        catalog,
        const [],
      );
      expect(match?.id, 2);
    });

    test('returns null when the text names no known condition', () {
      final catalog = [_condition(1, 'Fibromyalgia')];
      final match = QuickLogParser.matchCondition(
        'Knees and wrists both swollen again',
        catalog,
        const [],
      );
      expect(match, isNull);
    });
  });

  group('QuickLogParser.matchSymptom', () {
    test('matches a global catalogue symptom not in the generic word list', () {
      final catalog = [_symptom(1, 'Photophobia')];
      final match = QuickLogParser.matchSymptom(
        'Photophobia again this afternoon',
        catalog,
        const [],
      );
      expect(match?.id, 1);
    });

    test('matches the active profile\'s own previously-created symptom', () {
      final tracked = [_trackedSymptom(4, 'Brain fog')];
      final match = QuickLogParser.matchSymptom(
        'Brain fog again, hard to focus',
        const [],
        tracked,
      );
      expect(match?.id, 4);
    });

    test(
      'returns null for a brand-new symptom with no catalogue or history match',
      () {
        final match = QuickLogParser.matchSymptom(
          'Pins and needles in feet',
          const [],
          const [],
        );
        expect(match, isNull);
      },
    );

    // Regression: symptoms typed into the standalone symptom entry form
    // (the everyday path) only ever create a SymptomEntry.name string — no
    // UserSymptom record — so a real user's "Brain fog" went undetected on
    // every later Quick Log mention until loggedNames was added.
    test('matches a symptom that was only ever typed into the full entry form '
        '(no UserSymptom record — logged name only)', () {
      final match = QuickLogParser.matchSymptom(
        'Brain fog again, hard to focus',
        const [],
        const [],
        loggedNames: const ['Brain fog'],
      );
      expect(match?.name, 'Brain fog');
    });

    test('prefers the longest match across catalogue, tracked, and logged '
        'names combined', () {
      final match = QuickLogParser.matchSymptom(
        'Chronic brain fog again today',
        [_symptom(1, 'Brain fog')],
        const [],
        loggedNames: const ['Chronic brain fog'],
      );
      expect(match?.name, 'Chronic brain fog');
    });
  });

  group('QuickLogParser.parseSeverity', () {
    test('parses an explicit "x/10" scale', () {
      expect(QuickLogParser.parseSeverity('Joint pain 8/10 today'), 8);
      expect(QuickLogParser.parseSeverity('Pain was 6 out of 10'), 6);
    });

    test('parses "severity"/"pain level" phrasing', () {
      expect(QuickLogParser.parseSeverity('Severity 7 this morning'), 7);
      expect(QuickLogParser.parseSeverity('Pain level 9'), 9);
    });

    test('maps qualitative words to representative points on the scale', () {
      expect(QuickLogParser.parseSeverity('Mild headache today'), 3);
      expect(QuickLogParser.parseSeverity('Moderate cramping'), 5);
      expect(QuickLogParser.parseSeverity('Severe migraine all day'), 7);
      expect(QuickLogParser.parseSeverity('Excruciating, unbearable pain'), 9);
    });

    test('ignores an out-of-range numeric scale', () {
      expect(QuickLogParser.parseSeverity('Pain level 15'), isNull);
    });

    test('returns null when nothing can be inferred', () {
      expect(
        QuickLogParser.parseSeverity('Knees and wrists both swollen again'),
        isNull,
      );
    });

    test('does not false-positive on unrelated numbers near "pain"', () {
      expect(QuickLogParser.parseSeverity('Pain for 6 days now'), isNull);
    });
  });

  group('QuickLogParser.mentionsNewDiagnosis', () {
    test('recognises "diagnosed"/"diagnosis"/"found out"', () {
      expect(
        QuickLogParser.mentionsNewDiagnosis('Just got diagnosed today'),
        isTrue,
      );
      expect(
        QuickLogParser.mentionsNewDiagnosis('Got the diagnosis this week'),
        isTrue,
      );
      expect(
        QuickLogParser.mentionsNewDiagnosis('Just found out I have it'),
        isTrue,
      );
    });

    test('a bare mention of a condition is not a fresh diagnosis', () {
      expect(
        QuickLogParser.mentionsNewDiagnosis('Fibromyalgia flare again today'),
        isFalse,
      );
    });
  });

  group('QuickLogParser.parseConditionStatus', () {
    test('recognises remission and relapse language', () {
      expect(
        QuickLogParser.parseConditionStatus('Officially in remission now'),
        ConditionStatus.inRecovery,
      );
      expect(
        QuickLogParser.parseConditionStatus('Had a relapse this week'),
        ConditionStatus.active,
      );
    });

    test('returns null with no status language', () {
      expect(
        QuickLogParser.parseConditionStatus('Rough fibromyalgia day today'),
        isNull,
      );
    });
  });

  group('QuickLogParser.textMentionsName', () {
    test('never matches a name shorter than 3 characters', () {
      expect(QuickLogParser.textMentionsName('I saw ME today', 'ME'), isFalse);
    });

    test('does not crash on a parenthesised name (regex metacharacters '
        'in a would-be acronym)', () {
      // "Lupus (SLE)" would naively acronym to "L(" — an invalid, unescaped
      // regex that throws FormatException on every call, not just one that
      // matches "Lupus (SLE)".
      expect(
        () => QuickLogParser.textMentionsName(
          'Rough day today, feeling awful',
          'Lupus (SLE)',
        ),
        returnsNormally,
      );
    });

    test('matches a multi-word acronym only in uppercase', () {
      expect(
        QuickLogParser.textMentionsName(
          'Rough ME day',
          'Myalgic Encephalomyelitis',
        ),
        isTrue,
      );
      expect(
        QuickLogParser.textMentionsName(
          'let me think about it',
          'Myalgic Encephalomyelitis',
        ),
        isFalse,
      );
    });
  });
}
