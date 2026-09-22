import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';

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
  group('QuickLogClassifier: full vital type coverage', () {
    test('classifies every documented vital type', () {
      const cases = {
        'HR 72': QuickLogEntryType.vital,
        'Blood pressure 128 over 84': QuickLogEntryType.vital,
        '74kg': QuickLogEntryType.vital,
        '157cm height': QuickLogEntryType.vital,
        'Temp 38.2°C': QuickLogEntryType.vital,
        'Oxygen sat 96%': QuickLogEntryType.vital,
        'Respiratory rate 16 br/min': QuickLogEntryType.vital,
        'Blood glucose 110 mg/dl': QuickLogEntryType.vital,
      };
      for (final entry in cases.entries) {
        expect(
          QuickLogClassifier.classify(entry.key),
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('respiratory rate is a Vital, never the Journal fallback', () {
      expect(
        QuickLogClassifier.classify('Respiratory rate 18 br/min'),
        QuickLogEntryType.vital,
      );
    });
  });

  group('QuickLogClassifier: condition detection', () {
    test('without any catalogue/tracked data, condition text is not '
        'misclassified as a Condition', () {
      expect(
        QuickLogClassifier.classify('Just found out I have fibromyalgia'),
        isNot(QuickLogEntryType.condition),
      );
    });

    test('a known catalogue condition suggests Condition', () {
      expect(
        QuickLogClassifier.classify(
          'Just found out I have fibromyalgia',
          conditionCatalog: [_condition(1, 'Fibromyalgia')],
        ),
        QuickLogEntryType.condition,
      );
    });

    test('a previously-created custom condition is recognised by acronym', () {
      expect(
        QuickLogClassifier.classify(
          'Rough ME day today',
          trackedConditions: [
            _trackedCondition(9, 'Myalgic encephalomyelitis'),
          ],
        ),
        QuickLogEntryType.condition,
      );
    });

    test('free text describing only symptoms is not misclassified as '
        'Condition', () {
      expect(
        QuickLogClassifier.classify(
          'Knees and wrists both swollen again',
          conditionCatalog: [_condition(1, 'Fibromyalgia')],
        ),
        QuickLogEntryType.symptom,
      );
    });

    test('generic diagnosis-status language suggests Condition with no '
        'catalogue or tracked match needed', () {
      const cases = [
        'Just got diagnosed with something new today',
        'Got my official diagnosis this afternoon, finally',
        'Officially in remission as of this week',
        'Had a relapse after months of feeling fine',
      ];
      for (final text in cases) {
        expect(
          QuickLogClassifier.classify(text),
          QuickLogEntryType.condition,
          reason: text,
        );
      }
    });

    test('medication keywords still take priority over a condition name '
        'match', () {
      expect(
        QuickLogClassifier.classify(
          'Took 400mg ibuprofen for my fibromyalgia',
          conditionCatalog: [_condition(1, 'Fibromyalgia')],
        ),
        QuickLogEntryType.medication,
      );
    });
  });

  group('QuickLogClassifier: catalogue/user-aware symptom detection', () {
    test('a catalogue symptom outside the generic word list is recognised', () {
      expect(
        QuickLogClassifier.classify(
          'Photophobia again this afternoon',
          symptomCatalog: [_symptom(1, 'Photophobia')],
        ),
        QuickLogEntryType.symptom,
      );
    });

    test('a previously-created custom symptom is recognised on later '
        'mentions', () {
      expect(
        QuickLogClassifier.classify(
          'Brain fog again, hard to focus',
          trackedSymptoms: [_trackedSymptom(4, 'Brain fog')],
        ),
        QuickLogEntryType.symptom,
      );
    });

    test('a brand-new custom symptom with no catalogue/history/keyword '
        'match is not guaranteed a chip', () {
      expect(
        QuickLogClassifier.classify('Pins and needles in feet'),
        isNot(QuickLogEntryType.symptom),
      );
    });

    // Regression: a symptom logged only via the standalone symptom entry
    // form (no UserSymptom record: see recentSymptomNamesProvider) must
    // still be recognised on a later Quick Log mention.
    test('a symptom logged only via the full entry form (no UserSymptom '
        'record) is recognised on later mentions', () {
      expect(
        QuickLogClassifier.classify(
          'Brain Fog again',
          loggedSymptomNames: const ['Brain fog'],
        ),
        QuickLogEntryType.symptom,
      );
    });
  });
}
