// docs/features/illness.feature, "Recovery and relapse" (#157). The flow
// shipped in 1.1.0 without tests; these pin it before 1.10.0 moves the
// list into Care > Conditions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/illness/screens/condition_detail_screen.dart';
import 'package:health_flare/features/tracking/screens/tracking_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/user_condition.dart';

final _arthritis = UserCondition(
  id: 1,
  profileId: 1,
  conditionId: 3,
  conditionName: 'Arthritis',
  trackedSince: DateTime(2021, 6, 15),
  diagnosedAt: DateTime(2021, 6, 15),
);

final _fibro = UserCondition(
  id: 2,
  profileId: 1,
  conditionId: 7,
  conditionName: 'Fibromyalgia',
  trackedSince: DateTime(2022),
  status: ConditionStatus.inRecovery,
  statusHistory: [
    ConditionStatusEvent(eventType: 'recovery', date: DateTime(2025, 4, 20)),
  ],
);

class _Conditions extends UserConditionListNotifier {
  _Conditions(this._start);

  final List<UserCondition> _start;
  final saved = <UserCondition>[];

  @override
  List<UserCondition> build() => _start;

  @override
  Future<void> update(UserCondition updated) async {
    saved.add(updated);
    state = [
      for (final c in state)
        if (c.id == updated.id) updated else c,
    ];
  }
}

Widget _app(Widget home, _Conditions conditions) => ProviderScope(
  overrides: [
    userConditionListProvider.overrideWith(() => conditions),
    activeProfileDataProvider.overrideWith(
      (ref) => Profile(id: 1, name: 'Sarah'),
    ),
  ],
  child: MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => home)),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ),
);

Future<_Conditions> _openDetail(WidgetTester tester, UserCondition c) async {
  tester.view.physicalSize = const Size(1179, 3000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final conditions = _Conditions([c]);
  await tester.pumpWidget(
    _app(ConditionDetailScreen(condition: c), conditions),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return conditions;
}

/// Picks [day] in the current month of an open date picker and confirms.
Future<void> _pick(WidgetTester tester, {int? day}) async {
  if (day != null) {
    await tester.tap(find.text('$day').last);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

void main() {
  testWidgets('Marking a condition as in recovery', (tester) async {
    final conditions = await _openDetail(tester, _arthritis);
    expect(find.text('Active'), findsOneWidget);

    await tester.tap(find.text('Mark as in recovery'));
    await tester.pumpAndSettle();
    await _pick(tester, day: 1);
    expect(find.text('In recovery'), findsWidgets);

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    final saved = conditions.saved.single;
    expect(saved.status, ConditionStatus.inRecovery);
    final now = _today();
    expect(saved.statusHistory.single.eventType, 'recovery');
    expect(saved.statusHistory.single.date, DateTime(now.year, now.month, 1));
  });

  testWidgets('Recovery date defaults to today', (tester) async {
    final conditions = await _openDetail(tester, _arthritis);
    await tester.tap(find.text('Mark as in recovery'));
    await tester.pumpAndSettle();
    await _pick(tester);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(conditions.saved.single.statusHistory.single.date, _today());
  });

  testWidgets('Marking a condition in recovery as relapsed', (tester) async {
    final conditions = await _openDetail(tester, _fibro);
    expect(find.text('Mark as relapsed'), findsOneWidget);
    expect(find.text('Mark as in recovery'), findsNothing);

    await tester.tap(find.text('Mark as relapsed'));
    await tester.pumpAndSettle();
    await _pick(tester);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final saved = conditions.saved.single;
    expect(saved.status, ConditionStatus.active);
    expect(
      [for (final e in saved.statusHistory) e.eventType],
      ['recovery', 'relapse'],
    );
    expect(saved.statusHistory.last.date, _today());
  });

  testWidgets('Condition detail shows a timeline of status changes', (
    tester,
  ) async {
    await _openDetail(
      tester,
      UserCondition(
        id: 1,
        profileId: 1,
        conditionId: 3,
        conditionName: 'Arthritis',
        trackedSince: DateTime(2021),
        diagnosedAt: DateTime(2021, 6, 15),
        statusHistory: [
          // Stored out of order: the timeline sorts by date.
          ConditionStatusEvent(eventType: 'relapse', date: DateTime(2025, 5)),
          ConditionStatusEvent(
            eventType: 'recovery',
            date: DateTime(2025, 4, 20),
          ),
        ],
      ),
    );
    final labels = ['Diagnosed', 'In recovery', 'Relapsed'];
    final ys = [
      for (final l in labels)
        tester
            .getTopLeft(
              find.descendant(
                of: find.byType(ListTile),
                matching: find.text(l),
              ),
            )
            .dy,
    ];
    expect(ys, orderedEquals([...ys]..sort()));
    // Also on the diagnosis date row.
    expect(find.text('15 Jun 2021'), findsNWidgets(2));
    expect(find.text('20 Apr 2025'), findsOneWidget);
    expect(find.text('1 May 2025'), findsOneWidget);
  });

  testWidgets('Active and in-recovery conditions are grouped separately in the '
      'Conditions tab', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userConditionListProvider.overrideWith(
            () => _Conditions([_arthritis, _fibro]),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ConditionListBody())),
      ),
    );
    await tester.pumpAndSettle();

    double y(String text) => tester.getTopLeft(find.text(text).first).dy;
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('In recovery'), findsWidgets);
    expect(y('Active'), lessThan(y('Arthritis')));
    expect(y('Arthritis'), lessThan(y('In recovery')));
    expect(y('In recovery'), lessThan(y('Fibromyalgia')));
  });
}
