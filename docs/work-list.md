# Health Flare — Work List

Prioritized backlog for taking the app from current state (journal + sleep partially wired) to
a trustworthy daily-use caregiver tool. Each item is written for a **fresh context window** —
all prerequisite knowledge is included inline.

---

## Quick-start for a new session

```bash
# Read project context
cat CLAUDE.md
cat docs/work-list.md          # this file
cat docs/SDLC_WORKFLOW.md      # BDD cycle: /scenario → /test → /implement → /validate

# Understand the data layer before touching anything
cat lib/data/database/migration_runner.dart   # current schema v3
cat lib/data/database/app_database.dart       # registered Isar collections
cat lib/data/models/profile_isar.dart         # ID pattern: int auto-increment (NOT uuid)

# Understand the provider pattern
# Notifiers extend Notifier<T>, build() returns [], fire _init() async,
# _init() subscribes watchLazy then calls _reload() which queries Isar.
cat lib/core/providers/journal_provider.dart  # canonical provider example
```

### Key architectural invariants
| Rule | Detail |
|---|---|
| ID type | Isar auto-increment `int` — all collections, all foreign keys |
| Imports | `package:health_flare/` only — no relative imports |
| Provider pattern | Synchronous `Notifier<List<T>>`, async `_init()` via `addPostFrameCallback` |
| Profile scoping | Every user-data collection has `late int profileId` indexed |
| Migration | Increment `_targetVersion` in `MigrationRunner`, add `if (currentVersion < N)` block |
| Codegen | Schema changes → `./scripts/generate_isar.sh` then copy `.g.dart` files |
| Riverpod codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Isar.open() | Add new `XxxIsarSchema` to the list in `lib/data/database/app_database.dart` |

### What is already built
- Profiles (create, edit, delete, switch, active-profile persistence)
- Journal (list, composer with autosave/undo, detail, search, profile scoping)
- Illness setup (condition catalog 1131 entries, symptom catalog 243, UserCondition, UserSymptom)
- Sleep data model (`SleepEntryIsar` exists but **not registered** in Isar.open() yet)
- Backup service: `BackupService.export()` (hot backup → share sheet) and `stagePendingRestore()` + startup apply — **fully implemented, needs UI only**
- `BackupNotifier` provider — fully implemented, needs a surface in the Settings screen

### Schema version history
| Version | Change |
|---|---|
| v1 | AppSettings singleton |
| v2 | Condition + Symptom catalog seeded from SeedData |
| v3 | ProfileIsar.weatherTrackingEnabled + weatherOptInShown |
| **v4** | Reserved: ProfileIsar.colorSeed + register SleepEntryIsar |
| **v5** | Reserved: SymptomEntryIsar + VitalEntryIsar |
| **v6** | Reserved: MedicationIsar + DoseLogIsar |
| **v7** | Reserved: MealEntryIsar |
| **v8** | Reserved: FlareIsar |
| **v9** | Reserved: DailyCheckinIsar |
| **v10** | Reserved: AppointmentIsar (with embedded questions + med changes) |
| **v11** | Reserved: ActivityEntryIsar |

---

## Gitea setup (run once)

```bash
# Labels
tea label create --name "priority:p0" --color "#e11d48" --description "Must ship before any handoff"
tea label create --name "priority:p1" --color "#f97316" --description "Core tracking MVP"
tea label create --name "priority:p2" --color "#eab308" --description "Enhanced usability"
tea label create --name "priority:p3" --color "#22c55e" --description "Polish and analysis"
tea label create --name "type:fix"           --color "#6b7280"
tea label create --name "type:feature"       --color "#3b82f6"
tea label create --name "type:schema"        --color "#8b5cf6" --description "Isar schema change + codegen + migration required"
tea label create --name "type:infrastructure" --color "#1e293b"

# Milestones
tea milestone create --title "Phase 0 — Safety & Language"
tea milestone create --title "Phase 1 — Core Tracking MVP"
tea milestone create --title "Phase 2 — Enhanced Features"
tea milestone create --title "Phase 3 — Intelligence & Insights"
```

---

## Parallel execution strategy

Use `claude --worktree` (or `Agent` with `isolation: worktree`) for items that touch different
parts of the codebase. Merge order must respect schema version reservations.

```
Phase 0 (sequential — establishes baseline for all branches):
  WL-01 → WL-02 → (WL-03 + WL-04 in parallel) → WL-05

Phase 1 (parallel development, sequential merge by schema version):
  main (post-Phase 0)
    ├── WL-06 (symptoms+vitals, schema v5) ──────────────────┐
    ├── WL-07 (medications, schema v6)     ─────────────┐    │ merge v5 first,
    └── WL-08 (meals, schema v7)           ─────────┐   │    │ then v6, then v7
                                                     └───┴────┘

Phase 2 (parallel after Phase 1 merged):
  main (post-Phase 1)
    ├── WL-09 (flare, schema v8)
    ├── WL-10 (daily check-in, schema v9)  ← no deps on flare
    └── WL-11 (appointments, schema v10)   ← no deps on flare
    └── WL-12 (quick-log) ← depends on all Phase 1 entry types existing
```

---

## Phase 0 — Safety & Language
*Prerequisite for handoff. Nothing goes to Claire until all five items are merged to main.*

---

### WL-01 · Fix caregiver language in first-log prompt
**Branch:** `fix/caregiver-language`
**Priority:** P0
**Labels:** `priority:p0` `type:fix`
**Milestone:** Phase 0 — Safety & Language
**Schema change:** None
**Parallel with:** Nothing — merge first

**Problem:** `docs/features/onboarding.feature` line 176 says the prompt heading updates to
"Now, how are you feeling today?" after an illness is added. This is first-person patient
language. The primary user is Claire, a parent logging for her children Ethan and Nora. She
is not the patient.

**Fix:** Every place in the first-log prompt copy that uses first-person patient language
("how are you feeling", "your first entry", "start your journey") must be replaced with
profile-name-aware copy: "How is [name] doing today?", "Log [name]'s first entry."

**Files to touch:**
- `docs/features/onboarding.feature` — update scenarios to use profile-name framing
- The widget that renders the first-log prompt (find via grep for the current string)
- Any widget tests that assert the first-person string

**Acceptance criteria:**
- [ ] `grep -r "how are you feeling" lib/` returns nothing
- [ ] First-log prompt heading uses profile name: "How is Ethan doing today?"
- [ ] All onboarding widget tests pass
- [ ] `flutter analyze` passes

**tea command:**
```bash
tea issue create \
  --title "Fix: caregiver language in first-log prompt" \
  --body "The first-log prompt uses first-person patient language ('how are you feeling today'). Replace with profile-name-aware copy ('How is [name] doing today?') throughout. See docs/work-list.md WL-01." \
  --label "priority:p0,type:fix" \
  --milestone "Phase 0 — Safety & Language"
```

---

### WL-02 · Register SleepEntryIsar and complete sleep feature wiring
**Branch:** `feature/sleep-complete`
**Priority:** P0
**Labels:** `priority:p0` `type:feature` `type:schema`
**Milestone:** Phase 0 — Safety & Language
**Schema change:** v4 — adds `SleepEntryIsarSchema` to `Isar.open()`; migration block is
a no-op (Isar handles structural addition automatically, just bump the version)
**Parallel with:** WL-03, WL-04 (after this is merged)
**Depends on:** WL-01 merged

**Problem:** `lib/data/models/sleep_entry_isar.dart` and its `.g.dart` exist. `SleepEntryIsar`
is NOT in the `Isar.open()` schema list in `app_database.dart`. The sleep provider and feature
screens may be partially built; verify and complete.

**Tasks:**
1. Add `SleepEntryIsarSchema` to `Isar.open()` in `app_database.dart`
2. Add schema v4 migration block to `MigrationRunner` (bump version only, no data transform)
3. Verify `lib/core/providers/sleep_provider.dart` follows the canonical notifier pattern
4. Verify `lib/features/sleep/` has list screen and entry form
5. Wire the FAB "Sleep" option on the dashboard to the sleep entry form
6. Write/complete widget tests for the sleep entry form and list

**Data model — already exists, verify fields:**
```dart
// lib/data/models/sleep_entry_isar.dart (already exists)
@collection
class SleepEntryIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late DateTime bedtime;
  @Index() late DateTime wakeTime;  // entry dated by wake date
  int? qualityRating;               // 1–5
  String? notes;
  late bool isNap;
  late DateTime createdAt;
}
```

**Acceptance criteria:**
- [ ] Sleep entries can be created, saved, and read back after cold restart
- [ ] Sleep entries are scoped to the active profile
- [ ] Dashboard FAB "Sleep" option opens the sleep entry form
- [ ] Dashboard activity feed shows sleep entries
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Complete sleep feature: register SleepEntryIsar, wire dashboard" \
  --body "SleepEntryIsar model exists but is not registered in Isar.open(). Add schema v4, wire the sleep feature end to end. See docs/work-list.md WL-02." \
  --label "priority:p0,type:feature,type:schema" \
  --milestone "Phase 0 — Safety & Language"
```

---

### WL-03 · Settings screen with backup/restore UI and schema version display
**Branch:** `feature/settings-screen`
**Priority:** P0
**Labels:** `priority:p0` `type:feature`
**Milestone:** Phase 0 — Safety & Language
**Schema change:** None
**Parallel with:** WL-04 (after WL-02 merged)

**Context:** `BackupService` (hot backup via `Isar.copyToFile`) and `BackupNotifier` (export
to share sheet, restore via file picker + staged apply at startup) are **fully implemented**.
They just need a UI surface.

**Tasks:**
1. Create a Settings screen accessible from the profile switcher or dashboard app bar
2. Surface "Export backup" button → calls `ref.read(backupProvider.notifier).export()`
3. Surface "Restore from backup" button → calls `stageRestore()`, then prompt restart
4. Display current schema version (read from `AppSettings.schemaVersion` via Isar)
5. Display app version (from `package_info_plus` or pubspec)
6. Show last backup date (store `DateTime? lastExportDate` in `AppSettings` — update on each
   successful export)

**AppSettings change needed** (add field, bump schema v4 alongside WL-02):
```dart
// lib/data/database/app_settings.dart — add one field:
DateTime? lastExportDate;
```
Coordinate with WL-02: both touch schema v4. Either batch them or have this item depend on
WL-02's PR being merged first.

**Acceptance criteria:**
- [ ] Settings screen reachable from the main app (not hidden)
- [ ] Export button produces a `.isar` file via the OS share sheet
- [ ] Restore button opens file picker, user selects `.isar` file, app prompts restart
- [ ] After restart, all data from the backup is present
- [ ] Schema version number is visible in Settings
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Settings screen: backup/restore UI + schema version display" \
  --body "BackupService and BackupNotifier are fully implemented. Build the Settings screen to surface export, restore, and schema version. See docs/work-list.md WL-03." \
  --label "priority:p0,type:feature" \
  --milestone "Phase 0 — Safety & Language"
```

---

### WL-04 · Profile visual identity — color accent per profile
**Branch:** `feature/profile-color-identity`
**Priority:** P0
**Labels:** `priority:p0` `type:feature` `type:schema`
**Milestone:** Phase 0 — Safety & Language
**Schema change:** v4 — add `int? colorSeed` to `ProfileIsar`; auto-assign on creation
**Parallel with:** WL-03 (after WL-02 merged)

**Problem:** With two children's profiles, a name label alone is insufficient to prevent
logging to the wrong child when working fast. A distinct color accent per profile (Material 3
`ColorScheme.fromSeed`) makes the active profile immediately obvious.

**Data model change:**
```dart
// lib/data/models/profile_isar.dart — add one field:
int? colorSeed;   // Material Color int; null = default app color
```

**Domain model change:**
```dart
// lib/models/profile.dart — add one field:
final int? colorSeed;
```

**Behavior:**
- On profile creation: if `colorSeed` is null, assign from a palette of 8 visually distinct
  Material 3 seed colors, cycling by profile count mod 8
- The active `ColorScheme` in the app's `MaterialApp.theme` is derived from the active
  profile's `colorSeed` — profile switch triggers a theme change
- If `colorSeed` is null (existing profiles before this migration), fall back to the default
  app seed color

**Palette (suggested, 8 colors covering the spectrum clearly):**
```dart
const _palette = [
  0xFF6750A4, // default purple
  0xFF006EBF, // blue
  0xFF006B5C, // teal
  0xFF2E7D32, // green
  0xFFE65100, // orange
  0xFFB00020, // red
  0xFF4A148C, // deep purple
  0xFF004D40, // dark teal
];
```

**Acceptance criteria:**
- [ ] Each profile has a distinct color accent visible in the app bar, FAB, and active chips
- [ ] Profile switch immediately changes the color theme
- [ ] New profiles are assigned a color automatically
- [ ] Existing profiles (colorSeed = null) fall back gracefully to default
- [ ] Dashboard heading uses the active profile's color
- [ ] `flutter analyze` passes, `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Profile visual identity: per-profile color accent (Material 3)" \
  --body "Add colorSeed to ProfileIsar. Derive app ColorScheme from active profile. Prevents wrong-child logging error. See docs/work-list.md WL-04." \
  --label "priority:p0,type:feature,type:schema" \
  --milestone "Phase 0 — Safety & Language"
```

---

### WL-05 · Navigation: wire all implemented tab destinations
**Branch:** `fix/nav-tab-destinations`
**Priority:** P0
**Labels:** `priority:p0` `type:fix`
**Milestone:** Phase 0 — Safety & Language
**Schema change:** None
**Parallel with:** Nothing — do after WL-01 through WL-04 merged

**Problem:** The bottom nav spec lists Dashboard, Symptoms & Vitals, Medications, Meals,
Reports. Currently only Dashboard and Journal are reachable. Unimplemented destinations show
empty screens or crash, which will erode Claire's trust on first use.

**Fix:** Until a tab destination is implemented, show a clear "Coming soon" empty state
(not an error, not a blank screen). Remove tabs from the nav that have zero content —
or retain them with explicit placeholder screens that set expectations.

**Decision:** Keep the Journal tab (it's implemented). Show "Coming soon" with a brief
description for Symptoms & Vitals, Medications, and Meals. Remove Reports from the nav
entirely until the report feature is built (it requires all data types to be meaningful).

**Acceptance criteria:**
- [ ] Tapping any nav item never crashes or shows a blank screen
- [ ] Journal tab is reachable and functional
- [ ] Symptoms & Vitals, Medications, Meals show intentional placeholder screens
- [ ] Navigation feature file scenarios pass with the implemented destinations
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Fix: wire all nav tab destinations to real or placeholder screens" \
  --body "Unimplemented tabs must show intentional placeholders, not blank screens or crashes. See docs/work-list.md WL-05." \
  --label "priority:p0,type:fix" \
  --milestone "Phase 0 — Safety & Language"
```

---

## Phase 1 — Core Tracking MVP
*These three features, combined with the Phase 0 foundation, produce the minimum viable
daily-use app for a caregiver managing two chronically ill children.*

---

### WL-06 · Symptom entry logging + Vital measurement logging
**Branch:** `feature/symptoms-vitals`
**Priority:** P1
**Labels:** `priority:p1` `type:feature` `type:schema`
**Milestone:** Phase 1 — Core Tracking MVP
**Schema change:** v5 — adds `SymptomEntryIsar` and `VitalEntryIsar`
**Parallel with:** WL-07, WL-08 (merge v5 before v6 and v7)
**Spec:** `docs/features/symptoms_and_vitals.feature`

**New Isar collections:**

```dart
// lib/data/models/symptom_entry_isar.dart
@collection
class SymptomEntryIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late String name;           // free text or from UserSymptomIsar
  int? userSymptomIsarId;     // nullable link to UserSymptomIsar.id
  int? userConditionIsarId;   // nullable: which condition this relates to
  late int severity;          // 1–10
  String? notes;
  @Index() late DateTime loggedAt;   // when the symptom occurred (user-set)
  late DateTime createdAt;
  int? flareIsarId;           // nullable: links to FlareIsar.id (schema v8)
}

// lib/data/models/vital_entry_isar.dart
@collection
class VitalEntryIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late String vitalType;    // enum-string: heartRate|bloodPressure|weight|
                            //   temperature|oxygenSaturation|respiratoryRate|bloodGlucose
  late double value;        // primary (systolic for BP)
  double? value2;           // secondary (diastolic for BP); null for other types
  late String unit;         // BPM | mmHg | kg | lbs | °C | °F | % | br/min | mmol/L | mg/dL
  String? notes;
  @Index() late DateTime loggedAt;
  late DateTime createdAt;
  int? flareIsarId;         // nullable; back-filled when FlareIsar lands in v8
}
```

**Domain models:**
```dart
// lib/models/symptom_entry.dart
@immutable class SymptomEntry { int id; int profileId; String name;
  int? userSymptomIsarId; int? userConditionIsarId; int severity;
  String? notes; DateTime loggedAt; DateTime createdAt; int? flareIsarId; }

// lib/models/vital_entry.dart
@immutable class VitalEntry { int id; int profileId; String vitalType;
  double value; double? value2; String unit; String? notes;
  DateTime loggedAt; DateTime createdAt; int? flareIsarId; }
```

**Vital type constants** (put in `lib/models/vital_type.dart`):
```dart
enum VitalType { heartRate, bloodPressure, weight, temperature,
                 oxygenSaturation, respiratoryRate, bloodGlucose }
// Each has: label, defaultUnit, hasSecondaryValue (bool for BP)
```

**Providers:**
- `symptomEntryListProvider` — `Notifier<List<SymptomEntry>>`, same pattern as journalProvider
- `vitalEntryListProvider` — `Notifier<List<VitalEntry>>`

**Screens:**
- `lib/features/symptoms_vitals/screens/symptoms_vitals_screen.dart` — list view (tabbed or sectioned: Symptoms / Vitals)
- `lib/features/symptoms_vitals/screens/symptom_entry_form_screen.dart` — new/edit form
- `lib/features/symptoms_vitals/screens/vital_entry_form_screen.dart` — new/edit form
- `lib/features/symptoms_vitals/screens/symptom_entry_detail_screen.dart`

**Key UX rules (from profiles.feature):**
- All entry forms show "Logging for [name]" label visible without scrolling
- Date/time defaults to now; user can change to any past value
- Symptom name can be free-text OR tapped from the UserSymptom shortcuts list

**Acceptance criteria:**
- [ ] Log a symptom with name, severity, optional notes, optional past timestamp
- [ ] Log a vital with type, value, unit, optional notes, optional past timestamp
- [ ] Blood pressure logs systolic + diastolic as two values
- [ ] Entries are scoped to active profile
- [ ] List shows reverse chronological, with edit + delete
- [ ] Symptoms & Vitals nav tab shows real content (replaces WL-05 placeholder)
- [ ] "Logging for [name]" attribution visible on all entry forms
- [ ] `flutter test` passes, `flutter analyze` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: symptom entry logging + vital measurement logging (schema v5)" \
  --body "Add SymptomEntryIsar and VitalEntryIsar. Full CRUD with profile scoping and past-timestamp support. See docs/work-list.md WL-06 for schema design." \
  --label "priority:p1,type:feature,type:schema" \
  --milestone "Phase 1 — Core Tracking MVP"
```

---

### WL-07 · Medication management + dose logging
**Branch:** `feature/medications`
**Priority:** P1
**Labels:** `priority:p1` `type:feature` `type:schema`
**Milestone:** Phase 1 — Core Tracking MVP
**Schema change:** v6 — adds `MedicationIsar` and `DoseLogIsar`
**Parallel with:** WL-06, WL-08 (merge after v5 is in main)
**Spec:** `docs/features/medications.feature`

**New Isar collections:**

```dart
// lib/data/models/medication_isar.dart
@collection
class MedicationIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late String name;
  late String medicationType;   // "medication" | "supplement"
  late double doseAmount;
  late String doseUnit;         // mg | mL | IU | mcg | g | etc.
  late String frequency;        // "once_daily" | "twice_daily" | "three_times_daily"
                                // | "as_needed" | "weekly" | "custom"
  String? frequencyLabel;       // human label for "custom" frequency
  @Index() late DateTime startDate;
  DateTime? endDate;            // null = still active
  String? notes;
  late DateTime createdAt;
  DateTime? updatedAt;
}

// lib/data/models/dose_log_isar.dart
@collection
class DoseLogIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;          // denormalized for fast profile queries
  @Index() late int medicationIsarId;   // links to MedicationIsar.id
  @Index() late DateTime loggedAt;      // when the dose was taken/skipped/missed
  late DateTime createdAt;
  late double amount;
  late String unit;
  late String status;                   // "taken" | "skipped" | "missed"
  String? reason;                       // for skipped/missed
  String? effectiveness;                // "helped_a_lot" | "helped_a_little"
                                        // | "no_effect" | "made_it_worse"
  String? notes;
  int? flareIsarId;                     // nullable; back-filled when FlareIsar lands
}
```

**Domain models:**
```dart
// lib/models/medication.dart
@immutable class Medication { int id; int profileId; String name;
  String medicationType; double doseAmount; String doseUnit;
  String frequency; String? frequencyLabel;
  DateTime startDate; DateTime? endDate; String? notes;
  DateTime createdAt; DateTime? updatedAt; }

// lib/models/dose_log.dart
@immutable class DoseLog { int id; int profileId; int medicationIsarId;
  DateTime loggedAt; double amount; String unit; String status;
  String? reason; String? effectiveness; String? notes; int? flareIsarId; }
```

**Providers:**
- `medicationListProvider` — `Notifier<List<Medication>>` (active + discontinued)
- `doseLogProvider(int medicationId)` — family provider, `Notifier<List<DoseLog>>`

**Screens:**
- `lib/features/medications/screens/medications_screen.dart` — list (active / discontinued sections)
- `lib/features/medications/screens/medication_form_screen.dart` — add/edit medication
- `lib/features/medications/screens/medication_detail_screen.dart` — detail with dose history
- `lib/features/medications/screens/dose_log_form_screen.dart` — log a dose

**Key UX rules:**
- Supplements section is visually separated from medications (same data model, different `medicationType`)
- Active = endDate is null or endDate > today
- Discontinued medications retain full dose history
- "Logging for [name]" attribution on all entry forms

**Acceptance criteria:**
- [ ] Add medication with name, dose, frequency, start date
- [ ] Add supplement (separate section in list)
- [ ] Log a dose (taken/skipped/missed with optional effectiveness + notes)
- [ ] View dose history per medication in reverse-chronological order
- [ ] Edit + delete medication (delete cascades to dose logs with confirmation)
- [ ] Discontinue by setting end date (history preserved)
- [ ] Medications nav tab shows real content
- [ ] `flutter test` passes, `flutter analyze` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: medication management + dose logging (schema v6)" \
  --body "Add MedicationIsar and DoseLogIsar. Full CRUD, dose history, supplements section, effectiveness tracking. See docs/work-list.md WL-07." \
  --label "priority:p1,type:feature,type:schema" \
  --milestone "Phase 1 — Core Tracking MVP"
```

---

### WL-08 · Meal logging with reaction flags
**Branch:** `feature/meals`
**Priority:** P1
**Labels:** `priority:p1` `type:feature` `type:schema`
**Milestone:** Phase 1 — Core Tracking MVP
**Schema change:** v7 — adds `MealEntryIsar`
**Parallel with:** WL-06, WL-07 (merge after v6 is in main)
**Spec:** `docs/features/meals.feature`

> **Note for EoE profile (Nora):** This is the highest-value feature for a child with
> eosinophilic esophagitis. The reaction flag + nearby-symptom correlation is the clinical
> workflow her GI team needs.

**New Isar collection:**

```dart
// lib/data/models/meal_entry_isar.dart
@collection
class MealEntryIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late String description;
  @Index() late DateTime loggedAt;    // when the meal was eaten (user-set)
  late DateTime createdAt;
  DateTime? updatedAt;
  String? notes;
  String? photoPath;                  // relative to app documents dir; null = no photo
  late bool reactionFlagged;          // default false
  int? flareIsarId;                   // nullable; back-filled when FlareIsar lands
}
```

**Domain model:**
```dart
// lib/models/meal_entry.dart
@immutable class MealEntry { int id; int profileId; String description;
  DateTime loggedAt; DateTime createdAt; DateTime? updatedAt;
  String? notes; String? photoPath; bool reactionFlagged; int? flareIsarId; }
```

**Provider:** `mealEntryListProvider` — `Notifier<List<MealEntry>>`

**Photo handling:**
- Store photos in `{appDocumentsDir}/meal_photos/{isarId}.jpg`
- Write photo file before saving the Isar record
- On delete: delete the photo file after the Isar record is removed
- Use `image_picker` (already in pubspec or add it)

**Nearby symptom correlation** (for the reaction flag detail view):
- When `reactionFlagged = true`, query `SymptomEntryIsar` for the same `profileId`
  where `loggedAt` is within 6 hours after the meal's `loggedAt`
- Display matched symptoms in the meal detail view as "Possible reactions"
- This is read-only cross-collection query — no schema change needed

**Acceptance criteria:**
- [ ] Log a meal with description, optional notes, optional photo
- [ ] Toggle reaction flag (at logging time and retroactively)
- [ ] Reaction-flagged meals show nearby symptoms (within 6h) in the detail view
- [ ] Past timestamp support
- [ ] Photo can be taken from camera or chosen from library
- [ ] Photo can be removed from an existing entry
- [ ] Meals nav tab shows real content
- [ ] "Logging for [name]" attribution on form
- [ ] `flutter test` passes, `flutter analyze` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: meal logging with reaction flags (schema v7)" \
  --body "Add MealEntryIsar. Reaction flag + nearby symptom correlation in detail view. Photo support. Critical for EoE profile. See docs/work-list.md WL-08." \
  --label "priority:p1,type:feature,type:schema" \
  --milestone "Phase 1 — Core Tracking MVP"
```

---

## Phase 2 — Enhanced Features
*Build after all Phase 1 items are merged to main. These require the core data types to exist.*

---

### WL-09 · Flare tracking
**Branch:** `feature/flare-tracking`
**Priority:** P2
**Labels:** `priority:p2` `type:feature` `type:schema`
**Milestone:** Phase 2 — Enhanced Features
**Schema change:** v8 — adds `FlareIsar`. After merge, back-fill `flareIsarId` onto existing
entry types by adding a nullable field to each (small migrations).
**Spec:** `docs/features/flare.feature`

**New Isar collection:**

```dart
// lib/data/models/flare_isar.dart
@collection
class FlareIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  @Index() late DateTime startedAt;
  DateTime? endedAt;                  // null = active flare
  List<int> conditionIsarIds = [];    // links to UserConditionIsar.id list
  int? initialSeverity;               // 1–10 at start
  int? peakSeverity;                  // 1–10 at peak or end
  String? notes;
  late DateTime createdAt;
  DateTime? updatedAt;
}
```

**Key constraint:** Only one active flare per profile at a time (endedAt == null). Enforce
in the provider, not just the UI.

**Back-filling flareIsarId on entry types:** After FlareIsar lands, the entry types
(SymptomEntryIsar, VitalEntryIsar, DoseLogIsar, MealEntryIsar) need `flareIsarId` added.
These fields are already present as comments in the v5–v7 schemas above — the fields are
there from the start, just nullable and un-used until this item ships.

**Dashboard integration:**
- Persistent "I'm flaring" / active flare indicator (condition name + day count)
- Only visible when an active flare exists for the active profile

**Acceptance criteria:**
- [ ] Start a flare (with optional condition attribution and severity)
- [ ] One active flare per profile enforced
- [ ] Active flare indicator on dashboard showing day count
- [ ] Entries logged during an active flare are tagged with `flareIsarId`
- [ ] End a flare with optional end time and closing severity
- [ ] Flare history list (reverse chronological)
- [ ] Flare detail shows all entries logged during the period
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: flare tracking (schema v8)" \
  --body "Add FlareIsar. Dashboard indicator, start/end flow, condition attribution, entry tagging. See docs/work-list.md WL-09." \
  --label "priority:p2,type:feature,type:schema" \
  --milestone "Phase 2 — Enhanced Features"
```

---

### WL-10 · Daily check-in
**Branch:** `feature/daily-checkin`
**Priority:** P2
**Labels:** `priority:p2` `type:feature` `type:schema`
**Milestone:** Phase 2 — Enhanced Features
**Schema change:** v9 — adds `DailyCheckinIsar`
**Parallel with:** WL-09, WL-11
**Spec:** `docs/features/daily-checkin.feature`

> **Note for caregiver profiles:** Daily check-in wellbeing and stress is the *caregiver's*
> observation of the child, not a self-report. "How is Ethan today overall? — 6/10." The
> cycle tracking field must remain hidden unless explicitly enabled per profile, and should
> never appear on a child's profile without opt-in.

**New Isar collection:**

```dart
// lib/data/models/daily_checkin_isar.dart
@collection
class DailyCheckinIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  @Index() late DateTime checkinDate;  // date only; unique per profileId+date
  late int wellbeing;                  // 1–10
  String? stressLevel;                 // "low" | "medium" | "high"
  String? cyclePhase;                  // "period"|"follicular"|"ovulation"|"luteal"|"not_sure"
  String? notes;
  late DateTime createdAt;
  DateTime? updatedAt;
}
```

**Profile field needed** (add to ProfileIsar as part of this migration or WL-04):
```dart
bool cycleTrackingEnabled = false;
```
Note: `cycleTrackingEnabled` may already exist if added in WL-04; check before adding again.

**Uniqueness:** Enforce one check-in per profileId + date in the provider. Second attempt for
same day opens the existing check-in for editing, not a new form.

**Dashboard integration:** Show check-in prompt if today has no check-in for the active
profile. Show saved check-in summary once completed. Prompt disappears once done for the day.

**Acceptance criteria:**
- [ ] Daily check-in prompt on dashboard when none exists for today
- [ ] Wellbeing 1–10 required; stress + notes optional
- [ ] Cycle phase field hidden unless `cycleTrackingEnabled` is true for the profile
- [ ] Only one check-in per profile per day; second attempt opens edit
- [ ] Backdating: add check-in for a past day from history view
- [ ] Check-in prompt copy uses profile name ("How is [name] doing today overall?")
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: daily check-in (schema v9)" \
  --body "Add DailyCheckinIsar. Dashboard prompt, wellbeing 1-10, stress, optional cycle phase. Caregiver copy: 'How is [name] doing today?' See docs/work-list.md WL-10." \
  --label "priority:p2,type:feature,type:schema" \
  --milestone "Phase 2 — Enhanced Features"
```

---

### WL-11 · Doctor visit and appointment tracking
**Branch:** `feature/doctor-visits`
**Priority:** P2
**Labels:** `priority:p2` `type:feature` `type:schema`
**Milestone:** Phase 2 — Enhanced Features
**Schema change:** v10 — adds `AppointmentIsar` with embedded `AppointmentQuestion` and
`MedicationChange` objects
**Parallel with:** WL-09, WL-10
**Spec:** `docs/features/doctor-visits.feature`

> **High caregiver value:** Pre-appointment question lists + post-appointment outcome notes
> are the core of pediatric chronic illness management. This is how Claire prepares for
> Ethan's rheumatology visits and Nora's GI appointments.

**New Isar collection (with embedded types):**

```dart
// lib/data/models/appointment_isar.dart
@embedded
class AppointmentQuestion {
  late String questionId;   // app-level UUID string (embedded, no Isar ID)
  late String question;
  bool discussed = false;
}

@embedded
class MedicationChange {
  late String changeId;           // app-level UUID string
  late String description;
  int? linkedMedicationIsarId;    // if user added to their med list
}

@collection
class AppointmentIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late String title;
  String? providerName;
  @Index() late DateTime scheduledAt;
  late String status;             // "upcoming" | "completed" | "cancelled" | "missed"
  String? outcomeNotes;
  List<AppointmentQuestion> questions = [];
  List<MedicationChange> medicationChanges = [];
  late DateTime createdAt;
  DateTime? updatedAt;
}
```

**Domain models:** `Appointment`, `AppointmentQuestion`, `MedicationChange` in `lib/models/`

**Dashboard integration:**
- Upcoming appointments (status = "upcoming", scheduledAt > now) shown in a dashboard section
- Past appointment (with outcome) appears in the activity feed on its date

**Acceptance criteria:**
- [ ] Create upcoming appointment with title, provider, date/time
- [ ] Add questions to an upcoming appointment; check them off during the visit
- [ ] Record outcome notes after the appointment
- [ ] Record medication change → offer to add it to the medication list (links to WL-07)
- [ ] Schedule a follow-up pre-fills the same provider
- [ ] Mark as cancelled / missed
- [ ] Upcoming appointments visible on dashboard
- [ ] Past appointments list in reverse chronological order
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: doctor visit and appointment tracking (schema v10)" \
  --body "Add AppointmentIsar with embedded questions and medication changes. Pre-visit question lists and post-visit outcomes. See docs/work-list.md WL-11." \
  --label "priority:p2,type:feature,type:schema" \
  --milestone "Phase 2 — Enhanced Features"
```

---

### WL-12 · Quick log with smart classification
**Branch:** `feature/quick-log`
**Priority:** P2
**Labels:** `priority:p2` `type:feature`
**Milestone:** Phase 2 — Enhanced Features
**Schema change:** None — quick log entries are promoted directly into existing typed
collections. Un-promoted general notes become journal entries.
**Depends on:** WL-06, WL-07, WL-08 all merged (needs typed entry types to exist)
**Spec:** `docs/features/quick-log.feature`

**Classification strategy (offline, no ML model):**
Keyword matching with ranked patterns. Run synchronously on the UI thread — no isolate needed
for this scope. A `QuickLogClassifier` class in `lib/features/quick_log/` with a `classify(String text)` method returning `EntryType?`.

```dart
// Pattern buckets (in priority order, first match wins):
// Meal:        contains food/ate/had/drink/breakfast/lunch/dinner/snack/eating
// Symptom:     contains pain/ache/hurt/sore/tired/fatigue/nausea/dizzy/swollen/stiff
// Vital:       matches number + unit pattern (e.g. "72 bpm", "120/80", "37.2°")
// Medication:  contains took/taken/dose/mg/pill/tablet/medication/medicine + dose pattern
// Doctor:      contains dr./doctor/appointment/clinic/hospital/saw dr
// Journal:     fallback for reflective / narrative text
// null:        ambiguous or too short (< 3 words)
```

**Promotion flow:**
- Save without tapping "Add details" → creates the typed entry directly with text as the
  primary field (description for Meal, name for Symptom, body for Journal, etc.)
- Tap "Add details" → opens the full form for that type, pre-filled with the quick-log text
- After promotion, the original quick log text is the canonical record — no separate table

**Acceptance criteria:**
- [ ] FAB on all main screens opens quick log sheet with keyboard raised immediately
- [ ] Sheet header shows "Logging for [name]"
- [ ] Classification chip appears/updates as user types
- [ ] "Add details" opens the full typed form pre-filled
- [ ] Save without "Add details" creates the correct typed entry
- [ ] Unclassifiable text saves as a journal entry
- [ ] Classification runs with no network call (tested offline)
- [ ] Discard confirmation shown if sheet dismissed with text
- [ ] `flutter test` passes

**tea command:**
```bash
tea issue create \
  --title "Feature: quick log with smart classification (no schema change)" \
  --body "FAB sheet with keyboard-on-open, local keyword classifier, promote to typed entry. Depends on WL-06/07/08. See docs/work-list.md WL-12." \
  --label "priority:p2,type:feature" \
  --milestone "Phase 2 — Enhanced Features"
```

---

## Phase 3 — Intelligence & Insights
*Build after Phase 2. Requires weeks of data before it is meaningful.*

---

### WL-13 · Reports — PDF and CSV export
**Branch:** `feature/reports`
**Priority:** P3
**Labels:** `priority:p3` `type:feature`
**Milestone:** Phase 3 — Intelligence & Insights
**Schema change:** None
**Depends on:** WL-06 through WL-08 merged (needs data types)
**Spec:** `docs/features/reports.feature`

**Tasks:**
- Report configuration screen: date range picker, data type toggles
- Query each Isar collection by profileId + date range
- PDF generation: `pdf` package (add to pubspec)
- CSV generation: `dart:convert` + `csv` package
- Share via OS share sheet (already wired via `share_plus`)
- Report header: profile name + date range
- Profile color applied to PDF header (uses WL-04)

**Acceptance criteria:**
- [ ] Generate report for last 7 / 30 days or custom range
- [ ] Toggle data types to include/exclude
- [ ] Export as PDF (formatted) and CSV (machine-readable)
- [ ] PDF includes profile name and date range in header
- [ ] Share sheet opens with generated file
- [ ] No data leaves the device except via explicit user share action

**tea command:**
```bash
tea issue create \
  --title "Feature: reports — PDF and CSV export" \
  --body "Date range + type picker, PDF via 'pdf' package, CSV export, OS share sheet. See docs/work-list.md WL-13." \
  --label "priority:p3,type:feature" \
  --milestone "Phase 3 — Intelligence & Insights"
```

---

### WL-14 · Pattern insights — in-app charts and correlations
**Branch:** `feature/pattern-insights`
**Priority:** P3
**Labels:** `priority:p3` `type:feature`
**Milestone:** Phase 3 — Intelligence & Insights
**Schema change:** None
**Depends on:** WL-06, WL-07, WL-08, WL-09, WL-10 merged
**Spec:** `docs/features/reports.feature` (pattern visualisation section)

**Scope:**
- Symptom severity trend chart (line chart over date range)
- Vital trend chart (line chart)
- Flare overlay on symptom charts (shaded bands)
- Sleep quality vs next-day symptom severity correlation
- Meal reaction frequency (most-reacted ingredients)
- Food trigger view: reaction-flagged meals + nearby symptoms

**Chart library:** `fl_chart` (add to pubspec — pure Flutter, offline)

**tea command:**
```bash
tea issue create \
  --title "Feature: pattern insights — in-app charts and correlations" \
  --body "Symptom trends, flare overlays, sleep/symptom correlation, food trigger view. fl_chart. Needs weeks of data. See docs/work-list.md WL-14." \
  --label "priority:p3,type:feature" \
  --milestone "Phase 3 — Intelligence & Insights"
```

---

### WL-15 · Activity logging
**Branch:** `feature/activity-logging`
**Priority:** P3
**Labels:** `priority:p3` `type:feature` `type:schema`
**Milestone:** Phase 3 — Intelligence & Insights
**Schema change:** v11 — adds `ActivityEntryIsar`
**Spec:** `docs/features/activity.feature`

**New Isar collection:**
```dart
@collection
class ActivityEntryIsar {
  Id id = Isar.autoIncrement;
  @Index() late int profileId;
  late String description;
  String? activityType;     // "walk"|"swim"|"cycle"|"gym"|"yoga"|"rest"|"other"
  int? effortLevel;         // 1–5
  int? durationMinutes;
  @Index() late DateTime loggedAt;
  late DateTime createdAt;
  String? notes;
  int? flareIsarId;
}
```

**tea command:**
```bash
tea issue create \
  --title "Feature: activity logging (schema v11)" \
  --body "Add ActivityEntryIsar. Type, effort level 1-5, duration. Correlates with next-day symptoms in pattern insights. See docs/work-list.md WL-15." \
  --label "priority:p3,type:feature,type:schema" \
  --milestone "Phase 3 — Intelligence & Insights"
```

---

### WL-16 · Weather tracking integration
**Branch:** `feature/weather-tracking`
**Priority:** P3
**Labels:** `priority:p3` `type:feature`
**Milestone:** Phase 3 — Intelligence & Insights
**Schema change:** None new — `WeatherSnapshot` is stored as embedded fields on entry
types that already have a `weatherSnapshot` nullable embedded field (add this field during
v5–v7 migrations, null until weather is enabled)
**Note:** Weather is the ONLY network call the app makes. All other network access is
prohibited. The `.url-scan-ignore` file must whitelist the weather API endpoint with
documented justification.
**Spec:** `docs/features/quick-log.feature` (weather section), `docs/features/onboarding.feature` (weather opt-in)

**tea command:**
```bash
tea issue create \
  --title "Feature: weather tracking integration" \
  --body "Location permission opt-in, weather API (only network call in app), barometric pressure stored on entries, pattern correlation in insights. See docs/work-list.md WL-16." \
  --label "priority:p3,type:feature" \
  --milestone "Phase 3 — Intelligence & Insights"
```

---

## CI / Infrastructure

### WL-17 · Migration smoke test in CI
**Branch:** `ci/migration-smoke-test`
**Priority:** P1
**Labels:** `priority:p1` `type:infrastructure`
**Milestone:** Phase 1 — Core Tracking MVP
**Parallel with:** WL-06, WL-07, WL-08 (can be developed concurrently)

**Problem:** CI validates code quality and build integrity but has no test that runs
migrations against a realistic seeded dataset. A broken migration can pass CI and corrupt
Claire's data.

**Solution:** An integration test (or a Dart test in `test/unit/database/`) that:
1. Opens a fresh Isar instance on the test target schema version
2. Seeds it with realistic fixture data (2 profiles, 30 journal entries, 10 sleep entries,
   20 symptom entries, 5 medications, 10 dose logs, 10 meals)
3. Runs `MigrationRunner.run()` to bump to the next version
4. Asserts record counts, spot-checks field values, confirms no data loss

**Acceptance criteria:**
- [ ] Test runs as part of `flutter test`
- [ ] Test seeds fixture data at each prior schema version and migrates forward
- [ ] Test fails visibly if record counts change unexpectedly
- [ ] CI pipeline runs this test on every PR

**tea command:**
```bash
tea issue create \
  --title "CI: migration smoke test against seeded fixture data" \
  --body "Test that runs MigrationRunner against realistic fixture data and asserts data integrity post-migration. See docs/work-list.md WL-17." \
  --label "priority:p1,type:infrastructure" \
  --milestone "Phase 1 — Core Tracking MVP"
```

---

## Agent + worktree execution guide

```bash
# Start Phase 0 sequentially (WL-01 first, it touches shared copy)
git checkout -b fix/caregiver-language
# ... implement WL-01, merge to main ...

git checkout -b feature/sleep-complete
# ... implement WL-02, merge to main (schema v4) ...

# Now run WL-03 and WL-04 in parallel (independent code paths)
claude --worktree "Implement WL-03: Settings screen with backup/restore UI. Read docs/work-list.md for full spec."
claude --worktree "Implement WL-04: Profile color identity. Read docs/work-list.md for full spec."

# After Phase 0 is on main, run Phase 1 features in parallel
# (they touch different collections; merge in schema version order: v5, v6, v7)
claude --worktree "Implement WL-06: Symptom entry + vital measurement logging (schema v5). Read docs/work-list.md."
claude --worktree "Implement WL-07: Medication management + dose logging (schema v6). Read docs/work-list.md."
claude --worktree "Implement WL-08: Meal logging with reaction flags (schema v7). Read docs/work-list.md."
# Merge order: WL-06 first (v5), then WL-07 (v6), then WL-08 (v7)

# Phase 2: run WL-09, WL-10, WL-11 in parallel; WL-12 after all are merged
claude --worktree "Implement WL-09: Flare tracking (schema v8). Read docs/work-list.md."
claude --worktree "Implement WL-10: Daily check-in (schema v9). Read docs/work-list.md."
claude --worktree "Implement WL-11: Doctor visits + appointments (schema v10). Read docs/work-list.md."
```

### Subagent handoff template

When spawning a subagent for any WL item, include:

```
You are implementing WL-XX from docs/work-list.md in the Health Flare Flutter project.

1. Read CLAUDE.md (project rules and architecture)
2. Read docs/work-list.md section WL-XX (your spec)
3. Read lib/data/database/migration_runner.dart (current schema version and migration pattern)
4. Read lib/data/database/app_database.dart (registered collections)
5. Read lib/core/providers/journal_provider.dart (canonical provider pattern)
6. Read lib/data/models/profile_isar.dart (ID type = int auto-increment)
7. Implement the feature following the BDD cycle in docs/SDLC_WORKFLOW.md
8. Run /validate before declaring done
```
