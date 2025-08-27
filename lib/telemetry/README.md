# Telemetry Events

This directory contains generated telemetry event constants derived from `feature_matrix.yaml`.

Process:
1. Features may declare telemetry events either under `telemetry: events:` or at the root `events:` (for aggregate features like quality.telemetry).
2. `scripts/generate_from_feature_matrix.py` parses all features, collects unique event names, sorts them, and emits `events.dart` with the constant `kTelemetryEvents`.
3. Only files beginning with the banner line `// GENERATED - DO NOT EDIT.` are overwritten.

To regenerate:
```
python scripts/generate_from_feature_matrix.py
```

Add new events by updating the feature matrix rather than editing code directly.
