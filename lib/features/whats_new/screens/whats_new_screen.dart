import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';

/// Settings > What's new: every release up to the installed one, newest
/// first. Highlights first, the full list collapsed under "All changes".
/// Works the same with update highlights off. Spec:
/// docs/features/whats-new.feature ("Finding it later").
class WhatsNewScreen extends ConsumerWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(whatsNewProvider);
    return Scaffold(
      appBar: const HFAppBar(
        title: Text("What's new"),
        showSettingsButton: false,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text("What's new couldn't be loaded."),
          ),
        ),
        data: (state) => ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            for (final r in state.history) _ReleaseSection(release: r),
          ],
        ),
      ),
    );
  }
}

class _ReleaseSection extends StatelessWidget {
  const _ReleaseSection({required this.release});

  final ReleaseNote release;

  static final _date = DateFormat('d MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final date = release.date;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Version ${release.version}',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
          ),
          if (date != null)
            Text(
              _date.format(date),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          for (final h in release.highlights)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.title, style: tt.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    h.body,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          if (release.changes.isNotEmpty)
            Theme(
              // No divider lines above and below the expanded list.
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  'All changes',
                  style: tt.labelLarge?.copyWith(color: cs.primary),
                ),
                children: [
                  for (final c in release.changes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ExcludeSemantics(child: Text('•  ')),
                          Expanded(child: Text(c, style: tt.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
