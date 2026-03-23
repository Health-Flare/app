# Handoff Readiness Checklist

Work required before handing Health Flare to Claire for daily use with Ethan (JIA) and Nora (EoE).
Derived from the Marcus / Developer-Spouse persona review on 2026-03-23.

---

## 🔴 Critical blockers — must fix before handoff

- [ ] **Journal backdating** — add a date picker to the journal composer so entries can be created at a past date/time. This is the entire import path for Claire's Apple Notes history. Without it, months of appointment notes, food reactions, and flare records all land on today's date and the timeline is lost. Requires a schema change (override `createdAt` field) and a UI change (date/time picker in composer).

- [ ] **Database backup — export** — implement a one-tap "Export backup" that produces a complete snapshot of the Isar database (all profiles, all data, all dates) as a single file the user can save or share. Must work before any schema migration is pushed while Claire has live data in the app.

- [ ] **Database backup — restore** — implement a "Restore from backup" flow that replaces the current database with a previously exported file. The recovery path after a bad migration depends on this.

- [ ] **`flutter test` in CI** — add `flutter test` to the required CI check list in `.github/workflows/ci.yml`. Currently the pipeline runs: analyze, format, pub-get, pub-audit, url-scan, build-apk — but no test run. A commit that breaks profile isolation or data persistence can pass all CI checks and merge to main undetected.

---

## 🟡 Important — fix before Claire relies on the data

- [ ] **EoE reaction-link window** — the meal-to-symptom reaction linking window is specified as 6 hours. EoE reactions are commonly delayed 12–24 hours. Make the window configurable (or increase the default to 24 hours) before Nora's food diary data is in the app.

- [ ] **Medication approximate start dates** — the medication form requires an exact start date and rejects entries without one. Claire may not recall the exact date Ethan started methotrexate. Add a "date approximate / unknown" option to the start date field to unblock retrospective medication entry.

---

## 🟢 Nice to have — polish before handoff

- [ ] **Profile deletion confirmation copy** — make the deletion dialog explicitly name the profile and data scope: "This will permanently delete ALL of Ethan's health data and cannot be undone." The spec specifies a warning dialog exists but not the copy.

- [ ] **First-log prompt language** — change "Now, how are you feeling today?" to "Now, how is [profile name] feeling today?" so the prompt reads correctly when the active profile is a child's profile, not the user's own.

- [ ] **Empty state language audit** — review all empty state messages for first-person patient language ("Start tracking how you feel", "your health journey", etc.) and replace with profile-name-aware neutral language for caregiver use cases.

- [ ] **Severity scale descriptions** — add plain-language anchors to the symptom severity scale (e.g. "7 = significant difficulty with normal activity") to help a caregiver calibrate a child's self-reported pain consistently over time.

---

## Developer pre-migration protocol (to establish before first schema change on live data)

1. Ask Claire to run Export backup → save the file somewhere safe
2. Apply the migration on a copy of the database file and verify: profile list intact, entry counts match, medication list intact
3. Merge the migration PR
4. After Claire updates: spot-check that her data looks correct
5. If wrong: have Claire run Restore from backup
