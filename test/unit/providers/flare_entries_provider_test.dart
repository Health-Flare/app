// #173: what's in a flare, for the flare screen and the forms.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/flare_entries_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';

final _start = DateTime(2026, 3, 3, 9);
final _during = DateTime(2026, 3, 5, 12);
final _later = DateTime(2026, 3, 6, 12);
final _before = DateTime(2026, 2, 1);

class _Flares extends FlareListNotifier {
  _Flares(this.flares);
  final List<Flare> flares;
  @override
  List<Flare> build() => flares;
}

class _Symptoms extends SymptomEntryListNotifier {
  _Symptoms(this.items);
  final List<SymptomEntry> items;
  @override
  List<SymptomEntry> build() => items;
}

class _Vitals extends VitalEntryListNotifier {
  _Vitals(this.items);
  final List<VitalEntry> items;
  @override
  List<VitalEntry> build() => items;
}

class _Meals extends MealEntryListNotifier {
  _Meals(this.items);
  final List<MealEntry> items;
  @override
  List<MealEntry> build() => items;
}

class _Doses extends DoseLogListNotifier {
  _Doses(this.items);
  final List<DoseLog> items;
  @override
  List<DoseLog> build() => items;
}

class _Activities extends ActivityEntryListNotifier {
  _Activities(this.items);
  final List<ActivityEntry> items;
  @override
  List<ActivityEntry> build() => items;
}

SymptomEntry _symptom(
  int id,
  DateTime at, {
  int profileId = 1,
  bool detached = false,
}) => SymptomEntry(
  id: id,
  profileId: profileId,
  name: 'Joint pain',
  severity: 6,
  loggedAt: at,
  createdAt: at,
  flareDetached: detached,
);

ProviderContainer _container({
  List<Flare>? flares,
  List<SymptomEntry> symptoms = const [],
}) {
  final c = ProviderContainer(
    overrides: [
      flareListProvider.overrideWith(
        () => _Flares(
          flares ??
              [
                Flare(
                  id: 1,
                  profileId: 1,
                  startedAt: _start,
                  endedAt: DateTime(2026, 3, 10),
                  createdAt: _start,
                ),
              ],
        ),
      ),
      symptomEntryListProvider.overrideWith(() => _Symptoms(symptoms)),
      vitalEntryListProvider.overrideWith(
        () => _Vitals([
          VitalEntry(
            id: 1,
            profileId: 1,
            vitalType: VitalType.temperature,
            value: 38.1,
            unit: '°C',
            loggedAt: _during,
            createdAt: _during,
          ),
        ]),
      ),
      mealEntryListProvider.overrideWith(
        () => _Meals([
          MealEntry(
            id: 1,
            profileId: 1,
            description: 'Soup',
            hasReaction: false,
            loggedAt: _during,
            createdAt: _during,
          ),
        ]),
      ),
      doseLogListProvider.overrideWith(
        () => _Doses([
          DoseLog(
            id: 1,
            profileId: 1,
            medicationIsarId: 1,
            loggedAt: _during,
            createdAt: _during,
            amount: 1,
            unit: 'tablet',
            status: 'taken',
          ),
        ]),
      ),
      activityEntryListProvider.overrideWith(
        () => _Activities([
          ActivityEntry(
            id: 1,
            profileId: 1,
            description: 'Walk',
            loggedAt: _during,
            createdAt: _during,
          ),
        ]),
      ),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('a flare lists every kind of entry during it', () {
    final c = _container(symptoms: [_symptom(1, _during)]);
    final e = c.read(flareEntriesProvider(1));
    expect(
      [
        e.symptoms.length,
        e.vitals.length,
        e.meals.length,
        e.doses.length,
        e.activities.length,
      ],
      [1, 1, 1, 1, 1],
    );
    expect(e.total, 5);
  });

  test('entries outside it, taken out, or another profile\'s are not', () {
    final c = _container(
      symptoms: [
        _symptom(1, _before),
        _symptom(2, _during, detached: true),
        _symptom(3, _during, profileId: 2),
      ],
    );
    expect(c.read(flareEntriesProvider(1)).symptoms, isEmpty);
  });

  test('newest first', () {
    final c = _container(symptoms: [_symptom(1, _during), _symptom(2, _later)]);
    expect(
      [for (final s in c.read(flareEntriesProvider(1)).symptoms) s.id],
      [2, 1],
    );
  });

  test("moving the flare's start takes in earlier entries", () {
    final c = _container(
      flares: [
        Flare(
          id: 1,
          profileId: 1,
          startedAt: DateTime(2026, 1, 1),
          endedAt: DateTime(2026, 3, 10),
          createdAt: _start,
        ),
      ],
      symptoms: [_symptom(1, _before)],
    );
    expect(c.read(flareEntriesProvider(1)).symptoms, hasLength(1));
  });

  test('a form sees the flare covering its time, unless taken out', () {
    final c = _container();
    expect(
      c
          .read(
            entryFlareProvider((
              profileId: 1,
              at: _during,
              pinnedFlareId: null,
              detached: false,
            )),
          )
          ?.id,
      1,
    );
    expect(
      c.read(
        entryFlareProvider((
          profileId: 1,
          at: _during,
          pinnedFlareId: null,
          detached: true,
        )),
      ),
      isNull,
    );
    expect(
      c.read(coveringFlareProvider((profileId: 1, at: _during)))?.id,
      1,
      reason: '"Add back" knows which flare',
    );
  });
}
