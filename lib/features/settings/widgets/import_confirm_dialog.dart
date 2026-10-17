import 'package:flutter/material.dart';

import 'package:health_flare/data/database/backup_summary.dart';

/// Says what a backup will do before "Add missing data" merges it or
/// "Replace everything" stages it (#104). Pops true for Add / Replace,
/// false for Cancel.
class ImportConfirmDialog extends StatelessWidget {
  const ImportConfirmDialog.add({super.key, required this.summary})
    : currentProfiles = null;

  const ImportConfirmDialog.replace({
    super.key,
    required this.summary,
    required List<String> this.currentProfiles,
  });

  final BackupSummary summary;

  /// Set for "Replace everything": the profiles in the app now.
  final List<String>? currentProfiles;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
