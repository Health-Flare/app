import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/appointments/screens/appointment_detail_screen.dart';
import 'package:health_flare/features/appointments/screens/appointment_form_screen.dart';
import 'package:health_flare/features/appointments/screens/appointment_list_screen.dart';
import 'package:health_flare/features/appointments/widgets/upcoming_appointments_card.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeAppointmentList extends AppointmentListNotifier {
  _FakeAppointmentList({this.appointments = const []});
  final List<Appointment> appointments;

  @override
  List<Appointment> build() => appointments;
}

/// Records update/move calls so tests can check nothing typed is lost when
/// an appointment moves (#77).
class _RecordingAppointmentList extends AppointmentListNotifier {
  _RecordingAppointmentList(this.appointment);
  final Appointment appointment;
  final updates = <Appointment>[];
  final calls = <String>[];

  @override
  List<Appointment> build() => [appointment];

  @override
  Future<void> update(Appointment updated) async {
    updates.add(updated);
    calls.add('update');
    state = [updated];
  }

  @override
  Future<void> moveToProfile(int id, int newProfileId) async =>
      calls.add('move:$newProfileId');
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  _FakeProfileList([List<Profile>? profiles])
    : profiles = profiles ?? [Profile(id: 1, name: 'Sarah')];
  final List<Profile> profiles;

  @override
  List<Profile> build() => profiles;
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 3, 26, 12, 0);

Appointment makeAppointment({
  int id = 1,
  String title = 'Rheumatology follow-up',
  String? providerName = 'Dr. Chen',
  String status = AppointmentStatus.upcoming,
  DateTime? scheduledAt,
  String? outcomeNotes,
  List<AppointmentQuestion> questions = const [],
  List<MedicationChange> medicationChanges = const [],
}) => Appointment(
  id: id,
  profileId: 1,
  title: title,
  providerName: providerName,
  scheduledAt: scheduledAt ?? _now.add(const Duration(days: 7)),
  status: status,
  outcomeNotes: outcomeNotes,
  questions: questions,
  medicationChanges: medicationChanges,
  createdAt: _now,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _baseOverrides({
  List<Appointment> appointments = const [],
  List<Profile>? profiles,
}) => [
  appointmentListProvider.overrideWith(
    () => _FakeAppointmentList(appointments: appointments),
  ),
  activeProfileAppointmentsProvider.overrideWith(
    (ref) =>
        appointments.where((a) => a.profileId == 1).toList()
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt)),
  ),
  clockProvider.overrideWithValue(() => _now),
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  profileListProvider.overrideWith(() => _FakeProfileList(profiles)),
  activeProfileDataProvider.overrideWith(
    (ref) => Profile(id: 1, name: 'Sarah'),
  ),
];

Widget _buildListScreen({List<Appointment> appointments = const []}) {
  return ProviderScope(
    overrides: _baseOverrides(appointments: appointments),
    child: const MaterialApp(home: AppointmentListScreen()),
  );
}

Widget _buildFormScreen({Appointment? appointment, String? prefillProvider}) {
  return ProviderScope(
    overrides: _baseOverrides(),
    child: MaterialApp(
      home: AppointmentFormScreen(
        appointment: appointment,
        prefillProvider: prefillProvider,
      ),
    ),
  );
}

Widget _buildDetailScreen({
  required Appointment appointment,
  List<Profile>? profiles,
  bool scrollToOutcome = false,
}) {
  return ProviderScope(
    overrides: _baseOverrides(appointments: [appointment], profiles: profiles),
    child: MaterialApp(
      home: AppointmentDetailScreen(
        appointmentId: appointment.id,
        scrollToOutcome: scrollToOutcome,
      ),
    ),
  );
}

Widget _buildCard({List<Appointment> appointments = const []}) {
  return ProviderScope(
    overrides: _baseOverrides(appointments: appointments),
    child: const MaterialApp(home: Scaffold(body: UpcomingAppointmentsCard())),
  );
}

// ---------------------------------------------------------------------------
// AppointmentListScreen
// ---------------------------------------------------------------------------

void main() {
  group('AppointmentListScreen', () {
    testWidgets('shows empty state when no appointments', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.text('No appointments recorded yet'), findsOneWidget);
      expect(find.text('Add appointment'), findsOneWidget);
    });

    testWidgets('shows upcoming appointment title', (tester) async {
      final appt = makeAppointment(status: AppointmentStatus.upcoming);
      await tester.pumpWidget(_buildListScreen(appointments: [appt]));
      await tester.pump();

      expect(find.text('Rheumatology follow-up'), findsOneWidget);
      expect(find.textContaining('Upcoming'), findsWidgets);
    });

    testWidgets('shows completed appointment in past section', (tester) async {
      final appt = makeAppointment(status: AppointmentStatus.completed);
      await tester.pumpWidget(_buildListScreen(appointments: [appt]));
      await tester.pump();

      expect(find.textContaining('Past'), findsOneWidget);
    });

    testWidgets('shows provider name in subtitle', (tester) async {
      final appt = makeAppointment(providerName: 'Dr. Chen');
      await tester.pumpWidget(_buildListScreen(appointments: [appt]));
      await tester.pump();

      expect(find.textContaining('Dr. Chen'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // AppointmentFormScreen
  // ---------------------------------------------------------------------------

  group('AppointmentFormScreen (new)', () {
    testWidgets('shows title and attribution', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('New appointment'), findsOneWidget);
      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('shows title, provider and date fields', (tester) async {
      await tester.pumpWidget(_buildFormScreen());
      await tester.pump();

      expect(find.text('Appointment title'), findsOneWidget);
      expect(find.text('Provider name (optional)'), findsOneWidget);
      expect(find.text('Date & time'), findsOneWidget);
    });

    testWidgets('pre-fills provider when prefillProvider set', (tester) async {
      await tester.pumpWidget(_buildFormScreen(prefillProvider: 'Dr. Smith'));
      await tester.pump();

      expect(find.text('Dr. Smith'), findsOneWidget);
    });
  });

  group('AppointmentFormScreen (edit)', () {
    testWidgets('shows edit title and save changes button', (tester) async {
      final appt = makeAppointment();
      await tester.pumpWidget(_buildFormScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Edit appointment'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('pre-fills title and provider from appointment', (
      tester,
    ) async {
      final appt = makeAppointment(
        title: 'GP check-in',
        providerName: 'Dr. Ali',
      );
      await tester.pumpWidget(_buildFormScreen(appointment: appt));
      await tester.pump();

      expect(find.text('GP check-in'), findsOneWidget);
      expect(find.text('Dr. Ali'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // AppointmentDetailScreen
  // ---------------------------------------------------------------------------

  group('AppointmentDetailScreen', () {
    group('moving keeps text typed but not saved (#77)', () {
      Future<_RecordingAppointmentList> moveAfter(
        WidgetTester tester,
        Future<void> Function() type,
      ) async {
        final fake = _RecordingAppointmentList(
          makeAppointment(status: AppointmentStatus.upcoming),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appointmentListProvider.overrideWith(() => fake),
              activeProfileProvider.overrideWith(_FakeActiveProfile.new),
              profileListProvider.overrideWith(
                () => _FakeProfileList([
                  Profile(id: 1, name: 'Sarah'),
                  Profile(id: 2, name: 'Dad'),
                ]),
              ),
            ],
            child: MaterialApp.router(
              routerConfig: GoRouter(
                initialLocation: '/detail',
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (_, _) => const Scaffold(body: Text('Root')),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        builder: (_, _) => AppointmentDetailScreen(
                          appointmentId: fake.appointment.id,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await type();
        await tester.tap(find.byTooltip('Move to another profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dad'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Move'));
        await tester.pumpAndSettle();
        return fake;
      }

      testWidgets('unsaved outcome notes are saved, then it moves', (
        tester,
      ) async {
        final fake = await moveAfter(tester, () async {
          await tester.enterText(
            find.widgetWithText(TextField, 'What did the doctor say?'),
            'Try a lower dose',
          );
        });
        expect(fake.calls, ['update', 'move:2']);
        expect(fake.updates.single.outcomeNotes, 'Try a lower dose');
        expect(
          fake.updates.single.status,
          AppointmentStatus.upcoming,
          reason: 'moving is not completing the appointment',
        );
      });

      testWidgets('a typed question that was not added is kept', (
        tester,
      ) async {
        final fake = await moveAfter(tester, () async {
          await tester.enterText(
            find.widgetWithText(TextField, 'Add a question'),
            'Is this a side effect?',
          );
        });
        expect(fake.calls, ['update', 'move:2']);
        expect(
          fake.updates.single.questions.map((q) => q.question),
          contains('Is this a side effect?'),
        );
      });

      testWidgets('a typed medication change that was not added is kept', (
        tester,
      ) async {
        final fake = await moveAfter(tester, () async {
          // The list is lazy: scroll until the field is built.
          final field = find.widgetWithText(TextField, 'Add medication change');
          await tester.scrollUntilVisible(
            field,
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.enterText(field, 'Stop naproxen');
        });
        expect(fake.calls, ['update', 'move:2']);
        expect(
          fake.updates.single.medicationChanges.map((c) => c.description),
          contains('Stop naproxen'),
        );
      });

      testWidgets('with nothing pending, it just moves', (tester) async {
        final fake = await moveAfter(tester, () async {});
        expect(fake.calls, ['move:2']);
      });
    });

    // #77: appointments logged under the wrong person can be moved.
    testWidgets('offers "Move to another profile" when others exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildDetailScreen(
          appointment: makeAppointment(),
          profiles: [
            Profile(id: 1, name: 'Sarah'),
            Profile(id: 2, name: 'Dad'),
          ],
        ),
      );
      await tester.pump();
      expect(find.byTooltip('Move to another profile'), findsOneWidget);
    });

    testWidgets('hides "Move to another profile" with a single profile', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildDetailScreen(appointment: makeAppointment()),
      );
      await tester.pump();
      expect(find.byTooltip('Move to another profile'), findsNothing);
    });

    testWidgets('shows upcoming header for upcoming appointment', (
      tester,
    ) async {
      final appt = makeAppointment(status: AppointmentStatus.upcoming);
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Upcoming appointment'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
    });

    testWidgets('shows completed header for completed appointment', (
      tester,
    ) async {
      final appt = makeAppointment(status: AppointmentStatus.completed);
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Appointment detail'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('shows questions section', (tester) async {
      final appt = makeAppointment(
        questions: [
          const AppointmentQuestion(
            questionId: 'q1',
            question: 'Should I increase my dose?',
          ),
        ],
      );
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Should I increase my dose?'), findsOneWidget);
      expect(find.text('Questions (1)'), findsOneWidget);
    });

    testWidgets('shows medication changes count in section header', (
      tester,
    ) async {
      final appt = makeAppointment(
        status: AppointmentStatus.completed,
        medicationChanges: [
          const MedicationChange(
            changeId: 'c1',
            description: 'Prednisolone 5mg for 14 days',
          ),
        ],
      );
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      // Section header is visible; description may be below fold.
      expect(find.text('Medication changes (1)'), findsOneWidget);
    });

    testWidgets('shows outcome notes when present', (tester) async {
      final appt = makeAppointment(
        status: AppointmentStatus.completed,
        outcomeNotes: 'Referral to physio recommended',
      );
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Referral to physio recommended'), findsOneWidget);
    });

    testWidgets('shows status action buttons for upcoming', (tester) async {
      final appt = makeAppointment(status: AppointmentStatus.upcoming);
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Mark completed'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
    });

    testWidgets('shows follow-up button for completed', (tester) async {
      final appt = makeAppointment(status: AppointmentStatus.completed);
      await tester.pumpWidget(_buildDetailScreen(appointment: appt));
      await tester.pump();

      expect(find.text('Schedule follow-up'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // UpcomingAppointmentsCard
  // ---------------------------------------------------------------------------

  group('UpcomingAppointmentsCard', () {
    // Was "hidden when no upcoming appointments". #138 replaced that rule:
    // with no appointments the card is a one-line prompt.
    testWidgets('shows the add prompt when there are no appointments', (
      tester,
    ) async {
      await tester.pumpWidget(_buildCard());
      await tester.pump();

      expect(
        find.text('Got an appointment coming up? Tap to add it.'),
        findsOneWidget,
      );
    });

    testWidgets('shows appointment title when upcoming', (tester) async {
      final appt = makeAppointment(
        status: AppointmentStatus.upcoming,
        scheduledAt: DateTime.now().add(const Duration(days: 3)),
      );
      await tester.pumpWidget(_buildCard(appointments: [appt]));
      await tester.pump();

      expect(find.text('Rheumatology follow-up'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // One rule for "upcoming" (#138)
  // ---------------------------------------------------------------------------

  group('Upcoming means status and time (#138)', () {
    testWidgets('A passed appointment with no outcome is listed under Past', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildListScreen(
          appointments: [
            makeAppointment(
              id: 1,
              title: 'GP check-in',
              scheduledAt: _now.subtract(const Duration(days: 2)),
            ),
            makeAppointment(
              id: 2,
              title: 'Bloods',
              status: AppointmentStatus.completed,
              scheduledAt: _now.subtract(const Duration(days: 5)),
            ),
            makeAppointment(
              id: 3,
              title: 'Physio intake',
              status: AppointmentStatus.completed,
              scheduledAt: _now.subtract(const Duration(days: 1)),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.textContaining('Upcoming ('), findsNothing);
      expect(find.text('Past (3)'), findsOneWidget);
      expect(find.text('Outcome not recorded'), findsOneWidget);
      final y = {
        for (final t in ['Physio intake', 'GP check-in', 'Bloods'])
          t: tester.getTopLeft(find.text(t)).dy,
      };
      expect(y['Physio intake']!, lessThan(y['GP check-in']!));
      expect(y['GP check-in']!, lessThan(y['Bloods']!));
    });

    testWidgets('"How did it go?" stops after 7 days (list keeps the label)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildListScreen(
          appointments: [
            makeAppointment(
              title: 'GP check-in',
              scheduledAt: _now.subtract(const Duration(days: 8)),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Past (1)'), findsOneWidget);
      expect(find.text('Outcome not recorded'), findsOneWidget);
    });

    testWidgets('an appointment still ahead stays in Upcoming', (tester) async {
      await tester.pumpWidget(
        _buildListScreen(
          appointments: [
            makeAppointment(scheduledAt: _now.add(const Duration(hours: 2))),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Upcoming (1)'), findsOneWidget);
      expect(find.text('Outcome not recorded'), findsNothing);
    });

    testWidgets(
      "The detail screen doesn't call a passed appointment upcoming",
      (tester) async {
        await tester.pumpWidget(
          _buildDetailScreen(
            appointment: makeAppointment(
              title: 'GP check-in',
              scheduledAt: _now.subtract(const Duration(days: 2)),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Upcoming appointment'), findsNothing);
        expect(find.text('Appointment detail'), findsOneWidget);
        expect(find.text('Outcome not recorded'), findsOneWidget);
        expect(find.text('Upcoming'), findsNothing);
        expect(find.text('Mark completed'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Missed'), findsOneWidget);
      },
    );

    testWidgets('detail opened from "How did it go?" shows the outcome field', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // Enough questions to push the outcome field well below the fold.
      final appt = makeAppointment(
        title: 'GP check-in',
        scheduledAt: _now.subtract(const Duration(days: 2)),
        questions: [
          for (var i = 0; i < 20; i++)
            AppointmentQuestion(questionId: 'q$i', question: 'Question $i'),
        ],
      );
      await tester.pumpWidget(
        _buildDetailScreen(appointment: appt, scrollToOutcome: true),
      );
      await tester.pumpAndSettle();

      final field = find.byKey(const Key('appointment_outcome_field'));
      expect(field, findsOneWidget);
      final rect = tester.getRect(field);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(1000));
    });

    test('the outcome link carries the focus parameter', () {
      expect(AppRoutes.appointmentOutcome(5), '/appointments/5?focus=outcome');
    });
  });

  // ---------------------------------------------------------------------------
  // Appointment domain model
  // ---------------------------------------------------------------------------

  group('Appointment domain model', () {
    test('isUpcoming true for upcoming status', () {
      final appt = makeAppointment(status: AppointmentStatus.upcoming);
      expect(appt.isUpcoming, isTrue);
    });

    test('isCompleted true for completed status', () {
      final appt = makeAppointment(status: AppointmentStatus.completed);
      expect(appt.isCompleted, isTrue);
    });

    test('equality based on id', () {
      final a = makeAppointment(id: 1);
      final b = makeAppointment(id: 1);
      final c = makeAppointment(id: 2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith preserves unchanged fields', () {
      final appt = makeAppointment(title: 'GP visit', providerName: 'Dr. Ali');
      final updated = appt.copyWith(title: 'Specialist visit');
      expect(updated.title, 'Specialist visit');
      expect(updated.providerName, 'Dr. Ali');
    });

    test('copyWith clearProviderName removes provider', () {
      final appt = makeAppointment(providerName: 'Dr. Chen');
      final updated = appt.copyWith(clearProviderName: true);
      expect(updated.providerName, isNull);
    });

    test('AppointmentQuestion copyWith toggles discussed', () {
      const q = AppointmentQuestion(
        questionId: 'q1',
        question: 'Test question',
      );
      final toggled = q.copyWith(discussed: true);
      expect(toggled.discussed, isTrue);
      expect(toggled.question, 'Test question');
    });
  });
}
