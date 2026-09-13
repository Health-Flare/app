import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/features/onboarding/widgets/first_log_prompt.dart';
import 'package:health_flare/features/onboarding/widgets/weather_opt_in_sheet.dart';
import 'package:health_flare/features/shared/widgets/guided_step_header.dart';

enum _StepKind { weather, firstLog }

/// Post-setup guided mini-flow — pushed full-screen from the Dashboard once
/// per profile, for whichever of the weather opt-in and first-log prompt
/// have not yet been shown for the active profile.
///
/// Reuses [GuidedStepHeader], the same header used by the main onboarding
/// flow, so a one-time prompt doesn't feel like a different screen bolted
/// onto the side of the app.
class PostSetupFlowScreen extends ConsumerStatefulWidget {
  const PostSetupFlowScreen({
    super.key,
    required this.showWeatherStep,
    required this.showFirstLogStep,
    required this.profileName,
  });

  final bool showWeatherStep;
  final bool showFirstLogStep;
  final String profileName;

  @override
  ConsumerState<PostSetupFlowScreen> createState() =>
      _PostSetupFlowScreenState();
}

class _PostSetupFlowScreenState extends ConsumerState<PostSetupFlowScreen> {
  late final List<_StepKind> _steps = [
    if (widget.showWeatherStep) _StepKind.weather,
    if (widget.showFirstLogStep) _StepKind.firstLog,
  ];
  late final _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (_steps.isEmpty) {
      // Nothing to show — pop once the first frame is up rather than
      // during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _advance() {
    if (_index >= _steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipCurrentStep() async {
    if (_steps[_index] == _StepKind.weather) {
      await _handleWeatherResult(false);
    } else {
      await ref.read(firstLogPromptProvider.notifier).markShown();
      _advance();
    }
  }

  Future<void> _handleWeatherResult(bool enabled) async {
    await ref.read(weatherOptInProvider.notifier).dismiss(enabled: enabled);
    _advance();
  }

  String _titleFor(_StepKind step) => switch (step) {
    _StepKind.weather => 'Enable weather tracking',
    _StepKind.firstLog => 'Log your first entry',
  };

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const SizedBox.shrink();

    // No back-swipe/back-button dismissal — each step's own Skip control
    // (or, on the first-log step, its "I'll explore on my own" link) is the
    // only way out, so a choice always gets persisted via markShown/dismiss.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GuidedStepHeader(
                total: _steps.length,
                currentIndex: _index,
                stepTitle: _titleFor(_steps[_index]),
                onSkip: _skipCurrentStep,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  children: [
                    for (final step in _steps)
                      if (step == _StepKind.weather)
                        SingleChildScrollView(
                          child: WeatherTrackingOptInSheet(
                            onResult: _handleWeatherResult,
                          ),
                        )
                      else
                        // FirstLogPrompt scrolls internally.
                        FirstLogPrompt(
                          profileName: widget.profileName,
                          onFinished: _advance,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
