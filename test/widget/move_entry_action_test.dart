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

Widget _buildApp({required List<Profile> profiles}) {
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
              MoveEntryAction(onMove: (target) async => _moved.add(target)),
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

Future<void> _openDetail(WidgetTester tester, List<Profile> profiles) async {
  await tester.pumpWidget(_buildApp(profiles: profiles));
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
  });
}
