// WCAG 2.2 contrast ratio, for tests in the app's own themes.
import 'dart:math' as math;

import 'package:flutter/material.dart';

double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

/// WCAG contrast ratio; [bg] must be opaque.
double contrast(Color fg, Color bg) {
  final f = _luminance(Color.alphaBlend(fg, bg));
  final b = _luminance(bg);
  return (math.max(f, b) + 0.05) / (math.min(f, b) + 0.05);
}
