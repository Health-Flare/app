# F-Droid and IzzyOnDroid

Two FOSS Android repositories, two different models:

- **F-Droid** builds the APK itself from a tagged commit, using the recipe
  in `org.healthflare.app.healthflare.yml` (this folder), and signs it with
  F-Droid's key. The recipe lives in `fdroid/fdroiddata` once the merge
  request is accepted; this copy is the one we keep tested.
- **IzzyOnDroid** takes our signed APK from the GitHub release. It caps a
  file at about 30 MB, so each release also carries
  `healthflare-vX.Y.Z-arm64-v8a.apk` (about 25 MB; the universal APK is
  about 70 MB). Same versionCode and signing key as the universal APK.

Both read the store listing from `fastlane/metadata/android/en-US/`: title,
short and full description (copied from the Google Play section of
`docs/store-listing.md`), icon, the Play screenshot set in upload order
(`scripts/store_upload_set.sh`), and `changelogs/<versionCode>.txt` (the
Play release notes from `docs/store-notes/<version>.md`). The privacy-claims
test scans these files too.

## What F-Droid needs that the Play build doesn't

Two dependencies don't pass F-Droid's rules as shipped:

- **Google Play Services.** `geolocator_android` depends on
  `play-services-location` (non-free). `scripts/fdroid/strip_gms_location.sh`
  removes it from the pub cache before the build: the dependency, the
  fused-location client, and the Play Services check. geolocator then always
  uses Android's `LocationManager`, which it already does on phones without
  Play Services. The weather lookup takes one coarse fix, so nothing the user
  sees changes. The script fails if a geolocator update moves the code it
  edits, so a bump can't quietly bring Play Services back.
  The GitHub release APKs (and so IzzyOnDroid) are built the same way
  (`release.yaml`). Only the Play Store build keeps Play Services.
- **Prebuilt libisar.** `isar_community_flutter_libs` ships `libisar.so`
  binaries. The scanner deletes them, and `scripts/fdroid/build_isar.sh`
  builds them from source: the `third_party/isar-community` submodule, pinned
  to the same tag as `isar_community_flutter_libs` in `pubspec.lock`
  (3.3.2), with Rust 1.88.0 (what upstream's `tool/build_android.sh` names)
  and `scripts/fdroid/isar-Cargo.lock` (upstream commits no lockfile; this
  is the one LocalMaterialNotes builds 3.3.2 with on F-Droid). The script
  refuses to run if the submodule and the lockfile disagree.
  **When Renovate bumps Isar**, move the submodule to the new tag
  (`git -C third_party/isar-community checkout <tag>`), regenerate the Cargo
  lock (`cargo generate-lockfile` in the submodule, copy it over), and let the
  F-Droid build job confirm it.

And one of ours:

- **Unsigned release.** `HEALTHFLARE_UNSIGNED_RELEASE=true` builds a release
  APK with no signature (not the debug key); F-Droid signs it.

## The build is verified, not assumed

`.github/workflows/fdroid-build.yml` runs `scripts/fdroid/ci_build.sh` in
F-Droid's own `fdroidserver:buildserver-trixie` image, the same steps as the
"fdroid build" job on an fdroiddata merge request: fetch the Flutter srclib,
run the recipe, scan the source and pub cache for non-free and prebuilt
binaries, build, then `fdroid lint`. It points the recipe's first build entry
at the commit under test, so every PR that touches Android, the lockfile,
the submodule or the recipe proves the next release still builds there.

## Anti-features

None expected. No ads, no tracking, no non-free dependencies once Play
Services is stripped. The one network call is the optional weather lookup
to Open-Meteo, whose server software is open source (AGPL), so it isn't
`NonFreeNet`. Reviewers may still ask; that's the answer.

## Submitting (needs a GitLab account)

1. Cut the release that will be the first F-Droid version. It must include
   this PR, so the first candidate is the next tag after 1.10.0.
2. In `org.healthflare.app.healthflare.yml`, set `versionName`,
   `versionCode` and `commit` (full hash of the tag's commit, never the tag
   name) and `CurrentVersion`/`CurrentVersionCode`. Add
   `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt`.
3. Fork https://gitlab.com/fdroid/fdroiddata, copy the file to
   `metadata/org.healthflare.app.healthflare.yml`, run `fdroid rewritemeta`
   and `fdroid lint` on it, and open the merge request with their "App
   inclusion" template. Their CI runs the same build as ours.
4. After that, `AutoUpdateMode: Version` + `UpdateCheckMode: Tags` means
   F-Droid picks up new `vX.Y.Z` tags itself. Per release: the changelog
   file, and the Isar steps above if Isar moved.

IzzyOnDroid: open a request at https://codeberg.org/IzzyOnDroid/repo/issues
naming the repo and the `-arm64-v8a.apk` asset.
