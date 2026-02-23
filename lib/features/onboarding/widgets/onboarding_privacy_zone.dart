import 'package:flutter/material.dart';

import 'package:health_flare/core/theme/app_colors.dart';

/// Zone 2 — Privacy & data promise.
///
/// Shows a headline commitment, 4 supporting facts, and an expandable
/// "How does this work?" section with full plain-English detail.
///
/// Copy source: docs/onboarding-copy.md › Zone 2
class OnboardingPrivacyZone extends StatefulWidget {
  const OnboardingPrivacyZone({super.key});

  @override
  State<OnboardingPrivacyZone> createState() => _OnboardingPrivacyZoneState();
}

class _OnboardingPrivacyZoneState extends State<OnboardingPrivacyZone>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow label
          Text(
            'YOUR DATA',
            style: tt.labelSmall?.copyWith(
              color: cs.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          // Headline commitment
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: cs.primary,
                size: 28,
                semanticLabel: '',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Everything stays on this device.',
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Supporting privacy facts
          ..._privacyFacts(context),

          const SizedBox(height: 24),

          // "Learn more" toggle
          Semantics(
            button: true,
            label: _expanded
                ? 'Privacy details, expanded. Double tap to collapse.'
                : 'Privacy details, collapsed. Double tap to expand.',
            child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Got it  ‹' : 'How does this work?  ›',
                      style: tt.labelLarge?.copyWith(
                        color: cs.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable detail
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _ExpandedPrivacyDetail(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _privacyFacts(BuildContext context) {
    const facts = [
      (
        icon: Icons.no_accounts_outlined,
        text: 'No account or login required — ever.',
      ),
      (
        icon: Icons.cloud_off_outlined,
        text: 'Nothing is uploaded to any server or cloud.',
      ),
      (
        icon: Icons.share_outlined,
        text:
            'Your data only leaves this device when you choose to export or share it.',
      ),
      (
        icon: Icons.visibility_off_outlined,
        text: "We don't see it. We don't store it. We can't access it.",
      ),
    ];

    return facts.map((f) => _PrivacyFactRow(icon: f.icon, text: f.text)).toList();
  }
}

class _PrivacyFactRow extends StatelessWidget {
  const _PrivacyFactRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary, semanticLabel: ''),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedPrivacyDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final paragraphs = [
      'All of your health records — symptoms, vitals, medications, meals, and '
          'reports — are stored in a local database on this device only. This is '
          'not a backup. This is the only copy.',
      'No network connection is required to use Health Flare. No data is sent '
          'anywhere in the background. There are no analytics trackers, no usage '
          'reports, and no third-party services with access to your records.',
      'When you export a report as a PDF or CSV, that file is created on your '
          'device. You decide where it goes — whether that\'s an email to your '
          'doctor, a message to a family member, or a folder on your computer. '
          "Health Flare doesn't know what you did with it.",
      'If you delete a profile, it is removed from the main views of the '
          'application. You can restore a profile as long as the data exists on '
          'your device. From the profile manager, you can choose to delete these '
          'profiles from your device permanently. There is no cloud backup to recover.',
      'A note on backups: because your data lives only on this device, it will be '
          'included in your device\'s standard backup (iCloud Backup on iOS, Google '
          'Backup on Android, or your desktop\'s backup system). Those backups are '
          'managed by your device, not by Health Flare. We recommend keeping device '
          "backups enabled so you don't lose your records if something happens to "
          'your device.',
      'There is no "Health Flare account". There are no subscription services tied '
          'to your data. Your records belong to you.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Health Flare handles your data',
            style: tt.titleSmall?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 16),
          ...paragraphs.expand((p) => [
                Text(
                  p,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
              ]),
        ],
      ),
    );
  }
}
