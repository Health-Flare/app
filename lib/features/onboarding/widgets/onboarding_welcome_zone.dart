import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Zone 1 — Welcome & purpose.
///
/// Copy source: docs/onboarding-copy.md › Zone 1
class OnboardingWelcomeZone extends StatelessWidget {
  const OnboardingWelcomeZone({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.teal,
            AppColors.tealDark,
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
            ],
          ),
        ),
      ),
    );
  }
}
