#!/usr/bin/env bash
set -euo pipefail

echo '=== AshTrail Quality Gate ==='

echo '* Formatting check'
python scripts/branch_policy.py --allow-main || { echo 'Branch policy violation'; exit 1; }
flutter format --set-exit-if-changed .

echo '* Static analysis'
flutter analyze

echo '* Tests with coverage'
flutter test --coverage

# Parse coverage via dev assistant (json)
COV_JSON=$(python scripts/dev_assistant.py test-coverage --json || true)
LINE_COV=$(echo "$COV_JSON" | python - <<'PY'
import json,sys
try:
 data=json.load(sys.stdin)
 cov=data.get('coverage_after',{}) or {}
 print(cov.get('line_coverage',0))
except Exception:
 print(0)
PY
)

echo "Coverage: ${LINE_COV}%"
COV_INT=${LINE_COV%.*}
if [ "${COV_INT}" -lt 80 ]; then
  echo "Coverage below 80% threshold"
  exit 1
fi

echo '* Patch coverage check'
# Uses patch_coverage.py (added by automation hardening phase) to enforce diff coverage.
PATCH_JSON=$(python scripts/patch_coverage.py --json || true)
PATCH_PCT=$(echo "$PATCH_JSON" | python - <<'PY'
import json,sys
try:
 data=json.load(sys.stdin)
 print(data.get('patch_coverage_pct',0))
except Exception:
 print(0)
PY
)
echo "Patch coverage: ${PATCH_PCT}%"
PATCH_INT=${PATCH_PCT%.*}
THRESH=$(echo "$PATCH_JSON" | python - <<'PY'
import json,sys
try:
 data=json.load(sys.stdin)
 print(int(data.get('threshold',85)))
except Exception:
 print(85)
PY
)
if [ "${PATCH_INT}" -lt "${THRESH}" ]; then
  echo "Patch coverage below threshold (${PATCH_INT}% < ${THRESH}%)"
  echo "$PATCH_JSON" > build/last_patch_coverage.json || true
  exit 1
fi

echo 'Quality gate passed.'
