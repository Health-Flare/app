import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';

// ---------------------------------------------------------------------------
// Fake notifiers — skip Isar by overriding build()
// ---------------------------------------------------------------------------

class _FakeProfileList extends ProfileListNotifier {
  final List<Profile> _profiles;
  _FakeProfileList([this._profiles = const []]);

  @override
  List<Profile> build() => _profiles;
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  final int? _id;
  _FakeActiveProfile([this._id]);

  @override
  int? build() => _id;
}

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  @override
  List<Condition> build() => [];
}

class _FakeSymptomCatalog extends SymptomCatalogNotifier {
  @override
  List<Symptom> build() => [];
}

class _FakeUserConditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => [];
}

class _FakeUserSymptoms extends UserSymptomListNotifier {
  @override
  List<UserSymptom> build() => [];
}

class _FakeFirstLogPrompt extends FirstLogPromptNotifier {
  @override
  bool build() => false;
}

class _FakeWeatherOptIn extends WeatherOptInNotifier {
  @override
  bool build() => false;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// All overrides needed to run HealthFlareApp without a real Isar DB.
List<Override> _appOverrides({
  List<Profile> profiles = const [],
  int? activeProfileId,
}) => [
  profileListProvider.overrideWith(() => _FakeProfileList(profiles)),
  activeProfileProvider.overrideWith(() => _FakeActiveProfile(activeProfileId)),
  conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
  symptomCatalogProvider.overrideWith(_FakeSymptomCatalog.new),
  userConditionListProvider.overrideWith(_FakeUserConditions.new),
  userSymptomListProvider.overrideWith(_FakeUserSymptoms.new),
  firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
  weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
];

// ---------------------------------------------------------------------------
// Tests — routing / app-level behaviour
//
// Form-level tests (CTA enabled/disabled, whitespace validation) are in
// test/widget/onboarding_validation_test.dart, which pumps OnboardingProfileZone
// directly and avoids the off-screen scroll issue in the full app.
// ---------------------------------------------------------------------------

void main() {
  group('App routing', () {
    testWidgets('shows onboarding screen when no profile exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(),
          child: const HealthFlareApp(),
        ),
      );
      // One pump handles post-frame callbacks. The repeating welcome animation
      // means pumpAndSettle never settles — use pump(Duration) instead.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Your health story,\nin your hands.'), findsOneWidget);
    });

    testWidgets('skips onboarding and shows dashboard when profile exists', (
      tester,
    ) async {
      final profile = Profile(id: 1, name: 'Sarah');

      await tester.pumpWidget(
        ProviderScope(
          overrides: _appOverrides(
            profiles: [profile],
            activeProfileId: profile.id,
          ),
          child: const HealthFlareApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Onboarding welcome text must not appear.
      expect(find.text('Your health story,\nin your hands.'), findsNothing);
    });
  });
}
