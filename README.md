# AshTrail

Compact, privacy-minded smoking event logger and insights app built with Flutter.

This repository contains the AshTrail mobile app (Flutter) and supporting documentation for development, data model, and platform-specific builds.

## Quick overview

- Primary goal: capture and inspect smoking events with minimal friction while supporting offline-first, multi-account usage and strong privacy defaults.
- Platform targets: Android and iOS (Flutter). See `feature_matrix.yaml` for the full feature and architecture definition.
- State management: Riverpod (as documented in the feature matrix).

## Key artifacts in this repo

- `feature_matrix.yaml` — canonical feature, data and platform definitions (source of truth).
- `docs/data-model.md` — human-friendly summary of the data model and recent changes.
- `docs/api/openapi.yaml` — API contract (if using the backend API). See `api/openapi.yaml`.
- `docs/adr/` — architectural decisions (ADRs) documenting tradeoffs and chosen patterns.
- `lib/` — Flutter application source.

## Getting started (developer)

Prerequisites
- Install Flutter 3.x or newer. Follow the official Flutter install guide for your OS: https://docs.flutter.dev/get-started/install
- Android: Android SDK + device/emulator. Set `ANDROID_HOME`/`ANDROID_SDK_ROOT` if needed.
- iOS (macOS only): Xcode and CocoaPods.

Clone and run

1. Clone the repo and open it in your IDE (VS Code, Android Studio, or IntelliJ).
2. Run flutter pub get to install dependencies.
3. Launch a simulator/emulator or connect a device.
4. Run the app:

	- Android: `flutter run -d android` (or select device in your IDE)
	- iOS: `flutter run -d ios` (on macOS)
	- Web: `flutter run -d chrome`

Notes
- If the project uses generated code (e.g. Freezed, Isar models, OpenAPI clients), run code generation after `pub get`: `flutter pub run build_runner build --delete-conflicting-outputs`.

## Development workflow

- Branching: follow GitHub flow on `main` (feature branches → PRs → review).
- Tests: unit and widget tests live under `test/`. Run them with `flutter test`.
- Linting & formatting: the repo includes `analysis_options.yaml`; run `dart analyze` and `flutter format`.
- CI: CI (if configured) will run analysis, tests and builds. See repository settings.

## Data model & sync

The canonical data model and platform decisions are in `feature_matrix.yaml`. For a readable schema and examples, see `docs/data-model.md`.

Notable recent model changes:
- `SmokeLog` now stores numeric `moodScore` and `physicalScore` (1..10).
- Tags and reasons are modelled via join tables `SmokeLogTag` and `SmokeLogReason`.

If you change the schema, add a migration step and update `docs/data-model.md` and `feature_matrix.yaml` accordingly.

## Performance & security

Performance budgets and key constraints are specified in `feature_matrix.yaml` under `perf_budgets`.

Security considerations in `feature_matrix.yaml` include data-at-rest protections and telemetry opt-in.

## Contributing

We welcome contributions. Small guidance:

1. Open an issue to discuss large features or breaking changes.
2. Create a feature branch off `main` named `feat/<short-name>` or `fix/<short-name>`.
3. Add tests for new behavior. Keep changes focused and well-documented.
4. Submit a PR and reference related `feature_matrix.yaml` entries or ADRs.

For feature planning, the `feature_matrix.yaml` contains epics, features, and acceptances — link PRs to the relevant feature IDs.

## Troubleshooting

- Common Flutter issues: run `flutter doctor` to verify your environment.
- If Android build fails, ensure Android SDK and platform-tools are installed and `local.properties` points to the correct SDK path.

## Useful commands

- Get deps: `flutter pub get`
- Run app: `flutter run`
- Run tests: `flutter test`
- Analyze: `dart analyze`
- Codegen (if used): `flutter pub run build_runner build --delete-conflicting-outputs`

## Where to read more

- Data model: `docs/data-model.md` and `feature_matrix.yaml`
- API spec: `api/openapi.yaml`
- ADRs: `docs/adr/`
- Release notes & planning: `docs/release-plan.md`

## License

See the repository `LICENSE` file if present. If no license file exists, contact the maintainers.

---

Last updated: 2025-08-26 (matches `feature_matrix.yaml` last_updated)
