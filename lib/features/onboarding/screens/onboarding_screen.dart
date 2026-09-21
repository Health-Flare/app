import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_features_zone.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_welcome_zone.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_privacy_zone.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_profile_zone.dart';
import 'package:health_flare/features/shared/widgets/guided_step_header.dart';
import 'package:health_flare/models/condition.dart';

/// Onboarding: shown exactly once on first launch, as a short guided flow.
///
/// Four steps on a shared [PageView]:
///   1. Welcome
///   2. What you can track (feature highlights)
///   3. Your privacy
///   4. Create profile (mandatory: the only step that cannot be skipped)
///
/// Steps 1-3 can be skipped straight to profile creation via the header's
/// "Skip" action, since a profile is the only thing actually required to
/// use the app. The CTA on step 4 is disabled until a valid profile name is
/// entered.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No explicit backgroundColor: inherit ThemeData.scaffoldBackgroundColor
    // so the screen tracks light/dark mode instead of staying pinned light.
    return const Scaffold(body: _OnboardingBody());
  }
}

class _OnboardingBody extends ConsumerStatefulWidget {
  const _OnboardingBody();

  @override
  ConsumerState<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends ConsumerState<_OnboardingBody> {
  static const _stepCount = 4;
  static const _stepTitles = [
    'Welcome',
    'What you can track',
    'Your privacy',
    'Create profile',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _pageController = PageController();

  int _index = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _next() => _goTo(_index + 1);
  void _back() => _goTo(_index - 1);
  void _skipToProfile() => _goTo(_stepCount - 1);

  Future<void> _submit(
    DateTime? dateOfBirth,
    String? avatarPath,
    List<Condition> selectedConditions,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // Create the first profile; Isar assigns the id and makes it active.
    await ref
        .read(profileListProvider.notifier)
        .add(
          name: _nameController.text.trim(),
          dateOfBirth: dateOfBirth,
          avatarPath: avatarPath,
        );
    if (!mounted) return;

    // Persist any conditions selected during onboarding.
    if (selectedConditions.isNotEmpty) {
      final conditionsNotifier = ref.read(userConditionListProvider.notifier);
      for (final condition in selectedConditions) {
        await conditionsNotifier.add(
          conditionId: condition.id,
          conditionName: condition.name,
        );
      }
    }
    if (!mounted) return;

    // onboardingProvider derives from profileListProvider: no explicit call
    // needed, but kept for call-site clarity.
    ref.read(onboardingProvider.notifier).markComplete();

    // The post-setup mini-flow (weather opt-in, first-log prompt) is shown
    // from the Dashboard once the router navigates there automatically
    // (onboardingProvider → false).
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GuidedStepHeader(
          total: _stepCount,
          currentIndex: _index,
          stepTitle: _stepTitles[_index],
          onBack: _index > 0 ? _back : null,
          onSkip: _index < _stepCount - 1 ? _skipToProfile : null,
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _index = i),
            children: [
              SingleChildScrollView(
                child: OnboardingWelcomeZone(onNext: _next),
              ),
              SingleChildScrollView(
                child: OnboardingFeaturesZone(onNext: _next),
              ),
              SingleChildScrollView(
                child: OnboardingPrivacyZone(onNext: _next),
              ),
              SingleChildScrollView(
                child: OnboardingProfileZone(
                  formKey: _formKey,
                  nameController: _nameController,
                  nameFocusNode: _nameFocusNode,
                  isSubmitting: _isSubmitting,
                  onSubmit: _submit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
