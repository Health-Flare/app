import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/theme/app_theme.dart';
import 'package:health_flare/features/journal/widgets/journal_empty_state.dart';
import 'package:health_flare/features/onboarding/widgets/first_log_prompt.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';
import 'package:health_flare/features/shared/widgets/weather_chip.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';
import 'package:health_flare/features/sleep/widgets/sleep_quality_selector.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/weather_snapshot.dart';

// ---------------------------------------------------------------------------
// Golden file tests — reference images live in test/goldens/.
//
// Regenerate after an intentional visual change:
//   flutter test --update-goldens test/golden
//
// Only deterministic widgets belong here: no DateTime.now() in the rendered
// output, no repeating animations. Rendering uses the FlutterTest font, which
// is stable across platforms on a pinned Flutter version (see ci.yaml).
// ---------------------------------------------------------------------------

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [
    Profile(id: 1, name: 'Sarah'),
    Profile(id: 2, name: 'Dad'),
  ];
}

final _profileOverrides = <Override>[
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  profileListProvider.overrideWith(_FakeProfileList.new),
  activeProfileDataProvider.overrideWith(
    (ref) => Profile(id: 1, name: 'Sarah'),
  ),
];

Widget _harness(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: child,
    ),
  );
}

Future<void> _pumpAtPhoneSize(WidgetTester tester, Widget widget) async {
  // iPhone-15-class logical resolution; small enough to catch layout
  // regressions, large enough for real content to fit.
  tester.view.physicalSize = const Size(430, 930);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(widget);
  await tester.pump();
}

void main() {
  testWidgets('golden: journal empty state', (tester) async {
    await _pumpAtPhoneSize(
      tester,
      _harness(const Scaffold(body: JournalEmptyState(isSearch: false))),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/journal_empty_state.png'),
    );
  });

  testWidgets('golden: sleep quality selector', (tester) async {
    await _pumpAtPhoneSize(
      tester,
      _harness(
        Scaffold(
          body: Center(
            child: SleepQualitySelector(value: 3, onChanged: (_) {}),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/sleep_quality_selector.png'),
    );
  });

  testWidgets('golden: weather chip', (tester) async {
    final snapshot = WeatherSnapshot(
      temperatureCelsius: 18.0,
      weatherCode: 2,
      pressureHPa: 1013.0,
      humidityPercent: 62,
      windSpeedKmh: 14.0,
      capturedAt: DateTime(2026, 5, 4, 9, 30),
    );
    await _pumpAtPhoneSize(
      tester,
      _harness(
        Scaffold(
          body: Center(child: WeatherChip(snapshot: snapshot)),
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/weather_chip.png'),
    );
  });

  testWidgets('golden: profile avatar', (tester) async {
    await _pumpAtPhoneSize(
      tester,
      _harness(
        Scaffold(
          body: Center(
            child: ProfileAvatar(profile: Profile(id: 1, name: 'Sarah')),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/profile_avatar.png'),
    );
  });

  testWidgets('golden: first-log prompt uses the profile name', (tester) async {
    await _pumpAtPhoneSize(
      tester,
      _harness(
        const Scaffold(body: FirstLogPrompt(profileName: 'Ethan')),
        overrides: _profileOverrides,
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/first_log_prompt.png'),
    );
  });

  testWidgets('golden: app bar with utility action and profile icon', (
    tester,
  ) async {
    await _pumpAtPhoneSize(
      tester,
      _harness(
        Scaffold(
          appBar: HFAppBar(
            title: const Text('Journal'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search entries',
                onPressed: () {},
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
        overrides: _profileOverrides,
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/hf_app_bar.png'),
    );
  });
}
