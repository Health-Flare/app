import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

/// Tabbed screen showing the Symptoms and Vitals logs for the active profile.
class SymptomsVitalsScreen extends ConsumerStatefulWidget {
  const SymptomsVitalsScreen({super.key});

  @override
  ConsumerState<SymptomsVitalsScreen> createState() =>
      _SymptomsVitalsScreenState();
}

class _SymptomsVitalsScreenState extends ConsumerState<SymptomsVitalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final symptoms = ref.watch(activeProfileSymptomEntriesProvider);
    final vitals = ref.watch(activeProfileVitalEntriesProvider);

    final isSymptomTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Symptoms & Vitals'),
            if (activeProfile != null)
              Text(
                activeProfile.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Symptoms'),
            Tab(text: 'Vitals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SymptomList(entries: symptoms),
          _VitalList(entries: vitals),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: isSymptomTab ? 'fab_symptom' : 'fab_vital',
        onPressed: () {
          if (isSymptomTab) {
            context.push(AppRoutes.symptomsNew);
          } else {
            context.push(AppRoutes.vitalsNew);
          }
        },
        tooltip: isSymptomTab ? 'Log symptom' : 'Log vital',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Symptom list tab
// ---------------------------------------------------------------------------

class _SymptomList extends StatelessWidget {
  const _SymptomList({required this.entries});

  final List<SymptomEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _SymptomEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: entries.length,
      itemBuilder: (context, i) => _SymptomEntryTile(entry: entries[i]),
    );
  }
}

class _SymptomEntryTile extends StatelessWidget {
  const _SymptomEntryTile({required this.entry});

  final SymptomEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return ListTile(
      key: Key('symptom_tile_${entry.id}'),
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: Text(
          '${entry.severity}',
          style: tt.labelLarge?.copyWith(color: cs.onPrimaryContainer),
        ),
      ),
      title: Text(entry.name),
      subtitle: Text(fmt.format(entry.loggedAt)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.symptomsEdit(entry.id), extra: entry),
    );
  }
}

class _SymptomEmptyState extends StatelessWidget {
  const _SymptomEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_neutral_outlined,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No symptoms logged yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to log a symptom',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Vital list tab
// ---------------------------------------------------------------------------

class _VitalList extends StatelessWidget {
  const _VitalList({required this.entries});

  final List<VitalEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const _VitalEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: entries.length,
      itemBuilder: (context, i) => _VitalEntryTile(entry: entries[i]),
    );
  }
}

class _VitalEntryTile extends StatelessWidget {
  const _VitalEntryTile({required this.entry});

  final VitalEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return ListTile(
      key: Key('vital_tile_${entry.id}'),
      leading: CircleAvatar(
        backgroundColor: cs.secondaryContainer,
        child: Icon(
          Icons.monitor_heart_outlined,
          color: cs.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(entry.vitalType.label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(entry.displayValue), Text(fmt.format(entry.loggedAt))],
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.vitalsEdit(entry.id), extra: entry),
    );
  }
}

class _VitalEmptyState extends StatelessWidget {
  const _VitalEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No vitals logged yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to log a vital measurement',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
