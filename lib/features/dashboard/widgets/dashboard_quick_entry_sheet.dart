import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';

/// Opens the quick-entry bottom sheet and returns when it is dismissed.
Future<void> showDashboardQuickEntrySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _DashboardQuickEntrySheet(),
  );
}

/// Bottom sheet that lets the user choose what kind of entry to create.
class _DashboardQuickEntrySheet extends StatelessWidget {
  const _DashboardQuickEntrySheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Journal entry'),
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.journalNew);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bedtime_outlined),
            title: const Text('Sleep'),
            onTap: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.sleepNew);
            },
          ),
        ],
      ),
    );
  }
}
