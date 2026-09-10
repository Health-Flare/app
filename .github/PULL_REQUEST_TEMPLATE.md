## Summary

<!-- What does this change do, and why? -->

## Related issue(s)

<!-- Closes #... -->

## Checklist

- [ ] Relevant `docs/features/*.feature` file added/updated
- [ ] `flutter analyze` passes with zero issues
- [ ] `dart format --output=none --set-exit-if-changed lib/ test/` passes
- [ ] `flutter test` passes
- [ ] `bash scripts/check_urls.sh` passes (no new network calls outside the documented exceptions)
- [ ] New/upgraded dependencies checked for GPL-3.0-compatible licenses, and `THIRD_PARTY_NOTICES.md` updated if needed
- [ ] Generated code committed (`build_runner` output for `@riverpod`, or Isar codegen output via `scripts/generate_isar.sh`), if applicable
