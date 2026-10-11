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

// TODO(#145): stubs.
GuideCardMode guideCardMode({
  required bool pending,
  required GuideRecord record,
  required DateTime now,
  required bool hiddenThisSession,
}) => throw UnimplementedError('#145');

List<GuideChoice> guideChoices({required bool customized}) =>
    throw UnimplementedError('#145');

String choiceLabel(GuideChoice c) => throw UnimplementedError('#145');

String guideCardTitle({required bool customized}) =>
    throw UnimplementedError('#145');

List<String> movedPinNotes(
  List<String>? stored, {
  Map<String, String>? retired,
  String Function(String id)? label,
}) => throw UnimplementedError('#145');

String pinnedLine(String label) => throw UnimplementedError('#145');

String pinFullLine(String label) => throw UnimplementedError('#145');
