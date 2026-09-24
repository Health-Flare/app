import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:health_flare/core/providers/backup_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/import_service.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

// ---------------------------------------------------------------------------
// Local provider: reads schema version from AppSettings singleton.
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
      appBar: const HFAppBar(
        title: Text('Settings'),
        showSettingsButton: false,
      ),
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

class _BackupTiles extends ConsumerStatefulWidget {
  @override
  ConsumerState<_BackupTiles> createState() => _BackupTilesState();
}

class _BackupTilesState extends ConsumerState<_BackupTiles> {
  /// Tracks the currently-open password prompt so it's opened once and
  /// reused for retries (the same dialog watches state and shows the new
  /// error inline) rather than stacked. Driven from the *current* state on
  /// every build, not `ref.listen`, because this can be the very first
  /// state the provider ever has (e.g. resuming with an already-picked
  /// encrypted file), and `ref.listen` only fires on later transitions.
  bool _passwordDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);
    final isBusy = backupState is BackupInProgress;

    if (backupState is ImportPasswordRequired && !_passwordDialogOpen) {
      _passwordDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _ImportPasswordDialog(),
        ).then((_) {
          if (mounted) setState(() => _passwordDialogOpen = false);
        });
      });
    }

    ref.listen(backupProvider, (prev, next) {
      if (!mounted) return;

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
      } else if (next is ImportPreviewReady) {
        // Show category picker sheet: user selects what to import.
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (ctx) => _ImportCategorySheet(
            preview: next,
            onConfirm: (selected) {
              Navigator.of(ctx).pop();
              notifier.commitSelectiveImport(selected);
            },
            onCancel: () {
              Navigator.of(ctx).pop();
              notifier.reset();
            },
          ),
        ).then((_) {
          if (!mounted) return;
          // Dismissed without Import or Cancel (swipe/barrier tap): drop the
          // preview so a decrypted working copy doesn't linger on disk.
          if (ref.read(backupProvider) is ImportPreviewReady) notifier.reset();
        });
      } else if (next is ImportComplete) {
        notifier.reset();
        final msg = next.recordsAdded == 0
            ? 'Everything in the backup is already up to date.'
            : 'Added ${next.recordsAdded} '
                  '${next.recordsAdded == 1 ? 'record' : 'records'}.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
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
        // Export
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
          onTap: isBusy ? null : () => _showExportSheet(context, notifier),
        ),

        // Import / restore
        ListTile(
          leading: const Icon(Icons.download_rounded),
          title: const Text('Import / restore'),
          subtitle: const Text('Bring data back from a backup file'),
          onTap: isBusy ? null : () => _showImportModeSheet(context, notifier),
        ),
      ],
    );
  }

  void _showImportModeSheet(BuildContext context, BackupNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      ctx,
                    ).colorScheme.onSurfaceVariant.withAlpha(76),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Import / restore',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Choose how to use a backup file.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: Replace everything
              _ImportModeOption(
                icon: Icons.swap_horiz_rounded,
                title: 'Replace everything',
                subtitle:
                    'Overwrite all current data with the backup. '
                    'Requires app restart.',
                isDestructive: true,
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Replace all data?'),
                      content: const Text(
                        'This will delete everything currently in the app '
                        'and replace it with the backup. The restore is '
                        'applied when you restart the app.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              dialogCtx,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              dialogCtx,
                            ).colorScheme.onError,
                          ),
                          onPressed: () => Navigator.of(dialogCtx).pop(true),
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

              const SizedBox(height: 8),

              // Option 2: Add missing data
              _ImportModeOption(
                icon: Icons.merge_rounded,
                title: 'Add missing data',
                subtitle:
                    'Import records from the backup that you don\'t already '
                    'have. Nothing is deleted.',
                onTap: () {
                  Navigator.of(ctx).pop();
                  notifier.mergeRestore();
                },
              ),

              const SizedBox(height: 8),

              // Option 3: Choose what to import
              _ImportModeOption(
                icon: Icons.checklist_rounded,
                title: 'Choose what to import',
                subtitle:
                    'Preview the backup and select exactly which data to '
                    'bring in.',
                onTap: () {
                  Navigator.of(ctx).pop();
                  notifier.startSelectiveImport();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportSheet(BuildContext context, BackupNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExportSheet(notifier: notifier),
    );
  }
}

// ---------------------------------------------------------------------------
// Export sheet: plain or password-encrypted
// ---------------------------------------------------------------------------

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({required this.notifier});

  final BackupNotifier notifier;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _encryptEnabled = false;
  bool _acknowledged = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? get _passwordError {
    final password = _passwordController.text;
    if (password.isEmpty) return null;
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  String? get _confirmError {
    final confirm = _confirmController.text;
    if (confirm.isEmpty) return null;
    if (confirm != _passwordController.text) return "Passwords don't match.";
    return null;
  }

  bool get _canExport {
    if (!_encryptEnabled) return true;
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    return password.isNotEmpty &&
        confirm.isNotEmpty &&
        _passwordError == null &&
        _confirmError == null &&
        _acknowledged;
  }

  void _handleExport() {
    final password = _passwordController.text;
    // Drop the sheet's own copies of the password as soon as it's handed
    // off; nothing in the app keeps a reference to it after the export.
    _passwordController.clear();
    _confirmController.clear();
    Navigator.of(context).pop();
    if (_encryptEnabled) {
      widget.notifier.exportWithPassword(password);
    } else {
      widget.notifier.export();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withAlpha(76),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Export backup', style: tt.titleMedium),
              const SizedBox(height: 12),

              // Data ownership notice: see docs/features/encrypted-backup.feature,
              // "The export screen explains data ownership before the user
              // shares anything". Specific and checkable, not a vague
              // reassurance.
              Container(
                key: const Key('export_ownership_notice'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This data belongs to you.',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exporting writes it to a file you control. Health '
                      'Flare has no server or account that receives a copy. '
                      'Health Flare never sees, stores, or has access to '
                      'the file. Whoever has the file can read it, unless '
                      'you lock it with a password below.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Encryption toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Encrypt with a password'),
                subtitle: const Text(
                  'Locks the file so only someone with the password can '
                  'read it.',
                ),
                value: _encryptEnabled,
                onChanged: (v) => setState(() => _encryptEnabled = v),
              ),

              if (_encryptEnabled) ...[
                const SizedBox(height: 4),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _passwordError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    errorText: _confirmError,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  "If you lose this password, the backup can't be "
                  'recovered. There is no account to reset it from.',
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _acknowledged,
                  onChanged: (v) => setState(() => _acknowledged = v ?? false),
                  title: const Text(
                    "I understand this password can't be recovered",
                  ),
                ),
              ],

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canExport ? _handleExport : null,
                  child: const Text('Export'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Import password prompt: shown when a picked backup file is encrypted
// ---------------------------------------------------------------------------

class _ImportPasswordDialog extends ConsumerStatefulWidget {
  const _ImportPasswordDialog();

  @override
  ConsumerState<_ImportPasswordDialog> createState() =>
      _ImportPasswordDialogState();
}

class _ImportPasswordDialogState extends ConsumerState<_ImportPasswordDialog> {
  final _controller = TextEditingController();

  /// Set once this dialog has started closing, so it never tries to remove
  /// itself twice.
  bool _closed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Removes this dialog's own route, wherever it sits in the stack.
  ///
  /// Deliberately not `Navigator.pop`: when an unlock succeeds, the parent's
  /// listener may already have pushed the next route (e.g. the selective
  /// import category sheet) on top of this dialog, and popping would close
  /// that route instead of this one.
  void _close() {
    if (_closed) return;
    _closed = true;
    final route = ModalRoute.of(context);
    if (route != null && route.isActive) {
      Navigator.of(context).removeRoute(route);
    }
  }

  void _cancel() {
    _controller.clear();
    _close();
    ref.read(backupProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    // The flow has moved past needing a password (unlocked, or failed for
    // a reason other than the password): close this dialog.
    ref.listen(backupProvider, (prev, next) {
      if (next is ImportPasswordRequired || next is BackupInProgress) return;
      _controller.clear();
      _close();
    });

    final state = ref.watch(backupProvider);
    final busy = state is BackupInProgress;

    final errorMessage = state is ImportPasswordRequired
        ? state.errorMessage
        : null;

    return AlertDialog(
      title: const Text('Enter password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This backup is encrypted. Enter its password to continue.',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller,
            obscureText: true,
            enabled: !busy,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: errorMessage,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : _cancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () => ref
                    .read(backupProvider.notifier)
                    .submitImportPassword(_controller.text),
          child: const Text('Unlock'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Import mode option tile
// ---------------------------------------------------------------------------

class _ImportModeOption extends StatelessWidget {
  const _ImportModeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive ? cs.error : cs.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? cs.error : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selective import: category picker sheet
// ---------------------------------------------------------------------------

class _ImportCategorySheet extends StatefulWidget {
  const _ImportCategorySheet({
    required this.preview,
    required this.onConfirm,
    required this.onCancel,
  });

  final ImportPreviewReady preview;
  final void Function(Set<String> selectedIds) onConfirm;
  final VoidCallback onCancel;

  @override
  State<_ImportCategorySheet> createState() => _ImportCategorySheetState();
}

class _ImportCategorySheetState extends State<_ImportCategorySheet> {
  late List<ImportCategoryInfo> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.of(widget.preview.categories);
  }

  int get _totalSelected =>
      _categories.where((c) => c.selected).fold(0, (sum, c) => sum + c.count);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withAlpha(76),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Choose what to import', style: tt.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Select the data you want to bring in. '
                    'Existing records won\'t be duplicated.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Category list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return CheckboxListTile(
                    value: cat.selected,
                    onChanged: (v) => setState(
                      () => _categories[index] = cat.copyWith(
                        selected: v ?? false,
                      ),
                    ),
                    title: Text(cat.label),
                    subtitle: Text(
                      '${cat.count} '
                      '${cat.count == 1 ? 'record' : 'records'}',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Footer: confirm / cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _totalSelected == 0
                          ? null
                          : () => widget.onConfirm(
                              _categories
                                  .where((c) => c.selected)
                                  .map((c) => c.id)
                                  .toSet(),
                            ),
                      child: Text(
                        _totalSelected == 0
                            ? 'Import'
                            : 'Import $_totalSelected',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About tiles
// ---------------------------------------------------------------------------

const _kPrivacyPolicyUrl = 'https://healthflare.org/privacy';

class _AboutTiles extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemaAsync = ref.watch(_schemaVersionProvider);

    return Column(
      children: [
        // Privacy policy
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy policy'),
          subtitle: const Text('healthflare.org/privacy'),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () async {
            final uri = Uri.parse(_kPrivacyPolicyUrl);
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open privacy policy'),
                  ),
                );
              }
            }
          },
        ),

        // Schema version
        schemaAsync.when(
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
        ),

        // License
        const ListTile(
          leading: Icon(Icons.gavel_outlined),
          title: Text('License'),
          subtitle: Text(
            'Health Flare is free software, licensed under the GNU GPL-3.0',
          ),
        ),

        // Open source licenses
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Open source licenses'),
          subtitle: const Text(
            'Third-party packages and fonts used by this app',
          ),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Health Flare',
            applicationLegalese: '© 2026 Health Flare, GNU GPL-3.0',
          ),
        ),
      ],
    );
  }
}
