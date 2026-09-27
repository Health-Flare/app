import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/models/appointment.dart';

// Regression tests for #77: doses and appointments could not be moved to
// another profile.

Future<Isar> _openIsar() async {
  return Isar.open(
    [DoseLogIsarSchema, AppointmentIsarSchema],
    directory: '',
    name: 'move_dose_appt_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

Future<(Isar, ProviderContainer)> _setUp() async {
  final isar = await _openIsar();
  addTearDown(() => isar.close(deleteFromDisk: true));
  final container = ProviderContainer(
    overrides: [isarProvider.overrideWithValue(isar)],
  );
  addTearDown(container.dispose);
  return (isar, container);
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  group('DoseLogListNotifier.moveToProfile', () {
    test('reassigns the dose and relinks it to the target medication, '
        'keeping its details', () async {
      final (isar, container) = await _setUp();
      final notifier = container.read(doseLogListProvider.notifier);
      final loggedAt = DateTime(2026, 7, 1, 12, 0);
      final id = await notifier.add(
        profileId: 1,
        medicationIsarId: 10,
        loggedAt: loggedAt,
        amount: 400,
        unit: 'mg',
        status: 'taken',
        effectiveness: 'helped_a_little',
        notes: 'After lunch',
      );

      await notifier.moveToProfile(id, 2, targetMedicationId: 20);

      final row = await isar.doseLogIsars.get(id);
      expect(row, isNotNull);
      expect(row!.profileId, 2);
      expect(row.medicationIsarId, 20);
      expect(row.loggedAt, loggedAt);
      expect(row.amount, 400);
      expect(row.unit, 'mg');
      expect(row.status, 'taken');
      expect(row.effectiveness, 'helped_a_little');
      expect(row.notes, 'After lunch');
    });

    test('clears the flare link', () async {
      final (isar, container) = await _setUp();
      final notifier = container.read(doseLogListProvider.notifier);
      final id = await notifier.add(
        profileId: 1,
        medicationIsarId: 10,
        loggedAt: DateTime(2026, 7, 1),
        amount: 1,
        unit: 'tab',
        status: 'taken',
        flareIsarId: 42,
      );

      await notifier.moveToProfile(id, 2, targetMedicationId: 20);

      final row = await isar.doseLogIsars.get(id);
      expect(
        row!.flareIsarId,
        isNull,
        reason: 'flares belong to the source profile',
      );
    });

    test('on a missing id is a no-op', () async {
      final (isar, container) = await _setUp();
      await container
          .read(doseLogListProvider.notifier)
          .moveToProfile(9999, 2, targetMedicationId: 20);
      expect(await isar.doseLogIsars.count(), 0);
    });
  });

  group('AppointmentListNotifier.moveToProfile', () {
    test('reassigns the appointment with its questions and outcome', () async {
      final (isar, container) = await _setUp();
      final notifier = container.read(appointmentListProvider.notifier);
      final scheduledAt = DateTime(2026, 8, 3, 9, 30);
      final id = await notifier.add(
        profileId: 1,
        title: 'Rheumatology follow-up',
        providerName: 'Dr. Chen',
        scheduledAt: scheduledAt,
      );
      final original = (await isar.appointmentIsars.get(id))!.toDomain();
      await notifier.update(
        original.copyWith(
          outcomeNotes: 'Increase dose next month',
          questions: const [
            AppointmentQuestion(
              questionId: 'q1',
              question: 'Is the morning stiffness expected?',
              discussed: true,
            ),
          ],
        ),
      );

      await notifier.moveToProfile(id, 2);

      final row = await isar.appointmentIsars.get(id);
      expect(row, isNotNull);
      expect(row!.profileId, 2);
      expect(row.title, 'Rheumatology follow-up');
      expect(row.providerName, 'Dr. Chen');
      expect(row.scheduledAt, scheduledAt);
      expect(row.outcomeNotes, 'Increase dose next month');
      expect(
        row.questions.single.question,
        'Is the morning stiffness expected?',
      );
      expect(row.questions.single.discussed, isTrue);
    });

    test('keeps medication-change text but drops links to the source '
        "profile's medications", () async {
      final (isar, container) = await _setUp();
      final notifier = container.read(appointmentListProvider.notifier);
      final id = await notifier.add(
        profileId: 1,
        title: 'GP',
        scheduledAt: DateTime(2026, 8, 3),
      );
      final original = (await isar.appointmentIsars.get(id))!.toDomain();
      await notifier.update(
        original.copyWith(
          medicationChanges: const [
            MedicationChange(
              changeId: 'c1',
              description: 'Start methotrexate 10 mg weekly',
              linkedMedicationIsarId: 10,
            ),
          ],
        ),
      );

      await notifier.moveToProfile(id, 2);

      final change = (await isar.appointmentIsars.get(
        id,
      ))!.medicationChanges.single;
      expect(change.description, 'Start methotrexate 10 mg weekly');
      expect(change.linkedMedicationIsarId, isNull);
    });

    test('on a missing id is a no-op', () async {
      final (isar, container) = await _setUp();
      await container
          .read(appointmentListProvider.notifier)
          .moveToProfile(9999, 2);
      expect(await isar.appointmentIsars.count(), 0);
    });
  });
}
