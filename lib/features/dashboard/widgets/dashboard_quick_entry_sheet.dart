import 'package:flutter/material.dart';

import 'package:health_flare/features/quick_log/widgets/quick_log_sheet.dart';

/// Opens the quick-entry bottom sheet from the dashboard FAB.
///
/// Delegates to [showQuickLogSheet], which provides freeform text input
/// with smart classification and one-tap promotion to typed entries.
Future<void> showDashboardQuickEntrySheet(BuildContext context) =>
    showQuickLogSheet(context);
