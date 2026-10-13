// #173: which flare an entry is part of, worked out from its time.
// Spec: docs/features/flare.feature, "Which flare an entry is part of".
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/flare_membership.dart';

Flare _flare(int id, DateTime start, [DateTime? end, int profileId = 1]) =>
    Flare(
      id: id,
      profileId: profileId,
      startedAt: start,
      endedAt: end,
      createdAt: start,
    );

void main() {
  final march3 = DateTime(2026, 3, 3, 9);
  final march10 = DateTime(2026, 3, 10, 18);
  final past = _flare(1, march3, march10);
  final active = _flare(2, DateTime(2026, 4, 1, 14));
  final flares = [past, active];

  int? at(
    DateTime t, {
    int profileId = 1,
    int? pinned,
    bool detached = false,
  }) => flareFor(
    at: t,
    profileId: profileId,
    flares: flares,
    pinnedFlareId: pinned,
    detached: detached,
  );

  group('flareFor', () {
    test('an entry during a past flare is part of it', () {
      expect(at(DateTime(2026, 3, 5)), 1);
    });

    test('start and end are included', () {
      expect(at(march3), 1);
      expect(at(march10), 1);
    });

    test('just outside is not', () {
      expect(at(march3.subtract(const Duration(minutes: 1))), isNull);
      expect(at(march10.add(const Duration(minutes: 1))), isNull);
    });

    test('an active flare covers everything after its start', () {
      expect(at(DateTime(2026, 4, 1, 14)), 2);
      expect(at(DateTime(2027, 1, 1)), 2);
    });

    test('earlier the day an active flare started is not part of it', () {
      expect(at(DateTime(2026, 4, 1, 9)), isNull);
    });

    test("another profile's flare never counts", () {
      expect(at(DateTime(2026, 3, 5), profileId: 2), isNull);
    });

    test('when two flares cover it, the one that started last', () {
      final overlapping = [
        _flare(1, DateTime(2026, 3, 1), DateTime(2026, 3, 20)),
        _flare(3, DateTime(2026, 3, 10), DateTime(2026, 3, 12)),
      ];
      expect(
        flareFor(at: DateTime(2026, 3, 11), profileId: 1, flares: overlapping),
        3,
      );
    });

    test('taken out by hand: part of no flare', () {
      expect(at(DateTime(2026, 3, 5), detached: true), isNull);
    });

    test('taken out by hand wins over a pin', () {
      expect(at(DateTime(2026, 3, 5), pinned: 2, detached: true), isNull);
    });

    test('pinned to a flare that exists: that flare, whatever the time', () {
      expect(at(DateTime(2025, 1, 1), pinned: 1), 1);
    });

    test('pinned to a deleted flare: back to the rule', () {
      expect(at(DateTime(2026, 3, 5), pinned: 99), 1);
      expect(at(DateTime(2025, 1, 1), pinned: 99), isNull);
    });

    test("pinned to another profile's flare: back to the rule", () {
      final theirs = _flare(7, DateTime(2020), null, 2);
      expect(
        flareFor(
          at: DateTime(2026, 3, 5),
          profileId: 1,
          flares: [...flares, theirs],
          pinnedFlareId: 7,
        ),
        1,
      );
    });
  });

  group('flareCovering', () {
    test('returns the flare itself', () {
      expect(
        flareCovering(DateTime(2026, 3, 5), profileId: 1, flares: flares),
        past,
      );
    });

    test('no flares: null', () {
      expect(
        flareCovering(DateTime(2026, 3, 5), profileId: 1, flares: const []),
        isNull,
      );
    });
  });
}
