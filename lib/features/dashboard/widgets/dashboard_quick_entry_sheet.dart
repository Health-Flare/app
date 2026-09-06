import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/features/onboarding/widgets/weather_opt_in_sheet.dart';
import 'package:health_flare/features/quick_log/widgets/quick_log_sheet.dart';

/// Opens the quick-entry bottom sheet from the dashboard FAB — and, once
/// per profile, the same place the first-log trigger opens it from too.
///
/// The weather opt-in (if not yet seen for the active profile) is shown
/// first, right before the sheet: asking "want weather tracked with this
/// entry?" makes more sense at the moment someone is actually about to log
/// something than as a blocking modal shown before they've seen the app at
/// all. After that one-time check, this is a single tap straight to
/// [showQuickLogSheet].
Future<void> showDashboardQuickEntrySheet(
  BuildContext context,
  WidgetRef ref,
) async {
  if (ref.read(weatherOptInProvider)) {
    await showWeatherOptIn(
      context,
      onResult: (enabled) async {
        await ref
            .read(weatherOptInProvider.notifier)
            .dismiss(enabled: enabled);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
  if (!context.mounted) return;

  await showQuickLogSheet(context);
}
