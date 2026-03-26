import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/daily_checkin/screens/checkin_form_screen.dart';
import 'package:health_flare/features/daily_checkin/screens/checkin_history_screen.dart';
import 'package:health_flare/features/daily_checkin/widgets/daily_checkin_card.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeCheckinList extends DailyCheckinListNotifier {
  _FakeCheckinList({this.checkins = const []});
  final List<DailyCheckin> checkins;

  @override
  List<DailyCheckin> build() => checkins;
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

class _FakeFlareList extends FlareListNotifier {
  @override
  List<Flare> build() => [];
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _today = DateTime(2026, 3, 26);

DailyCheckin makeCheckin({
  int id = 1,
  int wellbeing = 7,
  String? stressLevel,
  String? cyclePhase,
  String? notes,
  DateTime? checkinDate,
}) => DailyCheckin(
  id: id,
  profileId: 1,
  checkinDate: checkinDate ?? _today,
  wellbeing: wellbeing,
  stressLevel: stressLevel,
  cyclePhase: cyclePhase,
  notes: notes,
  createdAt: _today,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHistoryScreen({List<DailyCheckin> checkins = const []}) {
  return ProviderScope(
    overrides: [
      dailyCheckinListProvider.overrideWith(
        () => _FakeCheckinList(checkins: checkins),
      ),
      activeProfileCheckinsProvider.overrideWith(
        (ref) =>
            checkins.where((c) => c.profileId == 1).toList()
              ..sort((a, b) => b.checkinDate.compareTo(a.checkinDate)),
      ),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
    ],
    child: const MaterialApp(home: CheckInHistoryScreen()),
  );
}

Widget _buildFormScreen({DailyCheckin? checkin, bool cycleEnabled = false}) {
  return ProviderScope(
    overrides: [
      dailyCheckinListProvider.overrideWith(_FakeCheckinList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) =>
            Profile(id: 1, name: 'Sarah', cycleTrackingEnabled: cycleEnabled),
      ),
    ],
    child: MaterialApp(home: CheckInFormScreen(checkin: checkin)),
  );
}

Widget _buildCard({DailyCheckin? todayCheckin}) {
  return ProviderScope(
    overrides: [
      dailyCheckinListProvider.overrideWith(
        () => _FakeCheckinList(
          checkins: todayCheckin != null ? [todayCheckin] : [],
        ),
      ),
      todayCheckinProvider.overrideWith((ref) => todayCheckin),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith(
        (ref) => Profile(id: 1, name: 'Sarah'),
      ),
      flareListProvider.overrideWith(_FakeFlareList.new),
      activeFlareProvider.overrideWith((ref) => null),
    ],
    child: const MaterialApp(home: Scaffold(body: DailyCheckinCard())),
  );
}

// ---------------------------------------------------------------------------
// CheckInHistoryScreen
// ---------------------------------------------------------------------------

void main() {
  group('CheckInHistoryScreen', () {
    testWidgets('shows empty state when no check-ins', (tester) async {
      await tester.pumpWidget(_buildHistoryScreen());
      await tester.pump();

      expect(find.text('No check-ins recorded yet.'), findsOneWidget);
    });

    testWidgets('shows check-in date and wellbeing', (tester) async {
      final checkin = makeCheckin(wellbeing: 8);
      await tester.pumpWidget(_buildHistoryScreen(checkins: [checkin]));
      await tester.pump();

      expect(find.text('8'), findsOneWidget);
      expect(find.textContaining('26 Mar 2026'), findsOneWidget);
    });

    testWidgets('shows stress level in subtitle', (tester) async {
      final checkin = makeCheckin(stressLevel: 'high');
      await tester.pumpWidget(_buildHistoryScreen(checkins: [checkin]));
      await tester.pump();

      expect(find.text('High stress'), findsOneWidget);
    });

    testWidgets('shows multiple check-ins', (tester) async {
      final checkins = [
        makeCheckin(id: 1, wellbeing: 8, checkinDate: _today),
        makeCheckin(
          id: 2,
          wellbeing: 4,
          checkinDate: _today.subtract(const Duration(days: 1)),
        ),
      ];
      await tester.pumpWidget(_buildHistoryScreen(checkins: checkins));
      await tester.pump();

      expect(find.text('8'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // CheckInFormScreen
  // ---------------------------------------------------------------------------

  group('CheckInFormScreen (new)', () {
    testWidgets('shows title and attribution', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Daily check-in'), findsOneWidget);
      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('shows wellbeing question with profile name', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(
        find.textContaining('How is Sarah doing overall today?'),
        findsOneWidget,
      );
    });

    testWidgets('shows wellbeing chips 1–10', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('shows stress level chips', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('does not show cycle phase when disabled', (tester) async {
      await tester.pumpWidget(_buildFormScreen(cycleEnabled: false));
      await tester.pump();

      expect(find.text('Period'), findsNothing);
    });

    testWidgets('shows cycle phase when enabled', (tester) async {
      await tester.pumpWidget(_buildFormScreen(cycleEnabled: true));
      await tester.pump();

      expect(find.text('Period'), findsOneWidget);
      expect(find.text('Follicular'), findsOneWidget);
    });

    testWidgets('save button disabled when no wellbeing selected', (
      tester,
    ) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });
  });

  group('CheckInFormScreen (edit)', () {
    testWidgets('shows edit title', (tester) async {
      final checkin = makeCheckin(wellbeing: 6);
      await tester.pumpWidget(_buildFormScreen(checkin: checkin));
      await tester.pump();

      expect(find.text('Edit check-in'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('pre-fills wellbeing value', (tester) async {
      final checkin = makeCheckin(wellbeing: 6);
      await tester.pumpWidget(_buildFormScreen(checkin: checkin));
      await tester.pump();

      // Chip '6' should be selected (ChoiceChip shows selected state)
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      final selected = chips.where((c) => c.selected).toList();
      expect(selected.length, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // DailyCheckinCard
  // ---------------------------------------------------------------------------

  group('DailyCheckinCard', () {
    testWidgets('shows prompt when no check-in today', (tester) async {
      await tester.pumpWidget(_buildCard());
      await tester.pump();

      expect(find.textContaining('How is Sarah doing today?'), findsOneWidget);
    });

    testWidgets('shows summary when check-in exists', (tester) async {
      final checkin = makeCheckin(wellbeing: 7);
      await tester.pumpWidget(_buildCard(todayCheckin: checkin));
      await tester.pump();

      expect(find.text('Today\'s check-in'), findsOneWidget);
      expect(find.textContaining('7/10'), findsOneWidget);
    });

    testWidgets('shows stress in summary', (tester) async {
      final checkin = makeCheckin(wellbeing: 5, stressLevel: 'low');
      await tester.pumpWidget(_buildCard(todayCheckin: checkin));
      await tester.pump();

      expect(find.textContaining('Low stress'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DailyCheckin domain model
  // ---------------------------------------------------------------------------

  group('DailyCheckin domain model', () {
    test('equality based on id', () {
      final a = makeCheckin(id: 1);
      final b = makeCheckin(id: 1);
      final c = makeCheckin(id: 2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith clearStress removes stress level', () {
      final c = makeCheckin(stressLevel: 'high');
      final updated = c.copyWith(clearStress: true);
      expect(updated.stressLevel, isNull);
    });

    test('copyWith clearCyclePhase removes cycle phase', () {
      final c = makeCheckin(cyclePhase: 'period');
      final updated = c.copyWith(clearCyclePhase: true);
      expect(updated.cyclePhase, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final c = makeCheckin(wellbeing: 7, stressLevel: 'low');
      final updated = c.copyWith(wellbeing: 9);
      expect(updated.wellbeing, 9);
      expect(updated.stressLevel, 'low');
      expect(updated.profileId, c.profileId);
    });
  });
}
