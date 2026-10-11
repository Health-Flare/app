import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/providers/database_provider.dart';

// The person's bottom bar choice (#143), per device, on AppSettings.
// Rules: navigation-customization.feature header.

typedef BarStore = Future<void> Function(BarRecord record);
typedef Announcer = void Function(BuildContext context, String message);

/// Saves a bar record. Overridden in widget tests.
final barStoreProvider = Provider<BarStore>(
  (ref) =>
      (record) => BarLayoutStore.write(ref.read(isarProvider), record),
);

/// Says [message] to a screen reader. Overridden in tests to record it.
final announcerProvider = Provider<Announcer>(
  (ref) =>
      (context, message) => SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
      ),
);

/// The stored choice. `main()` preloads what [BarLayoutStore.settle] read,
/// so the first frame has the right bar.
class BarChoiceNotifier extends Notifier<BarRecord> {
  BarRecord? _preloaded;

  void preload(BarRecord record) => _preloaded = record;

  int get _current => currentDefaultBarVersion(ref.read(featureFlagsProvider));

  List<String> get _default => defaultBarVersions[_current]!;

  @override
  BarRecord build() => _preloaded ?? BarRecord(seenVersion: _current);

  /// The bar's ids as chosen: stored, resolved (merged ids followed,
  /// unknown ones skipped), or the default. Features in use aren't applied
  /// here: see [effectiveBarProvider].
  List<String> get shownIds => barFor(state, current: _current);

  /// Stores [ids] as the bar (null, or the default itself, = the default:
  /// rule 4), on the current default version. Returns the record before, for
  /// Undo.
  Future<BarRecord> choose(List<String>? ids) async {
    final before = state;
    final stored = ids == null || _sameAsDefault(ids) ? null : List.of(ids);
    state = BarRecord(storedBar: stored, seenVersion: _current);
    await ref.read(barStoreProvider)(state);
    return before;
  }

  bool _sameAsDefault(List<String> ids) =>
      ids.length == _default.length &&
      [
        for (var i = 0; i < ids.length; i++) ids[i] == _default[i],
      ].every((x) => x);

  /// Puts back a record from before a change (Undo).
  Future<void> restore(BarRecord record) async {
    state = record;
    await ref.read(barStoreProvider)(state);
  }

  /// "Use default": stores no ids.
  Future<BarRecord> useDefault() => choose(null);

  /// The "Like before" preset, also used by the release guide.
  Future<BarRecord> applyLikeBefore() => choose(likeBeforePreset);
}

final barChoiceProvider = NotifierProvider<BarChoiceNotifier, BarRecord>(
  BarChoiceNotifier.new,
);

/// "Customized" in Settings, rather than "Default".
final barIsCustomizedProvider = Provider<bool>(
  (ref) => ref.watch(barChoiceProvider).storedBar != null,
);

/// Whether a section or tab can be shown for the active profile.
final barShownProvider = Provider<bool Function(String id)>((ref) {
  final sections = {for (final s in ref.watch(visibleSectionsProvider)) s.id};
  ref.watch(activeDisabledFeaturesProvider);
  return (id) {
    if (navSections.any((s) => s.id == id)) return sections.contains(id);
    return ref.read(featureOnProvider(id));
  };
});

/// The bar as shown now: the choice, with features in use applied.
final effectiveBarProvider = Provider<List<BarSlot>>((ref) {
  ref.watch(barChoiceProvider);
  final notifier = ref.read(barChoiceProvider.notifier);
  return effectiveBar(
    notifier.shownIds,
    shown: ref.watch(barShownProvider),
    fallback: notifier._default,
  );
});
