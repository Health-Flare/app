import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/shared/widgets/move_entry_action.dart';
import 'package:health_flare/models/profile.dart';

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  _FakeProfileList(this.profiles);
  final List<Profile> profiles;

  @override
  List<Profile> build() => profiles;
}

final _moved = <Profile>[];

Widget _buildApp({
  required List<Profile> profiles,
  Future<void> Function(Profile target)? onMove,
  Future<bool> Function()? beforeMove,
  List<String> notices = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => ctx.push('/detail'),
                child: const Text('Open detail'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Entry detail'),
            actions: [
              MoveEntryAction(
                onMove: onMove ?? (target) async => _moved.add(target),
                beforeMove: beforeMove,
                notices: notices,
              ),
            ],
          ),
          body: const Center(child: Text('Entry body')),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(() => _FakeProfileList(profiles)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _openDetail(
  WidgetTester tester,
  List<Profile> profiles, {
  Future<void> Function(Profile target)? onMove,
  Future<bool> Function()? beforeMove,
  List<String> notices = const [],
}) async {
  await tester.pumpWidget(
    _buildApp(
      profiles: profiles,
      onMove: onMove,
      beforeMove: beforeMove,
      notices: notices,
    ),
  );
  await tester.pump();
  await tester.tap(find.text('Open detail'));
  await tester.pumpAndSettle();
}

void main() {
  final sarah = Profile(id: 1, name: 'Sarah');
  final dad = Profile(id: 2, name: 'Dad');
  final mia = Profile(id: 3, name: 'Mia');

  setUp(_moved.clear);

  group('MoveEntryAction', () {
    testWidgets('renders nothing when only one profile exists', (tester) async {
      await _openDetail(tester, [sarah]);
      expect(find.byIcon(Icons.swap_horiz), findsNothing);
    });

    testWidgets('is visible when other profiles exist', (tester) async {
      await _openDetail(tester, [sarah, dad]);
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('sheet lists every profile except the active one', (
      tester,
    ) async {
      await _openDetail(tester, [sarah, dad, mia]);
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Move this entry to'), findsOneWidget);
      expect(find.text('Dad'), findsOneWidget);
      expect(find.text('Mia'), findsOneWidget);
      expect(find.text('Sarah'), findsNothing);
    });

    testWidgets('choosing a profile calls onMove, confirms, and pops', (
      tester,
    ) async {
      await _openDetail(tester, [sarah, dad]);
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dad'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move'));
      await tester.pumpAndSettle();

      expect(_moved.map((p) => p.id), [2]);
      expect(find.text('Moved to Dad'), findsOneWidget);
      // Popped back to the home route.
      expect(find.text('Open detail'), findsOneWidget);
      expect(find.text('Entry body'), findsNothing);
    });

    testWidgets('dismissing the sheet without choosing does nothing', (
      tester,
    ) async {
      await _openDetail(tester, [sarah, dad]);
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      // Tap outside the sheet to dismiss.
      await tester.tapAt(const Offset(200, 50));
      await tester.pumpAndSettle();

      expect(_moved, isEmpty);
      expect(find.text('Entry body'), findsOneWidget);
    });

    // Moving must never lose data (#77 follow-up).
    Future<void> pickDad(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.swap_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dad'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks for confirmation before moving', (tester) async {
      await _openDetail(tester, [sarah, dad]);
      await pickDad(tester);

      expect(find.text('Move to Dad?'), findsOneWidget);
      expect(_moved, isEmpty, reason: 'nothing moves until confirmed');
    });

    testWidgets('cancelling the confirmation leaves the entry alone', (
      tester,
    ) async {
      await _openDetail(tester, [sarah, dad]);
      await pickDad(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_moved, isEmpty);
      expect(find.text('Entry body'), findsOneWidget);
    });

    testWidgets('the confirmation lists what will change', (tester) async {
      await _openDetail(
        tester,
        [sarah, dad],
        notices: ["It will no longer be part of Sarah's flare."],
      );
      await pickDad(tester);

      expect(
        find.text("It will no longer be part of Sarah's flare."),
        findsOneWidget,
      );
    });

    testWidgets('pending edits are saved before the move', (tester) async {
      final order = <String>[];
      await _openDetail(
        tester,
        [sarah, dad],
        beforeMove: () async {
          order.add('save');
          return true;
        },
        onMove: (target) async => order.add('move'),
      );
      await pickDad(tester);
      await tester.tap(find.text('Move'));
      await tester.pumpAndSettle();

      expect(order, ['save', 'move']);
    });

    testWidgets('if the edits cannot be saved, nothing moves', (tester) async {
      await _openDetail(tester, [sarah, dad], beforeMove: () async => false);
      await pickDad(tester);
      await tester.tap(find.text('Move'));
      await tester.pumpAndSettle();

      expect(_moved, isEmpty);
      expect(
        find.text('Fix the highlighted fields first, then move it again.'),
        findsOneWidget,
      );
      expect(find.text('Entry body'), findsOneWidget, reason: 'stays open');
    });

    testWidgets('a failed move says so and keeps the screen open', (
      tester,
    ) async {
      await _openDetail(tester, [
        sarah,
        dad,
      ], onMove: (target) async => throw StateError('disk full'));
      await pickDad(tester);
      await tester.tap(find.text('Move'));
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't move this entry. It's still in Sarah's record."),
        findsOneWidget,
      );
      expect(find.text('Moved to Dad'), findsNothing);
      expect(find.text('Entry body'), findsOneWidget);
    });
  });
}
