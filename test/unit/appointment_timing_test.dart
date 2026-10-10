import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/appointment_timing.dart';

// #138: one rule for "upcoming" everywhere (status AND time), plus the
// dashboard card's "How did it go?" window.
// Spec: docs/features/doctor-visits.feature, "Dashboard appointments card".

final _now = DateTime(2026, 3, 26, 11, 0);

Appointment _appt({
  int id = 1,
  String title = 'GP check-in',
  String status = AppointmentStatus.upcoming,
  required DateTime at,
  String? outcomeNotes,
}) => Appointment(
  id: id,
  profileId: 1,
  title: title,
  scheduledAt: at,
  status: status,
  outcomeNotes: outcomeNotes,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  group('appointmentTiming', () {
    test('status Upcoming and still ahead is upcoming', () {
      final a = _appt(at: _now.add(const Duration(days: 5)));
      expect(appointmentTiming(a, _now), AppointmentTiming.upcoming);
      expect(isUpcomingAt(a, _now), isTrue);
    });

    test('status Upcoming and passed is outcome not recorded', () {
      final a = _appt(at: _now.subtract(const Duration(days: 2)));
      expect(appointmentTiming(a, _now), AppointmentTiming.outcomeNotRecorded);
      expect(isUpcomingAt(a, _now), isFalse);
    });

    test('earlier today counts as passed once its time has gone', () {
      final a = _appt(at: DateTime(2026, 3, 26, 9, 0));
      expect(appointmentTiming(a, _now), AppointmentTiming.outcomeNotRecorded);
    });

    test('passed 8 days ago is still outcome not recorded, not upcoming', () {
      final a = _appt(at: _now.subtract(const Duration(days: 8)));
      expect(appointmentTiming(a, _now), AppointmentTiming.outcomeNotRecorded);
    });

    test('the stored status wins for completed, cancelled and missed', () {
      final past = _now.subtract(const Duration(days: 2));
      final ahead = _now.add(const Duration(days: 2));
      for (final at in [past, ahead]) {
        expect(
          appointmentTiming(
            _appt(status: AppointmentStatus.completed, at: at),
            _now,
          ),
          AppointmentTiming.completed,
        );
        expect(
          appointmentTiming(
            _appt(status: AppointmentStatus.cancelled, at: at),
            _now,
          ),
          AppointmentTiming.cancelled,
        );
        expect(
          appointmentTiming(
            _appt(status: AppointmentStatus.missed, at: at),
            _now,
          ),
          AppointmentTiming.missed,
        );
      }
    });

    test('status labels', () {
      expect(
        appointmentStatusLabel(
          _appt(at: _now.add(const Duration(days: 1))),
          _now,
        ),
        'Upcoming',
      );
      expect(
        appointmentStatusLabel(
          _appt(at: _now.subtract(const Duration(days: 1))),
          _now,
        ),
        'Outcome not recorded',
      );
    });
  });

  group('needsOutcome', () {
    test('passed 2 days ago with nothing recorded needs an outcome', () {
      expect(
        needsOutcome(_appt(at: _now.subtract(const Duration(days: 2))), _now),
        isTrue,
      );
    });

    test('earlier today, once passed, needs an outcome', () {
      expect(
        needsOutcome(_appt(at: DateTime(2026, 3, 26, 9, 0)), _now),
        isTrue,
      );
    });

    test('still ahead does not need an outcome', () {
      expect(
        needsOutcome(_appt(at: _now.add(const Duration(hours: 1))), _now),
        isFalse,
      );
    });

    test('8 days ago no longer asks', () {
      expect(
        needsOutcome(_appt(at: _now.subtract(const Duration(days: 8))), _now),
        isFalse,
      );
    });

    test('just inside 7 days still asks, exactly 7 days does not', () {
      expect(
        needsOutcome(
          _appt(at: _now.subtract(const Duration(days: 6, hours: 23))),
          _now,
        ),
        isTrue,
      );
      expect(
        needsOutcome(_appt(at: _now.subtract(needsOutcomeWindow)), _now),
        isFalse,
      );
    });

    test('a saved outcome clears it, even if status is still Upcoming', () {
      final a = _appt(
        at: _now.subtract(const Duration(days: 2)),
        outcomeNotes: 'Referral to physio',
      );
      expect(needsOutcome(a, _now), isFalse);
    });

    test('completed, missed or cancelled clears it', () {
      final at = _now.subtract(const Duration(days: 2));
      for (final s in [
        AppointmentStatus.completed,
        AppointmentStatus.missed,
        AppointmentStatus.cancelled,
      ]) {
        expect(
          needsOutcome(_appt(status: s, at: at), _now),
          isFalse,
          reason: s,
        );
      }
    });
  });

  group('dashboardCardAppointments', () {
    List<int> ids(List<Appointment> xs) => [for (final a in xs) a.id];

    test('shows the next three upcoming, soonest first', () {
      final list = [
        _appt(id: 40, at: _now.add(const Duration(days: 40))),
        _appt(id: 9, at: _now.add(const Duration(days: 9))),
        _appt(id: 2, at: _now.add(const Duration(days: 2))),
        _appt(id: 20, at: _now.add(const Duration(days: 20))),
      ];
      expect(ids(dashboardCardAppointments(list, _now)), [2, 9, 20]);
    });

    test(
      'needs-an-outcome rows come first, most recent first, and share the three',
      () {
        final list = [
          _appt(id: 102, at: _now.add(const Duration(days: 2))),
          _appt(id: 103, at: _now.subtract(const Duration(days: 3))),
          _appt(id: 109, at: _now.add(const Duration(days: 9))),
          _appt(id: 101, at: _now.subtract(const Duration(days: 1))),
        ];
        expect(ids(dashboardCardAppointments(list, _now)), [101, 103, 102]);
      },
    );

    test('leaves out completed, cancelled, missed and passed over 7 days', () {
      final list = [
        _appt(
          id: 1,
          status: AppointmentStatus.completed,
          at: _now.subtract(const Duration(days: 1)),
        ),
        _appt(
          id: 2,
          status: AppointmentStatus.cancelled,
          at: _now.add(const Duration(days: 1)),
        ),
        _appt(id: 3, at: _now.subtract(const Duration(days: 8))),
        _appt(id: 4, at: _now.add(const Duration(days: 4))),
      ];
      expect(ids(dashboardCardAppointments(list, _now)), [4]);
    });
  });
}
