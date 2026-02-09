#!/bin/bash

# =============================================================================
# TestFlight Build & Deploy Script
# Works both locally and in CI (GitHub Actions)
#
# Usage:
#   ./scripts/deploy_testflight.sh              # auto build number from pubspec
#   ./scripts/deploy_testflight.sh 42            # explicit build number
#   SKIP_TESTS=1 ./scripts/deploy_testflight.sh  # skip tests
#   SKIP_CLEAN=1 ./scripts/deploy_testflight.sh  # skip flutter clean
# =============================================================================

set -euo pipefail

# Colors (disabled in CI for cleaner logs)
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

# Resolve project root (script lives in scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# ── Configuration ──────────────────────────────────────────────────────────────
BUNDLE_ID="com.soup.smokeLog"
TEAM_ID="DGQ5P34GS9"
IPA_PATH="build/ios/ipa/ash_trail.ipa"

# Build number: argument > env > auto-increment from pubspec
if [ -n "${1:-}" ]; then
  BUILD_NUMBER="$1"
elif [ -n "${BUILD_NUMBER:-}" ]; then
  BUILD_NUMBER="$BUILD_NUMBER"
else
  # Extract current build number from pubspec.yaml and increment
  CURRENT_BUILD=$(grep '^version:' pubspec.yaml | sed 's/.*+//')
  BUILD_NUMBER=$((CURRENT_BUILD + 1))
fi

# Version name from pubspec (e.g. 1.0.1)
VERSION_NAME=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')

echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       TestFlight Build & Deploy               ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo -e "${BLUE}  Version:      ${NC}${VERSION_NAME}+${BUILD_NUMBER}"
echo -e "${BLUE}  Bundle ID:    ${NC}${BUNDLE_ID}"
echo ""

# ── Step 1: Preflight checks ──────────────────────────────────────────────────
echo -e "${YELLOW}[1/6] Preflight checks...${NC}"

if ! command -v flutter &> /dev/null; then
  echo -e "${RED}✗ Flutter not found in PATH${NC}"
  exit 1
fi

if ! command -v xcrun &> /dev/null; then
  echo -e "${RED}✗ xcrun not found — Xcode CLI tools required${NC}"
  exit 1
fi

# Check upload credentials
if [ -n "${APP_STORE_CONNECT_API_KEY:-}" ] && [ -n "${APP_STORE_CONNECT_ISSUER_ID:-}" ]; then
  # Check for .p8 key file
  KEY_FILE="${HOME}/.private_keys/AuthKey_${APP_STORE_CONNECT_API_KEY}.p8"
  if [ ! -f "$KEY_FILE" ]; then
    # CI may decode it from base64
    if [ -n "${APP_STORE_CONNECT_API_KEY_BASE64:-}" ]; then
      echo -e "  Decoding API key from base64..."
      mkdir -p "${HOME}/.private_keys"
      echo -n "$APP_STORE_CONNECT_API_KEY_BASE64" | base64 --decode > "$KEY_FILE"
      chmod 600 "$KEY_FILE"
    else
      echo -e "${RED}✗ API key file not found: ${KEY_FILE}${NC}"
      echo "  Run: mv ~/Downloads/AuthKey_${APP_STORE_CONNECT_API_KEY}.p8 ~/.private_keys/"
      exit 1
    fi
  fi
  UPLOAD_METHOD="altool"
  echo -e "  ${GREEN}✓${NC} API key found (${APP_STORE_CONNECT_API_KEY})"
else
  echo -e "${YELLOW}  ⚠ No API credentials found — will build only, skip upload${NC}"
  echo "  Set APP_STORE_CONNECT_API_KEY and APP_STORE_CONNECT_ISSUER_ID to enable upload"
  UPLOAD_METHOD="none"
fi

echo -e "  ${GREEN}✓${NC} Flutter $(flutter --version --machine 2>/dev/null | grep -o '"frameworkVersion":"[^"]*"' | cut -d'"' -f4 || echo "installed")"

# ── Step 2: Clean & dependencies ──────────────────────────────────────────────
echo -e "\n${YELLOW}[2/6] Clean & dependencies...${NC}"

if [ -z "${SKIP_CLEAN:-}" ]; then
  echo -e "  Cleaning build artifacts..."
  flutter clean > /dev/null 2>&1
else
  echo -e "  Skipping clean (SKIP_CLEAN=1)"
fi

echo -e "  Installing Flutter packages..."
flutter pub get > /dev/null 2>&1
echo -e "  ${GREEN}✓${NC} Dependencies installed"

# ── Step 3: Tests ─────────────────────────────────────────────────────────────
echo -e "\n${YELLOW}[3/6] Tests...${NC}"

if [ -z "${SKIP_TESTS:-}" ]; then
  if flutter test 2>&1 | tail -1; then
    echo -e "  ${GREEN}✓${NC} Tests passed"
  else
    echo -e "  ${YELLOW}⚠ Tests failed — continuing with build${NC}"
  fi
else
  echo -e "  Skipped (SKIP_TESTS=1)"
fi

# ── Step 4: Build IPA ─────────────────────────────────────────────────────────
echo -e "\n${YELLOW}[4/6] Building IPA...${NC}"
echo -e "  This may take a few minutes..."

flutter build ipa \
  --release \
  --build-number="$BUILD_NUMBER" \
  --dart-define=VERBOSE_LOGGING=true \
  --obfuscate \
  --split-debug-info=build/app/debug-info \
  2>&1 | while IFS= read -r line; do
    # Show progress dots for long builds, full output on error
    if echo "$line" | grep -qi "error\|fail\|exception"; then
      echo -e "  ${RED}$line${NC}"
    fi
  done

# Verify IPA exists
if [ ! -f "$IPA_PATH" ]; then
  # Try to find it
  FOUND_IPA=$(find build/ios/ipa -name "*.ipa" -type f 2>/dev/null | head -1)
  if [ -n "$FOUND_IPA" ]; then
    mv "$FOUND_IPA" "$IPA_PATH"
  else
    echo -e "${RED}✗ IPA not found after build${NC}"
    echo "  Check build output above for errors"
    exit 1
  fi
fi

IPA_SIZE=$(du -h "$IPA_PATH" | cut -f1)
echo -e "  ${GREEN}✓${NC} IPA built: ${IPA_PATH} (${IPA_SIZE})"

# ── Step 5: Validate IPA ──────────────────────────────────────────────────────
echo -e "\n${YELLOW}[5/6] Validating IPA...${NC}"

if [ "$UPLOAD_METHOD" = "altool" ]; then
  xcrun altool --validate-app --type ios \
    -f "$IPA_PATH" \
    --apiKey "$APP_STORE_CONNECT_API_KEY" \
    --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID" \
    2>&1 | tail -5

  echo -e "  ${GREEN}✓${NC} Validation passed"
else
  echo -e "  Skipped (no credentials)"
fi

# ── Step 6: Upload to TestFlight ──────────────────────────────────────────────
echo -e "\n${YELLOW}[6/6] Uploading to TestFlight...${NC}"

if [ "$UPLOAD_METHOD" = "altool" ]; then
  xcrun altool --upload-app --type ios \
    -f "$IPA_PATH" \
    --apiKey "$APP_STORE_CONNECT_API_KEY" \
    --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID" \
    2>&1

  echo -e "\n${GREEN}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✓ Uploaded to TestFlight successfully!       ║${NC}"
  echo -e "${GREEN}║  Version: ${VERSION_NAME}+${BUILD_NUMBER}$(printf '%*s' $((25 - ${#VERSION_NAME} - ${#BUILD_NUMBER})) '')║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  echo "  Build will appear in App Store Connect in ~5-15 minutes."
  echo "  https://appstoreconnect.apple.com/apps"
else
  echo -e "  Skipped (no credentials)"
  echo -e "\n${GREEN}✓ Build complete:${NC} ${IPA_PATH}"
  echo "  Upload manually with:"
  echo "  xcrun altool --upload-app --type ios -f $IPA_PATH \\"
  echo "    --apiKey \"\$APP_STORE_CONNECT_API_KEY\" \\"
  echo "    --apiIssuer \"\$APP_STORE_CONNECT_ISSUER_ID\""
fi
