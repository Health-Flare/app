import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether the user has completed onboarding.
///
/// In the MVP this is stored in memory only — a profile existing in the
/// database is the true source of truth. This provider bridges the gap
/// between app startup and a real database check being available.
///
/// Replace with a persistent check (e.g. SharedPreferences or Isar query)
/// once the Profile model and database layer are wired up.
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Default: onboarding not complete. Will be flipped once a profile
    // is created, or on app startup when we detect existing profiles.
    return false;
  }

  /// Call this after the first profile is successfully saved.
  void markComplete() => state = true;

  /// Call on app startup if profiles already exist in the database.
  void markAlreadyComplete() => state = true;
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

/// Tracks whether the first-log prompt has been shown for the current session.
/// Shown once per profile creation, dismissed permanently after first interaction.
class FirstLogPromptNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void dismiss() => state = false;
}

final firstLogPromptProvider =
    NotifierProvider<FirstLogPromptNotifier, bool>(FirstLogPromptNotifier.new);
