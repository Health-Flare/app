# Internationalization (i18n) strategy

**Status:** proposed — no code changes yet. This document is the investigation
behind the tracking issues; it captures the honest tradeoffs, not just the
recommendation, so the reasoning survives past the initial implementation.

## Current state

Health Flare has no i18n today. Every user-facing string in `lib/` is a
hardcoded English string literal. `intl` is already a dependency, but only
for `DateFormat` in the journal entry list/detail views — not for
translation. There is no `lib/l10n/`, no `AppLocalizations`, and
`MaterialApp` doesn't set `locale`, `localizationsDelegates`, or
`supportedLocales`, so even Flutter's own built-in widgets (date pickers,
"OK"/"Cancel", back-button semantics) render in whatever locale Flutter
falls back to.

## What this app's existing constraints rule in and out

- **Offline-first, with exactly one documented exception.** The app makes
  no network calls except the opt-in weather capture (`api.open-meteo.com`,
  coordinates sent, never stored — see `.url-scan-ignore`). Any i18n
  approach that adds its *own* network dependency (a cloud
  translation-management sync, a remote string-loading fallback) would be a
  second, undocumented exception to a rule the project otherwise treats as
  close to absolute. Disqualified.
- **No accounts, no cloud sync, no analytics/telemetry SDKs of any kind**
  (`CLAUDE.md` "Offline-First"). Same reasoning as above.
- **Fewer, better-trusted dependencies.** Nothing in `CLAUDE.md` states this
  as explicitly as Inner Flare's guide does, but the same org runs the same
  Renovate-gated dependency discipline here (`renovate.json5`), and a new
  i18n package is a new long-term maintenance and audit surface either way.
- **`intl` is already in the dependency tree.** Adopting the official
  `gen-l10n` path costs nothing new on this front — it's already there for
  date formatting.
- **CSV/PDF exports must stay portable.** `CsvReportService`/
  `PdfReportService` produce files meant to be opened outside the app
  (spreadsheet tools, printed for a clinician). Locale-aware UI formatting
  must not leak into these exports (see "Locale-invariant storage and
  exports" below) or a report generated under a non-English locale could
  silently produce a CSV a spreadsheet app parses wrong (comma-as-decimal
  vs comma-as-delimiter is the classic failure).
- **Custom bundled fonts.** Fraunces, DM Sans, and DM Mono are bundled
  locally (no `google_fonts`, per the "Must Pass" rules) and their glyph
  coverage is unknown for non-Latin scripts. This is Health Flare-specific
  — Inner Flare doesn't bundle custom fonts — and needs its own audit (see
  below).

## Options considered

### A. Official `flutter_localizations` + `intl` + `flutter gen-l10n` (recommended)

Flutter's own solution: ARB files (`lib/l10n/app_en.arb`, one per locale) as
source of truth, `flutter gen-l10n` (a built-in Flutter SDK command, not a
pub.dev package) generates a typed `AppLocalizations` class, and `intl`
(Dart-team-maintained, already a dependency here) provides
`DateFormat`/`NumberFormat`/ICU `plural`/`select`.

**Pros:**
- No *new* pub.dev dependency — `flutter_localizations` ships with the SDK,
  and `intl` is already in `pubspec.yaml`. This is the smallest possible
  supply-chain delta of any option on this list.
- Compile-time-checked string access — a missing/misspelled key is a build
  failure, not a blank label or raw key shown to a user.
- Full ICU plural/select support, which is necessary correctness (plural
  category rules are language-specific — Arabic has six categories, not
  two), not a nice-to-have.
- Doesn't add a second codegen tool next to `build_runner`/
  `riverpod_generator`/the isolated `isar_codegen` project — it's a
  separate, official SDK command triggered by `flutter: generate: true`.

**Cons (stated plainly):**
- More ceremony than the alternatives: `l10n.yaml`, ARB's verbose
  JSON-with-`@`-metadata format, a flat key namespace.
- `flutter gen-l10n` needs to be re-run (or `flutter run`/`build` re-invoked)
  after editing an ARB file outside the normal run loop.
- A runtime locale switcher (a Settings toggle, not just following system
  locale) needs a small amount of app-side plumbing — a Riverpod
  `localeProvider` feeding `MaterialApp.locale` — rather than being handled
  for free.

### B. `easy_localization`

Runtime JSON/CSV/YAML asset lookups via `'key'.tr()`, no codegen.

**Pros:** fast to start, no build step, offline in its default
configuration.

**Cons:** a third-party dependency to trust and patch indefinitely, for
something the SDK already does. Runtime string-keyed lookups mean a typo'd
key fails at runtime in front of a user, not at build time. It also ships
an *optional* remote-loading capability we'd never enable — but its mere
existence in the package is a mismatch for an app that documents its one
network exception this precisely.

### C. `slang` (successor to `fast_i18n`)

Codegen-based, JSON/YAML/CSV, typed accessors, nicer namespacing/DX than
ARB.

**Pros:** genuinely nicer to write than ARB, fully offline, typed, active
project.

**Cons:** still a third-party dependency for something the SDK already
solves. Better DX, not a different capability — and `intl` is already a
dependency here, so option A costs strictly less to adopt than introducing
`slang` alongside it would.

### D. `intl_utils` / the "Flutter Intl" IDE plugin / Localizely

Wraps `flutter gen-l10n` with IDE tooling, and optionally syncs ARB files
with the Localizely cloud translation platform. The generation-only part
isn't meaningfully different from option A; the cloud-sync part conflicts
with the app's one-documented-exception network posture. Not worth adopting
a wrapper whose distinguishing feature we can't use.

### E. Roll our own (hand-written locale maps, no package)

Zero dependencies, a `Map<String, Map<String, String>>` per locale.

**Rejected.** Quietly reimplements CLDR plural-category logic and
locale-aware formatting, both genuinely easy to get subtly wrong per
language. `intl` already solves this and is maintained by the people who
ship Flutter's own SDK localizations — skipping it isn't a privacy win, it's
re-deriving a known-hard problem with less scrutiny than the dependency it
replaces.

## Decision

**Option A: `flutter_localizations` (SDK) + `intl` (already a dependency) +
`flutter gen-l10n`.** Smallest supply-chain footprint of any option that
correctly handles plurals/ICU/RTL/locale formatting, and it's strictly
cheaper to adopt here than elsewhere since `intl` is already in the
dependency tree for date formatting.

## What we are deliberately not doing

- No cloud translation-management platform (Localizely, Lokalise, Crowdin,
  or similar) — ARB files are plain text, reviewed in PRs like everything
  else in this repo.
- No machine-translation-at-build-time step.
- No expansion of the app's network surface beyond the existing, documented
  weather-capture exception. Locale detection uses on-device
  `Platform.localeName` / `WidgetsBinding.instance.platformDispatcher.locale`,
  not a network lookup.
- No third-party i18n package. Revisitable if `gen-l10n` ergonomics turn out
  to be a real blocker in practice — that's a deliberate re-evaluation, not
  a default fallback.

## Beyond translation: what else internationalization touches

Translation is the visible fraction. The rest, roughly in the order it'll
bite:

1. **Locale-aware date/number/unit formatting.** `intl`'s `DateFormat`/
   `NumberFormat` should cover dates everywhere, replacing any ad hoc
   formatting. This app also has unit questions translation alone doesn't
   solve — weight (kg/lb), temperature (°C/°F) — which are a *units*
   preference, not strictly a locale one (a German-speaking user may still
   want °F). Worth deciding explicitly as a separate settings axis rather
   than silently inferring units from locale.
2. **Locale-invariant storage and exports.** Isar-stored values and the
   CSV/PDF report exports must keep using a fixed, locale-independent
   representation (ISO-8601 dates, `.` decimal separator) regardless of
   in-app UI locale — otherwise a CSV generated under a locale that uses `,`
   as a decimal separator could be misread by a spreadsheet tool expecting
   `,` as the field delimiter. This needs an explicit test, not an
   assumption, in `CsvReportService`/`PdfReportService`.
3. **Pluralization and gender/select rules.** Any string embedding a count
   (dose counts, symptom counts, "N entries this week") needs an ICU
   `plural`/`select` rewrite, not string concatenation — this is
   language-specific grammar.
4. **RTL layout.** Arabic/Hebrew support means auditing for hardcoded
   `left`/`right`/`Alignment.centerLeft` instead of `start`/`end`, and any
   custom icon that implies direction. Flutter's `Directionality` handles
   most of this once a locale's `TextDirection` is RTL — the audit is for
   the widgets that quietly assumed LTR (charts in `fl_chart`, PDF report
   layout, and the dashboard grid are the likely offenders given how visual
   this app is).
5. **Font glyph coverage.** Fraunces/DM Sans/DM Mono are bundled and their
   non-Latin coverage (Cyrillic, Greek, Arabic, CJK) is currently unknown
   and unaudited. Flutter falls back to system fonts for missing glyphs,
   but that fallback needs to be verified per target platform/OS version,
   not assumed — a silent tofu/blank-glyph render is a worse experience
   than a mismatched-but-legible fallback font.
6. **Text expansion.** Translated strings commonly run 30%+ longer than
   English — dense UI (dashboard cards, chart legends, the reports screen)
   needs a layout check per locale, not just a translation check.
7. **Locale-aware sorting.** Any alphabetically-sorted list (condition
   names, medication names) needs collation-aware sorting once non-English
   locales exist.
8. **A locale switcher.** A Settings toggle (follow system / pick a
   language), persisted locally. Not sensitive data — doesn't need special
   handling beyond an ordinary local preference.
9. **Accessibility interplay.** Screen reader locale announcement falls out
   of `localizationsDelegates`/`supportedLocales` being set correctly —
   worth an explicit per-locale check.
10. **Catching regressions.** New hardcoded strings creeping back in after
    the initial extraction is the likeliest long-term failure mode. This
    app already runs a `scripts/check_urls.sh`-style pre-commit scan for a
    structurally similar problem (network URLs in Dart files); a small
    grep-based scan for new `Text('literal')`-shaped widgets that bypass
    `AppLocalizations`, with the same `.url-scan-ignore`-style escape
    hatch, is a natural extension of a pattern that already exists here.
11. **Translation accuracy for medical/disclaimer copy.** Symptom and
    condition terminology, and any disclaimer language, carries more risk
    from a bad translation than an ordinary button label. Locale-specific
    disclaimer/medical-terminology strings should get a fluent or native
    speaker review before shipping, even if the rest of a locale ships more
    informally.
12. **Store listings are separate from in-app strings** and intentionally
    out of scope for the issue list below — downstream of in-app i18n
    existing, not a blocker for it.
13. **Translator contributions.** Once infrastructure and English
    extraction land, additional locales become a "call for help" —
    community contributors add `app_<locale>.arb` and open a PR without
    touching app code. Tracked as its own issue, deliberately last.

## Tracking issues

See [#37](https://github.com/Health-Flare/app/issues/37) for the full
breakdown and sub-issues (#38–#46); the infrastructure issue (#38) is the
dependency root for everything else in that list.
