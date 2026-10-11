// The release guide card and the guide (#145).
// Spec: docs/features/release-guides.feature.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide.dart';
import 'package:health_flare/features/release_guides/release_guide_provider.dart';
import 'package:health_flare/features/release_guides/screens/release_guide_screen.dart';
import 'package:health_flare/features/release_guides/widgets/guide_card.dart';
import 'package:health_flare/features/sections/section_screen.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/features/settings/screens/bottom_bar_screen.dart';
import 'package:health_flare/features/shell/app_shell.dart';
import 'package:health_flare/models/profile.dart';

class _Active extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _Profiles extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

TabContent _fake(String id) => TabContent(
  body: (_) => Center(child: Text('$id list')),
  addTooltip: 'Add',
  addTarget: Provider((ref) => const AddTarget('/')),
);

final _barSaves = <BarRecord>[];
final _guideSaves = <GuideRecord>[];
final _announced = <String>[];
var _now = DateTime(2026, 11, 2, 9);

/// Updated from 1.9.1: nothing recorded about the bar.
const _fromLegacy = BarRecord();
const _custom = BarRecord(
  storedBar: ['dashboard', 'track', 'care', 'care.medications'],
  seenVersion: 1,
);

List<Override> _overrides(BarRecord bar, GuideRecord guide) {
  final sarah = Profile(id: 1, name: 'Sarah');
  return [
    featureFlagsProvider.overrideWithValue(
      const FeatureFlags(trackAndCare: true),
    ),
    tabContentProvider.overrideWithValue({
      for (final s in navSections)
        for (final t in s.tabs) t.id: _fake(t.id),
    }),
    activeProfileProvider.overrideWith(_Active.new),
    profileListProvider.overrideWith(_Profiles.new),
    activeProfileDataProvider.overrideWith((ref) => sarah),
    activeFlareProvider.overrideWith((ref) => null),
    barChoiceProvider.overrideWith(() => BarChoiceNotifier()..preload(bar)),
    barStoreProvider.overrideWithValue((r) async => _barSaves.add(r)),
    releaseGuideProvider.overrideWith(
      () => ReleaseGuideNotifier()..preload(guide),
    ),
    guideStoreProvider.overrideWithValue((r) async => _guideSaves.add(r)),
    guideClockProvider.overrideWithValue(() => _now),
    announcerProvider.overrideWithValue((_, m) => _announced.add(m)),
  ];
}

Widget _app({
  BarRecord bar = _fromLegacy,
  GuideRecord guide = const GuideRecord(),
  String initial = AppRoutes.dashboard,
  double textScale = 1,
  bool reduceMotion = false,
}) {
  final listPaths = {
    for (final s in navSections)
      for (final t in s.tabs) Uri.parse(tabLocation(t.id)).path,
  };
  return ProviderScope(
    overrides: _overrides(bar, guide),
    child: MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: reduceMotion,
        size: const Size(400, 900),
      ),
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: initial,
          routes: [
            ShellRoute(
              builder: (context, state, child) => AppShell(child: child),
              routes: [
                GoRoute(
                  path: AppRoutes.dashboard,
                  builder: (_, _) =>
                      Scaffold(body: ListView(children: const [GuideCard()])),
                ),
                for (final path in listPaths)
                  GoRoute(path: path, pageBuilder: (_, s) => sectionPage(s)),
              ],
            ),
            GoRoute(
              path: '${AppRoutes.releaseGuide}/:id',
              builder: (_, s) => ReleaseGuideScreen(
                guideId: s.pathParameters['id']!,
                initialStep:
                    int.tryParse(s.uri.queryParameters['step'] ?? '') ?? 0,
                replay: s.uri.queryParameters['replay'] == '1',
              ),
            ),
            GoRoute(
              path: AppRoutes.bottomBar,
              builder: (_, s) => BottomBarScreen(pendingId: s.extra as String?),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (_, _) => const Scaffold(body: Text('Settings screen')),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _openGuide(
  WidgetTester tester, {
  BarRecord bar = _fromLegacy,
  int step = 0,
  bool replay = false,
  double textScale = 1,
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    _app(
      bar: bar,
      initial: AppRoutes.guide('track-and-care', step: step, replay: replay),
      textScale: textScale,
      reduceMotion: reduceMotion,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Next'));
  await tester.pumpAndSettle();
}

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Navigator).first));

List<String> _shownBar(WidgetTester tester) =>
    _c(tester).read(barChoiceProvider.notifier).shownIds;

bool _seen(WidgetTester tester) =>
    _c(tester).read(barChoiceProvider).seenVersion == 2;

void main() {
  setUp(() {
    _barSaves.clear();
    _guideSaves.clear();
    _announced.clear();
    _now = DateTime(2026, 11, 2, 9);
  });

  // ---------------------------------------------------------------------
  // The guide card
  // ---------------------------------------------------------------------

  group('the guide card', () {
    testWidgets('An update with a guide says plainly what moved', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('The bottom bar has changed'), findsOneWidget);
      expect(
        find.text(
          'Meds, Meals and Sleep have moved. Nothing has been removed.',
        ),
        findsOneWidget,
      );
      expect(find.text('Show me'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('The guide card comes back once if put off', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('The bottom bar has changed'), findsNothing);
      expect(_guideSaves.last.putOffOn, DateTime(2026, 11, 2));
      expect(_seen(tester), isFalse);

      // A later day.
      _now = DateTime(2026, 11, 3, 9);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        _app(guide: GuideRecord(putOffOn: DateTime(2026, 11, 2))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Not now'), findsNothing);
      expect(find.text('Dismiss'), findsOneWidget);
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('The bottom bar has changed'), findsNothing);
      expect(_seen(tester), isTrue);
    });

    testWidgets('Someone with a custom bar is told their bar was kept', (
      tester,
    ) async {
      await tester.pumpWidget(_app(bar: _custom));
      await tester.pumpAndSettle();
      expect(
        find.text('The default bottom bar has changed. Yours has been kept.'),
        findsOneWidget,
      );
    });

    testWidgets('"Show me" opens the guide', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show me'));
      await tester.pumpAndSettle();
      expect(find.byType(ReleaseGuideScreen), findsOneWidget);
      expect(find.text('Four sections now'), findsWidgets);
    });

    testWidgets('a fresh install sees no card', (tester) async {
      await tester.pumpWidget(_app(bar: const BarRecord(seenVersion: 2)));
      await tester.pumpAndSettle();
      expect(find.text('Show me'), findsNothing);
    });

    testWidgets('Leaving the app mid-guide resumes it next time', (
      tester,
    ) async {
      await tester.pumpWidget(_app(guide: const GuideRecord(resumeStep: 1)));
      await tester.pumpAndSettle();
      expect(find.byType(ReleaseGuideScreen), findsOneWidget);
      expect(find.text('Where things moved'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------
  // The guide
  // ---------------------------------------------------------------------

  testWidgets('the guide has the same dots, Back and Skip as onboarding, '
      'four steps in order, and saves its step', (tester) async {
    final handle = tester.ensureSemantics();
    await _openGuide(tester);
    expect(
      find.bySemanticsLabel('Step 1 of 4, Four sections now'),
      findsOneWidget,
    );
    expect(find.text('Skip'), findsOneWidget);
    for (final (i, title) in trackAndCareGuide.steps.indexed.skip(1)) {
      await _next(tester);
      expect(
        find.bySemanticsLabel('Step ${i + 1} of 4, $title'),
        findsOneWidget,
      );
      expect(_guideSaves.last.resumeStep, i);
    }
    handle.dispose();
  });

  testWidgets('The guide shows the new bar next to the old one', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _openGuide(tester);
    expect(
      find.bySemanticsLabel(
        'The bar you had: Dashboard, Tracking, Meds, Meals, Journal, Sleep',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('The new bar: Dashboard, Track, Care, Journal'),
      findsOneWidget,
    );
    for (final line in trackAndCareGuide.sectionLines.values) {
      expect(find.text(line), findsOneWidget, reason: line);
    }
    handle.dispose();
  });

  testWidgets('Every moved screen is listed with where it went', (
    tester,
  ) async {
    await _openGuide(tester, step: 1);
    for (final r in [
      ...trackAndCareGuide.moved,
      ...trackAndCareGuide.ownPlace,
    ]) {
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('moved-${r.was}')),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey('moved-${r.was}')),
          matching: find.text(r.now),
        ),
        findsOneWidget,
      );
    }
    expect(find.text('Pin'), findsNWidgets(3));
  });

  testWidgets('"Pin" on a moved row puts it back in the bar', (tester) async {
    await _openGuide(tester, step: 1);
    final pin = find.descendant(
      of: find.byKey(const ValueKey('moved-Sleep')),
      matching: find.text('Pin'),
    );
    await tester.ensureVisible(pin);
    await tester.tap(pin);
    await tester.pumpAndSettle();
    expect(_shownBar(tester), [
      'dashboard',
      'track',
      'care',
      'journal',
      'track.sleep',
    ]);
    expect(_c(tester).read(barIsCustomizedProvider), isTrue);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('moved-Sleep')),
        matching: find.text('Pinned'),
      ),
      findsOneWidget,
    );
    expect(find.text(pinnedLine('Sleep')), findsOneWidget);
  });

  testWidgets('"Pin" with a full bar opens the bar editor, and closing it '
      'returns to the same step', (tester) async {
    await _openGuide(
      tester,
      step: 1,
      bar: const BarRecord(
        storedBar: ['dashboard', 'track', 'care', 'journal', 'care.flares'],
        seenVersion: 1,
      ),
    );
    final pin = find.descendant(
      of: find.byKey(const ValueKey('moved-Sleep')),
      matching: find.text('Pin'),
    );
    await tester.ensureVisible(pin);
    await tester.tap(pin);
    await tester.pumpAndSettle();
    expect(find.byType(BottomBarScreen), findsOneWidget);
    expect(find.text(pinFullLine('Sleep')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ReleaseGuideScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('moved-Sleep')), findsOneWidget);
  });

  testWidgets('"Show me" on a row goes to that screen, and outlines its '
      'section in the bar', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show me'));
    await tester.pumpAndSettle();
    await _next(tester);
    final show = find.descendant(
      of: find.byKey(const ValueKey('moved-Meds')),
      matching: find.text('Show me'),
    );
    await tester.tap(show);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(ReleaseGuideScreen), findsNothing);
    expect(find.text('care.medications list'), findsOneWidget);
    expect(find.byKey(const ValueKey('bar-outline-care')), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const ValueKey('bar-outline-care')), findsNothing);
  });

  group('Keep it or change it', () {
    testWidgets('The guide offers to keep it like before; the new layout is '
        'selected by default', (tester) async {
      await _openGuide(tester, step: 2);
      final group = tester.widget<RadioGroup<GuideChoice>>(
        find.byType(RadioGroup<GuideChoice>),
      );
      expect(group.groupValue, GuideChoice.useNew);
      for (final label in [
        'Use the new layout',
        'Keep it like before',
        'Set it up myself',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.textContaining("features you don't use"), findsOneWidget);
      expect(find.textContaining('any time'), findsWidgets);
    });

    testWidgets('choosing "Keep it like before" applies the preset and '
        'counts as seen', (tester) async {
      await _openGuide(tester, step: 2);
      await tester.tap(find.text('Keep it like before'));
      await tester.pumpAndSettle();
      await _next(tester);
      expect(_shownBar(tester), likeBeforePreset);
      expect(_seen(tester), isTrue);
    });

    testWidgets('"Use the new layout" changes nothing but counts as seen', (
      tester,
    ) async {
      await _openGuide(tester, step: 2);
      await _next(tester);
      expect(_c(tester).read(barChoiceProvider).storedBar, isNull);
      expect(_seen(tester), isTrue);
    });

    testWidgets('a custom bar: "Keep my bar" first and selected', (
      tester,
    ) async {
      await _openGuide(tester, step: 2, bar: _custom);
      final group = tester.widget<RadioGroup<GuideChoice>>(
        find.byType(RadioGroup<GuideChoice>),
      );
      expect(group.groupValue, GuideChoice.keepMine);
      final labels = tester
          .widgetList<RadioListTile<GuideChoice>>(
            find.byType(RadioListTile<GuideChoice>),
          )
          .map((t) => (t.title! as Text).data)
          .toList();
      expect(labels, ['Keep my bar', 'Use the new layout', 'Set it up myself']);
      await _next(tester);
      expect(_c(tester).read(barChoiceProvider).storedBar, _custom.storedBar);
    });

    testWidgets('"Set it up myself" opens Settings after the guide', (
      tester,
    ) async {
      await _openGuide(tester, step: 2);
      await tester.tap(find.text('Set it up myself'));
      await tester.pumpAndSettle();
      await _next(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await tester.pumpAndSettle();
      expect(find.text('Settings screen'), findsOneWidget);
    });
  });

  testWidgets('The last step says where to find the guide again', (
    tester,
  ) async {
    await _openGuide(tester, step: 3);
    expect(find.textContaining("Settings > What's new"), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(_seen(tester), isTrue);
    expect(_guideSaves.last.resumeStep, isNull);
  });

  group('Skipping or finishing the guide counts as seen', () {
    testWidgets('Skip', (tester) async {
      await _openGuide(tester, step: 1);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.byType(ReleaseGuideScreen), findsNothing);
      expect(_seen(tester), isTrue);
      expect(_c(tester).read(barChoiceProvider).storedBar, isNull);
    });

    testWidgets('Back on the first step', (tester) async {
      await _openGuide(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ReleaseGuideScreen), findsNothing);
      expect(_seen(tester), isTrue);
    });

    testWidgets('Back on a later step goes back a step', (tester) async {
      await _openGuide(tester, step: 1);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Four sections now'), findsWidgets);
      expect(_seen(tester), isFalse);
    });
  });

  // ---------------------------------------------------------------------
  // Accessibility
  // ---------------------------------------------------------------------

  testWidgets('The guide works with a screen reader: each step announced', (
    tester,
  ) async {
    await _openGuide(tester);
    await _next(tester);
    expect(_announced.last, 'Step 2 of 4, Where things moved');
  });

  testWidgets('Reduce Motion: steps change without sliding', (tester) async {
    await _openGuide(tester, reduceMotion: true);
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pump();
    final page = tester.widget<PageView>(find.byType(PageView));
    expect(page.controller!.page, 1.0);
  });

  testWidgets('The guide fits large text: rows stack, every step scrolls', (
    tester,
  ) async {
    await _openGuide(tester, step: 1, textScale: 2);
    expect(find.byKey(const ValueKey('moved-Meds-stacked')), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Where things moved -> Keep it or change it -> Finding this again.
    for (var i = 0; i < 2; i++) {
      await _next(tester);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('The guide works with a keyboard: Escape closes it', (
    tester,
  ) async {
    await _openGuide(tester, step: 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(ReleaseGuideScreen), findsNothing);
    expect(_seen(tester), isTrue);
  });

  testWidgets('A guide can be replayed: it starts at the first step and '
      'records nothing new', (tester) async {
    await _openGuide(
      tester,
      replay: true,
      bar: const BarRecord(seenVersion: 2),
    );
    expect(find.text('Four sections now'), findsWidgets);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(_guideSaves, isEmpty);
  });
}
