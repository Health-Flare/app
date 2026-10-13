import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide.dart';

/// Reads and writes the guide fields on [AppSettings] (#145). Per device.
class GuideStore {
  GuideStore._();

  static GuideRecord _from(AppSettings? s) => s == null
      ? const GuideRecord()
      : GuideRecord(putOffOn: s.guidePutOffOn, resumeStep: s.guideResumeStep);

  static Future<GuideRecord> read(Isar isar) async =>
      _from(await isar.appSettings.get(1));

  static Future<void> write(Isar isar, GuideRecord r) async {
    await isar.writeTxn(() async {
      final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
      s
        ..guidePutOffOn = r.putOffOn
        ..guideResumeStep = r.resumeStep;
      await isar.appSettings.put(s);
    });
  }
}

typedef GuideSaver = Future<void> Function(GuideRecord record);

/// Saves the guide record. Overridden in widget tests.
final guideStoreProvider = Provider<GuideSaver>(
  (ref) =>
      (r) => GuideStore.write(ref.read(isarProvider), r),
);

/// The clock, so tests can move to a later day.
final guideClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class GuideState {
  const GuideState({
    required this.record,
    this.change,
    this.guide,
    this.hiddenThisSession = false,
    this.highlightsOff = false,
  });

  final GuideRecord record;

  /// The default-bar change not yet seen on this device, with a guide.
  final BarChange? change;
  final ReleaseGuide? guide;
  final bool hiddenThisSession;

  /// "Show update highlights" off: no guide card either (whats-new.feature).
  final bool highlightsOff;
}

/// The pending release guide, if any. Follows the bar: once the change is
/// marked seen (or the bar is changed in Settings, which records the
/// current default), there's nothing pending.
class ReleaseGuideNotifier extends Notifier<GuideState> {
  GuideRecord? _record;
  bool? _highlightsOff;
  bool _hidden = false;

  /// Widget tests set this instead of reading the database.
  void preload(GuideRecord record, {bool highlightsOff = false}) {
    _record = record;
    _highlightsOff = highlightsOff;
  }

  @override
  GuideState build() {
    if (_record == null) {
      AppSettings? s;
      try {
        s = ref.read(isarProvider).appSettings.getSync(1);
      } catch (_) {
        // No database (a widget test of another screen): nothing stored.
      }
      _record = GuideStore._from(s);
      _highlightsOff = s?.updateHighlightsOff ?? false;
    }
    ref.watch(barChoiceProvider);
    return _compute();
  }

  GuideState _compute() {
    final change = pendingBarChange(
      ref.read(barChoiceProvider),
      current: kCurrentBarVersion,
    );
    final guide = change == null
        ? null
        : releaseGuides[defaultBarGuideIds[change.toVersion]];
    return GuideState(
      record: _record!,
      change: guide == null ? null : change,
      guide: guide,
      hiddenThisSession: _hidden,
      highlightsOff: _highlightsOff ?? false,
    );
  }

  Future<void> _save(GuideRecord r) async {
    _record = r;
    state = _compute();
    await ref.read(guideStoreProvider)(r);
  }

  /// "Not now": hidden for this session; back once on a later day.
  Future<void> putOff() {
    _hidden = true;
    final now = ref.read(guideClockProvider)();
    return _save(
      GuideRecord(
        putOffOn: DateTime(now.year, now.month, now.day),
        resumeStep: _record!.resumeStep,
      ),
    );
  }

  /// Dismiss, Skip, Back on the first step, Done, or a choice: the change
  /// counts as seen and the guide won't resume.
  Future<void> markSeen() async {
    await ref.read(barChoiceProvider.notifier).markChangeSeen();
    await _save(GuideRecord(putOffOn: _record!.putOffOn));
  }

  /// The step the guide is on, to resume at after leaving the app.
  Future<void> saveStep(int step) =>
      _save(GuideRecord(putOffOn: _record!.putOffOn, resumeStep: step));

  /// Follows "Show update highlights".
  void setHighlightsOff(bool off) {
    _highlightsOff = off;
    if (_record != null) state = _compute();
  }
}

final releaseGuideProvider = NotifierProvider<ReleaseGuideNotifier, GuideState>(
  ReleaseGuideNotifier.new,
);

/// Whether the dashboard shows the guide card, and with which button.
final guideCardModeProvider = Provider<GuideCardMode>((ref) {
  final s = ref.watch(releaseGuideProvider);
  if (s.highlightsOff) return GuideCardMode.hidden;
  return guideCardMode(
    pending: s.change != null,
    record: s.record,
    now: ref.read(guideClockProvider)(),
    hiddenThisSession: s.hiddenThisSession,
  );
});

/// The bar item outlined after "Show me", or null.
final barOutlineProvider = StateProvider<String?>((ref) => null);
