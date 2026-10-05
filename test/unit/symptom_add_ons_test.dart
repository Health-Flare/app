import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/symptoms_vitals/symptom_add_ons.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';

// Optional symptom details offered as add-ons (Option C).
// Spec: docs/features/symptoms_and_vitals.feature, "Optional details: add
// only what helps"; docs/features/profiles.feature, "Show all symptom
// options". Credit: Dr Cat Hicks, Informed Patient.

var _nextId = 1;

SymptomEntry _entry(
  String name, {
  int profileId = 1,
  required int minutesAgo,
  List<String> locations = const [],
  int? interference,
  String? impact,
  String? notes,
}) {
  final t = DateTime(2026, 10, 4, 12).subtract(Duration(minutes: minutesAgo));
  return SymptomEntry(
    id: _nextId++,
    profileId: profileId,
    name: name,
    severity: 5,
    locations: locations,
    interference: interference,
    impact: impact,
    notes: notes,
    loggedAt: t,
    createdAt: t,
  );
}

/// [count] plain entries (nothing optional) for [profileId], newest first.
List<SymptomEntry> _plain(int count, {int profileId = 1, int offset = 0}) => [
  for (var i = 0; i < count; i++)
    _entry('Headache', profileId: profileId, minutesAgo: offset + i),
];

void main() {
  group('usedIn', () {
    test('nothing optional means nothing used', () {
      expect(SymptomAddOns.usedIn(_entry('Headache', minutesAgo: 0)), isEmpty);
    });

    test('each field maps to its add-on', () {
      final e = _entry(
        'Fatigue',
        minutesAgo: 0,
        locations: ['knees'],
        interference: 3,
        impact: 'Skipped my walk',
        notes: 'Worse after lunch',
      );
      expect(SymptomAddOns.usedIn(e), {
        SymptomAddOn.where,
        SymptomAddOn.interference,
        SymptomAddOn.impact,
        SymptomAddOn.notes,
      });
    });

    test('blank text does not count as used', () {
      final e = _entry('Fatigue', minutesAgo: 0, impact: '  ', notes: '');
      expect(SymptomAddOns.usedIn(e), isEmpty);
    });
  });

  group('fromLastTime', () {
    test('opens what the most recent entry for that symptom had', () {
      final entries = [
        _entry('Fatigue', minutesAgo: 10, interference: 4, impact: 'x'),
        _entry('Fatigue', minutesAgo: 500, notes: 'older one'),
      ];
      expect(
        SymptomAddOns.fromLastTime(
          entries: entries,
          profileId: 1,
          name: 'Fatigue',
        ),
        {SymptomAddOn.interference, SymptomAddOn.impact},
      );
    });

    test('looks only at the same symptom', () {
      final entries = [
        _entry('Fatigue', minutesAgo: 10, impact: 'Skipped my walk'),
        _entry('Headache', minutesAgo: 20),
      ];
      expect(
        SymptomAddOns.fromLastTime(
          entries: entries,
          profileId: 1,
          name: 'Headache',
        ),
        isEmpty,
      );
    });

    test('ignores case and spacing in the name', () {
      final entries = [_entry('Fatigue', minutesAgo: 10, interference: 2)];
      expect(
        SymptomAddOns.fromLastTime(
          entries: entries,
          profileId: 1,
          name: ' fatigue ',
        ),
        {SymptomAddOn.interference},
      );
    });

    test('is per profile', () {
      final entries = [
        _entry('Fatigue', profileId: 2, minutesAgo: 10, interference: 5),
      ];
      expect(
        SymptomAddOns.fromLastTime(
          entries: entries,
          profileId: 1,
          name: 'Fatigue',
        ),
        isEmpty,
      );
    });

    test('a field removed last time does not open next time', () {
      final entries = [
        _entry('Fatigue', minutesAgo: 5),
        _entry('Fatigue', minutesAgo: 600, impact: 'Skipped my walk'),
      ];
      expect(
        SymptomAddOns.fromLastTime(
          entries: entries,
          profileId: 1,
          name: 'Fatigue',
        ),
        isEmpty,
      );
    });

    test('an empty name opens nothing', () {
      final entries = [_entry('Fatigue', minutesAgo: 10, interference: 2)];
      expect(
        SymptomAddOns.fromLastTime(entries: entries, profileId: 1, name: ''),
        isEmpty,
      );
    });
  });

  group('folded', () {
    test('Where and Anything else fold after 10 unused entries', () {
      expect(
        SymptomAddOns.folded(entries: _plain(10), profileId: 1, showAll: false),
        {SymptomAddOn.where, SymptomAddOn.notes},
      );
    });

    test('nothing folds before 10 entries', () {
      expect(
        SymptomAddOns.folded(entries: _plain(9), profileId: 1, showAll: false),
        isEmpty,
      );
    });

    test('one recent use keeps an option showing', () {
      final entries = [
        ..._plain(9),
        _entry('Headache', minutesAgo: 50, notes: 'once'),
      ];
      expect(
        SymptomAddOns.folded(entries: entries, profileId: 1, showAll: false),
        {SymptomAddOn.where},
      );
    });

    test('only the last 10 entries count', () {
      final entries = [
        ..._plain(10),
        _entry('Headache', minutesAgo: 999, locations: ['head'], notes: 'old'),
      ];
      expect(
        SymptomAddOns.folded(entries: entries, profileId: 1, showAll: false),
        {SymptomAddOn.where, SymptomAddOn.notes},
      );
    });

    test('interference and impact never fold', () {
      final folded = SymptomAddOns.folded(
        entries: _plain(30),
        profileId: 1,
        showAll: false,
      );
      expect(folded, isNot(contains(SymptomAddOn.interference)));
      expect(folded, isNot(contains(SymptomAddOn.impact)));
    });

    test('other profiles do not count', () {
      final entries = [..._plain(10, profileId: 2), ..._plain(3, offset: 100)];
      expect(
        SymptomAddOns.folded(entries: entries, profileId: 1, showAll: false),
        isEmpty,
      );
    });

    test('"Show all symptom options" turns folding off', () {
      expect(
        SymptomAddOns.folded(entries: _plain(10), profileId: 1, showAll: true),
        isEmpty,
      );
    });
  });

  group('Profile symptom options (real Isar)', () {
    late Isar isar;
    late ProviderContainer container;
    late int id;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await Isar.open(
        [ProfileIsarSchema],
        directory: '',
        name: 'symptom_options_${DateTime.now().microsecondsSinceEpoch}',
      );
      container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      id = await isar.writeTxn(
        () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
      );
    });

    tearDown(() async {
      container.dispose();
      await isar.close(deleteFromDisk: true);
    });

    test('a new profile has folding on and has not seen the note', () async {
      final p = (await isar.profileIsars.get(id))!.toDomain();
      expect(p.showAllSymptomOptions, isFalse);
      expect(p.symptomFoldNoteShown, isFalse);
    });

    test('setShowAllSymptomOptions persists', () async {
      await container
          .read(profileListProvider.notifier)
          .setShowAllSymptomOptions(id, true);
      final row = (await isar.profileIsars.get(id))!;
      expect(row.showAllSymptomOptions, isTrue);
      expect(row.toDomain().showAllSymptomOptions, isTrue);
    });

    test('markSymptomFoldNoteShown persists', () async {
      await container
          .read(profileListProvider.notifier)
          .markSymptomFoldNoteShown(id);
      final row = (await isar.profileIsars.get(id))!;
      expect(row.symptomFoldNoteShown, isTrue);
      expect(row.toDomain().symptomFoldNoteShown, isTrue);
    });

    test('profile edit saves the switch and keeps the note flag', () async {
      await container
          .read(profileListProvider.notifier)
          .markSymptomFoldNoteShown(id);
      await container
          .read(profileListProvider.notifier)
          .update(Profile(id: id, name: 'Sarah', showAllSymptomOptions: true));
      final row = (await isar.profileIsars.get(id))!;
      expect(row.showAllSymptomOptions, isTrue);
      expect(
        row.symptomFoldNoteShown,
        isTrue,
        reason: 'editing a profile must not bring the note back',
      );
    });

    test('copyWith carries the new fields', () {
      final p = Profile(id: 1, name: 'Sarah');
      final q = p.copyWith(
        showAllSymptomOptions: true,
        symptomFoldNoteShown: true,
      );
      expect(q.showAllSymptomOptions, isTrue);
      expect(q.symptomFoldNoteShown, isTrue);
      expect(q.copyWith(name: 'S').showAllSymptomOptions, isTrue);
    });
  });
}
