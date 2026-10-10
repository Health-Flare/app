import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';

/// Bundled release notes. Nothing is ever fetched.
const kReleaseNotesAsset = 'assets/whats_new/releases.json';

Future<List<ReleaseNote>> loadBundledReleaseNotes() async =>
    ReleaseNote.listFromJson(await rootBundle.loadString(kReleaseNotesAsset));

/// Installed `major.minor.patch`, without the build number.
Future<String> readInstalledVersion() async =>
    (await PackageInfo.fromPlatform()).version;

final releaseNotesProvider = FutureProvider<List<ReleaseNote>>(
  (ref) => loadBundledReleaseNotes(),
);

final installedVersionProvider = FutureProvider<String>(
  (ref) => readInstalledVersion(),
);

/// Reads and writes the What's new fields on the [AppSettings] singleton.
/// Release state is per device, never per profile.
class WhatsNewStore {
  WhatsNewStore._();

  static Future<WhatsNewRecord> read(Isar isar) async {
    final s = await isar.appSettings.get(1);
    if (s == null) return const WhatsNewRecord();
    return WhatsNewRecord(
      lastSeenVersion: s.lastSeenWhatsNewVersion,
      highlightsOff: s.updateHighlightsOff,
      cardVersion: s.whatsNewCardVersion,
      cardShownCount: s.whatsNewCardShownCount ?? 0,
    );
  }

  static Future<void> write(Isar isar, WhatsNewRecord record) async {
    await isar.writeTxn(() async {
      final s = await isar.appSettings.get(1) ?? AppSettings();
      s
        ..lastSeenWhatsNewVersion = record.lastSeenVersion
        ..updateHighlightsOff = record.highlightsOff
        ..whatsNewCardVersion = record.cardVersion
        ..whatsNewCardShownCount = record.cardShownCount;
      await isar.appSettings.put(s);
    });
  }

  /// Applies [settleLaunch] to the stored record and saves the result.
  /// Called from `main()` before onboarding can create a profile, so a
  /// fresh install is told apart from an update.
  static Future<WhatsNewRecord> settle(
    Isar isar, {
    required List<ReleaseNote> releases,
    required String installed,
  }) async {
    final before = await read(isar);
    final after = settleLaunch(
      record: before,
      releases: releases,
      installed: installed,
      hasProfiles: await isar.profileIsars.count() > 0,
    );
    if (after != before) await write(isar, after);
    return after;
  }
}

class WhatsNewState {
  const WhatsNewState({
    required this.record,
    required this.releases,
    required this.installed,
  });

  final WhatsNewRecord record;
  final List<ReleaseNote> releases;
  final String installed;

  bool get highlightsOn => !record.highlightsOff;

  /// Releases the dashboard card covers, newest first. Empty: no card.
  List<ReleaseNote> get card => record.highlightsOff
      ? const []
      : cardReleases(
          releases: releases,
          lastSeen: record.lastSeenVersion ?? installed,
          installed: installed,
        );

  /// Every release up to the installed one, newest first.
  List<ReleaseNote> get history => releasesUpTo(releases, installed);

  WhatsNewState withRecord(WhatsNewRecord r) =>
      WhatsNewState(record: r, releases: releases, installed: installed);
}

class WhatsNewNotifier extends AsyncNotifier<WhatsNewState> {
  bool _countedThisLaunch = false;

  @override
  Future<WhatsNewState> build() async {
    final isar = ref.read(isarProvider);
    final releases = await ref.watch(releaseNotesProvider.future);
    final installed = await ref.watch(installedVersionProvider.future);
    // main() settles at launch; doing it again here is a no-op then, and
    // covers hot restart and tests.
    final record = await WhatsNewStore.settle(
      isar,
      releases: releases,
      installed: installed,
    );
    return WhatsNewState(
      record: record,
      releases: releases,
      installed: installed,
    );
  }

  Future<void> _save(WhatsNewRecord Function(WhatsNewState s) change) async {
    final current = state.value ?? await future;
    final next = change(current);
    if (next == current.record) return;
    await WhatsNewStore.write(ref.read(isarProvider), next);
    if (!ref.mounted) return;
    state = AsyncData(current.withRecord(next));
  }

  /// Dismissed or opened: final for every release up to the installed one.
  Future<void> dismiss() => _save((s) => markSeen(s.record, s.installed));

  /// The card was on screen this launch. Counts once per launch towards
  /// [kReleaseCardMaxOpens]. Returns true only the first time this launch,
  /// so the card is announced to screen readers once.
  Future<bool> noteCardShown() async {
    if (_countedThisLaunch) return false;
    _countedThisLaunch = true;
    await _save(
      (s) => s.card.isEmpty
          ? s.record
          : s.record.copyWith(cardShownCount: s.record.cardShownCount + 1),
    );
    return true;
  }

  /// "Show update highlights". Turning it off counts everything installed
  /// so far as seen, so turning it back on brings back no old card.
  Future<void> setHighlightsOn(bool on) => _save(
    (s) => on
        ? s.record.copyWith(highlightsOff: false)
        : markSeen(s.record.copyWith(highlightsOff: true), s.installed),
  );
}

final whatsNewProvider = AsyncNotifierProvider<WhatsNewNotifier, WhatsNewState>(
  WhatsNewNotifier.new,
);
