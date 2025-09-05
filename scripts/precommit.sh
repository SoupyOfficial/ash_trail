#!/usr/bin/env bash
set -euo pipefail
echo 'Running pre-commit checks...'
flutter format --set-exit-if-changed .
flutter analyze
flutter test --tags=fast || flutter test
echo 'Pre-commit checks passed.'
