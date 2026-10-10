// Features in use (#137): stored per profile as what's turned off.
// Spec: docs/features/navigation-customization.feature.
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/models/profile.dart';

Profile _p(String name, {List<String> off = const []}) =>
    Profile(id: name.length, name: name, disabledFeatureIds: off);

void main() {
  group('Features in use is per profile', () {
    final sarah = _p('Sarah');
    final dad = _p('Dad', off: ['track.meals']);

    test('the Meals tab is still shown when "Sarah" is active', () {
      expect(featureInUse(sarah, 'track.meals'), isTrue);
    });

    test('and it is hidden when "Dad" is active', () {
      expect(featureInUse(dad, 'track.meals'), isFalse);
    });
  });

  group('A new tab in a later version lands in its section, switched on', () {
    final p = _p('Sarah', off: ['track.meals', 'care.flares']);

    test('a feature this profile has never seen is on', () {
      expect(featureInUse(p, 'track.water'), isTrue);
    });

    test('and my other feature switches are not changed', () {
      expect(featureInUse(p, 'track.meals'), isFalse);
      expect(featureInUse(p, 'care.flares'), isFalse);
      expect(p.disabledFeatureIds, ['track.meals', 'care.flares']);
    });
  });

  test('Symptoms and Conditions are always on, whatever is stored', () {
    final p = _p('Sarah', off: ['track.symptoms', 'care.conditions']);
    expect(featureInUse(p, 'track.symptoms'), isTrue);
    expect(featureInUse(p, 'care.conditions'), isTrue);
  });

  test('a profile starts with every feature on', () {
    expect(_p('New').disabledFeatureIds, isEmpty);
  });

  test('copyWith carries the switches and can change them', () {
    final p = _p('Sarah', off: ['track.meals']);
    expect(p.copyWith(name: 'S').disabledFeatureIds, ['track.meals']);
    expect(p.copyWith(disabledFeatureIds: []).disabledFeatureIds, isEmpty);
  });
}
