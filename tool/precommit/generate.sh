#!/usr/bin/env bash
set -euo pipefail

python scripts/generate_from_feature_matrix.py

if ! git diff --quiet; then
  echo "ERROR: Generated files out of date. Commit changes." >&2
  git --no-pager diff --name-only
  exit 1
fi
