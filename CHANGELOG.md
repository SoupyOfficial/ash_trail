# Changelog

All notable changes to Ash Trail are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). The version scheme is `MAJOR.MINOR.PATCH+BUILD` from `pubspec.yaml`.

---

## [1.0.1+11] — 2026-02-09

### Added
- Comprehensive UI documentation suite (`docs/ui/`) with 19 cross-linked files, Mermaid diagrams, and MkDocs Material publishing
- Personalized greeting on home screen based on active account display name
- New widgets added to the catalog (27 total across 7 categories)
- Snackbar tests for Quick Log widget (display and auto-dismiss)
- Multi-account log switching tests

### Changed
- Refactored widget catalog tests for consistency
- Refactored account session manager tests
- Enhanced logging for multi-account debugging
- Increased SnackBar duration to 3 seconds
- Refactored error logging; enhanced log record filtering and sorting
- Disabled default drag handles in ReorderableListView (custom handles only)

### Removed
- LoggingScreen removed from main navigation (accessible via app bar only)
- Anonymous account support removed
- Backup `pubspec.yaml` file removed

### Fixed
- Quick log message formatting corrected
- CI workflow and TestFlight deployment script improvements

---

## [1.0.0] — 2026-01

### Added
- Initial release
- Core logging: Quick Log (press-and-hold), Detailed logging, Backdate entry
- 27 customizable home screen widgets across 7 categories (Time, Duration, Count, Comparison, Pattern, Secondary Data, Action)
- Analytics screen with bar charts, line charts, pie charts, and heatmaps
- History screen with search, filters, and grouping
- Multi-account support with instant switching
- 6 AM day boundary for all metrics
- Offline-first with Hive local storage
- Cloud sync to Firebase/Firestore (30-second auto-sync, batch push/pull)
- CSV and JSON export to clipboard
- Authentication: Email/password, Google SSO, Apple SSO
- Material 3 design with royal blue (`#4169E1`) color scheme
- iOS primary platform with Android, web, macOS, Linux, Windows support
- TestFlight deployment script with version bumping
- Location auto-capture (GPS) on log entries
- Mood (1–10) and physical (1–10) rating sliders
- Reason tagging (8 categories) on entries
- Soft-delete with undo snackbar
- Per-account widget layout persistence

---

_To add a new entry: document changes under the current version heading in `pubspec.yaml`. When deploying, move the `[Unreleased]` block to a new version heading._
