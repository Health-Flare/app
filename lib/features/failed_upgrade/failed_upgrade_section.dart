import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/features/failed_upgrade/failed_upgrade_provider.dart';

/// Settings > Data & backup while an upgrade has stopped retrying (#112):
/// what happened, and Export a backup, Copy details and, while the safety
/// copy exists, Restore the copy from before the update.
class FailedUpgradeSection extends ConsumerWidget {
  const FailedUpgradeSection({super.key});

  static final _when = DateFormat('d MMMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(failedUpgradeProvider);
    if (f == null) return const SizedBox.shrink();
    final actions = ref.watch(failedUpgradeActionsProvider);
    final copy = f.snapshotPath;
    final canRestore = copy != null && actions.safetyCopyExists(copy);
    final taken = f.snapshotTakenAt == null
        ? null
        : _when.format(f.snapshotTakenAt!.toLocal());
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // The theme makes outlined buttons full width.
    final compact = OutlinedButton.styleFrom(minimumSize: const Size(64, 48));

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: cs.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text("Update didn't finish", style: tt.titleMedium),
            ),
            const SizedBox(height: 8),
            Text(
              "Health Flare couldn't finish updating your data, so it stopped "
              'trying. Your data is as it was before the steps that didn\'t '
              'finish. Nothing was lost, and the app works as normal. A newer '
              'version of Health Flare will try again.',
              style: tt.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  style: compact,
                  onPressed: actions.exportBackup,
                  child: const Text('Export a backup'),
                ),
                OutlinedButton(
                  style: compact,
                  onPressed: () => _copyDetails(context, f, actions),
                  child: const Text('Copy details'),
                ),
              ],
            ),
            if (canRestore) ...[
              const SizedBox(height: 16),
              Text(
                'Restore the copy from before the update only if something '
                'looks wrong since the update. It replaces your data with the '
                'copy${taken == null ? '' : ' from $taken'}, so anything '
                'logged since then is removed. A backup of your current data '
                'is saved first.',
                style: tt.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: compact,
                onPressed: () => _restore(context, copy, taken, actions),
                child: const Text('Restore the copy from before the update'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copyDetails(
    BuildContext context,
    FailedUpgrade f,
    FailedUpgradeActions actions,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: failedUpgradeDetails(f, platform: actions.platform)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied. Paste it into an email or a GitHub issue.'),
      ),
    );
  }

  /// Saves a backup of the current data first, then says what will be
  /// replaced and asks.
  Future<void> _restore(
    BuildContext context,
    String copy,
    String? taken,
    FailedUpgradeActions actions,
  ) async {
    final backup = await actions.saveBackupFirst();
    if (!context.mounted) return;
    final name = backup.split('/').last;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore the copy from before the update?'),
        content: Text(
          'A backup of your current data is saved on this phone: $name.\n\n'
          'Restoring replaces your data with the copy'
          '${taken == null ? '' : ' from $taken'}. Anything logged since '
          'then will be replaced. Health Flare finishes the restore the next '
          'time it opens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => actions.share(backup),
            child: const Text('Share backup'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (ok == true) await actions.restore(copy);
  }
}
