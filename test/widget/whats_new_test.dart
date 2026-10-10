// What's new card, history and setting (#139).
// Spec: docs/features/whats-new.feature.
import 'package:flutter/semantics.dart' show Assertiveness;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/screens/whats_new_screen.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';
import 'package:health_flare/features/whats_new/widgets/whats_new_card.dart';
import 'package:health_flare/features/whats_new/widgets/whats_new_settings_tiles.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/profile.dart';

const _releases = [
  ReleaseNote(
    version: '1.12.0',
    highlights: [
      ReleaseHighlight(
        title: 'Naps in Quick Log',
        body: 'You can log a nap from Quick Log.',
      ),
    ],
    changes: ['You can log a nap from Quick Log.', 'A fix for sleep times.'],
  ),
  ReleaseNote(version: '1.11.0', changes: ['A fix for reports.']),
  ReleaseNote(
    version: '1.10.0',
    highlights: [
      ReleaseHighlight(
        title: 'Vitals on Insights',
        body: 'Insights charts your vitals.',
      ),
    ],
  ),
];

/// In-memory stand-in for [WhatsNewNotifier]: same rules, no Isar.
class _FakeWhatsNew extends WhatsNewNotifier {
  _FakeWhatsNew(this.initial);

  final WhatsNewRecord initial;
  final calls = <String>[];

  @override
  Future<WhatsNewState> build() async =>
      WhatsNewState(record: initial, releases: _releases, installed: '1.12.0');

  void _set(WhatsNewRecord r) => state = AsyncData(state.value!.withRecord(r));

  @override
  Future<void> dismiss() async {
    calls.add('dismiss');
    _set(markSeen(state.value!.record, '1.12.0'));
  }

  @override
  Future<bool> noteCardShown() async {
    final first = !calls.contains('shown');
    calls.add('shown');
    return first;
  }

  @override
  Future<void> setHighlightsOn(bool on) async {
    calls.add('highlights:$on');
    final r = state.value!.record;
    _set(
      on
          ? r.copyWith(highlightsOff: false)
          : markSeen(r.copyWith(highlightsOff: true), '1.12.0'),
    );
  }
}

const _pending = WhatsNewRecord(lastSeenVersion: '1.9.1');

/// The app bar's profile button reads the active profile; keep it off Isar.
class _NoProfiles extends ProfileListNotifier {
  @override
  List<Profile> build() => [];
}

class _NoActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => null;
}

final _flare = Flare(
  id: 1,
  profileId: 1,
  startedAt: DateTime(2026, 10, 1),
  createdAt: DateTime(2026, 10, 1),
);

Future<_FakeWhatsNew> _pump(
  WidgetTester tester, {
  required Widget home,
  WhatsNewRecord record = _pending,
  Flare? activeFlare,
}) async {
  final fake = _FakeWhatsNew(record);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => home is WhatsNewScreen
            ? home
            : Scaffold(body: ListView(children: [home])),
      ),
      GoRoute(
        path: AppRoutes.whatsNew,
        builder: (_, _) => const WhatsNewScreen(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        whatsNewProvider.overrideWith(() => fake),
        activeFlareProvider.overrideWith((ref) => activeFlare),
        activeProfileProvider.overrideWith(_NoActiveProfile.new),
        profileListProvider.overrideWith(_NoProfiles.new),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump();
  return fake;
}

void main() {
  group('Dashboard card', () {
    testWidgets('An update with highlights shows one quiet card', (
      tester,
    ) async {
      final fake = await _pump(tester, home: const WhatsNewCard());

      expect(find.textContaining("What's new"), findsOneWidget);
      expect(find.text('See what\'s new'), findsOneWidget);
      expect(find.byTooltip('Dismiss'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(fake.calls, contains('shown'));
    });

    testWidgets('Updating past several versions shows one card covering both', (
      tester,
    ) async {
      await _pump(tester, home: const WhatsNewCard());
      expect(find.byType(WhatsNewCard), findsOneWidget);
      expect(find.textContaining('Naps in Quick Log'), findsOneWidget);
      expect(find.textContaining('Vitals on Insights'), findsOneWidget);
    });

    testWidgets('A bug-fix-only update shows nothing', (tester) async {
      final fake = await _pump(
        tester,
        home: const WhatsNewCard(),
        record: const WhatsNewRecord(lastSeenVersion: '1.12.0'),
      );
      expect(find.text('See what\'s new'), findsNothing);
      expect(fake.calls, isNot(contains('shown')));
    });

    testWidgets('Dismissing is final for that release', (tester) async {
      final fake = await _pump(tester, home: const WhatsNewCard());
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(fake.calls, contains('dismiss'));
      expect(find.text('See what\'s new'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Swiping the card away dismisses it', (tester) async {
      final fake = await _pump(tester, home: const WhatsNewCard());
      await tester.drag(find.byType(Dismissible), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(fake.calls, contains('dismiss'));
      expect(find.text('See what\'s new'), findsNothing);
    });

    testWidgets('Opening What\'s new from the card counts as seen', (
      tester,
    ) async {
      final fake = await _pump(tester, home: const WhatsNewCard());
      await tester.tap(find.text('See what\'s new'));
      await tester.pumpAndSettle();

      expect(fake.calls, contains('dismiss'));
      expect(find.byType(WhatsNewScreen), findsOneWidget);
    });

    testWidgets('The card holds off during an active flare', (tester) async {
      final fake = await _pump(
        tester,
        home: const WhatsNewCard(),
        activeFlare: _flare,
      );
      expect(find.text('See what\'s new'), findsNothing);
      expect(fake.calls, isNot(contains('shown')));
    });

    testWidgets('Highlights off: no card', (tester) async {
      await _pump(
        tester,
        home: const WhatsNewCard(),
        record: const WhatsNewRecord(
          lastSeenVersion: '1.9.1',
          highlightsOff: true,
        ),
      );
      expect(find.text('See what\'s new'), findsNothing);
    });

    testWidgets('The card is announced once, politely, without moving focus', (
      tester,
    ) async {
      await _pump(tester, home: const WhatsNewCard());
      final said = tester.takeAnnouncements();
      expect(said, hasLength(1));
      expect(said.single.message, contains("What's new"));
      expect(said.single.assertiveness, Assertiveness.polite);
    });
  });

  group('History', () {
    testWidgets('lists every release newest first, highlights first and '
        '"All changes" collapsed', (tester) async {
      await _pump(tester, home: const WhatsNewScreen());

      final v12 = tester.getTopLeft(find.textContaining('1.12.0').first).dy;
      final v11 = tester.getTopLeft(find.textContaining('1.11.0').first).dy;
      final v10 = tester.getTopLeft(find.textContaining('1.10.0').first).dy;
      expect(v12, lessThan(v11));
      expect(v11, lessThan(v10));

      expect(find.text('Naps in Quick Log'), findsOneWidget);
      expect(find.text('All changes'), findsWidgets);
      expect(find.text('A fix for sleep times.'), findsNothing);

      await tester.tap(find.text('All changes').first);
      await tester.pumpAndSettle();
      expect(find.text('A fix for sleep times.'), findsOneWidget);
    });

    testWidgets('history works with highlights off', (tester) async {
      await _pump(
        tester,
        home: const WhatsNewScreen(),
        record: const WhatsNewRecord(
          lastSeenVersion: '1.12.0',
          highlightsOff: true,
        ),
      );
      expect(find.text('Naps in Quick Log'), findsOneWidget);
    });
  });

  group('Settings', () {
    testWidgets("What's new history lives in Settings", (tester) async {
      await _pump(tester, home: const WhatsNewSettingsTiles());
      await tester.tap(find.text("What's new"));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsNewScreen), findsOneWidget);
    });

    testWidgets('Highlights can be turned off, and the setting says what '
        'that means with no "Are you sure?"', (tester) async {
      final fake = await _pump(tester, home: const WhatsNewSettingsTiles());
      final toggle = find.widgetWithText(
        SwitchListTile,
        'Show update highlights',
      );
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);

      await tester.tap(toggle);
      await tester.pump();

      expect(fake.calls, ['highlights:false']);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(
        find.text(
          "You won't get a card after updates, even when screens move. "
          "Everything stays in What's new.",
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
