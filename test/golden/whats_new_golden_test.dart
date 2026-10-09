// Golden images for the What's new card, history and setting.
//
// Images live in test/goldens/whats_new_*.png and are rendered on Linux:
// macOS anti-aliasing differs slightly, so this file skips itself on
// macOS. To regenerate after an intentional visual change, run the
// "Regenerate goldens" workflow (Actions tab) and copy the PNGs from its
// artifact into test/goldens/. Guide: docs/testing/whats-new.md.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/features/whats_new/debug/whats_new_preview.dart';
import 'package:health_flare/features/whats_new/screens/whats_new_screen.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';
import 'package:health_flare/features/whats_new/widgets/whats_new_card.dart';
import 'package:health_flare/features/whats_new/widgets/whats_new_settings_tiles.dart';
import 'package:health_flare/models/profile.dart';

class _Fixed extends WhatsNewNotifier {
  _Fixed(this.record);
  final WhatsNewRecord record;

  @override
  Future<WhatsNewState> build() async => WhatsNewState(
    record: record,
    releases: previewReleases,
    installed: '99.2.0',
  );

  @override
  Future<bool> noteCardShown() async => false;
}

class _NoProfiles extends ProfileListNotifier {
  @override
  List<Profile> build() => [];
}

class _NoActive extends ActiveProfileNotifier {
  @override
  int? build() => null;
}

/// Goldens are rendered on Linux (CI); macOS pixels differ slightly.
final _skipOnMac = Platform.isMacOS;

Future<void> _golden(
  WidgetTester tester,
  String name,
  Widget child, {
  WhatsNewRecord record = const WhatsNewRecord(lastSeenVersion: '99.1.0'),
  bool dark = false,
  double height = 400,
}) async {
  tester.view.physicalSize = Size(430, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        whatsNewProvider.overrideWith(() => _Fixed(record)),
        activeFlareProvider.overrideWith((ref) => null),
        profileListProvider.overrideWith(_NoProfiles.new),
        activeProfileProvider.overrideWith(_NoActive.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../goldens/whats_new_$name.png'),
  );
}

Widget _onDashboard(Widget w) => Scaffold(body: ListView(children: [w]));

void main() {
  testWidgets('golden: card', skip: _skipOnMac, (tester) async {
    await _golden(tester, 'card', _onDashboard(const WhatsNewCard()));
  });

  testWidgets('golden: card, dark', skip: _skipOnMac, (tester) async {
    await _golden(
      tester,
      'card_dark',
      _onDashboard(const WhatsNewCard()),
      dark: true,
    );
  });

  testWidgets('golden: card covering two releases', skip: _skipOnMac, (
    tester,
  ) async {
    await _golden(
      tester,
      'card_multi',
      _onDashboard(const WhatsNewCard()),
      record: const WhatsNewRecord(lastSeenVersion: '99.0.0'),
    );
  });

  testWidgets('golden: history', skip: _skipOnMac, (tester) async {
    await _golden(tester, 'history', const WhatsNewScreen(), height: 930);
  });

  testWidgets('golden: settings tiles, highlights off', skip: _skipOnMac, (
    tester,
  ) async {
    await _golden(
      tester,
      'settings_off',
      _onDashboard(const WhatsNewSettingsTiles()),
      record: const WhatsNewRecord(
        lastSeenVersion: '99.2.0',
        highlightsOff: true,
      ),
      height: 260,
    );
  });
}
