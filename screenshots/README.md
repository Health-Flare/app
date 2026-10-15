# Screenshots

Only two folders here are for the stores. Everything else is for testing and review.

| Folder | What it is | Goes to |
|---|---|---|
| `appstore/iphone-6.3/` (required), `appstore/iphone-6.9/`, `appstore/ipad-13/` (required); `appstore/iphone-6.5/` isn't uploaded | Store captures from `scripts/take_screenshots.sh` | **App Store Connect**, through `scripts/store_upload_set.sh` |
| `playstore/phone/` | Store captures from `scripts/take_screenshots_android.sh` | **Google Play Console**, through `scripts/store_upload_set.sh` |
| `whats_new/` | What's new cards (`scripts/whats_new.sh shots`) | Nowhere: review only |
| `track_and_care/` | Track and Care flows (`scripts/track_and_care.sh shots`) | Nowhere: review only |
| `quick_log/` | Quick Log states and goldens | Nowhere: review only |
| `v1/`, `v2/` | Old store sets, kept for history | Nowhere |
| `release_review/` | Release review (`scripts/release_review.sh`), gitignored | Nowhere: review only |

Each store capture folder has more shots than a store accepts (App Store: 10 per device size; Play: 8 phone). Don't upload a folder from here directly. Run:

```bash
bash scripts/store_upload_set.sh
```

It builds `build/store_upload/app-store/<device>/` and `build/store_upload/play-store/phone/`, each holding exactly what to upload, numbered in order. Steps and the release notes for each store: `docs/store-notes/<version>.md`.
