# Health Flare — Persona Evaluation, Gap Analysis, and Next Steps

**Date:** 2026-07-05
**App version evaluated:** 1.3.0 (main @ `79526e4`)
**Method:** Review of `docs/requirements.md`, all 24 feature files in `docs/features/`, the work list, and the implemented code in `lib/` — evaluated against the four personas defined in `.claude/commands/user-review-*.md`.

The personas:

| Persona | Situation | What they need most |
|---|---|---|
| **Alex** (solo) | 34, fibromyalgia + CFS, tracks for themself | Fast logging on bad days, journal, privacy |
| **Jordan** (parent) | 42, tracks 11-year-old Mia's JIA | Child-framed language, illness vocabulary help, doctor reports |
| **Sam** (dual-role) | 38, Crohn's; tracks daughter Lily (T1D) and mother Rose (COPD + lupus) | Safe profile switching, low tap cost, complexity for Rose |
| **Marcus → Claire** (developer handing off to caregiver spouse) | Two children's histories in Apple Notes / paper; ongoing development on live data | Data recoverability, an import path, zero-explanation usability |

---

## Part 1 — What is good and simple

### Cross-cutting strengths (serve every persona)

**1. Caregiver-first framing is real, not cosmetic.**
Onboarding asks *"Who are we tracking?"* — not "Tell us about yourself" — and explicitly says you can set up a profile for someone else (`onboarding_profile_zone.dart`). The first-log prompt uses the profile's name ("How is Ethan feeling right now?"), and every entry form carries a **"Logging for [name]"** attribution line (quick-log sheet, check-in form). This is the single most important design decision for Jordan, Sam, and Claire, and it is implemented consistently. The requirements glossary even formalises the caregiver/profile distinction.

**2. Quick log is genuinely low-friction.**
One tap on the FAB from any screen opens a sheet with a single text field. Free text is classified live (meal / symptom / doctor visit / activity / journal) with a suggestion chip; saving without touching anything else still creates a complete, correctly-typed entry. Unclassifiable text falls back to a journal entry, so **nothing the user types is ever rejected or lost**. For Alex mid-flare or Jordan with dinner cooking, this is the right shape: type a sentence, tap save, done.

**3. Multi-profile safety has layered defences.**
Sam's core fear — logging Lily's entry under Rose — is addressed four ways: per-profile colour accents on app bar / FAB / chips (WL-04), the profile icon always visible in the rightmost app-bar slot via the shared `HFAppBar` (defined once, applied to all 32 screens), "Logging for [name]" on forms, and profile-scoped providers that reload on switch (bug #77 fixed this for conditions). Swipe on the profile icon cycles profiles without opening a sheet — fast for Sam's multiple daily switches, no-op when only one profile exists so Alex never sees it.

**4. The privacy promise is specific and mostly verifiable.**
No accounts, no cloud, Isar on device. Onboarding has a dedicated privacy zone with a "Learn more" expansion. CI enforces "no network URLs in Dart files" with a documented allowlist. Weather — the one network feature — is **opt-in via an explicit sheet** with a concrete claim ("Weather data is stored only on this device and never shared"). This is far above the vague "we value your privacy" bar the requirements forbid.

**5. Backup and restore exceed the original spec.**
Settings offers export (share sheet → Files/AirDrop/anywhere) and **three restore modes**: replace-everything (staged, applied on restart), merge (skips duplicates, no restart), and selective import with a category preview. Schema version is displayed in Settings. This is Marcus's #1 handoff requirement, and it's built.

**6. Scope grew in the right direction.**
Beyond the MVP requirements, the app now has flare tracking (one active flare per profile, day counter on dashboard), daily check-ins, sleep, activity, appointments, an illness catalog with symptom autocomplete, and an insights layer (trend charts, food-trigger detection, sleep correlation, weather impact). Every one of these maps to a real persona need — flares for Alex, appointments for Jordan, the illness catalog for Jordan's vocabulary gap.

**7. Reports cover the appointment use case end-to-end.**
PDF and CSV export with date-range scoping across all ten data types (symptoms, vitals, medications, dose logs, meals, journal, sleep, check-ins, activities, appointments). Reports live behind a dashboard icon rather than a nav slot — correct, since they're used before appointments, not daily.

**8. Engineering discipline protects Claire's data indirectly.**
BDD feature files as source of truth, 22 test files, migration smoke tests in CI (WL-17), schema version history documented in the work list, Keep-a-Changelog discipline, semantic versioning, `flutter analyze` zero-tolerance. For an app where the developer's own family is production, this is the right culture.

### Per-persona: what works today

- **Alex (solo):** Quick log + journal composer optimised for <10-second capture; mood/energy optional and non-blocking; journal search; single-profile mode hides all multi-profile chrome; no account and local-only storage matter for employment-related privacy fears.
- **Jordan (parent):** Onboarding creates Mia's profile without ever assuming user = patient; illness catalog + symptom autocomplete supply the vocabulary Jordan lacks; quick journal notes ("She limped at school pickup") land as journal entries with zero structure required; PDF report for the rheumatologist.
- **Sam (dual-role):** Fast profile cycling via swipe; colour identity per profile; per-profile data isolation verified by tests; Rose's complexity is servable (multiple conditions per profile, medication + dose history, discontinuation preserves history).
- **Marcus → Claire:** Backup/restore in three modes; schema version visible; migration smoke tests in CI; caregiver language throughout means Claire is never asked "how are you feeling?" when logging for Ethan.

---

## Part 2 — Gap analysis

Ordered by severity for the stated goal: *easily tracking chronic health issues, primarily for someone you are caring for.*

### Critical (blocks or endangers the caregiver handoff)

**G1 · No app lock.**
There is no PIN/biometric gate (`local_auth` is not a dependency). Whoever holds the device reads two children's complete health histories. The requirements accept this for MVP ("whoever has the device has access"), but for Jordan and Claire — children's medical data — and for Sam, who *hands the phone to Rose*, this is the largest trust gap. Sam's phone in the wrong hands exposes three people's data at once. Data at rest is also unencrypted (Isar default), which compounds it.

**G2 · No automatic or scheduled backup, and no pre-migration snapshot.**
Backup is manual (Settings → Export → share sheet). `migration_runner.dart` does **not** copy the database aside before applying a migration. Marcus's exact nightmare — pushing a bad migration onto Claire's live data — has a manual mitigation only, and Claire will not remember to export weekly. One bad migration between manual exports is unrecoverable data loss for the family's only copy of the kids' histories.

**G3 · No import path for pre-existing external data.**
Import/restore only reads the app's own `.isar` backups. Claire's months of Apple Notes, paper journal pages, and calendar entries have no way in except retyping each one through the UI. Marcus's goal #2 ("even a manual path, but not a cliff") is currently a cliff. There is no bulk journal entry mode, no back-dated batch entry flow, no CSV/text import.

### High (daily-use friction or trust erosion)

**G4 · Quick log silently downgrades vitals and medications to journal entries.**
The classifier recognises vital and medication text, but `_quickSave` maps `vital`, `medication`, and `journal` classifications all to a journal entry. "BP was 128 over 84" shows a "Vital" chip, then saves as unstructured text — it will never appear in vital history, trends, or reports' vitals section. For Sam logging Lily's glucose mid-day, this is a data-quality trap disguised as a convenience. Sleep quick-log is specced (on `feature/spec-updates`) but not implemented either.

**G5 · No wrong-profile recovery.**
The defences against cross-profile mistakes are all preventive. When a mistake happens anyway (Sam, fatigued, three profiles), there is no "move this entry to another profile" action and no undo after save — the fix is delete + re-enter on the other profile, losing the original timestamp. One "Move to profile…" action on entry detail screens would close the loop.

**G6 · The "fully offline" claim is now conditional, and the copy hasn't caught up everywhere.**
Weather (opt-in) sends device coordinates to `api.open-meteo.com`. That's a reasonable trade, and the opt-in sheet is honest about storage — but it does not say "your location is sent to a third-party weather service." CLAUDE.md still says "fully offline — no network calls." For Alex, whose privacy concern is employment-grade, and for the onboarding privacy zone's headline "all data stays on this device," every claim needs to be re-verified against the weather path. Specific-and-verifiable was the standard the app set for itself.

**G7 · No reminders.**
Deliberately out of MVP scope, but it's the biggest remaining daily-use gap for Rose's multi-medication regimen and for habit formation generally. Sam is currently the reminder system. A missed-dose pattern that the app could have prevented undermines the medication log's value at appointments.

### Medium

**G8 · Accessibility is asserted, not audited.**
The onboarding spec requires WCAG 2.1 AA; semantics/tooltips appear in ~35 feature files, and ui-patterns.feature sets good rules. But there's no golden-test or audit evidence of contrast, dynamic-type behaviour at large sizes, or full screen-reader traversal. Rose (elderly) and Alex (brain-fog days) are the users most hurt by regressions here. The specced golden-file/visual-regression work would carry this.

**G9 · Dictation has no affordance.**
Sam hands the phone to Rose to dictate. System keyboard dictation works in any text field, but nothing in the UI invites it, and Rose "is not a regular app user." A visible mic hint on the quick-log sheet (even just keyboard-dictation guidance) is cheap; true voice capture is a larger feature.

**G10 · Platform parity is incomplete.**
Requirements list iOS, Android, Web, macOS, Windows with parity. macOS shipped (with recent fixes); `feature/linux-windows-builds` is unmerged; web is untested territory for Isar and file-based backup. Claire-on-desktop is plausibly part of the bulk-entry answer, which raises the priority of at least one desktop platform being solid.

**G11 · Backup restore across schema versions is unverified.**
Restore stages a `.isar` file for open-on-restart; if the backup predates the current schema version, correctness depends on migrations running against the restored file. The CI migration smoke test covers forward migration of the live DB — restoring an *old backup* into a *new app* deserves its own test before Marcus trusts snapshots as his safety net.

### Low / hygiene

- **G12 ·** Seven `migration_test_*.isar`/`.isar-lck` files are committed at the repo root — test artefacts that should be gitignored and removed.
- **G13 ·** Five specced tasks sit on `feature/spec-updates` (sleep quick-log, app-bar/profile-icon coexistence rules, golden tests + screenshot automation, macOS, app-store) with no implementation started — spec/implementation drift risk if the branch goes stale.
- **G14 ·** Journal entries set their timestamp at save with no editable date — correct for the composer's speed goal, but it conflicts with back-dating during any manual import of Claire's historical notes (see G3).

---

## Part 3 — Next steps (recommended order)

### Phase A — Data safety before anything else (Marcus's go/no-go)

1. **Pre-migration automatic snapshot.** In `migration_runner.dart`, copy the database file aside before applying any migration; keep the last N snapshots; surface "last automatic backup" in Settings. Directly neutralises the bad-migration scenario. Small, high-leverage, no UI needed.
2. **Scheduled/local auto-backup.** Daily or on-app-close copy to app documents (and optionally a user-chosen folder on desktop). Claire never has to remember to export.
3. **Backup-restore cross-version test.** Add a CI test that restores a schema-v(N−1) backup into the current app and verifies data integrity. Makes the safety net trustworthy, not just present.

### Phase B — The handoff enablers (Claire's day one)

4. **Bulk/back-dated journal import.** Minimum viable: a "batch entry" mode in the journal composer with an editable date field, so Claire can work through her paper journal chronologically without fighting the auto-timestamp. Better: paste-a-block-of-text → split into dated entries; or CSV/plain-text import into journal + symptoms. This converts G3's cliff into a ramp and unblocks the entire handoff.
5. **App lock.** `local_auth` biometric/PIN gate with a per-device toggle in Settings. Closes G1 for children's data and the hand-the-phone-to-Rose case. Consider Isar encryption as a follow-on, but the lock is the 80%.
6. **Privacy copy audit.** Re-verify every privacy claim (onboarding zone, weather sheet, privacy policy, CLAUDE.md) against the weather network path; add "location is sent to Open-Meteo when enabled" to the opt-in sheet. Cheap; protects the app's strongest asset — its credibility.

### Phase C — Daily-use quality (all personas)

7. **Finish quick-log type coverage.** Implement structured save for vitals (parse "128 over 84") and medication doses, and the already-specced sleep type — or, until parsing lands, change the chip so it doesn't advertise a structure the save path doesn't deliver. Closes the G4 trap.
8. **"Move entry to another profile."** One action on entry detail screens, preserving timestamps. Closes Sam's loop (G5).
9. **Implement the `feature/spec-updates` backlog** — sleep quick-log (overlaps #7), app-bar rules, and golden-file/screenshot automation, which also gives G8 its audit evidence.

### Phase D — Reach

10. **Reminders** (medication schedules first, check-in nudge second) — revisit the out-of-scope decision now that the MVP is well past MVP.
11. **Windows/Linux builds + web decision** — either commit to web parity (validate Isar + backup story) or amend the requirements honestly.
12. **Dictation affordance** on quick log for the Rose case.
13. Hygiene: remove committed `migration_test_*.isar` artefacts and gitignore them.

### Sequencing rationale

Phase A before B because Marcus is actively developing against what will become live family data — every week of development before snapshots exist is a week of risk. Phase B is the actual handoff gate: Claire cannot start until her historical data has a path in (4) and the kids' data is protected on a shared family device (5). Everything in C and D improves an app that is already usable daily; nothing in C and D is worth delaying the handoff for.

### Verdict against the stated goal

For *easily tracking chronic health issues for someone you care for*, the app's foundation is unusually strong: the caregiver framing is structural, not skinned on; the quick-log path respects a caregiver's worst days; and the multi-profile safety work is layered and tested. The gaps that remain are not usability gaps — they are **trust** gaps (lock, auto-backup, import). Close Phase A and B and this is genuinely handoff-ready.
