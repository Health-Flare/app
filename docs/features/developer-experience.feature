Feature: Developer Experience
  As a developer working on Health Flare
  I want automated guardrails that prevent regressions, keep dependencies healthy,
  enforce code quality, and ensure the app stays fully offline
  So that the path to a correct, shippable build is smooth and failures are caught early

  # ---------------------------------------------------------------------------
  # Linting and static analysis
  # ---------------------------------------------------------------------------

  Scenario: Flutter analyse passes with zero issues on every commit
    Given any commit is pushed to any branch
    When the CI pipeline runs
    Then `flutter analyze` exits with code 0
    And no errors, warnings, or lint violations are reported
    And the pipeline fails visibly if any issue is found

  Scenario: Stricter lint rules are enforced beyond the flutter_lints baseline
    Given the analysis_options.yaml configuration
    Then the following rules are enabled above the flutter_lints baseline:
      | Rule                              | Rationale                                      |
      | always_use_package_imports        | Prevents relative import confusion             |
      | avoid_dynamic_calls               | Catches untyped runtime dispatch               |
      | avoid_print                       | No debug output in production builds           |
      | cancel_subscriptions              | Prevents stream/subscription memory leaks      |
      | close_sinks                       | Prevents sink memory leaks                     |
      | prefer_single_quotes              | Consistent string style                        |
      | require_trailing_commas           | Consistent formatting, better diffs            |
      | unawaited_futures                 | Catches fire-and-forget async bugs             |
      | unnecessary_lambdas               | Cleaner, more idiomatic Dart                   |

  Scenario: Dart formatter is enforced
    Given any Dart file in lib/ or test/
    When the CI pipeline runs
    Then `dart format --output=none --set-exit-if-changed .` exits with code 0
    And the pipeline fails if any file is not correctly formatted

  # ---------------------------------------------------------------------------
  # Dependency continuity and updates
  # ---------------------------------------------------------------------------

  Scenario: All direct dependencies resolve without conflicts on CI
    Given the current pubspec.yaml
    When `flutter pub get` is run in a clean environment
    Then it exits with code 0
    And pubspec.lock is consistent with pubspec.yaml
    And no dependency is marked as discontinued

  Scenario: Outdated direct dependencies are reported weekly
    Given it is the first day of a working week
    When the scheduled dependency audit runs
    Then `flutter pub outdated` output is captured
    And any direct dependency with a newer resolvable version is surfaced as a warning
    And any direct dependency with a discontinued transitive dependency is surfaced as an error

  Scenario: Dependency versions are pinned with caret (^) constraints
    Given any entry in the dependencies or dev_dependencies sections of pubspec.yaml
    Then every version constraint uses caret (^) syntax
    And no dependency uses an unbounded constraint (e.g. "any" or ">= x.y.z")
    And no dependency uses an exact pin without documented justification

  Scenario: isar_community_generator isolation is documented and enforced
    Given the known conflict between isar_community_generator and riverpod_generator
    Then isar_community_generator is absent from the main pubspec.yaml
    And the scripts/isar_codegen/ directory contains its own isolated pubspec.yaml
    And the scripts/generate_isar.sh script is executable and present
    And the CI pipeline verifies generated .g.dart files are committed and up to date

  # ---------------------------------------------------------------------------
  # Security scanning
  # ---------------------------------------------------------------------------

  Scenario: No known vulnerable packages are present
    Given the resolved dependency tree
    When the CI pipeline runs
    Then `flutter pub audit` exits with code 0
    And no dependency with a known security advisory is present
    And the pipeline fails if any advisory is reported

  Scenario: No hardcoded secrets or credentials appear in source code
    Given any file tracked by git
    When the CI pipeline runs
    Then no file contains patterns matching common secret formats:
      | Pattern type         | Example pattern                        |
      | API keys             | [A-Za-z0-9]{32,}                       |
      | Private key headers  | -----BEGIN (RSA\|EC\|PRIVATE) KEY----- |
      | Bearer tokens        | Bearer [A-Za-z0-9\-._~+/]+=*          |
    And the pipeline fails immediately if any match is found
    And false positives can be suppressed with an inline annotation comment

  # ---------------------------------------------------------------------------
  # Offline-first enforcement (no outbound URLs in code)
  # ---------------------------------------------------------------------------

  Scenario: No network URLs appear in Dart source files
    Given Health Flare is a fully offline application
    When the CI pipeline scans lib/ and test/
    Then no Dart file contains a hardcoded http:// or https:// URL outside of a comment
    And no Dart file imports a package that makes outbound network requests at runtime
      (specifically: google_fonts, firebase_*, supabase_*, http, dio, retrofit)
    And the pipeline fails with the offending file and line number if a URL is found

  Scenario: google_fonts package is not present as a dependency
    Given the app bundles all fonts as local assets
    Then google_fonts does not appear in pubspec.yaml dependencies
    And no Dart file in lib/ contains "import 'package:google_fonts"
    And the CI pipeline verifies both conditions on every run

  Scenario: URL scan whitelist is documented and version-controlled
    Given some URLs are legitimately present (e.g. in comments citing specifications)
    Then a .url-scan-ignore file exists at the repository root
    And each whitelisted pattern has a documented justification
    And the whitelist is reviewed as part of any PR that adds a new entry

  # ---------------------------------------------------------------------------
  # Build integrity
  # ---------------------------------------------------------------------------

  Scenario: Debug APK builds successfully on every PR
    Given a pull request is opened or updated against main
    When the CI pipeline runs
    Then `flutter build apk --debug` completes with exit code 0
    And the built APK artefact is archived for inspection

  Scenario: No generated files are out of date
    Given the Riverpod generated files (*.g.dart from riverpod_generator)
    When the CI pipeline runs
    Then `dart run build_runner build --delete-conflicting-outputs` produces no changes
    And the pipeline fails if any generated file differs from what is committed

  Scenario: The isar_codegen generated files are committed and current
    Given the Isar schema files in lib/data/models/
    Then all corresponding .g.dart files are present and committed
    And the CI pipeline detects if a schema file has changed without a corresponding
    regeneration by running scripts/generate_isar.sh and diffing the output

  # ---------------------------------------------------------------------------
  # Branch and PR hygiene
  # ---------------------------------------------------------------------------

  Scenario: All CI checks must pass before a PR can be merged
    Given a pull request targeting main
    Then the following checks are required to pass before merge is permitted:
      | Check                  |
      | flutter-analyze        |
      | dart-format            |
      | flutter-pub-get        |
      | flutter-pub-audit      |
      | url-scan               |
      | flutter-build-apk      |
    And no force-push to main is permitted
    And direct commits to main without a PR are blocked

  Scenario: Commit messages follow Conventional Commits format
    Given any commit pushed to a branch with an open PR
    Then the commit subject line matches the pattern:
      <type>(<optional scope>): <description>
    Where type is one of: feat, fix, chore, docs, refactor, test, perf, ci
    And the pipeline warns (but does not fail) if the format is not followed
