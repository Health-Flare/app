import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

/// Provides the [Isar] database instance to the rest of the app.
///
/// This provider is ALWAYS overridden at startup via:
/// ```dart
/// ProviderScope(overrides: [isarProvider.overrideWithValue(isar)])
/// ```
/// Accessing it without an override surfaces a clear error immediately.
final isarProvider = Provider<Isar>(
  (ref) => throw UnimplementedError(
    'isarProvider must be overridden with the Isar instance '
    'before ProviderScope builds. See lib/main.dart.',
  ),
);
