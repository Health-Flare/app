import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// More (#143): what isn't in the bottom bar, as a real screen. Sections
/// with their tabs, then any pinned screen that didn't fit.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final more = ref
        .watch(effectiveBarProvider)
        .where((s) => s.id == moreId)
        .firstOrNull;
    final ids = more?.moreIds ?? const <String>[];
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const HFAppBar(
        title: Text('More'),
        actions: [ReportsIconButton()],
      ),
      body: ListView(
        children: [
          for (final id in ids)
            ...switch (navSections.where((s) => s.id == id).firstOrNull) {
              final NavSection section => [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Semantics(
                    header: true,
                    child: Text(section.label, style: tt.titleMedium),
                  ),
                ),
                for (final tab in ref.watch(visibleTabsProvider(section.id)))
                  _tile(context, tab),
              ],
              _ => [if (tabFor(id) case final tab?) _tile(context, tab)],
            },
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Change the bottom bar'),
            onTap: () => context.push(AppRoutes.bottomBar),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, NavTab tab) => ListTile(
    leading: Icon(tab.icon),
    title: Text(tab.label),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.go(tabLocation(tab.id)),
  );
}

NavTab? tabFor(String id) {
  for (final s in navSections) {
    for (final t in s.tabs) {
      if (t.id == id) return t;
    }
  }
  return null;
}
