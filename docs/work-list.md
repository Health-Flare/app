# Health Flare — Work List (Backlog Refresh, 2026-08-24)

This replaces the April work list, which is fully complete — see
`docs/archive/work-list-2026-04-completed.md`. This backlog is sourced from two places:

1. **Status refresh** of the gaps (`G1`–`G14`) identified in `docs/persona-evaluation.md`
   (2026-07-05), re-verified against the live code today.
2. **New findings** from developer-experience friction encountered directly this session
   (release engineering, local dev environment, CI/CD topology) — not covered by either
   existing doc.

Items use a fresh `BL-` prefix (not `WL-`) to avoid colliding with the ~30 existing commits/PRs
that already reference `WL-01` through `WL-17` in their history.

---

## G1–G14 status refresh (2026-08-24)

| # | Gap (see `docs/persona-evaluation.md` for full description) | Status |
|---|---|---|
| G1 | No app lock (PIN/biometric) | **Open** — no `local_auth` dependency. → `BL-01` |
| G2 | No pre-migration snapshot / auto-backup | **Open** — no snapshot logic in `migration_runner.dart`. → `BL-02` |
| G3 | No caregiver-usable import path for external data | **Partially closed** — `tools/csv_import` (CLI) now exists but is developer-only, undocumented, journal+symptom only. → `BL-03` |
| G4 | Quick-log downgrades vitals/meds to journal text | **Fixed** — `quick_log_sheet.dart` now parses and saves vitals, medication doses, and sleep as typed entries |
| G5 | No wrong-profile recovery ("move entry to another profile") | Not re-verified this session — assume still open. → `BL-09` |
| G6 | "Fully offline" claim inaccurate (weather is a real network call) | **Open** — `CLAUDE.md` still says "no network calls"; `.url-scan-ignore` documents the exception correctly but the claim itself hasn't been corrected everywhere. → `BL-04` |
| G7 | No reminders | Not re-verified — deliberately out of scope until Phase A/B close, per original sequencing |
| G8 | Accessibility asserted, not audited | Not re-verified — see `O2` below |
| G9 | Dictation has no affordance | Not re-verified |
| G10 | Platform parity incomplete (Linux/Windows/web) | Not re-verified — macOS App Store planning is now active (see `docs/apple-app-store-checklist.md`), which makes this more visible, not less |
| G11 | Backup restore across schema versions unverified | Not re-verified |
| G12 | Migration test artifacts committed at repo root | **Was already better than described** — `.gitignore` covers `*.isar`/`*.isar-lck`, so nothing was actually committed. But 84 stray files had accumulated locally from repeated test runs with no cleanup; **deleted 2026-08-24**. Root cause (WL-17 smoke test doesn't clean up after itself) is still open. → `BL-10` |
| G13 | `feature/spec-updates` branch drift risk | **Materialized** — branch is 68 commits behind `main`, last touched 2026-04-28. Its content (golden tests, screenshot automation) already shipped via PR #93/#95 through a different path. Branch is dead weight now. → `BL-11` |
| G14 | Journal entries have no editable date | Not re-verified — relevant to `BL-03` (import needs back-dating) |

---

## New: Developer Experience gaps

Found directly this session while setting up App Store Connect release automation — not
previously documented anywhere.

### BL-05 · Document the real Gitea/GitHub CI topology
**Priority:** P1 · **Labels:** `type:infrastructure` `priority:p1`

`CLAUDE.md` says "this project uses Gitea, not GitHub — do not use `gh`." In practice: Gitea
Actions only reads `.gitea/workflows/` (two workflows there, both currently disabled), while
**all real release automation** (`release-appstore.yaml`, `release-playstore.yaml`,
`release-macos.yaml`, CI) lives in `.github/workflows/` and only executes on the
`Health-Flare/app` GitHub mirror that Gitea push-mirrors to within seconds of a push. Signing
secrets live on GitHub, not Gitea. A contributor following `CLAUDE.md` literally would never
find where CI actually runs, or that `gh` (not `tea`) is what you need to inspect workflow runs
and secrets.

**Fix:** Add a "CI/CD topology" section to `CLAUDE.md` explaining the mirror relationship,
where secrets live, and that `gh` is needed (read-only: inspecting runs/logs/secrets, not PRs)
alongside `tea`.

**tea command:**
```bash
tea issue create \
  --title "docs: document the real Gitea/GitHub Actions CI topology" \
  --body "CLAUDE.md says Gitea-only but all release workflows execute on the GitHub mirror. Document the push-mirror relationship, where secrets live, and gh's actual read-only role. See docs/work-list.md BL-05." \
  --label "priority:p1,type:infrastructure" \
  --login healthflare --repo HealthFlare/app
```

---

### BL-06 · Document local dev environment prerequisites (Xcode license)
**Priority:** P1 · **Labels:** `type:infrastructure` `priority:p1`

`flutter test` cannot run at all on a fresh macOS dev machine until Xcode's license is accepted
(`sudo xcodebuild -license` / `sudo xcodebuild -runFirstLaunch`) — `flutter pub get`'s
native-asset build hook for the `objective_c` package (pulled in transitively via
`geolocator_apple` or similar) fails with an opaque `Bad state: No element` error otherwise.
This isn't iOS-specific — it blocks every `flutter test` run, including on Android/other work.
`CLAUDE.md`'s "Quick Start Commands" don't mention this prerequisite.

**Fix:** Add a one-line prerequisite note + the fix command to `CLAUDE.md`'s Quick Start section.

**tea command:**
```bash
tea issue create \
  --title "docs: document Xcode license prerequisite for flutter test" \
  --body "flutter pub get fails via objective_c's native-asset hook until Xcode license is accepted, blocking ALL local test runs (not just iOS). Add to CLAUDE.md Quick Start. See docs/work-list.md BL-06." \
  --label "priority:p1,type:infrastructure" \
  --login healthflare --repo HealthFlare/app
```

---

### BL-07 · Finish App Store Connect CI signing
**Priority:** P1 · **Labels:** `type:infrastructure` `priority:p1`

`release-appstore.yaml` has failed 5 real attempts — see `docs/apple-app-store-checklist.md`
Phase 4 for the full attempt log. Root cause under active investigation: `xcodebuild archive`'s
automatic-signing resolution doesn't reliably invoke API-key auth for a brand-new Distribution
profile; provisioning it once via Xcode's own GUI is in progress. Tracked in the checklist doc
already — this entry exists so it's visible in the general backlog, not duplicated in detail.

**tea command:**
```bash
tea issue create \
  --title "ci(ios): finish App Store Connect signing for release-appstore.yaml" \
  --body "5 failed attempts so far, full log in docs/apple-app-store-checklist.md Phase 4. Root cause: xcodebuild archive automatic-signing not reliably invoking API-key auth for a first-ever Distribution profile. See docs/work-list.md BL-07." \
  --label "priority:p1,type:infrastructure" \
  --login healthflare --repo HealthFlare/app
```

---

### BL-08 · Dependency upgrade pass, including 2 discontinued packages
**Priority:** P2 · **Labels:** `type:infrastructure` `priority:p2`

`flutter pub outdated` shows 19 dependencies constrained below what's resolvable. Two —
`build_resolvers` and `build_runner_core` — are **discontinued** upstream. Not urgent today, but
a silent risk for a codegen-heavy project (Riverpod + Isar both depend on `build_runner`) — a
future Dart/Flutter SDK bump could break codegen with no warning.

**tea command:**
```bash
tea issue create \
  --title "chore: dependency upgrade pass (2 discontinued build_runner packages)" \
  --body "flutter pub outdated shows 19 constrained-below-resolvable deps; build_resolvers and build_runner_core are discontinued upstream. See docs/work-list.md BL-08." \
  --label "priority:p2,type:infrastructure" \
  --login healthflare --repo HealthFlare/app
```

---

## Priority backlog (persona-evaluation gaps, refreshed)

### BL-01 · App lock (G1)
**Priority:** P0 · **Labels:** `priority:p0` `type:feature`

PIN/biometric gate via `local_auth`, per-device toggle in Settings. Closes the largest trust gap
for children's data on a shared family device (Sam hands the phone to Rose).

```bash
tea issue create \
  --title "Feature: app lock (PIN/biometric via local_auth)" \
  --body "No app lock exists today — whoever holds the device reads two children's health histories. Add local_auth PIN/biometric gate, Settings toggle. Closes persona-evaluation.md G1. See docs/work-list.md BL-01." \
  --label "priority:p0,type:feature" \
  --login healthflare --repo HealthFlare/app
```

### BL-02 · Pre-migration snapshot + scheduled auto-backup (G2)
**Priority:** P0 · **Labels:** `priority:p0` `type:feature`

Copy the database aside before applying any migration (keep last N); add daily/on-close
auto-backup so Claire never has to remember to export manually. Directly neutralises the
"bad migration destroys the only copy of the kids' histories" scenario.

```bash
tea issue create \
  --title "Feature: pre-migration snapshot + scheduled auto-backup" \
  --body "migration_runner.dart has no snapshot-before-migrate step; backup is manual-only. Add automatic pre-migration snapshot (keep last N) and scheduled auto-backup. Closes persona-evaluation.md G2. See docs/work-list.md BL-02." \
  --label "priority:p0,type:feature" \
  --login healthflare --repo HealthFlare/app
```

### BL-03 · Caregiver-usable import path (G3 upgrade)
**Priority:** P0 · **Labels:** `priority:p0` `type:feature`

`tools/csv_import` proves the import pipeline works (dry-run, duplicate-skipping, writes
directly to Isar) but it's a developer-only CLI tool with no README, covering only journal and
symptom rows. Needs either: (a) a documented, safe standalone runbook a non-technical user could
follow once with help, or (b) a real in-app import screen (file picker → category preview →
import), matching the restore UI's existing pattern. Needs G14 (editable journal date) to
back-date correctly.

```bash
tea issue create \
  --title "Feature: caregiver-usable import path for external data" \
  --body "tools/csv_import exists but is a developer-only CLI with no README, journal+symptom only. Build an in-app import flow or a documented runbook. Depends on editable journal dates (G14). Closes persona-evaluation.md G3. See docs/work-list.md BL-03." \
  --label "priority:p0,type:feature" \
  --login healthflare --repo HealthFlare/app
```

### BL-04 · Privacy copy audit (G6)
**Priority:** P1 · **Labels:** `priority:p1` `type:fix`

Re-verify every privacy claim (onboarding zone, weather opt-in sheet, privacy policy,
`CLAUDE.md`) against the real weather network path. Add "location is sent to Open-Meteo when
enabled" to the opt-in sheet. Cheap, protects the app's strongest asset — its credibility.

```bash
tea issue create \
  --title "fix: privacy copy audit against the weather network path" \
  --body "CLAUDE.md and onboarding copy say 'fully offline / no network calls' but weather (opt-in) sends coordinates to api.open-meteo.com. Audit and correct every privacy claim. Closes persona-evaluation.md G6. See docs/work-list.md BL-04." \
  --label "priority:p1,type:fix" \
  --login healthflare --repo HealthFlare/app
```

### BL-09 · "Move entry to another profile" (G5)
**Priority:** P1 · **Labels:** `priority:p1` `type:feature`

One action on entry detail screens to move a mis-logged entry to the correct profile,
preserving the original timestamp. Closes the loop when Sam's preventive defences fail anyway.

```bash
tea issue create \
  --title "Feature: move entry to another profile" \
  --body "No recovery path when an entry is logged to the wrong profile — only delete + re-enter, losing the original timestamp. Add a 'Move to profile...' action on entry detail screens. Closes persona-evaluation.md G5. See docs/work-list.md BL-09." \
  --label "priority:p1,type:feature" \
  --login healthflare --repo HealthFlare/app
```

### BL-10 · Migration smoke test should clean up its own fixtures (G12 root cause)
**Priority:** P2 · **Labels:** `priority:p2` `type:fix`

The WL-17 migration smoke test creates a timestamped `.isar`/`.isar-lck` pair per run at the
repo root and never deletes them — 84 had accumulated as of 2026-08-24 (now cleaned up once,
manually). Add teardown (`tearDown`/`addTearDown` deleting the test DB file) so this doesn't
recur.

```bash
tea issue create \
  --title "fix: migration smoke test should delete its own fixture files" \
  --body "The WL-17 migration smoke test never cleans up its timestamped .isar/.isar-lck fixtures. 84 had accumulated at the repo root before a manual cleanup on 2026-08-24. Add teardown. See docs/work-list.md BL-10." \
  --label "priority:p2,type:fix" \
  --login healthflare --repo HealthFlare/app
```

### BL-11 · Close out `feature/spec-updates` branch (G13)
**Priority:** P2 · **Labels:** `priority:p2` `type:infrastructure`

68 commits behind `main`, last touched 2026-04-28. Its content (golden tests, screenshot
automation) already shipped via PR #93/#95 through a different path. Verify nothing unique
remains on the branch, then delete it — this is a destructive git action, so do it deliberately
rather than leaving it to rot further.

```bash
tea issue create \
  --title "chore: close out stale feature/spec-updates branch" \
  --body "68 commits behind main, last touched 2026-04-28; its content already shipped separately via PR #93/#95. Verify nothing unique remains, then delete. Closes persona-evaluation.md G13. See docs/work-list.md BL-11." \
  --label "priority:p2,type:infrastructure" \
  --login healthflare --repo HealthFlare/app
```

---

## Other / cross-cutting (not yet ticketed)

**O1 · No security review has ever been run on this repo.** Checked for prior artifacts — none
found beyond the `SECURITY.md` policy doc itself. Worth one pass given the app stores two
children's health data, especially around the backup/restore/import file-parsing paths (no
visible schema validation in `import_service.dart`'s CSV path). Use the `/security-review` skill.

**O2 · Accessibility remains asserted, not audited** (= G8, restated for visibility). WCAG 2.1 AA
is claimed in `docs/requirements.md`; no golden-test or audit evidence of contrast, dynamic-type
behaviour, or screen-reader traversal exists yet. Highest-impact for Rose (elderly persona) and
Alex (brain-fog days).

---

## Suggested sequencing

Unchanged from `persona-evaluation.md`'s Phase A/B/C/D rationale — this refresh doesn't change
that ordering, it updates what's actually still open within it:

1. **Trust gate before anything else:** `BL-01` (app lock), `BL-02` (auto-backup/snapshot),
   `BL-03` (import path) — these were Phase A/B in the original doc and are still the go/no-go
   for the caregiver handoff. Notably, App Store submission work (`BL-07`) has proceeded ahead
   of these — reasonable to run in parallel, but worth naming explicitly rather than by accident.
2. **Cheap trust wins:** `BL-04` (privacy copy audit) — small effort, protects credibility.
3. **DX foundation:** `BL-05`, `BL-06` — document the CI topology and local dev prerequisites
   before more time is lost to the exact confusion this session hit.
4. **Everything else:** `BL-07` through `BL-11`, `O1`, `O2` in roughly the priority order above.
