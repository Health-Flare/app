import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/appointments/widgets/upcoming_appointments_card.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/profile.dart';

// #138: the dashboard appointments card.
// Spec: docs/features/doctor-visits.feature, "Dashboard appointments card".
// Each test is named after its scenario.

final _now = DateTime(2026, 3, 26, 11, 0);
const _prompt = 'Got an appointment coming up? Tap to add it.';

class _FakeAppointmentList extends AppointmentListNotifier {
  _FakeAppointmentList(this.initial);
  final List<Appointment> initial;

  @override
  List<Appointment> build() => initial;

  @override
  Future<void> update(Appointment updated) async {
    state = [for (final a in state) a.id == updated.id ? updated : a];
  }
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;

  @override
  Future<void> setActive(int? id) async => state = id;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [
    Profile(id: 1, name: 'Sarah'),
    Profile(id: 2, name: 'Dad'),
  ];
}

Appointment _appt({
  int id = 1,
  int profileId = 1,
  String title = 'Rheumatology follow-up',
  String? providerName = 'Dr. Chen',
  String status = AppointmentStatus.upcoming,
  required DateTime at,
  String? outcomeNotes,
}) => Appointment(
  id: id,
  profileId: profileId,
  title: title,
  providerName: providerName,
  scheduledAt: at,
  status: status,
  outcomeNotes: outcomeNotes,
  createdAt: DateTime(2026, 1, 1),
);

Appointment _inDays(int days, {int id = 1, String? title}) => _appt(
  id: id,
  title: title ?? 'Appointment in $days days',
  at: _now.add(Duration(days: days)),
);

Appointment _daysAgo(int days, {int id = 1, String? title}) => _appt(
  id: id,
  title: title ?? 'Appointment $days days ago',
  at: _now.subtract(Duration(days: days)),
);

/// Pumps the card under a router with stub destinations, so taps can be
/// checked by where they land.
Future<ProviderContainer> _pumpCard(
  WidgetTester tester,
  List<Appointment> appointments,
) async {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(child: UpcomingAppointmentsCard()),
        ),
      ),
      GoRoute(
        path: AppRoutes.appointments,
        builder: (_, _) => const Scaffold(body: Text('Appointments list')),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, _) =>
                const Scaffold(body: Text('New appointment form')),
          ),
          GoRoute(
            path: ':aid',
            builder: (_, state) {
              final focus = state.uri.queryParameters['focus'];
              return Scaffold(
                body: Text(
                  'Detail ${state.pathParameters['aid']}'
                  '${focus == null ? '' : ' focus=$focus'}',
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => _now),
        appointmentListProvider.overrideWith(
          () => _FakeAppointmentList(appointments),
        ),
        activeProfileProvider.overrideWith(_FakeActiveProfile.new),
        profileListProvider.overrideWith(_FakeProfileList.new),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(UpcomingAppointmentsCard)),
  );
}

double _y(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

void main() {
  group('Dashboard appointments card (#138)', () {
    testWidgets('Upcoming appointments are shown on the dashboard', (
      tester,
    ) async {
      await _pumpCard(tester, [
        _appt(
          title: 'Rheumatology follow-up',
          at: _now.add(const Duration(days: 5)),
        ),
      ]);

      expect(find.text('Rheumatology follow-up'), findsOneWidget);
      expect(find.textContaining('Dr. Chen'), findsOneWidget);
      expect(find.textContaining('31 Mar'), findsOneWidget);
      expect(find.text('In 5 days'), findsOneWidget);
      expect(find.text('All appointments'), findsOneWidget);
    });

    testWidgets('The card links to all appointments with only one upcoming', (
      tester,
    ) async {
      await _pumpCard(tester, [_inDays(2)]);

      await tester.tap(find.text('All appointments'));
      await tester.pumpAndSettle();

      expect(find.text('Appointments list'), findsOneWidget);
    });

    testWidgets('The card shows the next three, soonest first', (tester) async {
      await _pumpCard(tester, [
        _inDays(40, id: 4),
        _inDays(9, id: 2),
        _inDays(2, id: 1),
        _inDays(20, id: 3),
      ]);

      expect(find.text('Appointment in 40 days'), findsNothing);
      final ys = [
        _y(tester, 'Appointment in 2 days'),
        _y(tester, 'Appointment in 9 days'),
        _y(tester, 'Appointment in 20 days'),
      ];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.text('All appointments'), findsOneWidget);
    });

    testWidgets('Tapping an appointment on the card opens its detail', (
      tester,
    ) async {
      await _pumpCard(tester, [
        _appt(
          id: 7,
          title: 'Rheumatology follow-up',
          at: _now.add(const Duration(days: 3)),
        ),
      ]);

      await tester.tap(find.text('Rheumatology follow-up'));
      await tester.pumpAndSettle();

      expect(find.text('Detail 7'), findsOneWidget);
    });

    testWidgets('An appointment that just happened asks how it went', (
      tester,
    ) async {
      await _pumpCard(tester, [
        _inDays(4, id: 1, title: 'Physio assessment'),
        _daysAgo(2, id: 5, title: 'GP check-in'),
      ]);

      expect(find.text('GP check-in'), findsOneWidget);
      expect(find.text('How did it go?'), findsOneWidget);
      expect(
        _y(tester, 'GP check-in'),
        lessThan(_y(tester, 'Physio assessment')),
      );

      await tester.tap(find.text('GP check-in'));
      await tester.pumpAndSettle();

      expect(find.text('Detail 5 focus=outcome'), findsOneWidget);
    });

    testWidgets(
      'An appointment earlier today asks how it went once its time has passed',
      (tester) async {
        await _pumpCard(tester, [
          _appt(title: 'Bloods', at: DateTime(2026, 3, 26, 9, 0)),
        ]);

        expect(find.text('Bloods'), findsOneWidget);
        expect(find.text('How did it go?'), findsOneWidget);
      },
    );

    group('Recording what happened clears "How did it go?"', () {
      final examples = <String, Appointment Function(Appointment)>{
        'save an outcome for it': (a) =>
            a.copyWith(outcomeNotes: 'Referral to physio'),
        'mark it as "Completed"': (a) =>
            a.copyWith(status: AppointmentStatus.completed),
        'mark it as "Missed"': (a) =>
            a.copyWith(status: AppointmentStatus.missed),
        'mark it as "Cancelled"': (a) =>
            a.copyWith(status: AppointmentStatus.cancelled),
      };
      for (final MapEntry(key: action, value: change) in examples.entries) {
        testWidgets(action, (tester) async {
          final appt = _daysAgo(2, title: 'GP check-in');
          final container = await _pumpCard(tester, [appt]);
          expect(find.text('How did it go?'), findsOneWidget);

          await container
              .read(appointmentListProvider.notifier)
              .update(change(appt));
          await tester.pump();

          expect(find.text('GP check-in'), findsNothing);
        });
      }
    });

    testWidgets('"How did it go?" stops after 7 days', (tester) async {
      await _pumpCard(tester, [_daysAgo(8, title: 'GP check-in')]);

      expect(find.text('GP check-in'), findsNothing);
      expect(find.text('How did it go?'), findsNothing);
    });

    testWidgets(
      'Appointments needing an outcome count toward the three shown',
      (tester) async {
        await _pumpCard(tester, [
          _inDays(9, id: 4),
          _daysAgo(3, id: 2),
          _inDays(2, id: 3),
          _daysAgo(1, id: 1),
        ]);

        expect(find.text('Appointment in 9 days'), findsNothing);
        expect(find.text('How did it go?'), findsNWidgets(2));
        expect(find.text('In 2 days'), findsOneWidget);
        final ys = [
          _y(tester, 'Appointment 1 days ago'),
          _y(tester, 'Appointment 3 days ago'),
          _y(tester, 'Appointment in 2 days'),
        ];
        expect(ys, orderedEquals([...ys]..sort()));
        expect(find.text('All appointments'), findsOneWidget);
      },
    );

    testWidgets('Only past appointments: the card offers to add one', (
      tester,
    ) async {
      await _pumpCard(tester, [
        _appt(
          status: AppointmentStatus.completed,
          at: _now.subtract(const Duration(days: 20)),
        ),
      ]);

      expect(find.text('No appointments coming up.'), findsOneWidget);
      expect(find.text('Add appointment'), findsOneWidget);
      expect(find.text('All appointments'), findsOneWidget);

      await tester.tap(find.text('Add appointment'));
      await tester.pumpAndSettle();
      expect(find.text('New appointment form'), findsOneWidget);
    });

    testWidgets('No appointments at all: a one-line prompt', (tester) async {
      await _pumpCard(tester, []);

      expect(find.text(_prompt), findsOneWidget);
      expect(find.text('All appointments'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byTooltip('Dismiss'), findsNothing);

      await tester.tap(find.text(_prompt));
      await tester.pumpAndSettle();
      expect(find.text('New appointment form'), findsOneWidget);
    });

    testWidgets('The card follows the active profile', (tester) async {
      final container = await _pumpCard(tester, [
        _appt(
          title: 'Physio assessment',
          at: _now.add(const Duration(days: 3)),
        ),
      ]);
      expect(find.text('Physio assessment'), findsOneWidget);

      await container.read(activeProfileProvider.notifier).setActive(2);
      await tester.pump();

      expect(find.text('Physio assessment'), findsNothing);
      expect(find.text(_prompt), findsOneWidget);
    });

    testWidgets("The card's links work with a screen reader", (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCard(tester, [
        _appt(
          status: AppointmentStatus.completed,
          at: _now.subtract(const Duration(days: 20)),
        ),
      ]);

      for (final label in ['All appointments', 'Add appointment']) {
        expect(find.text(label), findsOneWidget, reason: label);
        expect(
          tester.getSemantics(find.text(label)),
          isSemantics(label: label, isButton: true, hasTapAction: true),
          reason: label,
        );
      }
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets("The card's links work with a keyboard on desktop", (
      tester,
    ) async {
      await _pumpCard(tester, [
        _inDays(3, id: 1, title: 'Physio assessment'),
        _daysAgo(2, id: 2, title: 'GP check-in'),
      ]);

      for (final label in [
        'GP check-in',
        'Physio assessment',
        'All appointments',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }

      bool focused(String text) =>
          Focus.of(tester.element(find.text(text))).hasPrimaryFocus;

      final order = ['GP check-in', 'Physio assessment', 'All appointments'];
      var tabs = 0;
      while (!focused(order.first) && tabs < 10) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        tabs++;
      }
      expect(focused(order.first), isTrue, reason: 'first row never focused');
      for (final next in order.skip(1)) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(focused(next), isTrue, reason: next);
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Appointments list'), findsOneWidget);
    });

    testWidgets(
      'An appointment asking how it went has its own screen reader label',
      (tester) async {
        final handle = tester.ensureSemantics();
        await _pumpCard(tester, [_daysAgo(2, title: 'GP check-in')]);

        expect(
          find.bySemanticsLabel(
            'GP check-in, appointment 2 days ago, how did it go?',
          ),
          findsOneWidget,
        );
        handle.dispose();
      },
    );
  });
}
