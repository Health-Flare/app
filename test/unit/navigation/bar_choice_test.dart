// The stored bar choice (#143): changes, undo, reset and the preset, saved
// on AppSettings. Real Isar. Spec: navigation-customization.feature.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/migration_runner.dart';

const _default = ['dashboard', 'track', 'care', 'journal'];

void main() {
  setUpAll(() async => Isar.initializeIsarCore(download: true));

  late Directory dir;
  late Isar isar;
  late ProviderContainer c;

  Future<Isar> open() =>
      Isar.open(appSchemas, directory: dir.path, name: 'bar_choice');

  ProviderContainer container(BarRecord start) {
    final c = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        featureFlagsProvider.overrideWithValue(
          const FeatureFlags(trackAndCare: true),
        ),
        barChoiceProvider.overrideWith(
          () => BarChoiceNotifier()..preload(start),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hf_bar_choice_');
    isar = await open();
    await MigrationRunner.run(isar);
    c = container(const BarRecord(seenVersion: 2));
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close();
    dir.deleteSync(recursive: true);
  });

  BarChoiceNotifier bar() => c.read(barChoiceProvider.notifier);

  test('starts on the default bar, not customized', () {
    expect(bar().shownIds, _default);
    expect(c.read(barChoiceProvider).storedBar, isNull);
    expect(c.read(barIsCustomizedProvider), isFalse);
  });

  test('a change is stored, on the current default version, and survives a '
      'restart', () async {
    await bar().choose([..._default, 'care.medications']);
    expect(c.read(barIsCustomizedProvider), isTrue);
    await isar.close();
    isar = await open();
    expect(
      await BarLayoutStore.read(isar),
      const BarRecord(
        storedBar: [..._default, 'care.medications'],
        seenVersion: 2,
      ),
    );
  });

  test('Changes apply straight away and can be undone', () async {
    final before = await bar().choose(['dashboard', 'track', 'care']);
    expect(bar().shownIds, ['dashboard', 'track', 'care']);
    await bar().restore(before);
    expect(c.read(barChoiceProvider), const BarRecord(seenVersion: 2));
    expect((await BarLayoutStore.read(isar)).storedBar, isNull);
  });

  test('Reset to the default stores nothing', () async {
    await bar().choose(['dashboard', 'track', 'care']);
    await bar().useDefault();
    expect(c.read(barChoiceProvider).storedBar, isNull);
    expect(c.read(barIsCustomizedProvider), isFalse);
  });

  test("The guide's \"Keep it like before\" choice uses the preset", () async {
    await bar().applyLikeBefore();
    expect(c.read(barChoiceProvider).storedBar, likeBeforePreset);
    expect(c.read(barIsCustomizedProvider), isTrue);
  });

  test('putting the default back by hand counts as the default', () async {
    await bar().choose(['dashboard', 'track', 'care']);
    await bar().choose(_default);
    expect(c.read(barIsCustomizedProvider), isFalse);
  });
}
