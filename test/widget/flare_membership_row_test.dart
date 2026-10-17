// #173: the "Part of the … flare" row on the entry forms.
// Spec: docs/features/flare.feature, "Which flare an entry is part of".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/features/flare/widgets/flare_membership_row.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/user_condition.dart';

final _start = DateTime(2026, 3, 3, 9);
final _during = DateTime(2026, 3, 5, 12);
final _before = DateTime(2026, 2, 1);

final _fibro = UserCondition(
  id: 7,
  profileId: 1,
  conditionId: 70,
  conditionName: 'Fibromyalgia',
  trackedSince: DateTime(2021),
);
final _arthritis = UserCondition(
  id: 8,
  profileId: 1,
  conditionId: 80,
  conditionName: 'Arthritis',
  trackedSince: DateTime(2021),
);

Flare _flare({List<int> conditions = const [7]}) => Flare(
  id: 1,
  profileId: 1,
  startedAt: _start,
  endedAt: DateTime(2026, 3, 10),
  conditionIsarIds: conditions,
  createdAt: _start,
);

class _Flares extends FlareListNotifier {
  @override
  List<Flare> build() => [_flare()];
}

class _Conditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => [_fibro, _arthritis];
}

Future<List<bool>> _pump(
  WidgetTester tester, {
  required DateTime at,
  bool detached = false,
}) async {
  final changes = <bool>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flareListProvider.overrideWith(_Flares.new),
        userConditionListProvider.overrideWith(_Conditions.new),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FlareMembershipRow(
            profileId: 1,
            at: at,
            pinnedFlareId: null,
            detached: detached,
            onChanged: changes.add,
          ),
        ),
      ),
    ),
  );
  return changes;
}

void main() {
  group('flareName', () {
    test('one condition', () {
      expect(flareName(_flare(), [_fibro]), 'the Fibromyalgia flare');
    });
    test('two conditions', () {
      expect(
        flareName(_flare(conditions: [7, 8]), [_fibro, _arthritis]),
        'the Fibromyalgia and Arthritis flare',
      );
    });
    test('no conditions: when it started', () {
      expect(
        flareName(_flare(conditions: []), [_fibro]),
        'the flare that started 3 Mar',
      );
    });
    test('a condition no longer tracked is left out', () {
      expect(
        flareName(_flare(conditions: [7, 99]), [_fibro]),
        'the Fibromyalgia flare',
      );
    });
  });

  testWidgets('during a flare: says so, and offers Remove', (tester) async {
    final changes = await _pump(tester, at: _during);
    expect(find.text('Part of the Fibromyalgia flare'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    expect(changes, [true]);
  });

  testWidgets('taken out: says so, and offers Add back', (tester) async {
    final changes = await _pump(tester, at: _during, detached: true);
    expect(find.text('Not part of the Fibromyalgia flare'), findsOneWidget);
    await tester.tap(find.text('Add back'));
    expect(changes, [false]);
  });

  testWidgets('no flare covers the time: nothing shown', (tester) async {
    await _pump(tester, at: _before);
    expect(find.textContaining('flare'), findsNothing);
  });
}
