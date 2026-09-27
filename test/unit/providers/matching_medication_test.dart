import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/models/medication.dart';

// #77: a moved dose must be relinked to the target profile's copy of the
// same medication. Matching is by name, ignoring case and outer whitespace.

Medication _med(int id, int profileId, String name, {DateTime? endDate}) =>
    Medication(
      id: id,
      profileId: profileId,
      name: name,
      medicationType: 'medication',
      doseAmount: 1,
      doseUnit: 'tab',
      frequency: 'daily',
      startDate: DateTime(2026, 1, 1),
      endDate: endDate,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  final sarahsIbuprofen = _med(10, 1, 'Ibuprofen');

  test('matches the same name on the target profile', () {
    final all = [sarahsIbuprofen, _med(20, 2, 'Ibuprofen')];
    expect(matchingMedication(all, sarahsIbuprofen, 2)?.id, 20);
  });

  test('ignores case and surrounding whitespace', () {
    final all = [sarahsIbuprofen, _med(20, 2, '  ibuprofen ')];
    expect(matchingMedication(all, sarahsIbuprofen, 2)?.id, 20);
  });

  test('returns null when the target profile has no such medication', () {
    final all = [sarahsIbuprofen, _med(20, 2, 'Paracetamol')];
    expect(matchingMedication(all, sarahsIbuprofen, 2), isNull);
  });

  test("never matches another profile's medication", () {
    final all = [sarahsIbuprofen, _med(30, 3, 'Ibuprofen')];
    expect(matchingMedication(all, sarahsIbuprofen, 2), isNull);
  });

  test('prefers an active medication over a discontinued one', () {
    final all = [
      sarahsIbuprofen,
      _med(20, 2, 'Ibuprofen', endDate: DateTime(2026, 3, 1)),
      _med(21, 2, 'Ibuprofen'),
    ];
    expect(matchingMedication(all, sarahsIbuprofen, 2)?.id, 21);
  });
}
