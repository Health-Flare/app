import 'package:health_flare/models/appointment.dart';

/// Where an appointment sits relative to now (#138).
///
/// One rule for every screen and export that calls an appointment
/// upcoming (docs/features/doctor-visits.feature, "Dashboard appointments
/// card"):
///
/// - [upcoming]: status Upcoming and the scheduled time is still ahead.
/// - [outcomeNotRecorded]: status Upcoming and the scheduled time has
///   passed. The stored status is never changed automatically.
/// - otherwise the stored status.
enum AppointmentTiming {
  upcoming,
  outcomeNotRecorded,
  completed,
  cancelled,
  missed,
}

/// How long a passed appointment keeps asking "How did it go?" on the
/// dashboard card.
const needsOutcomeWindow = Duration(days: 7);

/// Most appointments the dashboard card lists before "All appointments".
const dashboardCardLimit = 3;

// TODO(#138): stub. Ignores [now]; implement the rule above.
AppointmentTiming appointmentTiming(Appointment a, DateTime now) =>
    switch (a.status) {
      AppointmentStatus.completed => AppointmentTiming.completed,
      AppointmentStatus.cancelled => AppointmentTiming.cancelled,
      AppointmentStatus.missed => AppointmentTiming.missed,
      _ => AppointmentTiming.upcoming,
    };

/// True when [a] is upcoming at [now].
bool isUpcomingAt(Appointment a, DateTime now) =>
    appointmentTiming(a, now) == AppointmentTiming.upcoming;

// TODO(#138): stub.
/// True when [a] passed less than [needsOutcomeWindow] ago and still has
/// no outcome recorded.
bool needsOutcome(Appointment a, DateTime now) => false;

/// Status text shown in the app and in PDF and CSV exports.
String appointmentStatusLabel(Appointment a, DateTime now) =>
    switch (appointmentTiming(a, now)) {
      AppointmentTiming.upcoming => 'Upcoming',
      AppointmentTiming.outcomeNotRecorded => 'Outcome not recorded',
      AppointmentTiming.completed => 'Completed',
      AppointmentTiming.cancelled => 'Cancelled',
      AppointmentTiming.missed => 'Missed',
    };

// TODO(#138): stub.
/// The rows for the dashboard card: appointments needing an outcome
/// (most recent first), then upcoming (soonest first), capped at
/// [dashboardCardLimit]. [appointments] is one profile's appointments.
List<Appointment> dashboardCardAppointments(
  List<Appointment> appointments,
  DateTime now,
) => const [];
