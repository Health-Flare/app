import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';

// ---------------------------------------------------------------------------
// Local provider — reads schema version from AppSettings singleton.
// ---------------------------------------------------------------------------

final _schemaVersionProvider = FutureProvider<int>((ref) async {
  final isar = ref.read(isarProvider);
  final settings = await isar.appSettings.get(1);
  return settings?.schemaVersion ?? 0;
});

/// App-level Settings screen.
///
/// Surfaces data backup / restore and displays the current schema version.
/// Accessible from the dashboard app bar (gear icon).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Data & backup ─────────────────────────────────────────────────
          const _SectionHeader(label: 'Data & backup'),
          _BackupTiles(),

          // ── About ─────────────────────────────────────────────────────────
          const _SectionHeader(label: 'About'),
          _AboutTiles(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backup tiles
// ---------------------------------------------------------------------------

class _BackupTiles extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);
    final isBusy = backupState is BackupInProgress;

    ref.listen(backupProvider, (prev, next) {
      if (next is BackupRestoreStaged) {
        notifier.reset();
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Backup staged'),
            content: const Text(
              'Close and reopen the app to apply the backup. '
              'All current data will be replaced.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (next is BackupError) {
        notifier.reset();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      } else if (next is BackupExportDone) {
        notifier.reset();
      }
    });

    return Column(
      children: [
        ListTile(
          leading: isBusy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_rounded),
          title: const Text('Export backup'),
          subtitle: const Text('Save a copy of all data to Files or share'),
          onTap: isBusy ? null : notifier.export,
        ),
        ListTile(
          leading: const Icon(Icons.download_rounded),
          title: const Text('Restore from backup'),
          subtitle: const Text(
            'Replace all data from a backup file — requires restart',
          ),
          onTap: isBusy
              ? null
              : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Restore from backup?'),
                      content: const Text(
                        'This will replace ALL current data with the '
                        'contents of the backup file. The restore is applied '
                        'when you restart the app.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Choose file'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await notifier.stageRestore();
                  }
                },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// About tiles
// ---------------------------------------------------------------------------

class _AboutTiles extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemaAsync = ref.watch(_schemaVersionProvider);

    return schemaAsync.when(
      loading: () => const ListTile(
        leading: Icon(Icons.info_outline_rounded),
        title: Text('Schema version'),
        subtitle: Text('Loading…'),
      ),
      error: (err, st) => const ListTile(
        leading: Icon(Icons.info_outline_rounded),
        title: Text('Schema version'),
        subtitle: Text('Unavailable'),
      ),
      data: (version) => ListTile(
        leading: const Icon(Icons.info_outline_rounded),
        title: const Text('Schema version'),
        subtitle: Text('v$version'),
      ),
    );
  }
}
