import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:health_flare/core/citations/symptom_sources.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

const _kSourcesUrl = 'https://healthflare.org/sources';

/// Settings > "Where our questions come from".
///
/// Credits Dr Cat Hicks and Informed Patient, explains the symptom questions
/// in plain words, and lists every source. Citations are plain text; the only
/// link opens healthflare.org in the system browser, on tap.
class SymptomSourcesScreen extends StatelessWidget {
  const SymptomSourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: tt.titleMedium),
    );

    return Scaffold(
      appBar: const HFAppBar(
        title: Text('Where our questions come from'),
        showSettingsButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            key: const Key('cat_hicks_credit'),
            color: cs.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(SymptomSources.credit, style: tt.bodyMedium),
            ),
          ),
          heading('What we ask, and why'),
          Text(
            'How intense a symptom is and how much it gets in the way are '
            'different things. A mild headache can still stop you working. '
            'So we ask about each one separately.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'A number on its own is hard for a clinician to act on. A short '
            'note of what the symptom stopped you doing is easier to '
            'understand in a short appointment.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We ask you to describe the symptom before rating it, and end '
            'with "anything else?" so you can add what our questions missed.',
            style: tt.bodyMedium,
          ),
          heading('About PROMIS'),
          Text(SymptomSources.promisNote, style: tt.bodyMedium),
          heading('Sources'),
          Text(
            SymptomSources.informedPatient,
            key: const Key('informed_patient_source'),
            style: tt.bodySmall,
          ),
          for (final s in SymptomSources.all) ...[
            const SizedBox(height: 12),
            Text(s.citation, style: tt.bodySmall),
            if (s.pmid != null)
              Text(
                'PMID ${s.pmid}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            Text(
              s.usedFor,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Read more on healthflare.org'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () async {
              final ok = await launchUrl(
                Uri.parse(_kSourcesUrl),
                mode: LaunchMode.externalApplication,
              );
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open the page')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
