import 'package:flutter/material.dart';

import 'package:health_flare/models/symptom_entry.dart';

/// Optional details a symptom entry can carry, offered under
/// "Add if it helps" on the symptom form.
enum SymptomAddOn {
  where('Where', Icons.place_outlined),
  interference('How much it got in the way', Icons.block_outlined),
  impact('What it stopped you doing', Icons.edit_note),
  notes('Anything else', Icons.chat_bubble_outline);

  const SymptomAddOn(this.chipLabel, this.icon);

  /// Label on the "Add if it helps" chip.
  final String chipLabel;
  final IconData icon;
}

/// Rules for which add-ons open on their own and which fold away.
abstract final class SymptomAddOns {
  /// Entries in a row without an add-on before it folds away.
  static const quietAfter = 10;

  /// Add-ons that may fold away. Interference and impact never do.
  static const foldable = {SymptomAddOn.where, SymptomAddOn.notes};

  /// The add-ons [entry] has a value for. Blank text does not count.
  static Set<SymptomAddOn> usedIn(SymptomEntry entry) => {
    if (entry.locations.isNotEmpty) SymptomAddOn.where,
    if (entry.interference != null) SymptomAddOn.interference,
    if (_hasText(entry.impact)) SymptomAddOn.impact,
    if (_hasText(entry.notes)) SymptomAddOn.notes,
  };

  /// The add-ons used on [profileId]'s most recent entry for [name].
  ///
  /// Worked out from the person's own entries each time; nothing is stored.
  /// Removing a field this time means the newest entry lacks it, so it will
  /// not open next time.
  static Set<SymptomAddOn> fromLastTime({
    required List<SymptomEntry> entries,
    required int profileId,
    required String name,
  }) {
    final last = lastEntryFor(
      entries: entries,
      profileId: profileId,
      name: name,
    );
    return last == null ? {} : usedIn(last);
  }

  /// The most recent entry for [name] on [profileId], or null. Names match
  /// ignoring case and surrounding spaces.
  static SymptomEntry? lastEntryFor({
    required List<SymptomEntry> entries,
    required int profileId,
    required String name,
  }) {
    final key = _key(name);
    if (key.isEmpty) return null;
    SymptomEntry? latest;
    for (final e in entries) {
      if (e.profileId != profileId || _key(e.name) != key) continue;
      if (latest == null || e.loggedAt.isAfter(latest.loggedAt)) latest = e;
    }
    return latest;
  }

  /// Foldable add-ons unused in [profileId]'s last [quietAfter] entries.
  /// Nothing folds until there are [quietAfter] entries to judge by, and
  /// nothing folds when [showAll] is on.
  static Set<SymptomAddOn> folded({
    required List<SymptomEntry> entries,
    required int profileId,
    required bool showAll,
  }) {
    if (showAll) return {};
    final recent = entries.where((e) => e.profileId == profileId).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    if (recent.length < quietAfter) return {};
    final used = <SymptomAddOn>{
      for (final e in recent.take(quietAfter)) ...usedIn(e),
    };
    return foldable.difference(used);
  }

  static bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  static String _key(String name) => name.trim().toLowerCase();
}
