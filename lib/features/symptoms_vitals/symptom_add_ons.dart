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

  /// The add-ons [entry] has a value for.
  static Set<SymptomAddOn> usedIn(SymptomEntry entry) => {};

  /// The add-ons used on [profileId]'s most recent entry for [name].
  static Set<SymptomAddOn> fromLastTime({
    required List<SymptomEntry> entries,
    required int profileId,
    required String name,
  }) => {};

  /// The most recent entry for [name] on [profileId], or null.
  static SymptomEntry? lastEntryFor({
    required List<SymptomEntry> entries,
    required int profileId,
    required String name,
  }) => null;

  /// Foldable add-ons unused in [profileId]'s last [quietAfter] entries.
  static Set<SymptomAddOn> folded({
    required List<SymptomEntry> entries,
    required int profileId,
    required bool showAll,
  }) => {};
}
