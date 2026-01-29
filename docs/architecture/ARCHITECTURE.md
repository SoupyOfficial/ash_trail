# Ash Trail – Architecture Summary

This document describes the project’s structural conventions: screen layout, utils vs services, and test layout.

---

## Screen layout (`lib/screens/`)

Screens are **flat** in a single folder: one file per screen (e.g. `login_screen.dart`, `profile_screen.dart`, `accounts_screen.dart`). There are no feature subdirectories under `screens/`; all screen files live directly in `lib/screens/`.

---

## Utils vs services

- **`lib/utils/`** – Pure helpers: no Riverpod or other dependency injection, minimal or no I/O. Easy to unit test with no mocks. Examples: `day_boundary.dart`, `design_constants.dart`, `responsive_layout.dart`, `a11y_utils.dart`.
- **`lib/services/`** – Injectable (e.g. Riverpod providers), may perform I/O, state, or platform calls. Test with mocks/fakes. Examples: `account_service.dart`, `sync_service.dart`, `validation_service.dart`.

If a file in `utils/` starts depending on Riverpod or heavy I/O, it should be moved to `services/` (or another appropriate layer).

**Verification:** As of the last architecture pass, all files in `lib/utils/` are pure helpers with no Riverpod/DI and minimal or no I/O.

---

## Test layout

- **`test/`** – Unit and widget tests only. Run with `flutter test`. Mirrors `lib/` where useful (e.g. `test/models/`, `test/screens/`, `test/widgets/`). In-process flow tests live under `test/flows/` (e.g. `quick_log_workflow_test.dart`).
- **`integration_test/`** – Tests that run on device/simulator (full app or heavy platform use). Not run by `flutter test`; use `flutter test integration_test/` or the appropriate integration test runner.

Naming: prefer `*_test.dart` for unit/widget files; flow tests can use names like `*_flow_test.dart` or `*_workflow_test.dart`.
