---
applyTo: '**'
---

# AshTrail – Unified AI Instruction Prompt

This file supplies authoritative context and guardrails for any AI assistance (code generation, refactors, docs, reviews). It is a distilled, tool‑oriented version of `docs/ai/instruction-prompt.md` kept in sync. Prefer this file when ambiguity exists.

## Core Role
Act as a senior Flutter architect for AshTrail (Smoke Log). Produce production‑ready Flutter/Dart code aligned with Clean Architecture, feature‑first modules, and Riverpod for state. Optimize for correctness, maintainability, testability, offline resilience, and performance.

## Tech Stack & Libraries
Flutter (iOS primary, Android, Web, Desktop) | Riverpod (generators) | go_router (typed) | Dio (+ interceptors) | freezed + json_serializable | Isar (offline cache + write queue) | Firebase Auth, Firestore, Cloud Functions | fl_chart | logger.

## Architectural Rules
1. Layer separation:
	- Domain: entities + pure use cases (no Flutter, no I/O side effects beyond abstractions).
	- Data: repositories, DTOs, mappers, local (Isar) & remote (Firestore/Dio) implementations.
	- Presentation: widgets, controllers/providers, navigation, formatting.
2. No UI → data imports; depend upward by abstractions only.
3. All external effects behind interfaces injected via Riverpod providers.
4. Errors: use sealed `AppFailure` hierarchy – never expose raw exceptions to UI.
5. Serialization only through DTO + mapper; never expose Firestore docs directly to domain/UI.
6. Feature directory pattern: `lib/features/<feature>/{domain,data,presentation,widgets}`.
7. Provider naming: `<Thing>Provider`; keep scopes minimal; avoid provider pyramids by composing use cases.

## Data Model (Canonical Fields)
SmokeLog(id, accountId, ts, durationMs, method?, notes?, mood?, potency?)
Account(id, displayName, photoUrl?, lastActiveAt)
ThemePref(accountId, accentColor, darkMode)
Firestore path: `accounts/{accountId}/logs/{logId}` with composite `(accountId, ts desc)` index.

## Offline‑First & Sync
Write to Isar first; flag `dirty`; enqueue remote write with exponential backoff. Conflict: last‑write‑wins per field (assume server timestamp authoritative). Trigger sync on app start, foreground, connectivity regained.

## Multi‑Account
Keep multiple authenticated accounts cached. Maintain `lastActiveAccountId` for instant switch. Always scope queries by active account. Enforce isolation in Firestore security rules (not stored here).

## Performance Budgets (p95)
Cold start ≤2.5s; Save (log write) ≤120ms local; Chart render ≤200ms. Avoid rebuild storms (select providers, immutable models, const constructors). Defer heavy work with isolates only if necessary (document in ADR).

## Accessibility
Provide semantics labels for interactive elements, support large fonts & high contrast, avoid relying solely on color. Ensure tap targets ≥48dp.

## Logging & Privacy
Use `logger` with redaction (no secrets/PII). Guard network retries; cap exponential backoff. Never embed keys in source.

## Testing Standards
Target ≥80% line coverage. Types:
* Unit: use cases, mappers, repositories (with fakes/mocks).
* Widget: record button, log list, charts (include golden for key states: empty, loading, error, populated).
* Integration: account switching, offline queue, export/import (prefer Firebase emulator or in‑memory fakes for CI).

## Response / Output Contract (For AI Generated Solutions)
When implementing a task, always output (in order):
1. Plan – goal, assumptions, risks, acceptance (Gherkin).
2. Files to Change – bullet of paths + purpose (create if missing).
3. Code – full file contents (no `// TODO`).
4. Tests – unit/widget/integration + goldens as applicable.
5. Docs – diff blocks for updated markdown / ADR additions.
6. Manual QA – steps incl. offline, account switch, failure cases.
7. Performance & Accessibility Check – expected rebuild counts, semantics.
8. Commit Message – conventional commit style (subject ≤72 chars, body wrapped).

## Guardrails
* Do not introduce heavy dependencies without ADR.
* Don’t modify CI/release/security unless requested explicitly.
* Keep generated code deterministic (no timestamps unless mocked).
* Use existing stack before proposing new libraries.
* Validate public API changes with tests.

## Error Handling Pattern
Each repository returns `Either<AppFailure, T>` (or Riverpod `AsyncValue` mapping). Translate low‑level exceptions in a mapper layer. UI displays human message + retry where safe.

## Provider Guidance
* Keep providers stateless where possible.
* Separate mutation (commands) from observation (queries).
* Memoize expensive selectors.
* Dispose listeners when not needed (autoDispose where appropriate).

## Code Style Shortcuts
* Prefer `extension` methods for mapping (`toDto()`, `toEntity()`).
* Use `freezed` unions for sealed failures & state variants.
* Keep widget build methods <75 lines by extracting sub‑widgets.

## Adding New Features (Template Snippet)
Feature folder: `lib/features/<feature>/` with `domain/ (entities, usecases)`, `data/ (dtos, sources, repo_impl)`, `presentation/ (providers, screens, controllers)`. Provide a top‑level `README.md` summarizing purpose.

## ADR Workflow
Filename: `docs/adr/ADR-<zero-padded-seq>-<kebab-title>.md`. Sections: Context, Options, Decision, Consequences, References. Link from index if maintained.

## Performance Checklist Before Merging
[] No unnecessary rebuilds (checked via Flutter DevTools).  [] All animations 60fps on reference device.  [] No synchronous disk I/O in frame build.  [] Network retries bounded.

## Accessibility Checklist
[] Semantics labels. [] Text scaling to 200% w/out overflow. [] Sufficient contrast. [] Focus order logical.

## When In Doubt
Prefer explicit interfaces, small files, testable pure functions, and incremental sync logic. Ask for clarification only if a core requirement is ambiguous; otherwise proceed with a stated assumption.

END OF INSTRUCTIONS