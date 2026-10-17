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

  bool get _isReplace => currentProfiles != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final current = currentProfiles;

    final lines = [
      for (final p in summary.profiles)
        _isReplace ? backupEntriesLine(p) : backupAddLine(p),
      if (!_isReplace && summary.layoutIsNew) "The backup's bottom bar",
    ];

    return AlertDialog(
      title: Text(_isReplace ? 'Replace everything?' : 'Add from this backup?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isReplace ? 'In the backup:' : 'This backup would add:',
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            const SizedBox(height: 12),
            if (current == null)
              const Text('Nothing in the app will be changed or deleted.')
            else ...[
              Text(
                'This replaces everything in the app now:',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(current.isEmpty ? 'No profiles' : current.join(', ')),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: _isReplace
              ? FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(_isReplace ? 'Replace' : 'Add'),
        ),
      ],
    );
  }
}
