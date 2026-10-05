import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/citations/symptom_sources.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/settings/screens/symptom_sources_screen.dart';
import 'package:health_flare/models/profile.dart';

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

// Settings > "Where our questions come from" (#92).
// Credit: Dr Cat Hicks, who pointed us to PROMIS, and her Informed Patient
// skill.

void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith(_FakeActiveProfile.new),
          profileListProvider.overrideWith(_FakeProfileList.new),
          activeProfileDataProvider.overrideWith(
            (ref) => Profile(id: 1, name: 'Sarah'),
          ),
        ],
        child: const MaterialApp(home: SymptomSourcesScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('credits Dr Cat Hicks and Informed Patient first', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text(SymptomSources.credit), findsOneWidget);
    expect(find.byKey(const Key('cat_hicks_credit')), findsOneWidget);
    expect(find.byKey(const Key('informed_patient_source')), findsOneWidget);
  });

  testWidgets('lists every source with its PMID', (tester) async {
    await pump(tester);
    for (final s in SymptomSources.all) {
      expect(find.text(s.citation), findsOneWidget);
      expect(find.text('PMID ${s.pmid}'), findsOneWidget);
    }
  });

  testWidgets('says the questions are informed by PROMIS, not PROMIS', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text(SymptomSources.promisNote), findsOneWidget);
  });

  testWidgets('offers a tap-only link to healthflare.org', (tester) async {
    await pump(tester);
    expect(find.text('Read more on healthflare.org'), findsOneWidget);
  });
}
