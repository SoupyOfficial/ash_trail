#!/bin/bash

# =============================================================================
# Download missing dSYMs from App Store Connect & upload to Crashlytics
#
# Usage:
#   ./scripts/fix_missing_dsyms.sh                   # all recent builds
#   ./scripts/fix_missing_dsyms.sh --version 1.0.6   # specific version
#   ./scripts/fix_missing_dsyms.sh --latest 5         # last 5 builds
# =============================================================================

set -euo pipefail

# Colors
if [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# ── Configuration ──────────────────────────────────────────────────────────────
APP_ID="com.soup.smokeLog"
DSYM_DIR="build/dsyms_from_appstore"
VERSION_FILTER=""
LATEST_COUNT="10"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)  VERSION_FILTER="$2"; shift 2 ;;
    --latest)   LATEST_COUNT="$2"; shift 2 ;;
    *)          echo -e "${RED}Unknown arg: $1${NC}"; exit 1 ;;
  esac
done

# ── Step 1: Verify credentials ─────────────────────────────────────────────────
echo -e "${BLUE}Downloading dSYMs from App Store Connect${NC}"
echo ""

if [ -z "${APP_STORE_CONNECT_API_KEY:-}" ] || [ -z "${APP_STORE_CONNECT_ISSUER_ID:-}" ]; then
  echo -e "${RED}✗ Missing API credentials${NC}"
  echo "  Export APP_STORE_CONNECT_API_KEY and APP_STORE_CONNECT_ISSUER_ID"
  exit 1
fi

KEY_FILE="${HOME}/.private_keys/AuthKey_${APP_STORE_CONNECT_API_KEY}.p8"
if [ ! -f "$KEY_FILE" ]; then
  echo -e "${RED}✗ API key file not found: ${KEY_FILE}${NC}"
  exit 1
fi

echo -e "  ${GREEN}✓${NC} API credentials found"

# ── Step 2: Ensure fastlane is available ─────────────────────────────────────
echo -e "\n${YELLOW}[1/3] Checking fastlane...${NC}"

if ! command -v fastlane &> /dev/null; then
  if [ -f "ios/Gemfile" ]; then
    echo -e "  Installing fastlane via Bundler..."
    cd ios
    if ! command -v bundle &> /dev/null; then
      gem install bundler 2>/dev/null
    fi
    bundle install --quiet 2>/dev/null
    cd "$PROJECT_ROOT"
    FASTLANE_CMD="cd ios && bundle exec fastlane"
  else
    echo -e "  Installing fastlane..."
    gem install fastlane --no-document 2>/dev/null
    FASTLANE_CMD="fastlane"
  fi
else
  FASTLANE_CMD="fastlane"
fi

echo -e "  ${GREEN}✓${NC} fastlane available"

# ── Step 3: Download dSYMs ────────────────────────────────────────────────────
echo -e "\n${YELLOW}[2/3] Downloading dSYMs from App Store Connect...${NC}"

mkdir -p "$DSYM_DIR"

echo -e "  Downloading (this may take a minute)..."

# Use fastlane refresh_dsyms lane (handles API auth, download, and Crashlytics upload)
cd ios
LANE_ARGS="output_directory:${PROJECT_ROOT}/${DSYM_DIR}"
if [ -n "$VERSION_FILTER" ]; then
  LANE_ARGS="${LANE_ARGS} version:${VERSION_FILTER}"
fi

if bundle exec fastlane refresh_dsyms $LANE_ARGS 2>&1 | tee /tmp/dsym_download.log | tail -30; then
  echo -e "  ${GREEN}✓${NC} Download and Crashlytics upload complete"
else
  echo -e "  ${YELLOW}⚠ fastlane encountered an issue — checking results...${NC}"
fi
cd "$PROJECT_ROOT"

# Check what we got
DSYM_COUNT=$(find "$DSYM_DIR" -name "*.dSYM.zip" -o -name "*.dSYM" -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$DSYM_COUNT" -eq 0 ]; then
  echo -e "  ${YELLOW}⚠ No dSYMs downloaded — builds may still be processing${NC}"
  echo ""
  echo "  You can also download manually from App Store Connect:"
  echo "  1. Go to https://appstoreconnect.apple.com/apps"
  echo "  2. Select your app → TestFlight → Select each build"
  echo "  3. Click 'Download dSYM' and save to: ${DSYM_DIR}/"
  echo "  4. Re-run this script"
  echo ""
  
  # Check if any zips were downloaded  
  ZIP_COUNT=$(find "$DSYM_DIR" -name "*.zip" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$ZIP_COUNT" -gt 0 ]; then
    echo -e "  Found ${ZIP_COUNT} zip file(s) — extracting..."
    for zipfile in "$DSYM_DIR"/*.zip; do
      unzip -o "$zipfile" -d "$DSYM_DIR" 2>/dev/null || true
    done
    DSYM_COUNT=$(find "$DSYM_DIR" -name "*.dSYM" -type d 2>/dev/null | wc -l | tr -d ' ')
  fi
fi

echo -e "  Found ${DSYM_COUNT} dSYM bundle(s)"

# ── Step 4: Upload to Crashlytics ─────────────────────────────────────────────
echo -e "\n${YELLOW}[3/3] Uploading dSYMs to Firebase Crashlytics...${NC}"

UPLOAD_SCRIPT=$(find "${PWD}/ios/Pods/FirebaseCrashlytics" -name "upload-symbols" -type f 2>/dev/null | head -1)

if [ -z "$UPLOAD_SCRIPT" ]; then
  # Need to run pod install first
  echo -e "  Running pod install to get upload-symbols..."
  cd ios && pod install --repo-update 2>/dev/null && cd "$PROJECT_ROOT"
  UPLOAD_SCRIPT=$(find "${PWD}/ios/Pods/FirebaseCrashlytics" -name "upload-symbols" -type f 2>/dev/null | head -1)
fi

if [ -z "$UPLOAD_SCRIPT" ]; then
  echo -e "  ${RED}✗ upload-symbols not found${NC}"
  exit 1
fi

# Upload all downloaded dSYMs
UPLOAD_PATHS=""

# Add any .dSYM directories
while IFS= read -r dsym; do
  UPLOAD_PATHS="$UPLOAD_PATHS \"$dsym\""
done < <(find "$DSYM_DIR" -name "*.dSYM" -type d 2>/dev/null)

# Add any .zip files (upload-symbols handles zips)
while IFS= read -r zipfile; do
  UPLOAD_PATHS="$UPLOAD_PATHS \"$zipfile\""
done < <(find "$DSYM_DIR" -name "*.dSYM.zip" -type f 2>/dev/null)

if [ -n "$UPLOAD_PATHS" ]; then
  echo -e "  Uploading to Crashlytics..."
  eval "$UPLOAD_SCRIPT" -gsp "ios/Runner/GoogleService-Info.plist" -p ios $UPLOAD_PATHS 2>&1 | tail -5
  echo -e "  ${GREEN}✓${NC} Upload complete"
else
  echo -e "  ${YELLOW}⚠ No dSYMs to upload${NC}"
fi

# Also re-upload current build's dSYMs if they exist
if [ -d "build/ios/archive/Runner.xcarchive/dSYMs" ]; then
  echo -e "  Re-uploading current build dSYMs..."
  "$UPLOAD_SCRIPT" -gsp "ios/Runner/GoogleService-Info.plist" -p ios \
    "build/ios/archive/Runner.xcarchive/dSYMs" 2>&1 | tail -3
  echo -e "  ${GREEN}✓${NC} Current build dSYMs re-uploaded"
fi

if [ -d "build/app/debug-info" ]; then
  "$UPLOAD_SCRIPT" -gsp "ios/Runner/GoogleService-Info.plist" -p ios \
    "build/app/debug-info" 2>&1 | tail -3
  echo -e "  ${GREEN}✓${NC} Obfuscation symbols re-uploaded"
fi

echo -e "\n${GREEN}✓ Done!${NC}"
echo "  Crashlytics may take 10-15 minutes to process and match dSYMs."
echo "  Check: https://console.firebase.google.com/project/smokelog-17303/crashlytics"
