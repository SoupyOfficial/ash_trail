#!/usr/bin/env bash
set -euo pipefail
echo 'Running pre-commit quality gate...'
bash scripts/quality_gate.sh
echo 'Pre-commit checks passed (quality gate).'
