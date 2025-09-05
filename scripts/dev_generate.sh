#!/usr/bin/env bash
set -euo pipefail
echo "== AshTrail dev generate =="
python scripts/generate_from_feature_matrix.py
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
if [ -d test ] && [ "$(ls -A test)" ]; then
  flutter test --coverage --reporter compact
fi
echo "Done."
