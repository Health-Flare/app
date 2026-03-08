import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

/// Tracks whether the user has completed onboarding.
///
/// Derived from [profileListProvider]: onboarding is complete whenever at
/// least one profile exists. This rebuilds automatically when profiles are
/// added or removed, so the router guard reacts without any explicit calls.
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final profiles = ref.watch(profileListProvider);
    return profiles.isNotEmpty;
  }

  /// No-op — state is fully derived from [profileListProvider].
  /// Kept for call-site compatibility with existing onboarding screens.
  void markComplete() {}

  /// No-op — state is fully derived from [profileListProvider].
  void markAlreadyComplete() {}
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

/// Tracks whether the first-log prompt should be shown for the active profile.
///
/// ## Persistence
/// The shown state is stored in [ProfileIsar.firstLogShown] so it survives
/// app restarts. Each profile has its own flag — creating a second profile
/// will show the prompt for that profile regardless of whether it was
/// previously shown for the first.
///
/// ## Automatic trigger
/// [build] listens to [activeProfileProvider]. When the active profile
/// changes (e.g. a new profile is created and made active), it asynchronously
/// checks [ProfileIsar.firstLogShown] for the new profile and sets state to
/// `true` if the prompt has not yet been shown.
///
/// ## Showing the prompt
/// [DashboardScreen] watches this provider and shows [FirstLogPrompt] as a
/// modal bottom sheet when state transitions to `true`. The Dashboard calls
/// [markShown] immediately before displaying the sheet, which persists the
/// flag and prevents the prompt from appearing again — even if the user
/// swipes the sheet away without tapping any option.
class FirstLogPromptNotifier extends Notifier<bool> {
  @override
  bool build() {
    // React to active-profile changes (new profile created, profile switched).
    ref.listen<int?>(activeProfileProvider, (prev, next) {
      if (next != null) {
        _syncFromProfile(next);
      } else {
        state = false;
      }
    });

    // Check the initial active profile on first build.
    final profileId = ref.read(activeProfileProvider);
    if (profileId != null) {
      _syncFromProfile(profileId);
    }

    return false;
  }

  /// Reads [ProfileIsar.firstLogShown] for [profileId] and updates state.
  Future<void> _syncFromProfile(int profileId) async {
    final isar = ref.read(isarProvider);
    final row = await isar.profileIsars.get(profileId);
    state = !(row?.firstLogShown ?? false);
  }

  /// Persists [ProfileIsar.firstLogShown] = true and sets state to false.
  ///
  /// Called by [DashboardScreen] immediately before displaying the sheet so
  /// the prompt is never shown again — even if the user swipes the sheet away.
  Future<void> markShown() async {
    if (!state) return; // already marked
    state = false;

    final isar = ref.read(isarProvider);
    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) return;

    final row = await isar.profileIsars.get(profileId);
    if (row == null) return;

    await isar.writeTxn(() async {
      row.firstLogShown = true;
      await isar.profileIsars.put(row);
    });
  }

  // ── Backwards-compatibility stubs ─────────────────────────────────────────

  /// No-op — prompt is triggered automatically via [activeProfileProvider].
  /// Retained so [OnboardingScreen] compiles without changes.
  void show() {}

  /// Alias for [markShown] — used by option cards inside [FirstLogPrompt].
  Future<void> dismiss() => markShown();
}

final firstLogPromptProvider = NotifierProvider<FirstLogPromptNotifier, bool>(
  FirstLogPromptNotifier.new,
);
