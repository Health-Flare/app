import 'package:flutter/material.dart';

/// Dashboard — the home tab.
///
/// Currently a placeholder. Will be fleshed out with a summary of
/// recent activity once the data layer (Isar + profiles) is wired up.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Flare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Switch profile',
            onPressed: () {
              // TODO: open profile switcher
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline_rounded,
              size: 64,
              color: cs.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing logged yet.',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tap the + button to record a symptom, vital, meal, or medication. '
                'The more you log, the clearer your health picture becomes.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open quick-entry bottom sheet
        },
        tooltip: 'Log entry',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
