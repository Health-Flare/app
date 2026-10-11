import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/profile_ids.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide_provider.dart';

/// `--dart-define=GUIDE_PREVIEW=true` (debug builds only): start as if just
/// updated from 1.9.1, so the release guide card shows (#145). Used by
/// `bash scripts/track_and_care.sh guide`.
bool guidePreviewFromEnvironment() =>
    !kReleaseMode && const bool.fromEnvironment('GUIDE_PREVIEW');

/// Forgets the bar and the guide, turns highlights on, and adds a demo
/// profile ("Sam") if there are none. Call before [BarLayoutStore.settle].
Future<void> applyGuidePreview(Isar isar) async {
  await isar.writeTxn(() async {
    final s = await isar.appSettings.get(1) ?? (AppSettings()..id = 1);
    if (await isar.profileIsars.count() == 0) {
      final id = await nextProfileId(isar);
      await isar.profileIsars.put(
        ProfileIsar()
          ..id = id
          ..name = 'Sam'
          ..firstLogShown = true
          ..weatherOptInShown = true,
      );
      s.activeProfileId = id;
    }
    s.updateHighlightsOff = false;
    await isar.appSettings.put(s);
  });
  await BarLayoutStore.write(isar, const BarRecord());
  await GuideStore.write(isar, const GuideRecord());
}
