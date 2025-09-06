# ADR-0003: Replace Freezed union for AppTab with enum

## Context
Initial implementation used a Freezed union `AppTab` with variant classes. This required code generation which introduced friction for early bootstrap and simple persistence logic (tab id mapping). Tests failed before running build_runner, and the additional boilerplate provided limited benefit.

## Decision
Use a simple `enum AppTab { home, logs, charts, settings }` with an extension for `id` and `fromId` mapping. This removes the build step dependency and simplifies persistence (SharedPreferences string) and comparisons in tests.

## Consequences
- Faster iteration; no codegen needed for this core navigation primitive.
- Slight loss of future exhaustiveness helper methods (Freezed pattern matching) but acceptable given small fixed set.
- If later metadata (e.g., icon, route path) grows, can introduce a data class or map without breaking stored values (ids remain same as enum names).

## Status
Accepted.

## Date
2025-09-05

## Alternatives Considered
- Keep Freezed union: rejected for early complexity.
- Static class with const instances: more boilerplate than enum.

## Follow-Up
- Ensure any future feature flags referencing tabs use the enum values.
- Update docs referencing old Freezed approach.
