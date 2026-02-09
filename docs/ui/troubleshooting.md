# Troubleshooting & FAQ

Common issues you'll encounter as the developer, how to diagnose them, and what to do. This is the "I've seen this before" reference — check here before debugging from scratch.

← [Back to Index](README.md)

---

## Sync Issues

### "Entries are stuck on pending"

**Symptoms:** [Sync state](glossary.md#sync-state) badge shows `pending` but never transitions to `synced`. Analytics summary card shows a growing "Pending" count.

**Diagnosis:**
1. Check network connectivity — sync only works when online
2. Check the debug console for `SyncService` log messages — look for errors from Firestore
3. Verify the active account has valid Firebase Auth credentials — expired tokens prevent uploads
4. Check if the Firestore path `accounts/{accountId}/logs/{logId}` is accessible

**Resolution:**
- Force a sync by switching accounts and switching back (triggers immediate sync)
- If auth tokens expired, sign out and sign back in to refresh them
- Check `lib/services/sync_service.dart` for the push logic

### "Sync conflict — data shows wrong values"

**Symptoms:** A record was edited on two devices and the wrong version won.

**How it works:** Ash Trail uses **last-write-wins** conflict resolution — the record with the newer `updatedAt` timestamp always wins. There is no merge or manual conflict resolution UI.

**Resolution:** Edit the record manually to the correct values. The edit sets `syncState = pending` and the corrected version will sync on the next cycle.

---

## Widget Data Issues

### "Widget shows `--` when I expect data"

**Symptoms:** A widget displays two dashes instead of a value even though you've logged entries.

**Common causes:**
- **Wrong day boundary window** — If it's 3 AM and you logged at 2 AM, that entry belongs to "yesterday" per the [6 AM day boundary](glossary.md#day-boundary). Widgets showing "today" won't include it until 6 AM rolls over.
- **Not enough entries** — Gap-based widgets (Average Gap, Longest Gap) require at least 2 entries to calculate. One entry isn't enough.
- **Optional fields not set** — Mood/Physical Avg shows `--` if no entries have mood or physical ratings set.
- **Wrong account** — Widgets are scoped to the active account. If you logged under Account A but are viewing Account B, you won't see those entries.

**Diagnosis:** Check `home_metrics_service.dart` — each method starts with a guard clause that returns `null` when data is insufficient. The builder renders `null` as `'--'`.

### "Trend arrow shows wrong direction"

**Symptoms:** The trend arrow seems backwards — green when usage went up, or red when it went down.

**Explanation:** Ash Trail uses an [inverted trend convention](trends.md) for usage metrics: **green ↓ = less usage = good**. This is intentional — in a harm-reduction app, less is better. Only mood/physical ratings use the standard convention (green ↑ = higher rating = good).

### "We're using 27 widgets but the plan says 30"

The original plan estimated 30 widgets. The actual catalog in `widget_catalog.dart` contains **27 widget types**. Three planned widgets were not implemented. This is documented in the [Widget Catalog](widgets/README.md). Always trust the code over the plan.

---

## Build Issues

### "Build fails after `flutter clean`"

**Symptoms:** `flutter build ios` or `flutter run` fails after cleaning.

**Checklist:**
1. `flutter pub get` — re-fetch dependencies
2. `cd ios && pod install && cd ..` — re-install CocoaPods (iOS only)
3. If pods fail, try `cd ios && pod deintegrate && pod install && cd ..`
4. If Gradle fails (Android), try `cd android && ./gradlew clean && cd ..`
5. After all else: delete `build/`, `ios/Pods/`, `ios/Podfile.lock`, re-run

### "Xcode build fails with signing errors"

**Symptoms:** `Code Signing Error: No profiles for 'com.soup.smokeLog' were found` or similar.

**Resolution:**
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target → Signing & Capabilities → ensure the correct team (`DGQ5P34GS9`) and provisioning profile are selected
- For CI/CD: the deploy script expects an App Store Connect API key (`.p8` file or `APP_STORE_CONNECT_API_KEY_BASE64` env var)

### "Tests fail but app runs fine"

**Symptoms:** `flutter test` reports failures but the app works correctly when run.

**Common causes:**
- **Missing test setup** — Some tests require Hive initialization or mock injection that isn't running
- **Flaky async tests** — Tests with `pump()` may need `pumpAndSettle()` or explicit delays
- **Provider not overridden** — Widget tests need provider overrides for Riverpod dependencies

**Diagnosis:** Run the specific failing test file in isolation: `flutter test test/path/to/specific_test.dart`

---

## TestFlight Deployment Issues

### "Deploy script fails at upload"

**Symptoms:** `./scripts/deploy_testflight.sh` builds successfully but fails at the "Upload to TestFlight" step.

**Checklist:**
1. Verify App Store Connect API key:
   - `APP_STORE_CONNECT_API_KEY` — key ID
   - `APP_STORE_CONNECT_ISSUER_ID` — issuer ID
   - API key `.p8` file at `~/.appstoreconnect/private_keys/` or base64 via `APP_STORE_CONNECT_API_KEY_BASE64`
2. Verify the build number is unique — App Store Connect rejects duplicate build numbers
3. Verify the bundle ID matches: `com.soup.smokeLog`
4. Try `SKIP_TESTS=1 ./scripts/deploy_testflight.sh --no-bump` to isolate upload issues from build issues

### "Build number conflict"

**Symptoms:** Upload rejected with "build already exists" error.

**Resolution:** The deploy script auto-increments the build number in `pubspec.yaml`. If it conflicts, force a specific number: `./scripts/deploy_testflight.sh --build 15` or set `BUILD_NUMBER=15`.

---

## Data & Privacy

### "How do I delete all data for an account?"

Use ProfileScreen → Delete Account. This marks the local account as deleted and signs out. However, **Firestore data is NOT automatically deleted** — there are no Cloud Functions or server-side cleanup. Manual Firestore cleanup is required via the Firebase Console.

### "Where is user data stored?"

- **Local:** Hive boxes in the app's sandboxed storage directory (auto-managed by the OS)
- **Cloud:** Firestore at path `accounts/{accountId}/logs/{logId}`
- **Auth:** Firebase Authentication (email/password or federated identity)
- **No analytics/tracking:** No Firebase Analytics, Crashlytics events, or third-party tracking SDKs

### "What location data is captured?"

GPS coordinates (latitude + longitude) are captured **only when the user has granted location permission**. Coordinates are stored on each [entry](glossary.md#entry) in the `latitude` and `longitude` fields. There is no background location tracking — capture only happens at the moment of logging.

---

## Common Development Gotchas

| Gotcha | Explanation |
|--------|-------------|
| Day starts at 6 AM, not midnight | The [day boundary](glossary.md#day-boundary) is 6 AM. Every widget and chart uses this. Don't use `DateTime.now().day` for "today" comparisons — use `DayBoundary.getLogicalDay()`. |
| Method names are public, not prefixed with `_` | `home_metrics_service.dart` methods like `getTimeSinceLastHit()` are public (no underscore). The plan referenced underscore-prefixed names — the code doesn't use them. |
| Widget catalog is the source of truth | Don't add widgets by just creating a builder. You must register in `widget_catalog.dart` first. The enum, catalog entry, builder, and metric method must all match. See [How to Add a New Widget](developer-guide.md#how-to-add-a-new-widget). |
| Soft-deleted records sync to Firestore | `isDeleted = true` records are still pushed to cloud. They're hidden from the UI but exist in the database. Don't assume deletion removes them. |
| Switching accounts refreshes everything | All providers chain from `activeAccountProvider`. Changing the active account triggers a full cascade — new records, new layout, new sync. |
| Ratings are 1–10 internally, not 1–5 | The mood and physical sliders go 1–10 despite some earlier docs suggesting 1–5. Check the current code. |

---

← [Back to Index](README.md)
