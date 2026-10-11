import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Last tab used in each section, by section id (#141). Held in memory
/// only, never stored: when the app is closed, every section opens on its
/// first tab again (navigation.feature, "Remembered tabs reset when the
/// app is closed"). Written as tabs are shown; nothing watches it.
final lastTabProvider = Provider<Map<String, String>>((ref) => {});

/// Last section shown in the bar, for screens in no section (Reports).
final lastSectionProvider = Provider<Map<String, String>>((ref) => {});

/// Scroll positions of section tabs, keyed by tab id, so switching tabs
/// and back keeps your place. Each tab switch is a new route, and a
/// route's own storage goes with it, so this one sits above them all.
final sectionScrollBucketProvider = Provider<PageStorageBucket>(
  (ref) => PageStorageBucket(),
);
