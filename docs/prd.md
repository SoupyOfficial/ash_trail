# Product Requirements Document (PRD)

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
* Riverpod, go_router, Dio, Freezed, json_serializable
* Isar for local store; WorkManager/BackgroundFetch
* fl_chart for charts

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
