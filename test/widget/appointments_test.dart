import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
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

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
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

List<Override> _baseOverrides({List<Appointment> appointments = const []}) => [
  appointmentListProvider.overrideWith(
    () => _FakeAppointmentList(appointments: appointments),
  ),
  activeProfileAppointmentsProvider.overrideWith(
    (ref) =>
        appointments.where((a) => a.profileId == 1).toList()
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt)),
  ),
  upcomingAppointmentsProvider.overrideWith(
    (ref) =>
        appointments
            .where(
              (a) =>
                  a.profileId == 1 &&
                  a.status == AppointmentStatus.upcoming &&
                  a.scheduledAt.isAfter(DateTime.now()),
            )
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
  ),
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  profileListProvider.overrideWith(_FakeProfileList.new),
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

Widget _buildDetailScreen({required Appointment appointment}) {
  return ProviderScope(
    overrides: _baseOverrides(appointments: [appointment]),
    child: MaterialApp(
      home: AppointmentDetailScreen(appointmentId: appointment.id),
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

      expect(find.text('No appointments recorded.'), findsOneWidget);
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
    testWidgets('hidden when no upcoming appointments', (tester) async {
      await tester.pumpWidget(_buildCard());
      await tester.pump();

      expect(find.byType(Card), findsNothing);
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
