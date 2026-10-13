// #160: screens watching the active profile are told when its settings
// change. Profile == compared ids only, and Riverpod 3 drops an update
// that == the old value, so a changed unit never reached them.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/profile.dart';

class _Profiles extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];

  void replace(Profile p) => state = [
    for (final q in state)
      if (q.id == p.id) p else q,
  ];
}

class _Active extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

void main() {
  group('Profile ==', () {
    final sarah = Profile(
      id: 1,
      name: 'Sarah',
      dateOfBirth: DateTime(1990, 5, 4),
      colorSeed: 3,
      temperatureUnit: '°C',
      disabledFeatureIds: const ['track.meals'],
    );

    test('equal when every field is', () {
      final same = sarah.copyWith();
      expect(same, sarah);
      expect(same.hashCode, sarah.hashCode);
      expect(
        Profile(id: 1, name: 'Sarah', disabledFeatureIds: ['a']),
        Profile(id: 1, name: 'Sarah', disabledFeatureIds: ['a']),
        reason: 'lists compare by contents',
      );
    });

    final changes = <String, Profile>{
      'name': sarah.copyWith(name: 'Sarah Chen'),
      'dateOfBirth': sarah.copyWith(clearDateOfBirth: true),
      'avatarPath': sarah.copyWith(avatarPath: '/a.jpg'),
      'weatherTrackingEnabled': sarah.copyWith(weatherTrackingEnabled: true),
      'colorSeed': sarah.copyWith(colorSeed: 4),
      'cycleTrackingEnabled': sarah.copyWith(cycleTrackingEnabled: true),
      'bowelTrackingEnabled': sarah.copyWith(bowelTrackingEnabled: true),
      'temperatureUnit': sarah.copyWith(temperatureUnit: '°F'),
      'disabledFeatureIds': sarah.copyWith(disabledFeatureIds: const []),
    };
    for (final MapEntry(:key, :value) in changes.entries) {
      test('not equal when $key differs', () {
        expect(value == sarah, isFalse);
      });
    }

    test('different profiles are never equal', () {
      expect(Profile(id: 1, name: 'A') == Profile(id: 2, name: 'A'), isFalse);
    });
  });

  test('watchers of the active profile hear about a changed setting', () {
    final c = ProviderContainer(
      overrides: [
        profileListProvider.overrideWith(_Profiles.new),
        activeProfileProvider.overrideWith(_Active.new),
      ],
    );
    addTearDown(c.dispose);
    final seen = <String?>[];
    c.listen(
      activeProfileDataProvider,
      (_, p) => seen.add(p?.temperatureUnit),
      fireImmediately: true,
    );

    (c.read(profileListProvider.notifier) as _Profiles).replace(
      Profile(id: 1, name: 'Sarah', temperatureUnit: '°F'),
    );
    c.read(activeProfileDataProvider);

    expect(seen, [null, '°F']);
  });
}
