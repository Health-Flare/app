import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/models/appointment.dart';

// Regression tests for #77: doses and appointments could not be moved to
// another profile.

Future<Isar> _openIsar() async {
  return Isar.open(
    [DoseLogIsarSchema, AppointmentIsarSchema, MedicationIsarSchema],
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

    // When the target has no matching medication, the move creates one from
    // the source medication, in the same transaction, so the dose always has
    // a parent and nothing is dropped.
    Future<(int, int)> sarahsIbuprofenDose(ProviderContainer c) async {
      final medId = await c
          .read(medicationListProvider.notifier)
          .add(
            profileId: 1,
            name: 'Ibuprofen',
            medicationType: 'medication',
            doseAmount: 400,
            doseUnit: 'mg',
            frequency: 'as_needed',
            startDate: DateTime(2026, 1, 1),
            notes: "Sarah's note",
          );
      final doseId = await c
          .read(doseLogListProvider.notifier)
          .add(
            profileId: 1,
            medicationIsarId: medId,
            loggedAt: DateTime(2026, 7, 1, 12),
            amount: 400,
            unit: 'mg',
            status: 'taken',
          );
      return (medId, doseId);
    }

    test('without a target medication, creates one on the target profile '
        'and links the dose to it', () async {
      final (isar, container) = await _setUp();
      final (sourceMedId, doseId) = await sarahsIbuprofenDose(container);

      await container
          .read(doseLogListProvider.notifier)
          .moveToProfile(doseId, 2);

      final dose = (await isar.doseLogIsars.get(doseId))!;
      expect(dose.profileId, 2);
      expect(dose.medicationIsarId, isNot(sourceMedId));
      final created = (await isar.medicationIsars.get(dose.medicationIsarId))!;
      expect(created.profileId, 2);
      expect(created.name, 'Ibuprofen');
      expect(created.medicationType, 'medication');
      expect(created.doseAmount, 400);
      expect(created.doseUnit, 'mg');
      expect(created.frequency, 'as_needed');
      expect(created.notes, isNull, reason: "Sarah's notes stay with Sarah");
    });

    test("the source profile's medication is left alone", () async {
      final (isar, container) = await _setUp();
      final (sourceMedId, doseId) = await sarahsIbuprofenDose(container);

      await container
          .read(doseLogListProvider.notifier)
          .moveToProfile(doseId, 2);

      final source = (await isar.medicationIsars.get(sourceMedId))!;
      expect(source.profileId, 1);
      expect(source.notes, "Sarah's note");
      expect(await isar.medicationIsars.count(), 2);
    });

    test('if the source medication is gone, fails without touching '
        'the dose', () async {
      final (isar, container) = await _setUp();
      final id = await container
          .read(doseLogListProvider.notifier)
          .add(
            profileId: 1,
            medicationIsarId: 777, // no such medication
            loggedAt: DateTime(2026, 7, 1),
            amount: 1,
            unit: 'tab',
            status: 'taken',
          );

      await expectLater(
        container.read(doseLogListProvider.notifier).moveToProfile(id, 2),
        throwsStateError,
      );

      final dose = (await isar.doseLogIsars.get(id))!;
      expect(dose.profileId, 1);
      expect(dose.medicationIsarId, 777);
      expect(await isar.medicationIsars.count(), 0);
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
