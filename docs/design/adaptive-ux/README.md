# Adaptive appointment review

Recommend contextual appointment list and detail panes when the available space can support both. Keep the compact journey and existing navigation. Treat iPhone Duo continuity as a separate validation and state-lifetime feature built on that same layout, not a second layout engine.

This branch is spec only plus a disposable HTML review. No Flutter application, schema, navigation registry, user preferences or health data changed. All new Gherkin scenarios are `@unverified` and require Alexander's review before implementation.

## Open and review

Open `index.html` directly in a browser. It is self-contained, including CSS, JavaScript, bundled font bytes and their OFL licenses. No server, installation or network access is needed. All fixture content is synthetic and labeled. Do not enter real health data.

The default view is Care > Appointments with a selected visit. Select another appointment, choose Edit, change the title, switch widths, then Save or Cancel. Save updates only the in-memory fixture. Reloading resets it. Unfinished edits are guarded when changing appointments, leaving the editor or switching synthetic profiles.

Review directions:

1. **Bounded column, conservative.** Keeps the familiar list, then detail journey inside a readable maximum width. Lowest layout risk, but still requires backtracking.
2. **Contextual panes, recommended.** Keeps the list beside the selected appointment. Questions remain visible while preparing for a visit. Edit reuses the inspector space rather than opening an unrelated surface.
3. **Fold continuity, exploratory.** Uses the same contextual panes and adds an explanatory continuity strip. This explores the transition experience, not a Duo-specific design or simulated hinge. Start an edit, then use Duo closed and Duo open.

The primary surface is Command / Inspect. There is no dashboard redesign, summary metric grid or new clinical advice. Static navigation labels are deliberately identified as reference-only. This prototype does not pretend to implement the whole application.

## Width and accessibility decisions

The controls request illustrative widths of 1120 CSS px for Tablet, 390 for Compact and Duo closed, and 900 for Duo open. These are test inputs, not Apple device dimensions. The canvas is capped by the actual browser space, so a narrow browser overrides a wider preset. Two panes require at least 800 CSS px at normal text size; the demo raises that requirement with text scale. Those numbers are review mechanics, not proposed production constants.

Use available content constraints, safe areas, text scale and readable minimum pane widths in Flutter. A tablet in multitasking can legitimately use the compact layout. At 200% text this review falls back to one column. The Care tabs scroll horizontally, matching the existing section pattern, while the page and form do not. Controls have at least 48 px target height; the browser verifier also checks width on visible app inputs and buttons. The default bar is icons-only at large text, with accessible reference names via title, following the existing shell's intent. Production semantics still need Flutter testing.

The HTML uses native buttons, inputs, a modal discard guard, visible focus, labeled fields and live status text. Resizing changes CSS presentation rather than replacing the editor DOM, preserving its draft, focus and caret. No animation is needed. Natural vertical page scrolling keeps all actions reachable; this is not a native keyboard or safe-area simulation.

## Source and evidence

Source repository: `Health-Flare/app`.

Fresh main fetched by HTTPS into `refs/remotes/gh/main`: **`cfef3775fe13e1cac9eac47e3b790e80c7a13b0b`**, `docs: credit non-code contributors in CONTRIBUTORS.md (#196)`.

Worktree: `/Users/ah/git/healthflare-wt/adaptive-ux-review`.
Branch: `feature/adaptive-ux-review`. Feature proposals: #197 (tablet) and #198 (Duo). Published for design review only.

Evidence paths below refer to that exact commit:

- `lib/core/theme/app_colors.dart:13-45,115-139`: amber `#F5A623`, background `#F4F1EC`, text `#2C2825`, subtle text `#6B6560`, peach and linen surfaces.
- `lib/core/theme/app_text_styles.dart:5-19,33-118`: Fraunces headings, DM Sans UI, DM Mono timestamps. Fonts embedded from `assets/fonts/`; corresponding OFL files are embedded in the HTML.
- `lib/core/theme/app_theme.dart:19-39,114-142,175-240`: 4 px spacing system, 12/18 px component radii, light/dark schemes and profile seed support. The review uses default theme colors only; it does not replace custom profile colors. Its dark secondary-text token is a readable review approximation, not a new production token.
- `lib/features/shell/app_shell.dart:14-32,44-89`: persistent bottom NavigationBar, customizable effective slots, icons-only at text scale 1.5 or greater. No width-driven rail is implemented here.
- `lib/core/navigation/nav_registry.dart:104-115,122-241`: Track and Care already exist, Appointments is `care.appointments`, Reports is not a default bar destination. Stable ids are a persisted format, not labels to rename.
- `lib/features/sections/section_screen.dart:94-159`: active profile caption, section actions, scrollable 48 dp tabs, PageStorage and tab-specific add action.
- `lib/features/sections/tab_content.dart:55-114`: reusable list bodies for Track and Care, including `AppointmentListBody`. This is the reuse boundary, not a reason to duplicate screens.
- `lib/core/router/app_router.dart:99-105,428-460`: `/appointments`, detail, edit and `?focus=outcome` routes. Keep route meaning and Back behavior across pane changes.
- `lib/features/appointments/screens/appointment_list_screen.dart:118-155`: active-profile list, shared timing rule, upcoming/past groups, existing empty state and Add appointment action.
- `lib/features/appointments/screens/appointment_detail_screen.dart:64-99,112-159,278-417`: controller-owned unfinished text, edit action, question checklist, outcome notes, medication changes and status actions. **Save outcome explicitly sets completed status.** Never reuse that operation merely to preserve a draft during resize.
- `lib/features/appointments/screens/appointment_form_screen.dart:33-51,85-121,150-180`: actual edit fields are title, optional provider and date/time. The prototype edits these fields rather than inventing a new preparation-note schema.
- `lib/features/tracking/screens/tracking_screen.dart:107-147`: symptoms already have a list-to-edit journey. Track is a later reuse candidate, not part of this initial interactive slice.
- `lib/features/dashboard/dashboard_screen.dart:146-199`: existing LayoutBuilder handles empty dashboard height at large text. It is not a tablet list/detail implementation.
- `docs/features/navigation.feature` and `docs/features/navigation-customization.feature`: existing navigation, disabled-feature and personal-layout contracts remain intact.

A search of remote branch names found no branch named for adaptive/tablet/Duo work. Existing navigation branches are not a reason to recreate Track and Care, which are on main. An all-state issue search found **#31**, the broader device/OS support audit. Its screen-size point concerns installability and manifest restrictions; this proposal concerns in-app layout and continuity. Link the eventual features to #31 without conflating their acceptance criteria.

### Profile-safety implementation risk

`AppointmentDetailScreen` currently looks up an id from the all-profile `appointmentListProvider` (`appointment_detail_screen.dart:34-38`); the list is separately active-profile scoped. Before introducing retained selection, explicitly validate profile ownership for detail lookup and draft lifetime. Do not carry the old selected id into a newly active profile. The prototype's synthetic profile guard demonstrates the desired boundary but is not a fix to the Flutter code.

## Apple source boundary

The parent task verified these primary sources:

- [Apple introduces iPhone Duo](https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo/): establishes the foldable inner/outer-display use case.
- [Apple Human Interface Guidelines: Layout](https://developer.apple.com/design/human-interface-guidelines/layout): adapt to available layout size/classes rather than device name or orientation alone.

No logical display size, hinge inset, posture API, SDK availability or Flutter implementation support is inferred from those sources. Native support validation is deferred. The only Duo case proposed here is continuity of the current task through changes in available area and supported lifecycle events.

## Recommended issue scope

Separate feature proposals:

**Large-screen appointment layout:** reuse existing Care list and detail/form bodies, introduce a constraint-based composition boundary, preserve routes, selected id, list position, draft/focus, profile isolation, features-in-use and customized bar/More. Start with appointments because the list, preparation questions and detail already exist. Do not add a navigation rail or change the bar by default. Verify the release classification; any moved control follows existing guide rules. No migration is expected merely for layout. A later durable draft requirement would need separate storage and privacy review.

Acceptance proposal: all 11 scenarios in `../../features/large-screen-layout.feature`.

**iPhone Duo task continuity:** depends on the shared composition and ownership model above. Exercise inner/outer transitions, safe-area and keyboard changes, rapid transitions around one explicit save, profile switches, interruption and supported restoration. Do not fork layouts or use device-name checks. Clarify process-death restoration separately from in-session relayout and never describe a browser resize test as native support.

Acceptance proposal: all 8 scenarios in `../../features/iphone-duo-continuity.feature`.

## Verification

`verify.cjs` is a browser-artifact verifier, not Flutter acceptance tests against unapproved scenarios. Run it with an installed Playwright package and Chrome:

```sh
PLAYWRIGHT_MODULE=/path/to/playwright node docs/design/adaptive-ux/verify.cjs
```

Local run used `/Users/ah/.hermes/hermes-agent/node_modules/playwright`, Chrome **155.0.8059.84**, and passed **13 checks**. Exact results: `verification.json`.

Covered: offline embedded fonts; tablet two-pane composition; selected appointment editing; real viewport resize preserving draft, focus and caret without saving; repeated illustrative Duo width changes; one explicit save; empty-title validation; keep/discard cancellation; selection guard; synthetic profile isolation; bounded layout; no horizontal page/form overflow at 320/390/1440 px with 200% text; keyboard field order and focus style; minimum visible app control sizes; dark and empty states; zero JavaScript errors and zero HTTP requests.

The first attempt found a truncated CSS generation input and was corrected before the passing run. The installed Playwright headless-shell binary was absent, so verification used the installed Chrome channel. No browser install was needed.

`git diff --check` and `bash scripts/check_urls.sh` passed. A direct scenario audit confirmed all 19 new scenarios have `@unverified` and each file has a TODO note. No Flutter tests or analysis were run because there are no Flutter changes and the new requirements are unapproved.

Screenshots, all of the HTML review rather than the Flutter app:

- `01-tablet-context.png`
- `02-compact-edit.png`
- `03-duo-open-draft.png`
- `04-duo-closed-draft.png`
- `05-tablet-bounded.png`
- `06-compact-200-text.png`
- `07-tablet-dark.png`
- `08-empty-fixture.png`

Visual review found a clear list/inspector relationship, no overlapping form controls, and intentionally scrollable Care tabs at large text. Full-page screenshots are tall because the review controls and large-text form are included. Text contrast spot checks: dark ink on amber 7.21:1, subtle text on white 5.74:1, subtle text on cloud 5.10:1, dark-mode secondary text on surface 8.50:1. These are spot checks, not an accessibility certification.

Design self-audit: 0/10 generic-design tells. No gradient, metric tiles, accent rails, glass, hero-led app composition or substituted brand type. The editorial review heading is outside the app; the app itself remains an inspector.

## Limitations and review questions

Not covered: Flutter widget lifecycle, native keyboard and safe areas, VoiceOver/TalkBack, OS screen locking or suspension, process death, actual fold transitions, storage failure, notification/deep-link handling, saved preferences and backups. List/detail scroll restoration is specified but not modeled as independent scroll controllers here. The browser uses document scrolling. Main's full appointment actions remain outside the prototype. The empty mock does not implement Add appointment. Static tabs and bar are references, not interactive routes. Custom colors, pins and disabled-feature controls are not reproduced; their preservation is an explicit spec requirement.

1. Approve contextual panes for Care > Appointments as the first slice, leaving Track and primary navigation unchanged?
2. Should selecting another appointment with an unfinished edit offer Keep editing / Discard, as shown, or also Save and continue? Recommended initial choice: the shown explicit guard.
3. Should the Duo work promise only in-session continuity initially? Recommended: require native lifecycle investigation before committing to process-death draft restoration.
