// Contrast in the app's own themes, light and dark (WCAG 2.2: 4.5:1 for
// text, 3:1 for icons that carry meaning). Found by the 1.10.0 release
// review (#171): chip labels and the guide's "was -> now" arrow.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/theme/app_theme.dart';

import '../helpers/contrast.dart';

/// The colour [text] is painted with. Null was the bug: the chip theme's
/// label style had no colour, and on a device that paints near-white.
Color _labelColor(WidgetTester tester, String text) {
  final color = tester
      .renderObject<RenderParagraph>(find.text(text))
      .text
      .style
      ?.color;
  expect(color, isNotNull, reason: '"$text" has no text colour');
  return color!;
}

final _themes = {'light': AppTheme.light, 'dark': AppTheme.dark};

void main() {
  for (final MapEntry(key: name, value: theme) in _themes.entries) {
    final cs = theme.colorScheme;
    final page = theme.scaffoldBackgroundColor;

    group('$name theme', () {
      Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: Center(child: child)),
        ),
      );

      // Quick Log's type chip and the dashboard appointment chip.
      testWidgets('a chip label on primaryContainer is readable', (
        tester,
      ) async {
        await pump(
          tester,
          Chip(label: const Text('Meal'), backgroundColor: cs.primaryContainer),
        );
        expect(
          contrast(_labelColor(tester, 'Meal'), cs.primaryContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      testWidgets('a plain chip label is readable', (tester) async {
        await pump(tester, const Chip(label: Text('in 2 days')));
        expect(
          contrast(
            _labelColor(tester, 'in 2 days'),
            theme.chipTheme.backgroundColor!,
          ),
          greaterThanOrEqualTo(4.5),
        );
      });

      // The symptom form's body areas.
      for (final selected in [false, true]) {
        testWidgets('a filter chip label is readable '
            '(${selected ? 'selected' : 'not selected'})', (tester) async {
          await pump(
            tester,
            FilterChip(
              label: const Text('lower back'),
              selected: selected,
              onSelected: (_) {},
            ),
          );
          final bg = selected
              ? Color.alphaBlend(theme.chipTheme.selectedColor!, page)
              : theme.chipTheme.backgroundColor!;
          expect(
            contrast(_labelColor(tester, 'lower back'), bg),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    });
  }
}
