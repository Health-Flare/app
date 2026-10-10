// Track and Care routing (#141): which tab and section a location is.
// Spec: docs/features/navigation.feature ("Primary navigation", "Old links
// still open the right screen", "Every list screen can be reached in two
// taps or fewer").
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';

String? _tab(String location) => tabIdForLocation(Uri.parse(location));
String? _section(String location) => sectionIdForLocation(Uri.parse(location));

void main() {
  group('The primary navigation has four sections', () {
    test('Dashboard, Track, Care and Journal, in order', () {
      expect(
        [for (final s in navSections) s.id],
        ['dashboard', 'track', 'care', 'journal'],
      );
      expect(
        [for (final s in navSections) s.label],
        ['Dashboard', 'Track', 'Care', 'Journal'],
      );
    });
  });

  group('Each section opens with its first tab selected', () {
    test('tabs, in order', () {
      List<String> labels(String id) => [
        for (final t in navSections.firstWhere((s) => s.id == id).tabs) t.label,
      ];
      expect(labels('track'), [
        'Symptoms',
        'Vitals',
        'Meals',
        'Sleep',
        'Activity',
      ]);
      expect(labels('care'), [
        'Medications',
        'Appointments',
        'Conditions',
        'Flares',
      ]);
      expect(labels('journal'), ['Entries', 'Check-ins']);
    });
  });

  group('every tab has its own location', () {
    test('no two tabs share one', () {
      final all = [
        for (final s in navSections)
          for (final t in s.tabs) tabLocation(t.id),
      ];
      expect(all.toSet().length, all.length);
    });

    test('a tab\'s own location reads back as that tab', () {
      for (final s in navSections) {
        for (final t in s.tabs) {
          expect(_tab(tabLocation(t.id)), t.id, reason: tabLocation(t.id));
          expect(_section(tabLocation(t.id)), s.id);
        }
      }
    });
  });

  group('Old links still open the right screen', () {
    test('old list addresses open their tab', () {
      expect(_tab('/medications'), 'care.medications');
      expect(_tab('/sleep'), 'track.sleep');
      expect(_tab('/meals'), 'track.meals');
      expect(_tab('/activity'), 'track.activity');
      expect(_tab('/appointments'), 'care.appointments');
      expect(_tab('/flare'), 'care.flares');
      expect(_tab('/journal'), 'journal.entries');
      expect(_tab('/checkin'), 'journal.checkins');
      expect(_tab('/tracking'), 'track.symptoms');
    });

    test('and their section is the one selected', () {
      expect(_section('/medications'), 'care');
      expect(_section('/sleep'), 'track');
      expect(_section('/checkin'), 'journal');
      expect(_section('/dashboard'), 'dashboard');
      expect(_section('/'), 'dashboard');
    });

    test('screens opened from a tab keep its section selected', () {
      expect(_section('/medications/3'), 'care');
      expect(_section('/medications/3/dose/new'), 'care');
      expect(_section('/meals/new'), 'track');
      expect(_section('/journal/4/edit'), 'journal');
      expect(_tab('/tracking/new-vital'), 'track.vitals');
      expect(_tab('/tracking/7/edit-vital'), 'track.vitals');
      expect(_tab('/tracking/new-symptom'), 'track.symptoms');
      expect(_tab('/tracking/7/edit'), 'track.symptoms');
    });

    test('condition screens belong to Care, though their address is under '
        '/tracking', () {
      expect(_tab('/tracking/condition/2'), 'care.conditions');
      expect(_tab('/illness'), 'care.conditions');
      expect(_section('/tracking?tab=conditions'), 'care');
    });

    test('an unknown tab in the address falls back to the first tab', () {
      expect(_tab('/tracking?tab=nope'), 'track.symptoms');
    });

    test('screens outside every section belong to none', () {
      expect(_section('/reports'), isNull);
      expect(_section('/reports/insights'), isNull);
      expect(_section('/settings'), isNull);
      expect(_tab('/medicationsx'), isNull);
    });
  });

  group('Every list screen can be reached in two taps or fewer', () {
    test('each list screen is a tab of a section in the bar', () {
      const screens = {
        'Symptoms': 'track.symptoms',
        'Vitals': 'track.vitals',
        'Meals': 'track.meals',
        'Sleep': 'track.sleep',
        'Activity': 'track.activity',
        'Medications': 'care.medications',
        'Appointments': 'care.appointments',
        'Conditions': 'care.conditions',
        'Flare history': 'care.flares',
        'Journal entries': 'journal.entries',
        'Check-in history': 'journal.checkins',
      };
      for (final MapEntry(key: name, value: id) in screens.entries) {
        // One tap on the section, at most one on the tab.
        expect(
          sectionOfTab(id).tabs.map((t) => t.id),
          contains(id),
          reason: name,
        );
      }
    });
  });
}
