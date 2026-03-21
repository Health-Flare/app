import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/theme/app_colors.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_welcome_zone.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_privacy_zone.dart';
import 'package:health_flare/features/onboarding/widgets/onboarding_profile_zone.dart';
import 'package:health_flare/models/condition.dart';

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
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _OnboardingBody(),
    );
  }
}

class _OnboardingBody extends ConsumerStatefulWidget {
  const _OnboardingBody();

  @override
  ConsumerState<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends ConsumerState<_OnboardingBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();
  final _nameFocusNode = FocusNode();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Ensure the screen always starts at the very top, even on devices where
    // the system tries to scroll to a focused field during the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

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

    // onboardingProvider derives from profileListProvider — no explicit call
    // needed, but kept for call-site clarity.
    ref.read(onboardingProvider.notifier).markComplete();

    // Weather opt-in and first-log prompt are shown on the Dashboard once
    // the router navigates there automatically (onboardingProvider → false).
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Zone 1 — Welcome
        const SliverToBoxAdapter(child: OnboardingWelcomeZone()),

        // Zone 2 — Privacy
        const SliverToBoxAdapter(child: OnboardingPrivacyZone()),

        // Zone 3 — Profile creation
        SliverToBoxAdapter(
          child: OnboardingProfileZone(
            formKey: _formKey,
            nameController: _nameController,
            nameFocusNode: _nameFocusNode,
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
