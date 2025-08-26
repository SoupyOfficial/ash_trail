# System Architecture

## 1. Context

* Mobile client only. Backend: Firebase Auth + Firestore; Cloud Functions for custom/refresh tokens.

## 2. High‑Level Diagram

* C4 Level 2: App ↔ API ↔ Auth provider; add caching and analytics.

## 3. Module Boundaries (feature‑first)

* `features/logs` (record, edit, list, table)
* `features/charts` (aggregations, time ranges)
* `features/accounts` (auth, multi‑account switcher)
* `features/sync` (queue, conflict resolution)
* `features/settings` (theme, preferences)
* `features/backup` (export/import)

## 4. Cross‑cutting Concerns

* **Navigation:** go_router with typed routes and deep links
* **State:** Riverpod `Provider`/`AsyncNotifier`
* **Networking:** Dio with interceptors for auth, retries, logging
* **Serialization:** `freezed` + `json_serializable`
* **Persistence:** Isar collections per aggregate root; background sync jobs
* **Error Handling:** sealed `AppFailure` types; global `FlutterError.onError`
* **Logging/Analytics:** `logger` + Firebase Analytics or alternative
* **Localization:** Flutter intl; key policy and fallback rules
* **Accessibility:** color contrast, large fonts, semantics
* **Security:**

  * Secrets in platform keychains. No secrets in git.
  * Pin TLS where possible. Validate cert chain.
  * Obfuscate release builds. Root/jailbreak checks if needed.
* **Performance budget:**

  * app start ≤ 2.5s cold, frame build ≤ 16ms avg, images cached
* **Background tasks:**

  * WorkManager/BackgroundFetch policies, constraints, backoff
* **Notifications:** FCM topics, foreground handling

## 5. Config and Flavors

* Flavors: dev, staging, prod. Each has bundle id, icons, API base URL.
* `.env` files or Dart `const` maps generated at build time.

## 6. Offline‑first Sync

* Local write‑through to Isar; enqueue remote write
* Retry with exponential backoff; mark dirty/clean
* Conflict policy: last‑write‑wins per field; clock skew mitigation
* Connectivity listener triggers flush

## 7. App Lifecycle

* Save state on `inactive/paused`. Lightweight restore on warm start.
