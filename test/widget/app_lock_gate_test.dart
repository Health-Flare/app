import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/app_lock_provider.dart';
import 'package:health_flare/core/security/device_auth.dart';
import 'package:health_flare/features/app_lock/app_lock_gate.dart';

import '../helpers/app_lock_fakes.dart';

// docs/features/app-lock.feature, "When the app locks" and "The lock
// screen" (#100).

/// Stands in for a screen with someone's records and unsaved work.
class _JournalDraft extends StatelessWidget {
  const _JournalDraft();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sarah')),
    body: Column(
      children: [
        const Text('Mia: 2 flares this week'),
        const TextField(key: Key('draft')),
        ElevatedButton(onPressed: () {}, child: const Text('Save entry')),
      ],
    ),
  );
}

class _Setup {
  _Setup({
    AppLockSettings settings = const AppLockSettings(),
    bool screenLock = true,
  }) : auth = FakeDeviceAuth(screenLock: screenLock),
       store = MemoryAppLockStore(settings);

  final FakeDeviceAuth auth;
  final MemoryAppLockStore store;
  final window = FakeSecureWindow();
  final clock = FakeClock();

  /// The app's real arrangement: the gate in a router app's builder. Back
  /// goes through the router there, not through WidgetsApp.
  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const _JournalDraft()),
        GoRoute(
          path: '/detail',
          builder: (_, _) => const Scaffold(body: Text('Entry detail')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: appLockOverrides(
          auth: auth,
          store: store,
          window: window,
          clock: clock,
        ),
        child: MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => AppLockGate(child: child!),
        ),
      ),
    );
    await tester.pump();
    return router;
  }

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: appLockOverrides(
          auth: auth,
          store: store,
          window: window,
          clock: clock,
        ),
        child: MaterialApp(
          builder: (context, child) => AppLockGate(child: child!),
          home: const _JournalDraft(),
        ),
      ),
    );
    await tester.pump();
  }
}

Future<void> _background(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await tester.pump();
}

Future<void> _foreground(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pump();
}

const _on = AppLockSettings(enabled: true);

void main() {
  testWidgets('with the lock off, the app opens straight to its screen', (
    tester,
  ) async {
    final s = _Setup();
    await s.pump(tester);

    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);
    expect(s.auth.prompts, 0);
  });

  testWidgets('a locked start shows only the app name and Unlock', (
    tester,
  ) async {
    final s = _Setup(settings: _on)..auth.next = DeviceAuthResult.cancelled;
    await s.pump(tester);
    await tester.pump();

    expect(find.text('Health Flare'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Unlock'), findsOneWidget);
    expect(find.text('Sarah'), findsNothing);
    expect(find.textContaining('Mia'), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('the lock screen asks for the phone\'s security straight away', (
    tester,
  ) async {
    final s = _Setup(settings: _on);
    await s.pump(tester);
    await tester.pump();

    expect(s.auth.reasons, [AppLockReasons.unlock]);
    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);
  });

  testWidgets('nothing behind the lock screen is announced or tappable', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final s = _Setup(settings: _on)..auth.next = DeviceAuthResult.cancelled;
    await s.pump(tester);
    await tester.pump();

    expect(find.bySemanticsLabel(RegExp('Sarah|Mia|Save entry')), findsNothing);
    // Still in the tree (so nothing is lost), but offstage.
    expect(find.text('Sarah', skipOffstage: false), findsOneWidget);
    expect(find.text('Save entry'), findsNothing);
    semantics.dispose();
  });

  testWidgets('cancelling keeps the app locked; Unlock tries again', (
    tester,
  ) async {
    final s = _Setup(settings: _on)..auth.next = DeviceAuthResult.cancelled;
    await s.pump(tester);
    await tester.pump();
    expect(find.text('Unlock'), findsOneWidget);
    expect(s.auth.prompts, 1);

    s.auth.next = DeviceAuthResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump();

    expect(s.auth.prompts, 2);
    expect(find.text('Sarah'), findsOneWidget);
  });

  testWidgets('unlocking returns to exactly where I was', (tester) async {
    final s = _Setup(
      settings: const AppLockSettings(
        enabled: true,
        relockAfter: RelockAfter.immediately,
      ),
    );
    await s.pump(tester);
    await tester.pump(); // auto-unlock on start
    await tester.enterText(find.byKey(const Key('draft')), 'Rough morning');
    expect(tester.testTextInput.isVisible, isTrue);

    s.auth.next = DeviceAuthResult.cancelled;
    await _background(tester);
    await _foreground(tester);
    await tester.pump();
    expect(find.text('Unlock'), findsOneWidget);
    expect(find.text('Rough morning'), findsNothing);
    // The keyboard goes away: typing can't reach the hidden draft.
    expect(tester.testTextInput.isVisible, isFalse);

    s.auth.next = DeviceAuthResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Rough morning'), findsOneWidget);
  });

  testWidgets('the app locks again after the re-lock time in the background', (
    tester,
  ) async {
    final s = _Setup(
      settings: const AppLockSettings(
        enabled: true,
        relockAfter: RelockAfter.oneMinute,
      ),
    );
    await s.pump(tester);
    await tester.pump();
    expect(find.text('Sarah'), findsOneWidget);

    s.auth.next = DeviceAuthResult.cancelled;
    await _background(tester);
    s.clock.advance(const Duration(seconds: 59));
    await _foreground(tester);
    expect(find.text('Sarah'), findsOneWidget);

    await _background(tester);
    s.clock.advance(const Duration(minutes: 1));
    await _foreground(tester);
    await tester.pump();
    expect(find.text('Sarah'), findsNothing);
    expect(find.text('Unlock'), findsOneWidget);
  });

  testWidgets('back on the lock screen doesn\'t pop the hidden screen', (
    tester,
  ) async {
    final s = _Setup(
      settings: const AppLockSettings(
        enabled: true,
        relockAfter: RelockAfter.immediately,
      ),
    );
    final router = await s.pumpRouter(tester);
    await tester.pump();
    unawaited(router.push('/detail'));
    await tester.pumpAndSettle();

    s.auth.next = DeviceAuthResult.cancelled;
    await _background(tester);
    await _foreground(tester);
    await tester.pump();
    expect(find.text('Unlock'), findsOneWidget);

    final popped = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') popped.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // The app is sent away instead.
    expect(popped, hasLength(1));
    s.auth.next = DeviceAuthResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('Entry detail'), findsOneWidget);
  });

  testWidgets('a paused lock opens the app and says why', (tester) async {
    final s = _Setup(settings: _on, screenLock: false);
    await s.pump(tester);
    await tester.pump();

    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);
    expect(
      find.text(
        'App lock is paused because your phone has no screen lock. '
        "Set one in your phone's settings to turn it back on.",
      ),
      findsOneWidget,
    );
  });
}
