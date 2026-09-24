import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/vital_type.dart';

void main() {
  group('word boundaries', () {
    const notMeal = [
      'Running late for work today',
      'So grateful for my sister today',
      'Feeling irritated and exhausted today',
      'Updated my notes on the app',
      'Water retention in my ankles again',
      'Had a date night with my partner',
    ];
    for (final text in notMeal) {
      test('"$text" is not a meal', () {
        expect(
          QuickLogClassifier.classify(text),
          isNot(QuickLogEntryType.meal),
        );
      });
    }

    test('pilates is activity, not a meal', () {
      expect(
        QuickLogClassifier.classify('Pilates class this morning'),
        QuickLogEntryType.activity,
      );
    });

    test('snap is not sleep and spilled/mistaken are not medication', () {
      expect(
        QuickLogClassifier.classify('Heard a snap in my knee'),
        isNot(QuickLogEntryType.sleep),
      );
      expect(
        QuickLogClassifier.classify('Spilled coffee all over my desk'),
        isNot(QuickLogEntryType.medication),
      );
      expect(
        QuickLogClassifier.classify('I was mistaken about the dosage times'),
        isNot(QuickLogEntryType.medication),
      );
    });

    test('interested and retired are not activity or symptom', () {
      expect(
        QuickLogClassifier.classify('Not interested in going out tonight'),
        isNot(QuickLogEntryType.activity),
      );
      expect(
        QuickLogClassifier.classify('Recently retired and adjusting well'),
        isNot(QuickLogEntryType.symptom),
      );
    });

    test('inflections still match', () {
      expect(
        QuickLogClassifier.classify('Headaches all week long'),
        QuickLogEntryType.symptom,
      );
      expect(
        QuickLogClassifier.classify('Knees aches after the stairs'),
        QuickLogEntryType.symptom,
      );
      expect(
        QuickLogClassifier.classify('Swallowed two paracetamol tablets'),
        QuickLogEntryType.medication,
      );
    });
  });

  group('scored routing', () {
    final cases = {
      'Took a walk around the park': QuickLogEntryType.activity,
      'Took the dog out this morning': QuickLogEntryType.journal,
      'Did my physio exercises this morning': QuickLogEntryType.activity,
      'Headache after skipping breakfast': QuickLogEntryType.symptom,
      'Bad stomach cramp after eating': QuickLogEntryType.symptom,
      'Consultant said I am in remission': QuickLogEntryType.condition,
      'Saw Dr Patel, upped my methotrexate': QuickLogEntryType.doctorVisit,
      'Took 400mg ibuprofen at noon': QuickLogEntryType.medication,
      'Had grilled salmon with rice for dinner': QuickLogEntryType.meal,
      'Took my 10mg prednisolone with breakfast': QuickLogEntryType.medication,
      'Tired after eating the pasta today': QuickLogEntryType.meal,
      'Slept badly after dinner last night': QuickLogEntryType.sleep,
    };
    for (final entry in cases.entries) {
      test(entry.key, () {
        expect(QuickLogClassifier.classify(entry.key), entry.value);
      });
    }

    test('remission at an appointment is a condition', () {
      expect(
        QuickLogClassifier.classify('Remission confirmed at my appointment'),
        QuickLogEntryType.condition,
      );
    });
  });

  group('weight and height', () {
    test('stone and pounds is the full weight in lbs', () {
      final vital = QuickLogParser.parseVital('Weight 11st 4lb');
      expect(vital?.vitalType, VitalType.weight);
      expect(vital?.value, 158);
      expect(vital?.unit, 'lbs');
    });

    test('a weight change is not a reading', () {
      expect(QuickLogParser.parseVital('Lost 2kg since last week'), isNull);
      expect(QuickLogParser.parseVital('Gained 3 lbs over the month'), isNull);
      expect(
        QuickLogClassifier.classify('Lost 2kg since last week'),
        isNot(QuickLogEntryType.vital),
      );
    });

    test('feet and inches written out is a vital', () {
      final vital = QuickLogParser.parseVital('5 ft 7 in');
      expect(vital?.vitalType, VitalType.height);
      expect(vital?.unit, 'in');
      expect(vital?.value, 67);
      expect(QuickLogClassifier.classify('5 ft 7 in'), QuickLogEntryType.vital);
    });
  });

  group('dose status', () {
    test('missed and skipped', () {
      expect(
        QuickLogParser.parseDoseStatus('Missed my methotrexate this morning'),
        'missed',
      );
      expect(
        QuickLogParser.parseDoseStatus('Forgot to take my methotrexate'),
        'missed',
      );
      expect(
        QuickLogParser.parseDoseStatus('Skipped my methotrexate tonight'),
        'skipped',
      );
      expect(
        QuickLogParser.parseDoseStatus('Took ibuprofen after lunch'),
        isNull,
      );
    });

    test('a dose change is not a dose', () {
      expect(
        QuickLogParser.isDoseChange('Doctor increased my methotrexate dose'),
        isTrue,
      );
    });
  });

  group('relative time', () {
    final now = DateTime(2026, 9, 23, 18);
    test('yesterday keeps the clock time', () {
      expect(
        QuickLogParser.parseRelativeTimestamp(
          'Yesterday my knees were very swollen',
          now,
        ),
        DateTime(2026, 9, 22, 18),
      );
    });

    test('this morning is 09:00', () {
      expect(
        QuickLogParser.parseRelativeTimestamp(
          'This morning pain was 6/10',
          now,
        ),
        DateTime(2026, 9, 23, 9),
      );
    });

    test('last night is preserved for sleep', () {
      expect(
        QuickLogParser.parseRelativeTimestamp(
          'Last night I slept 5 hours',
          now,
          preserveLastNight: true,
        ),
        isNull,
      );
    });

    test('next Tuesday defaults to 09:00', () {
      expect(
        QuickLogParser.parseRelativeTimestamp(
          'Appointment with Dr Lee next Tuesday',
          now,
        ),
        DateTime(2026, 9, 29, 9),
      );
    });

    test('tomorrow at 9', () {
      expect(
        QuickLogParser.parseRelativeTimestamp(
          'Blood test at the hospital tomorrow at 9',
          now,
        ),
        DateTime(2026, 9, 24, 9),
      );
    });
  });

  group('new extractors', () {
    test('activity type duration and effort', () {
      final walked = QuickLogParser.parseActivity(
        'Walked the dog for 30 minutes',
      );
      expect(walked.type, ActivityType.walking);
      expect(walked.durationMinutes, 30);

      final yoga = QuickLogParser.parseActivity('Did 15 minutes of yoga');
      expect(yoga.type, ActivityType.gentleExercise);
      expect(yoga.durationMinutes, 15);

      final garden = QuickLogParser.parseActivity('Spent an hour gardening');
      expect(garden.type, ActivityType.household);
      expect(garden.durationMinutes, 60);

      final rest = QuickLogParser.parseActivity('Rest day, stayed on the sofa');
      expect(rest.type, ActivityType.rest);
      expect(rest.durationMinutes, isNull);

      expect(
        QuickLogParser.parseActivity(
          'Walked 20 minutes, felt really hard going',
        ).effortLevel,
        4,
      );
    });

    test('naps parse minutes and are marked naps', () {
      expect(QuickLogParser.isNap('Had a 20 minute nap after lunch'), isTrue);
      expect(
        QuickLogParser.parseSleepDuration('Had a 20 minute nap after lunch'),
        const Duration(minutes: 20),
      );
      expect(
        QuickLogParser.parseSleepDuration('Napped for 2 hours this afternoon'),
        const Duration(hours: 2),
      );
      expect(QuickLogParser.isNap('Slept 7 hours last night'), isFalse);
    });

    test('meal reactions respect negation', () {
      expect(
        QuickLogParser.hasMealReaction('Pizza for dinner, felt bloated after'),
        isTrue,
      );
      expect(
        QuickLogParser.hasMealReaction(
          'Pasta for dinner, no reaction this time',
        ),
        isFalse,
      );
    });

    test('peak flow and steps', () {
      final peak = QuickLogParser.parseVital('Peak flow 420 this morning');
      expect(peak?.vitalType, VitalType.peakFlow);
      expect(peak?.value, 420);
      final steps = QuickLogParser.parseVital('12,500 steps');
      expect(steps?.vitalType, VitalType.steps);
      expect(steps?.value, 12500);
    });

    test('fluids', () {
      expect(
        QuickLogParser.parseFluid('500ml electrolyte drink')?.volumeMl,
        500,
      );
      expect(
        QuickLogParser.parseFluid('Drank two litres of water today')?.volumeMl,
        2000,
      );
      expect(
        QuickLogParser.parseFluid('Only had 3 glasses of water')?.volumeMl,
        750,
      );
      expect(
        QuickLogClassifier.classify('Coffee and toast for breakfast'),
        QuickLogEntryType.meal,
      );
      expect(
        QuickLogClassifier.classify('Drank two litres of water today'),
        QuickLogEntryType.hydration,
      );
      expect(
        QuickLogParser.parseFluid('Peak flow was 420 L/min this morning'),
        isNull,
      );
      expect(
        QuickLogParser.parseVital(
          'Peak flow was 420 L/min this morning',
        )?.value,
        420,
      );
    });

    test('mood does not guess a score and cycle needs the opt-in', () {
      expect(
        QuickLogParser.parseExplicitWellbeing('Feeling really low and anxious'),
        isNull,
      );
      expect(QuickLogParser.parseExplicitWellbeing('Wellbeing about 6/10'), 6);
      expect(
        QuickLogParser.parseStress('Wellbeing about 6/10, bit stressed'),
        'medium',
      );
      expect(
        QuickLogClassifier.classify('Period started this morning'),
        isNot(QuickLogEntryType.cycle),
      );
      expect(
        QuickLogClassifier.classify(
          'Period started this morning',
          cycleTrackingEnabled: true,
        ),
        QuickLogEntryType.cycle,
      );
      expect(QuickLogParser.parseCyclePhase('a period of rest'), isNull);
    });

    test('bowel is opt-in and locations are canonical', () {
      expect(
        QuickLogClassifier.classify('Loose stools again this morning'),
        isNot(QuickLogEntryType.bowel),
      );
      expect(
        QuickLogClassifier.classify(
          'Loose stools again this morning',
          bowelTrackingEnabled: true,
        ),
        QuickLogEntryType.bowel,
      );
      final parsed = QuickLogParser.parseElimination(
        'Bristol type 6 twice today',
      );
      expect(parsed?.bristolType, 6);
      expect(parsed?.count, 2);
      expect(
        QuickLogParser.parseElimination('Blood in stool this morning')?.blood,
        isTrue,
      );
      expect(
        QuickLogParser.parseLocations(
          'Bad flare today, knees and wrists both swollen',
        ),
        ['knees', 'wrists'],
      );
      expect(QuickLogParser.parseLocations('Pain level 8 in my lower back'), [
        'lower back',
      ]);
      expect(
        QuickLogParser.parseLocations('Left hip aching after the stairs'),
        ['left hip'],
      );
      expect(QuickLogParser.parseLocations('Stiff fingers this morning'), [
        'hands',
      ]);
      expect(
        QuickLogParser.parseLocations('Fatigue really bad today'),
        isEmpty,
      );
    });

    test('flare start beats a bare flare mention', () {
      expect(
        QuickLogClassifier.classify('Flare started today in my hands'),
        QuickLogEntryType.flare,
      );
      expect(
        QuickLogClassifier.classify('Knees swollen and sore'),
        QuickLogEntryType.symptom,
      );
      expect(
        QuickLogClassifier.classify(
          'Lupus flare kicking off again',
          conditionCatalog: [const Condition(id: 1, name: 'Lupus')],
        ),
        QuickLogEntryType.flare,
      );
      expect(
        QuickLogParser.parseFlareIntent(
          'Flare finally settling down, feels over',
        ),
        FlareIntent.end,
      );
    });

    test('negated symptoms fall through', () {
      expect(
        QuickLogClassifier.classify('No pain today at all'),
        isNot(QuickLogEntryType.symptom),
      );
      expect(
        QuickLogClassifier.classify('No headache but knees are sore'),
        QuickLogEntryType.symptom,
      );
    });
  });
}
