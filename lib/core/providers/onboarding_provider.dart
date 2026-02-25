import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Tracks whether the first-log prompt has been shown for the current session.
/// Shown once per profile creation, dismissed permanently after first interaction.
class FirstLogPromptNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void dismiss() => state = false;
}

final firstLogPromptProvider = NotifierProvider<FirstLogPromptNotifier, bool>(
  FirstLogPromptNotifier.new,
);
