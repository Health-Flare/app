import 'package:flutter/material.dart';

import 'package:health_flare/core/theme/app_colors.dart';

/// Zone 1 — Welcome & purpose.
///
/// Copy source: docs/onboarding-copy.md › Zone 1
class OnboardingWelcomeZone extends StatefulWidget {
  const OnboardingWelcomeZone({super.key});

  @override
  State<OnboardingWelcomeZone> createState() => _OnboardingWelcomeZoneState();
}

class _OnboardingWelcomeZoneState extends State<OnboardingWelcomeZone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<Offset> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.35),
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final topPadding = MediaQuery.viewPaddingOf(context).top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryAction,
            AppColors.secondaryAction,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, topPadding > 0 ? 20 : 40, 28, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App wordmark
              Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 28,
                    semanticLabel: '',
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Health Flare',
                    style: tt.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    semanticsLabel: 'Health Flare',
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Headline
              Text(
                'Your health story,\nin your hands.',
                style: tt.headlineLarge?.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
                semanticsLabel: 'Your health story, in your hands.',
              ),

              const SizedBox(height: 20),

              // Body copy
              Text(
                'Living with a chronic illness means tracking a lot. '
                'Symptoms, medications, meals, patterns — it adds up. '
                'Health Flare gives you one calm place to record it all, '
                'so nothing gets lost between appointments.',
                style: tt.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(229),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "It's not a doctor. It won't diagnose you. But it will help "
                'you walk into your next appointment with a clear, organised '
                'picture of how you\'ve really been feeling.',
                style: tt.bodyLarge?.copyWith(
                  color: Colors.white.withAlpha(229),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 28),

              // Medical disclaimer
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Health Flare is a personal health journal. It is not a '
                  'medical device and does not provide medical advice, '
                  'diagnosis, or treatment.',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(204),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Scroll hint — tells the user the form is below
              Semantics(
                label: 'Scroll down to create your profile',
                child: Center(
                  child: SlideTransition(
                    position: _bounceAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scroll down to get started',
                          style: tt.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(178),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withAlpha(178),
                          size: 28,
                          semanticLabel: '',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
