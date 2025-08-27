# ash_trail

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Data model

The canonical data model is defined in `feature_matrix.yaml` and summarized in `docs/data-model.md`.

Key recent changes: SmokeLog now uses numeric mood/physical scores and edges for tags and reasons are modelled with `SmokeLogTag` and `SmokeLogReason` join tables. See `docs/data-model.md` for details and Isar/Dart examples.
