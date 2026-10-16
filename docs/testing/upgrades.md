# Testing upgrades

Two checks prove that an update keeps everyone's data. Both use data written by released versions of Health Flare, not by current code pretending to be old.

| Check | Runs | What it proves |
|---|---|---|
| Release fixtures | In CI, on every pull request (`test/unit/database/upgrade_from_releases_test.dart`) | Each release's database upgrades through the real startup path with nothing lost |
| The real upgrade | On a simulator or emulator, before each release (`bash scripts/upgrade_test.sh <version>`) | Installing the new build over the old one keeps the data and opens correctly, native libraries included |

Spec and background: #181. If an upgrade does fail anyway, see #112 (`docs/features/datastore.feature`, "When an upgrade keeps failing").

## Release fixtures

`test/fixtures/upgrades/<version>/` holds:

- `healthflare.isar`: a database written by that release's own code. It contains two profiles, one row in every collection, flare links, a missed dose with its reason, a condition in recovery, an appointment with a question, and a deleted profile's leftovers.
- `manifest.json`: what's in it. The CI test checks every item after upgrading: the schema version, profiles, the active profile, row counts, values as logged, and that the leftovers are removed.

Current fixtures are 1.9.0 (schema 15), 1.9.1 (schema 16) and 1.10.0 (schema 22). Users on 1.7.0 through 1.9.0 have the same schema as 1.9.0.

The newest fixture is usually at the current schema until the next schema change lands. Then it should open as it is (`upToDate`, no safety copy), and the test checks that instead of a migration.

### Making one

```bash
bash scripts/upgrade_fixture.sh v1.9.1
```

This checks out the tag in a temporary worktree and copies in `tool/upgrade/seed_release_test.dart`, or `seed_<version>_test.dart` if there is one. It runs the seed there, so the release's own models, migrations and catalogue seeding write the data, then copies the result into `test/fixtures/upgrades/<version>/`.

If a release's models differ from the shared seed, copy it to `tool/upgrade/seed_<version>_test.dart` and adjust. 1.9.0 needed this, because symptom body areas arrived in 1.9.1. 1.10.0 has its own seed too:

- its user has already seen the Track and Care guide (`bottomBarLayoutVersion = 2`);
- it writes no rows from a deleted profile, because since v18 that can't happen.

Its manifest says `"expectGuide": false`, so the device check expects no guide card after updating. Files in `tool/upgrade/` aren't analyzed with the app, because they're written against old releases' code.

### When a release is cut

1. Tag it.
2. Run `bash scripts/upgrade_fixture.sh vX.Y.Z` and commit `test/fixtures/upgrades/X.Y.Z/`.

From then on, every pull request checks upgrades from that release.

## The real upgrade

```bash
bash scripts/upgrade_test.sh 1.9.1            # booted iPhone simulator
bash scripts/upgrade_test.sh 1.9.1 android    # running emulator (start it with -memory 4096, #176)
```

1. Builds the release from its tag and installs it, replacing any install.
2. Puts the fixture database in its documents folder, launches it once, and closes it.
3. Installs this checkout's build over it, keeping the data. Then runs `integration_test/upgrade_check_test.dart` through the app's real `main()`, which checks:
   - the release guide card shows and the failed-update card doesn't;
   - the schema is current, with a safety copy;
   - the profiles and rows are all there;
   - Sarah's journal entry is on screen.

Screenshots and logs go to `build/upgrade_test/<version>-<platform>/`. It replaces the app and its data on that simulator or emulator.

Run it for at least the last release, on iOS and Android, before every release.
