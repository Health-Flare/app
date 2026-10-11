import 'package:flutter/material.dart';

/// A bottom bar drawn as a picture, not tappable (#145). Read to screen
/// readers as one line: "[label]: Dashboard, Track, ...".
class BarDrawing extends StatelessWidget {
  const BarDrawing({super.key, required this.label, required this.items});

  final String label;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '$label: ${items.map((i) => i.$2).join(', ')}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tt.labelLarge),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  for (final (icon, name) in items)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: cs.onSurfaceVariant),
                          const SizedBox(height: 4),
                          // Six items (the old bar) shrink rather than cut off.
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(name, style: tt.labelSmall),
                          ),
                        ],
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
