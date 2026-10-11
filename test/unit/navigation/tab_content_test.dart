// What each tab's add button opens (#141).
// Spec: navigation.feature, "A section's add button follows the selected
// tab"; quick-log.feature, "Typed screens keep an add button".
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/models/daily_checkin.dart';

final _today = DailyCheckin(
  id: 42,
  profileId: 1,
  checkinDate: DateTime(2026, 10, 10),
  createdAt: DateTime(2026, 10, 10, 8),
);

AddTarget _target(String tabId, {DailyCheckin? today}) {
  final container = ProviderContainer(
    overrides: [todayCheckinProvider.overrideWith((ref) => today)],
  );
  addTearDown(container.dispose);
  final content = container.read(tabContentProvider)[tabId]!;
  return container.read(content.addTarget);
}

void main() {
  test('every tab has content', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final contents = container.read(tabContentProvider);
    for (final s in navSections) {
      for (final t in s.tabs) {
        expect(contents[t.id], isNotNull, reason: t.id);
      }
    }
  });

  group("A section's add button follows the selected tab", () {
    const forms = {
      'track.symptoms': '/tracking/new-symptom',
      'track.vitals': '/tracking/new-vital',
      'track.meals': '/meals/new',
      'track.sleep': '/sleep/new',
      'track.activity': '/activity/new',
      'care.medications': '/medications/new',
      'care.appointments': '/appointments/new',
      'care.conditions': '/illness',
      'care.flares': '/flare/new',
      'journal.entries': '/journal/new',
      'journal.checkins': '/checkin/new',
    };

    for (final MapEntry(key: tab, value: location) in forms.entries) {
      test('$tab opens $location', () {
        expect(_target(tab).location, location);
      });
    }
  });

  group('Check-ins add button', () {
    test("opens today's check-in", () {
      expect(_target('journal.checkins').location, '/checkin/new');
    });

    test('opens it to edit if it is already done', () {
      final t = _target('journal.checkins', today: _today);
      expect(t.location, '/checkin/42/edit');
      expect(t.extra, same(_today));
    });
  });
}
