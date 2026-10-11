import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Settings > Your layout > Features in use (#142): turn off a whole kind
/// of tracking for the active profile. Its tab and dashboard card go; its
/// data never does. Spec: docs/features/navigation-customization.feature.
class FeaturesInUseScreen extends ConsumerWidget {
  const FeaturesInUseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileDataProvider);
    // Rebuilt from the switches' own provider: see
    // activeDisabledFeaturesProvider for why not activeProfileDataProvider.
    ref.watch(activeDisabledFeaturesProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const HFAppBar(title: Text('Features in use')),
      body: profile == null
          ? const SizedBox.shrink()
          // A short list: every row is built, for screen readers too.
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'These switches apply to ${profile.name}. Turning one off '
                      'hides its tab and dashboard card. Nothing you have '
                      'logged is deleted, and reports still include it.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  for (final f in navFeatures)
                    if (f.canTurnOff)
                      SwitchListTile(
                        title: Text(
                          f.label,
                          semanticsLabel: '${f.label} for ${profile.name}',
                        ),
                        subtitle: Text(sectionOfTab(f.id).label),
                        value: ref.watch(featureOnProvider(f.id)),
                        onChanged: (on) => _set(context, ref, f.id, on),
                      )
                    else
                      ListTile(
                        title: Text(f.label),
                        subtitle: Text(sectionOfTab(f.id).label),
                        trailing: Text(
                          'Always on',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                ],
              ),
            ),
    );
  }

  Future<void> _set(
    BuildContext context,
    WidgetRef ref,
    String featureId,
    bool on,
  ) async {
    final profile = ref.read(activeProfileDataProvider);
    if (profile == null) return;
    // Counted before the switch changes: what's kept, in the profile's
    // own data.
    final count = ref.read(featureEntryCountProvider(featureId));
    final messenger = ScaffoldMessenger.of(context);
    await setFeatureOn(
      ref.read(profileListProvider.notifier),
      profile,
      featureId,
      on: on,
    );
    if (on) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            featureKeptMessage(
              profileName: profile.name,
              featureId: featureId,
              count: count,
            ),
          ),
        ),
      );
  }
}
