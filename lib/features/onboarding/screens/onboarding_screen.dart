import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/onboarding_welcome_zone.dart';
import '../widgets/onboarding_privacy_zone.dart';
import '../widgets/onboarding_profile_zone.dart';

/// Onboarding screen — shown exactly once on first launch.
///
/// Three zones on a single scrollable canvas:
///   Zone 1 — Welcome & purpose
///   Zone 2 — Privacy & data promise (with expandable detail)
///   Zone 3 — Profile creation form (inline, no navigation away)
///
/// The screen cannot be dismissed or skipped. The CTA button is disabled
/// until a valid profile name is entered.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // SafeArea handled per-zone so the hero gradient can bleed to the top.
      body: _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends ConsumerState<_OnboardingBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit(DateTime? dateOfBirth) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // dateOfBirth is available here for when the Isar profile save is wired up.
    // ignore: unused_local_variable
    final dob = dateOfBirth;

    // TODO: persist the profile to Isar once the data layer is ready.
    // For now we simulate a short async save.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Mark onboarding complete — the router will redirect to the dashboard.
    ref.read(onboardingProvider.notifier).markComplete();

    // Trigger the first-log prompt on the dashboard.
    ref.read(firstLogPromptProvider.notifier).show();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Zone 1 — Welcome
        SliverToBoxAdapter(
          child: OnboardingWelcomeZone(),
        ),

        // Zone 2 — Privacy
        SliverToBoxAdapter(
          child: OnboardingPrivacyZone(),
        ),

        // Zone 3 — Profile creation
        SliverToBoxAdapter(
          child: OnboardingProfileZone(
            formKey: _formKey,
            nameController: _nameController,
            isSubmitting: _isSubmitting,
            onSubmit: _submit,
          ),
        ),

        // Bottom safe-area padding
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
