# Project Overview

* **Working name:** AshTrail (Smoke Log)
* **Owner:** Jacob Campbell
* **Repo:** SoupyOfficial/AshTrail
* **Platforms:** Android, iOS (Flutter)
* **IDE:** VS Code
* **Assistant:** GitHub Copilot Chat + GPT‑5 mini
* **Architecture style:** Clean Architecture + Feature‑first modules
* **State management:** Riverpod (recommended) or Bloc
* **Navigation:** go\_router
* **Networking:** Dio + Retrofit (optional)
* **Persistence:** Isar (offline‑first) + secure storage for secrets

---

## Repository Layout (proposed)

```
repo/
  .github/workflows/ci.yml
  docs/
    prd.md
    system-architecture.md
    adr/
      ADR-0001-state-management.md
    api/
      openapi.yaml
    data-model.md
    testing-strategy.md
    release-plan.md
  lib/
    app/
      app.dart
      router.dart
      theme/
    core/
      config/
      errors/
      logging/
      network/
      storage/
      util/
    features/
      <feature_name>/
        data/
        domain/
        presentation/
        widgets/
    flavors/
      env.dart
  test/
  integration_test/
  assets/
  tool/
  fastlane/  # optional
```

---

# Product Requirements Document (PRD)

> Save as `docs/prd.md`

## 1. Goal

* Problem statement: Users want fast, low‑friction tracking of smoking sessions and accurate review via charts and tables, even offline.
* Primary users: Individuals who track inhalation length and effects; some power users maintain multiple profiles.
* One‑sentence value prop: Log every hit in seconds and understand patterns with clear analytics across devices.

## 2. Non‑Goals

* Social network features
* Marketplace or strain database curation
* Community sharing beyond export

## 3. Personas

* **Tracker:** wants one‑tap logging and weekly patterns.
* **Power User:** manages multiple accounts, imports/exports data, tweaks charts and themes.

## 4. User Stories

* As a user, I long‑press a button to record hit duration.
* As a user, I view daily/weekly charts and a sortable table of logs.
* As a user, I edit or delete logs.
* As a user, I switch between multiple signed‑in accounts without re‑auth.
* As a user, I use the app offline; data syncs later.
* As a user, I export/import my data.

Acceptance criteria example:

```
Given I am on the Log screen
When I long‑press the record button and release
Then a new log is saved with duration, timestamp, and account
```

## 5. Use Cases and Flows

* Primary flow: Home → Hold‑to‑Record → Auto‑save → Snackbar undo → Charts/Table review → Edit
* Alternate: Offline capture → Local queue → Background sync
* Error: Token expired → Silent refresh → Retry; Sync conflict → last‑write‑wins

## 6. Success Metrics (north‑star + guardrails)

* Activation: 80% of new users create ≥1 log on day‑1
* Retention: 35% D30 retention
* Performance: p95 cold start ≤ 2.5s; p95 save ≤ 120ms; p95 chart render ≤ 200ms
* Crash‑free sessions ≥ 99.5%
* Data loss defects = 0 per release

## 7. Constraints

* Offline‑first requirement
* iOS 15+, Android 8+
* Minimal PII; no health claims
* Single developer velocity

## 8. Dependencies

* Firebase Auth + Firestore; Cloud Functions for token handling
* Riverpod, go\_router, Dio, Freezed, json\_serializable
* Isar for local store; WorkManager/BackgroundFetch
* fl\_chart for charts

## 9. Risks + Mitigations

* Data loss → Defense‑in‑depth: local writes + retry queue + e2e tests
* Token expiry loops → Robust refresh + backoff
* Performance regressions → Golden tests + frame budget CI gate
* App Store rejection → ATS review, privacy policy hosted, consent flows

## 10. Milestones

* M0: Architecture + skeleton
* M1: Logging + table
* M2: Charts + filters
* M3: Multi‑account + theme
* M4: Offline sync + export/import
* M5: 1.0 GA

## 11. Acceptance for Release

* All blocking bugs closed, test coverage ≥ <N>%, docs updated.

## 12. Open Questions

*

---

# System Architecture

> Save as `docs/system-architecture.md`

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

* **Navigation:** go\_router with typed routes and deep links
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

---

# ADR Template + Example

> Put ADRs in `docs/adr/`

## ADR Template

```
# ADR-<id>: <title>
Date: YYYY-MM-DD
Status: Proposed | Accepted | Superseded | Deprecated
Context: <why the decision is needed>
Options: <A, B, C>
Decision: <chosen option>
Consequences: <tradeoffs>
Links: <PRs, issues>
```

## ADR-0001: State Management

* **Date:** 2025-08-26
* **Status:** Proposed
* **Context:** Need predictable state, testability, DI.
* **Options:** Bloc, Provider, Riverpod, MobX
* **Decision:** Riverpod for compile‑time safety and simple DI.
* **Consequences:** Add `riverpod_generator`; training for team; avoid global singletons.

## ADR-0002: Backend & Sync

* **Date:** 2025-08-26
* **Status:** Proposed
* **Context:** Multi‑account, offline‑first, and existing Firebase artifacts in current repo.
* **Options:** Firebase (Auth + Firestore), Supabase, local‑only + periodic export
* **Decision:** Use Firebase Auth + Firestore with Cloud Functions for token creation/refresh; Isar for local cache and queues.
* **Consequences:** Vendor lock‑in; fast iteration; strong SDK support. Add privacy policy and data export.

---

# API Specification Stub (OpenAPI 3.1)

> Save as `docs/api/openapi.yaml`

```yaml
openapi: 3.1.0
info:
  title: <APP_NAME> API
  version: 0.1.0
servers:
  - url: https://api.example.com
paths:
  /v1/items:
    get:
      summary: List items
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Item'
components:
  schemas:
    Item:
      type: object
      required: [id, name]
      properties:
        id:
          type: string
        name:
          type: string
```

---

# Data Model

> Save as `docs/data-model.md`

## Entities

| Entity    | Fields                                                                                                                      | Source     | Persisted        | Indexes       |
| --------- | --------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------------- |
| SmokeLog  | id\:string, accountId\:string, ts\:DateTime, durationMs\:int, method?\:string, notes?\:string, mood?\:int, potency?\:double | User input | Isar + Firestore | ts, accountId |
| Account   | id\:string, displayName\:string, photoUrl?\:string, lastActiveAt\:DateTime                                                  | Auth       | Isar + Firestore | lastActiveAt  |
| ThemePref | accountId\:string, accentColor\:int, darkMode\:bool                                                                         | Local      | Isar             | accountId     |

## Isar Example

```dart
@collection
class SmokeLog {
  Id id = Isar.autoIncrement;
  late String remoteId; // Firestore doc id
  late String accountId;
  late DateTime ts;
  late int durationMs;
  String? method;
  String? notes;
  int? mood; // 1..5
  double? potency; // optional
}
```

\---|---|---|---|---|
\| Item | id\:string, name\:string, updatedAt\:DateTime | API | Isar | id, updatedAt |

## Isar Example

```dart
import 'package:isar/isar.dart';
part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;
  late String remoteId;
  late String name;
  DateTime updatedAt = DateTime.now();
}
```

---

# Testing Strategy

> Save as `docs/testing-strategy.md`

## Levels

* Unit: domain use cases
* Widget: record button, log list, charts
* Integration: account switcher, offline queue
* Contract: Firestore rules tests using emulator

## Tooling

* `flutter_test`, `integration_test`, `golden_toolkit`, `mocktail`, Firebase emulator
* Coverage gate ≥ 80% on CI

## Example Golden

```dart
testGoldens('RecordButton', (tester) async {
  await tester.pumpWidgetBuilder(RecordButton(onStart: (){}, onStop: (_){},));
  await screenMatchesGolden(tester, 'record_button');
});
```

---

# CI/CD

> Save as `.github/workflows/ci.yml`

```yaml
name: flutter-ci
on:
  pull_request:
  push:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
```

Optional release lanes via Fastlane and store actions.

---

# Release Plan

> Save as `docs/release-plan.md`

* Versioning: SemVer for code; build numbers per store
* Tracks: dev → beta → prod via flavors and tags
* Crash monitoring: Firebase Crashlytics before beta
* Feature flags for analytics and backup
* Beta cohort: internal TestFlight and closed Play test

---

# Security & Privacy Checklist

* [ ] Data classification documented
* [ ] PII minimization; optional pseudonyms only
* [ ] Network TLS enforced
* [ ] Secrets in keychain/keystore only
* [ ] Biometric/Pin gate for account switch if enabled
* [ ] Firestore rules locked to `accountId`
* [ ] Dependency license review

---

# Copilot Chat + GPT‑5 mini Playbooks

## Code generation prompt

```
You are GitHub Copilot Chat. Generate Flutter code for <feature>. Use Riverpod and go_router.
Follow repo layout and naming from docs/. Add tests. Explain assumptions in comments only.
```

## Test generation prompt

```
Given this widget code <paste>, write widget and golden tests. Target coverage 90%.
```

## Doc assistant prompt

```
Fill docs/prd.md sections using these inputs: <paste research>. Keep bullets terse. Propose measurable KPIs.
```

## Refactor prompt

```
Refactor this feature to separate domain/data/presentation. Create repository interfaces and inject via Riverpod.
```

---

# VS Code Setup

* Extensions: Dart, Flutter, Error Lens, GitHub Copilot Chat, GitLens, YAML, Markdown All in One
* `settings.json` snippet:

```json
{
  "dart.previewFlutterUiGuides": true,
  "editor.formatOnSave": true,
  "files.eol": "\n",
  "dart.lineLength": 100
}
```

* `launch.json` example:

```json
{
  "configurations": [
    {
      "name": "Flutter dev",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    }
  ]
}
```

---

# Definition of Done (per feature)

* [ ] PRD story linked and acceptance criteria met
* [ ] ADRs updated for any tech decisions
* [ ] Unit + widget tests passing with coverage ≥ <N>%
* [ ] Lints clean; no analyzer warnings
* [ ] Performance budget respected
* [ ] Accessibility scan complete
* [ ] Docs updated (README, changelog)

---

# Next Actions

1. Create flavors and env config.
2. Implement walking skeleton: Splash → Home → Hold‑to‑Record → Table → Charts.
3. Build `LogRepository` with Isar + Firestore implementations.
4. Add account switcher with last‑active tracking.
5. Set up Firebase emulator and CI job.
6. Write ADRs for charts package choice and export format (CSV/JSON).

---

# Repo Recon Summary (for redesign)

* Evidence of Firebase init, refresh token handling, and token service in existing repo. Plan Firebase Auth + Firestore with Cloud Functions in new design.
* Evidence of multi‑account and last‑user tracking; keep and formalize in `features/accounts`.
* Evidence of local caching and sync indicators; replace with durable Isar queue.
* Evidence of log editing, LogList refactor, and log transfer; standardize under `features/logs` and `features/backup`.

See commit history and planning issues for context.
