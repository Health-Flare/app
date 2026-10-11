// The bar as shown (#143): stored choice -> what's in the bar and in More.
// Pure: no database, no widgets. Spec: navigation-customization.feature
// ("Bottom bar (per device)", "Later updates").
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';

const _default = ['dashboard', 'track', 'care', 'journal'];

bool _all(String id) => true;

/// As if a later update merged Activity into Sleep: its id is retired.
final _knownWithoutActivity = {
  for (final s in navSections) ...[s.id, for (final t in s.tabs) t.id],
}..remove('track.activity');

List<String> _ids(List<BarSlot> slots) => [for (final s in slots) s.id];

BarSlot _more(List<BarSlot> slots) => slots.firstWhere((s) => s.id == moreId);

/// Shown unless turned off: [off] holds tab ids; a section shows while any
/// of its tabs does.
bool Function(String) _offFor(List<String> off) => (id) {
  if (off.contains(id)) return false;
  final section = navSections.where((s) => s.id == id).firstOrNull;
  if (section == null || section.tabs.isEmpty) return true;
  return section.tabs.any((t) => !off.contains(t.id));
};

void main() {
  test('the default bar is Dashboard, Track, Care and Journal, no More', () {
    expect(_ids(effectiveBar(_default, shown: _all)), _default);
  });

  group('Pin a screen to the bar', () {
    test('Medications joins the end', () {
      final slots = effectiveBar([
        ..._default,
        'care.medications',
      ], shown: _all);
      expect(_ids(slots), [..._default, 'care.medications']);
      expect(slots.last.label, 'Medications');
    });

    test('Care is not highlighted while Medications is open', () {
      final slots = effectiveBar([
        ..._default,
        'care.medications',
      ], shown: _all);
      expect(
        selectedSlotId(slots, Uri.parse('/medications')),
        'care.medications',
      );
      expect(selectedSlotId(slots, Uri.parse('/appointments')), 'care');
      expect(
        selectedSlotId(slots, Uri.parse('/medications/3')),
        'care.medications',
      );
    });
  });

  group('A section left out of the bar goes into More', () {
    test('removing Journal puts More at the end, listing Journal', () {
      final slots = effectiveBar(['dashboard', 'track', 'care'], shown: _all);
      expect(_ids(slots), ['dashboard', 'track', 'care', moreId]);
      expect(_more(slots).moreIds, ['journal']);
    });

    test('a Journal tab opened from More highlights More', () {
      final slots = effectiveBar(['dashboard', 'track', 'care'], shown: _all);
      expect(selectedSlotId(slots, Uri.parse('/checkin')), moreId);
      expect(selectedSlotId(slots, Uri.parse(moreLocation)), moreId);
    });

    test('More counts toward the five-item limit', () {
      final three = ['dashboard', 'track', 'care'];
      expect(canAdd(three, 'care.medications'), isTrue); // 4 + More = 5
      expect(canAdd([...three, 'care.medications'], 'track.meals'), isFalse);
      expect(barLimitNote([...three, 'care.medications']), contains('More'));
    });
  });

  test('More only appears when it has something in it', () {
    expect(_ids(effectiveBar(_default, shown: _all)), isNot(contains(moreId)));
    // Journal turned off entirely: not in the bar, and not in More.
    final off = _offFor(['journal.entries', 'journal.checkins']);
    expect(_ids(effectiveBar(_default, shown: off)), [
      'dashboard',
      'track',
      'care',
    ]);
  });

  group('The bar holds three to five items', () {
    test("can't remove an item when three are left", () {
      expect(canRemove(['dashboard', 'track', 'care', 'journal']), isTrue);
      expect(canRemove(['dashboard', 'track', 'care']), isFalse);
      expect(barLimitNote(['dashboard', 'track', 'care']), isNotNull);
    });

    test("can't add an item when five are in the bar", () {
      final five = [..._default, 'care.medications'];
      expect(canAdd(five, 'track.meals'), isFalse);
      expect(barLimitNote(five), isNotNull);
    });

    test('no note in between', () {
      expect(barLimitNote(_default), isNull);
    });
  });

  test('Dashboard is always first', () {
    expect(
      _ids(
        effectiveBar(['track', 'dashboard', 'care', 'journal'], shown: _all),
      ),
      _default,
    );
    expect(
      _ids(effectiveBar(['track', 'care', 'journal'], shown: _all)),
      _default,
    );
  });

  group('The bar can be set up close to the old one', () {
    test('Dashboard, Track, Medications, Meals and More', () {
      final slots = effectiveBar(likeBeforePreset, shown: _all);
      expect(_ids(slots), [
        'dashboard',
        'track',
        'care.medications',
        'track.meals',
        moreId,
      ]);
      expect(
        [for (final s in slots) s.label],
        ['Dashboard', 'Track', 'Medications', 'Meals', 'More'],
      );
    });

    test('More lists Care and Journal', () {
      expect(_more(effectiveBar(likeBeforePreset, shown: _all)).moreIds, [
        'care',
        'journal',
      ]);
    });

    test('the note', () {
      expect(
        likeBeforeNote,
        'The old bar had six items. Sleep is now in Track.',
      );
    });
  });

  group('Pinned screens for a turned-off feature drop out quietly', () {
    test('Meals is not shown while it is off; the stored bar is untouched', () {
      final stored = [..._default, 'track.meals'];
      final shown = effectiveBar(stored, shown: _offFor(['track.meals']));
      expect(_ids(shown), _default);
      expect(stored, [..._default, 'track.meals']);
    });

    test('fewer than three left uses the default bar', () {
      final stored = ['dashboard', 'track.meals', 'track.sleep'];
      final shown = effectiveBar(
        stored,
        shown: _offFor(['track.meals', 'track.sleep']),
      );
      expect(_ids(shown), _default);
    });
  });

  test('a feature turned back on never pushes the bar past five', () {
    // Five stored while Journal was off; Journal back on needs More.
    final stored = [
      'dashboard',
      'track',
      'care',
      'care.medications',
      'track.meals',
    ];
    final slots = effectiveBar(stored, shown: _all);
    expect(_ids(slots), [
      'dashboard',
      'track',
      'care',
      'care.medications',
      moreId,
    ]);
    expect(_more(slots).moreIds, ['journal', 'track.meals']);
  });

  group('Later updates (with a fake replacement map)', () {
    test('A pinned screen that was merged follows its replacement', () {
      final ids = resolveBarIds(
        ['dashboard', 'track', 'track.activity', 'care'],
        defaultBar: _default,
        retired: const {'track.activity': 'track.sleep'},
        known: _knownWithoutActivity,
      );
      expect(ids, ['dashboard', 'track', 'track.sleep', 'care']);
    });

    test('and if that tab is already in the bar, the duplicate is removed', () {
      final ids = resolveBarIds(
        ['dashboard', 'track.sleep', 'track.activity', 'care'],
        defaultBar: _default,
        retired: const {'track.activity': 'track.sleep'},
        known: _knownWithoutActivity,
      );
      expect(ids, ['dashboard', 'track.sleep', 'care']);
    });

    test("A turned-off feature that was merged keeps the user's choice: the "
        'tab it merged into stays on', () {
      // Activity off; an update merges it into Sleep, which is on. The
      // switch is stored by id, so Sleep's own switch decides.
      final shown = _offFor(['track.activity']);
      expect(shown('track.sleep'), isTrue);
    });

    test("An id the app doesn't recognise is skipped safely", () {
      final ids = barFor(
        const BarRecord(
          storedBar: ['dashboard', 'track.water', 'care', 'journal'],
          seenVersion: 2,
        ),
        current: 2,
      );
      expect(ids, ['dashboard', 'care', 'journal']);
    });
  });

  test('the move announcement', () {
    expect(
      moveAnnouncement('Medications', 3, 5),
      'Medications, position 3 of 5',
    );
  });

  test('every tab can be pinned: it has an icon and a label for the bar', () {
    for (final s in navSections) {
      for (final t in s.tabs) {
        final slot = effectiveBar([..._default, t.id], shown: _all).last;
        expect(slot.id, t.id);
        expect(slot.label, isNotEmpty);
      }
    }
  });
}
