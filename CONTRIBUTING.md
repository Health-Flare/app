# Contributing to Health Flare

Thanks for considering a contribution. Health Flare is free software (GPL-3.0) and welcomes
outside contributions — this doc covers the essentials; `CLAUDE.md` and the README's
"Contributing" section have the full day-to-day developer workflow.

By submitting a contribution, you agree it is licensed under the project's
[GNU GPL-3.0](LICENSE.md), the same as the rest of the codebase. There is no separate CLA to sign.

Please also read the [Code of Conduct](CODE_OF_CONDUCT.md) — it applies to all project spaces.

## Before you start

- **Check `docs/features/*.feature` first.** Feature files (Gherkin) are the source of truth for
  app behavior. If you're changing behavior, update the relevant `.feature` file as part of your
  change, not after.
- **For anything non-trivial, open an issue first** so the approach can be discussed before you
  invest time in an implementation.
- This is a **fully offline-first** app with one narrow, documented exception (opt-in weather
  lookup). New network calls, analytics, or telemetry will not be accepted — see the "Offline-first
  rule" in the README.

## Getting set up

```bash
git clone https://git.ahosking.com/HealthFlare/app.git
cd app
flutter pub get
flutter run
```

See the README's "Prerequisites" and "Code generation" sections for the Riverpod/Isar codegen
setup — Isar uses an isolated codegen project (`scripts/isar_codegen/`) due to an analyzer version
conflict with the Riverpod generator.

## Making a change

1. Branch off `main` using the project's naming convention:
   - `feature/<name>` — new features
   - `fix/<name>` — bug fixes
   - `ci/<name>` — pipeline and tooling changes
   - `chore/<name>` — dependency updates, refactors, housekeeping
2. Write or update the relevant `docs/features/*.feature` scenario.
3. Implement the change, following the existing feature-first architecture
   (`lib/features/<feature>/{screens,widgets}`, `lib/core/providers/`, `lib/models/` vs
   `lib/data/models/`).
4. Add or update tests in `test/`.
5. Run the local checks before opening a PR:

   ```bash
   flutter analyze
   dart format --output=none --set-exit-if-changed lib/ test/
   flutter test
   bash scripts/check_urls.sh
   bash scripts/check_deps.sh
   ```

6. Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
   (`feat(scope): ...`, `fix(scope): ...`, `docs: ...`, `chore: ...`, etc.).

## Opening a pull request

This project uses **Gitea**, not GitHub — use the `tea` CLI:

```bash
tea pr create --title "feat(foo): short title" --description "## Summary\n..."
```

`main` only accepts changes via PR — no direct commits. Every PR runs CI (dependency resolution,
URL/offline-integrity scan, formatting, static analysis, a debug APK build) and must pass before
merge.

## Adding or upgrading a dependency

Check the new/updated package's license is GPL-3.0-compatible (permissive — MIT, BSD, Apache-2.0 —
is fine; a copyleft-incompatible or non-free license is not) and update
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) in the same PR.

## Questions

Open an issue, or for anything sensitive (security, privacy, conduct), see the contacts listed in
`SECURITY.md` and `CODE_OF_CONDUCT.md`.
