import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';

// When the guide card shows, and what the guide offers (#145). Pure.

/// What's stored about the pending guide on this device.
class GuideRecord {
  const GuideRecord({this.putOffOn, this.resumeStep});

  /// The day "Not now" was tapped. The card comes back once, on a later day.
  final DateTime? putOffOn;

  /// The step the guide was left on, to resume at. Null: not started, or
  /// seen.
  final int? resumeStep;

  @override
  bool operator ==(Object other) =>
      other is GuideRecord &&
      other.putOffOn == putOffOn &&
      other.resumeStep == resumeStep;

  @override
  int get hashCode => Object.hash(putOffOn, resumeStep);

  @override
  String toString() => 'GuideRecord(putOff: $putOffOn, step: $resumeStep)';
}

enum GuideCardMode { hidden, notNow, dismiss }

enum GuideChoice { useNew, likeBefore, setUpMyself, keepMine }

/// Whether the guide card shows, and with which button.
///
/// "Not now" hides it for the session and stores the day. On a later day it
/// shows once more, with "Dismiss" instead. Seen (Dismiss, Skip, Done, a
/// choice) clears [pending], so it never comes back.
GuideCardMode guideCardMode({
  required bool pending,
  required GuideRecord record,
  required DateTime now,
  required bool hiddenThisSession,
}) {
  if (!pending || hiddenThisSession) return GuideCardMode.hidden;
  final putOff = record.putOffOn;
  if (putOff == null) return GuideCardMode.notNow;
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(putOff.year, putOff.month, putOff.day);
  return today.isAfter(day) ? GuideCardMode.dismiss : GuideCardMode.hidden;
}

/// "Keep it or change it", in order; the first is selected.
List<GuideChoice> guideChoices({required bool customized}) => customized
    ? const [GuideChoice.keepMine, GuideChoice.useNew, GuideChoice.setUpMyself]
    : const [
        GuideChoice.useNew,
        GuideChoice.likeBefore,
        GuideChoice.setUpMyself,
      ];

String choiceLabel(GuideChoice c) => switch (c) {
  GuideChoice.useNew => 'Use the new layout',
  GuideChoice.likeBefore => 'Keep it like before',
  GuideChoice.setUpMyself => 'Set it up myself',
  GuideChoice.keepMine => 'Keep my bar',
};

String guideCardTitle({required bool customized}) => customized
    ? 'The default bottom bar has changed. Yours has been kept.'
    : 'The bottom bar has changed';

/// For each pinned screen a later version merged into another: what
/// happened, for the guide card. The pin already follows (resolveNavIds).
List<String> movedPinNotes(
  List<String>? stored, {
  Map<String, String>? retired,
  String Function(String id)? label,
}) {
  if (stored == null) return const [];
  final map = retired ?? retiredNavIds;
  final name = label ?? barLabelFor;
  return [
    for (final id in stored)
      if (map[id] case final to?)
        '${name(id)} is now part of ${name(to)}, so your bar shows '
            '${name(to)}.',
  ];
}

/// After "Pin". Pinning makes the bar the person's own, so it stops
/// following new defaults; this says so.
String pinnedLine(String label) =>
    '$label is in your bar. Your bar is now your own, so later updates '
    "won't change it.";

String pinFullLine(String label) =>
    'The bar holds five items. Remove one to add $label.';
