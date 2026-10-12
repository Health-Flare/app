// docs/features/datastore.feature, "When an upgrade keeps failing" (#112):
// the dashboard card and the Settings section.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/features/failed_upgrade/failed_upgrade_card.dart';
import 'package:health_flare/features/failed_upgrade/failed_upgrade_provider.dart';
import 'package:health_flare/features/failed_upgrade/failed_upgrade_section.dart';

const _failure = FailedUpgrade(
  appVersion: '1.10.0+42',
  fromVersion: 16,
  reachedVersion: 17,
  failedStep: 18,
  targetVersion: 22,
  attempts: 3,
  error: 'StateError: Bad state: v18 broke',
  snapshotPath: '/docs/snapshots/healthflare_pre_v16_20261102T101200Z.isar',
  snapshotTakenAt: null,
);

class _FakeActions implements FailedUpgradeActions {
  final calls = <String>[];
  bool copyExists = true;

  @override
  String get platform => 'ios 26.0';

  @override
  bool safetyCopyExists(String path) => copyExists;

  @override
  Future<String> saveBackupFirst() async {
    calls.add('backup');
    return '/docs/backups/healthflare_before_restore_20261102T1015Z.isar';
  }

  @override
  Future<void> share(String path) async => calls.add('share $path');

  @override
  Future<void> exportBackup() async => calls.add('export');

  @override
  Future<void> restore(String snapshotPath) async =>
      calls.add('restore $snapshotPath');
}

String? _clipboard;

Widget _app(
  Widget home, {
  FailedUpgrade? failure = _failure,
  required _FakeActions actions,
}) => ProviderScope(
  overrides: [
    failedUpgradeProvider.overrideWithValue(failure),
    failedUpgradeActionsProvider.overrideWithValue(actions),
  ],
  child: MaterialApp.router(
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: ListView(children: [home])),
        ),
        GoRoute(
          path: AppRoutes.settingsUpdate,
          builder: (_, _) => const Scaffold(body: Text('Settings update')),
        ),
      ],
    ),
  ),
);

void main() {
  late _FakeActions actions;

  setUp(() {
    actions = _FakeActions();
    _clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            _clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
  });

  group('the dashboard card', () {
    testWidgets('The card says what happened and what to do', (tester) async {
      await tester.pumpWidget(
        _app(const FailedUpgradeCard(), actions: actions),
      );
      await tester.pumpAndSettle();
      expect(find.text("This update didn't finish"), findsOneWidget);
      expect(
        find.text(
          'Your data is safe and the app works. Updating the app again will '
          'retry it.',
        ),
        findsOneWidget,
      );
      // Can't be dismissed: no close button, not swipeable.
      expect(find.byTooltip('Dismiss'), findsNothing);
      expect(find.byType(Dismissible), findsNothing);

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('Settings update'), findsOneWidget);
    });

    testWidgets('no failure: no card', (tester) async {
      await tester.pumpWidget(
        _app(const FailedUpgradeCard(), failure: null, actions: actions),
      );
      await tester.pumpAndSettle();
      expect(find.text("This update didn't finish"), findsNothing);
    });
  });

  group('the Settings section', () {
    Future<void> pump(WidgetTester tester, {FailedUpgrade? failure}) async {
      tester.view.physicalSize = const Size(1179, 3000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          const FailedUpgradeSection(),
          failure: failure ?? _failure,
          actions: actions,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Settings explains the failed update', (tester) async {
      await pump(tester);
      expect(find.text("Update didn't finish"), findsOneWidget);
      expect(find.textContaining('Nothing was lost'), findsOneWidget);
      expect(find.textContaining('newer version'), findsOneWidget);
      expect(find.text('Export a backup'), findsOneWidget);
      expect(find.text('Copy details'), findsOneWidget);
      expect(
        find.text('Restore the copy from before the update'),
        findsOneWidget,
      );
      expect(
        find.textContaining('only if something looks wrong'),
        findsOneWidget,
      );

      await tester.tap(find.text('Export a backup'));
      await tester.pumpAndSettle();
      expect(actions.calls, ['export']);
    });

    testWidgets('Copy details holds what we need and no health data', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Copy details'));
      await tester.pumpAndSettle();
      expect(_clipboard, failedUpgradeDetails(_failure, platform: 'ios 26.0'));
      expect(
        find.text('Copied. Paste it into an email or a GitHub issue.'),
        findsOneWidget,
      );
    });

    testWidgets('Restoring the safety copy saves a backup first, then asks', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Restore the copy from before the update'));
      await tester.pumpAndSettle();
      expect(actions.calls, ['backup'], reason: 'saved before anything else');
      expect(
        find.textContaining('healthflare_before_restore_20261102T1015Z.isar'),
        findsOneWidget,
      );
      expect(find.textContaining('logged since'), findsOneWidget);

      await tester.tap(find.text('Share backup'));
      await tester.pumpAndSettle();
      expect(actions.calls.last, startsWith('share '));

      await tester.tap(find.widgetWithText(FilledButton, 'Restore'));
      await tester.pumpAndSettle();
      expect(actions.calls.last, 'restore ${_failure.snapshotPath}');
    });

    testWidgets('cancelling the restore keeps the backup and changes nothing', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text('Restore the copy from before the update'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(actions.calls, ['backup']);
    });

    testWidgets('No restore is offered when the safety copy is gone', (
      tester,
    ) async {
      actions.copyExists = false;
      await pump(tester);
      expect(
        find.text('Restore the copy from before the update'),
        findsNothing,
      );
      expect(find.text('Export a backup'), findsOneWidget);
      expect(find.text('Copy details'), findsOneWidget);
    });

    testWidgets('no failure: no section', (tester) async {
      await tester.pumpWidget(
        _app(const FailedUpgradeSection(), failure: null, actions: actions),
      );
      await tester.pumpAndSettle();
      expect(find.text("Update didn't finish"), findsNothing);
    });
  });
}
