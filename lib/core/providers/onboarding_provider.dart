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

/// Tracks whether the quick-log sheet should open automatically for the
/// active profile the next time it reaches the dashboard.
///
/// ## Persistence
/// The shown state is stored in [ProfileIsar.firstLogShown] so it survives
/// app restarts. Each profile has its own flag — creating a second profile
/// triggers the automatic open for that profile regardless of whether it
/// was previously shown for the first.
///
/// ## Automatic trigger
/// [build] listens to [activeProfileProvider]. When the active profile
/// changes (e.g. a new profile is created and made active), it asynchronously
/// checks [ProfileIsar.firstLogShown] for the new profile and sets state to
/// `true` if the sheet has not yet been shown automatically.
///
/// ## Opening the sheet
/// `DashboardScreen` watches this provider and opens the same quick-log
/// sheet the "+" FAB uses (via `showDashboardQuickEntrySheet`) when state
/// transitions to `true`. The Dashboard calls [markShown] immediately
/// before opening it, which persists the flag and prevents the automatic
/// open from happening again — even if the user dismisses the sheet
/// without saving anything.
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
  /// Called by `DashboardScreen` immediately before opening the sheet so
  /// the automatic open never happens again — even if the user dismisses
  /// the sheet without saving anything.
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
}

final firstLogPromptProvider = NotifierProvider<FirstLogPromptNotifier, bool>(
  FirstLogPromptNotifier.new,
);

/// Tracks whether the weather opt-in prompt should be shown for the active
/// profile.
///
/// Mirrors the pattern of [FirstLogPromptNotifier]: state is derived from
/// [ProfileIsar.weatherOptInShown] and persisted immediately when the user
/// makes a choice, so it cannot be shown twice.
///
/// [dismiss] saves both the "shown" flag and the user's preference
/// ([ProfileIsar.weatherTrackingEnabled]) in a single Isar transaction.
class WeatherOptInNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.listen<int?>(activeProfileProvider, (prev, next) {
      if (next != null) {
        _syncFromProfile(next);
      } else {
        state = false;
      }
    });

    final profileId = ref.read(activeProfileProvider);
    if (profileId != null) {
      _syncFromProfile(profileId);
    }

    return false;
  }

  Future<void> _syncFromProfile(int profileId) async {
    final isar = ref.read(isarProvider);
    final row = await isar.profileIsars.get(profileId);
    state = !(row?.weatherOptInShown ?? false);
  }

  /// Persists the user's choice and marks the prompt as shown.
  ///
  /// [enabled] = true if the user tapped "Enable weather tracking".
  /// [enabled] = false if the user tapped "Not now".
  Future<void> dismiss({required bool enabled}) async {
    if (!state) return;
    state = false;

    final isar = ref.read(isarProvider);
    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) return;

    final row = await isar.profileIsars.get(profileId);
    if (row == null) return;

    await isar.writeTxn(() async {
      row
        ..weatherOptInShown = true
        ..weatherTrackingEnabled = enabled;
      await isar.profileIsars.put(row);
    });
  }
}

final weatherOptInProvider = NotifierProvider<WeatherOptInNotifier, bool>(
  WeatherOptInNotifier.new,
);
