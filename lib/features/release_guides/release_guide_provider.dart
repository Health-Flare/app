import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide.dart';

// TODO(#145): stubs.
class GuideStore {
  GuideStore._();
  static Future<GuideRecord> read(Isar isar) => throw UnimplementedError();
  static Future<void> write(Isar isar, GuideRecord r) =>
      throw UnimplementedError();
}

typedef GuideSaver = Future<void> Function(GuideRecord record);

final guideStoreProvider = Provider<GuideSaver>((ref) => (r) async {});

/// The clock, so tests can move to a later day.
final guideClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class GuideState {
  const GuideState({
    required this.record,
    this.change,
    this.guide,
    this.hiddenThisSession = false,
  });
  final GuideRecord record;
  final BarChange? change;
  final ReleaseGuide? guide;
  final bool hiddenThisSession;
}

class ReleaseGuideNotifier extends Notifier<GuideState> {
  GuideRecord? _preloaded;
  void preload(GuideRecord r) => _preloaded = r;

  @override
  GuideState build() => GuideState(record: _preloaded ?? const GuideRecord());

  Future<void> putOff() => throw UnimplementedError();
  Future<void> markSeen() => throw UnimplementedError();
  Future<void> saveStep(int step) => throw UnimplementedError();
}

final releaseGuideProvider = NotifierProvider<ReleaseGuideNotifier, GuideState>(
  ReleaseGuideNotifier.new,
);

final guideCardModeProvider = Provider<GuideCardMode>(
  (ref) => throw UnimplementedError(),
);

/// The bar item outlined after "Show me", or null.
final barOutlineProvider = StateProvider<String?>((ref) => null);
