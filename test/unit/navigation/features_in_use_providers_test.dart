// Features in use (#142): which features are on for the active profile,
// what that hides, and what the app says. Pure rules and providers.
// Spec: docs/features/navigation-customization.feature.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/features/quick_log/quick_log_features.dart';
import 'package:health_flare/models/profile.dart';

class _Profiles extends ProfileListNotifier {
  _Profiles(this._p);
  final Profile _p;

  @override
  List<Profile> build() => [_p];
}

ProviderContainer _with({List<String> off = const [], bool flag = true}) {
  final sarah = Profile(id: 1, name: 'Sarah', disabledFeatureIds: off);
  final c = ProviderContainer(
    overrides: [
      featureFlagsProvider.overrideWithValue(FeatureFlags(trackAndCare: flag)),
      profileListProvider.overrideWith(() => _Profiles(sarah)),
      activeProfileDataProvider.overrideWith((ref) => sarah),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

List<String> _tabs(ProviderContainer c, String section) => [
  for (final t in c.read(visibleTabsProvider(section))) t.id,
];

List<String> _sections(ProviderContainer c) => [
  for (final s in c.read(visibleSectionsProvider)) s.id,
];

void main() {
  group('active profile', () {
    test('a feature turned off for the active profile is off', () {
      final c = _with(off: ['track.meals']);
      expect(c.read(featureOnProvider('track.meals')), isFalse);
      expect(c.read(featureOnProvider('track.sleep')), isTrue);
    });

    test('Symptoms and Conditions are always on', () {
      final c = _with(off: ['track.symptoms', 'care.conditions']);
      expect(c.read(featureOnProvider('track.symptoms')), isTrue);
      expect(c.read(featureOnProvider('care.conditions')), isTrue);
    });

    test('with Track and Care off, everything is on, whatever is stored', () {
      final c = _with(off: ['track.meals'], flag: false);
      expect(c.read(featureOnProvider('track.meals')), isTrue);
    });
  });

  group('Turning a feature off removes it from everyday use', () {
    test('its tab is not shown in its section', () {
      final c = _with(off: ['track.meals']);
      expect(_tabs(c, 'track'), [
        'track.symptoms',
        'track.vitals',
        'track.sleep',
        'track.activity',
      ]);
    });
  });

  group('A section with every tab turned off leaves the bar', () {
    test('Journal goes when Journal and Check-ins are both off', () {
      final c = _with(off: ['journal.entries', 'journal.checkins']);
      expect(_sections(c), ['dashboard', 'track', 'care']);
    });

    test('Journal stays while either is on', () {
      expect(_sections(_with(off: ['journal.entries'])), [
        'dashboard',
        'track',
        'care',
        'journal',
      ]);
    });

    test('Track and Care never go: Symptoms and Conditions are always on', () {
      final c = _with(
        off: [
          for (final id in [
            'track.vitals',
            'track.meals',
            'track.sleep',
            'track.activity',
            'care.medications',
            'care.appointments',
            'care.flares',
          ])
            id,
        ],
      );
      expect(_sections(c), ['dashboard', 'track', 'care', 'journal']);
      expect(_tabs(c, 'care'), ['care.conditions']);
    });
  });

  group('Turning a feature off keeps its data: what I am told', () {
    test('the scenario\'s wording', () {
      expect(
        featureKeptMessage(
          profileName: 'Sarah',
          featureId: 'track.meals',
          count: 40,
        ),
        "Sarah's 40 meals are kept. Turn Meals back on any time to see them.",
      );
    });

    test('one entry', () {
      expect(
        featureKeptMessage(
          profileName: 'Sarah',
          featureId: 'track.meals',
          count: 1,
        ),
        "Sarah's 1 meal is kept. Turn Meals back on any time to see it.",
      );
    });

    test('Turning off a feature with nothing logged', () {
      expect(
        featureKeptMessage(
          profileName: 'Sarah',
          featureId: 'track.meals',
          count: 0,
        ),
        'Meals is off for Sarah. Turn it back on any time.',
      );
    });

    test('every feature that can be turned off has words for its entries', () {
      for (final id in [
        'track.vitals',
        'track.meals',
        'track.sleep',
        'track.activity',
        'care.medications',
        'care.appointments',
        'care.flares',
        'journal.entries',
        'journal.checkins',
      ]) {
        expect(
          featureKeptMessage(profileName: 'Sarah', featureId: id, count: 2),
          startsWith("Sarah's 2 "),
          reason: id,
        );
      }
    });
  });

  group('Quick Log still logs a turned-off feature, and says so', () {
    test('each saved type belongs to its feature', () {
      expect(quickLogFeatureFor(QuickLogEntryType.meal), 'track.meals');
      expect(quickLogFeatureFor(QuickLogEntryType.vital), 'track.vitals');
      expect(quickLogFeatureFor(QuickLogEntryType.sleep), 'track.sleep');
      expect(quickLogFeatureFor(QuickLogEntryType.activity), 'track.activity');
      expect(
        quickLogFeatureFor(QuickLogEntryType.medication),
        'care.medications',
      );
      expect(
        quickLogFeatureFor(QuickLogEntryType.doctorVisit),
        'care.appointments',
      );
      expect(quickLogFeatureFor(QuickLogEntryType.flare), 'care.flares');
      expect(quickLogFeatureFor(QuickLogEntryType.journal), 'journal.entries');
      expect(quickLogFeatureFor(QuickLogEntryType.mood), 'journal.checkins');
      expect(quickLogFeatureFor(QuickLogEntryType.cycle), 'journal.checkins');
    });

    test('types that are always offered belong to no switch', () {
      expect(quickLogFeatureFor(QuickLogEntryType.symptom), isNull);
      expect(quickLogFeatureFor(QuickLogEntryType.condition), isNull);
      expect(quickLogFeatureFor(QuickLogEntryType.hydration), isNull);
      expect(quickLogFeatureFor(QuickLogEntryType.bowel), isNull);
    });

    test('the warning, word for word', () {
      expect(
        quickLogOffWarning(profileName: 'Sarah', featureId: 'track.meals'),
        'Meals is turned off for Sarah. This meal will be saved and shown in '
        'recent activity, but not in Track until Meals is back on.',
      );
    });
  });
}
