#!/bin/bash
# Run All Component-Style Integration Tests
# Passes all test targets to a single `patrol test` invocation so the
# simulator stays alive for the entire run.
#
# Usage:
#   ./scripts/run_all_e2e.sh                        # Run all tests in one patrol invocation
#   ./scripts/run_all_e2e.sh login_flow_test.dart    # Run a single test by name
#   ./scripts/run_all_e2e.sh test1.dart test2.dart   # Run specific tests
#   ./scripts/run_all_e2e.sh --list                  # List all test files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test files — order-independent. Each test dynamically detects app state
# (Welcome vs Home) and performs the setup it needs (login, sign-out, etc.).
# Listed alphabetically to match Patrol/XCTest execution order.
TESTS=(
  accounts_test.dart
  analytics_test.dart
  auth_test.dart
  history_test.dart
  home_screen_test.dart
  logging_test.dart
  login_flow_test.dart
  multi_account_test.dart
  navigation_test.dart
)

# ── Parse args ────────────────────────────────────────────────────────────────
SELECTED_TESTS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list)
      echo "Available integration tests:"
      for t in "${TESTS[@]}"; do echo "  $t"; done
      exit 0 ;;
    *) SELECTED_TESTS+=("$1"); shift ;;
  esac
done

if [ ${#SELECTED_TESTS[@]} -gt 0 ]; then
  TESTS=("${SELECTED_TESTS[@]}")
fi

# ── Setup ─────────────────────────────────────────────────────────────────────
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  AshTrail — Run All Integration Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

export PATH="$HOME/.pub-cache/bin${PUB_CACHE:+:$PUB_CACHE/bin}:$PATH"

# Ensure patrol CLI
if ! command -v patrol &> /dev/null; then
  echo -e "${YELLOW}Installing patrol_cli 3.6.0...${NC}"
  dart pub global activate patrol_cli 3.6.0
else
  dart pub global activate patrol_cli 3.6.0 2>/dev/null
fi

# Dependencies
echo -e "${BLUE}📦 flutter pub get${NC}"
flutter pub get --suppress-analytics

# Clear previous diagnostics log & screenshots
rm -f "$PROJECT_ROOT/logs/ash_trail_test_diagnostics.log"
rm -rf /tmp/ash_trail_screenshots
mkdir -p /tmp/ash_trail_screenshots
mkdir -p "$PROJECT_ROOT/logs"

# ── Find & boot iOS simulator (prevent patrol from cloning) ───────────────────
# Patrol / xcodebuild will clone a new simulator if the target device isn't
# already booted AND visible in Simulator.app. We guarantee both here so the
# test run reuses the existing sim.
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 16 Pro Max" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
if [ -z "$DEVICE_ID" ]; then
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
fi
if [ -z "$DEVICE_ID" ]; then
  echo -e "${RED}❌ No iOS simulator found.${NC}"
  exit 1
fi

DEVICE_NAME=$(xcrun simctl list devices available | grep "$DEVICE_ID" | sed 's/(.*//' | xargs)
echo -e "${GREEN}📱 Simulator: ${DEVICE_NAME} (${DEVICE_ID})${NC}"

# Boot if needed
BOOTED=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c "Booted" || true)
if [ "$BOOTED" -eq 0 ]; then
  echo -e "${BLUE}🚀 Booting simulator...${NC}"
  xcrun simctl boot "$DEVICE_ID" || true
fi

# Open Simulator.app so the device is visible — this is the key step that
# prevents xcodebuild from creating a cloned simulator for UI testing.
echo -e "${BLUE}📲 Opening Simulator.app...${NC}"
open -a Simulator

# Wait until the simulator is fully booted and responsive
echo -e "${BLUE}⏳ Waiting for simulator to finish booting...${NC}"
xcrun simctl bootstatus "$DEVICE_ID" -b 2>/dev/null || true
sleep 2
echo -e "${GREEN}✅ Simulator is ready${NC}"

# Pre-build Pods framework once (shared across all tests)
echo -e "${BLUE}🔧 Pre-building Pods-Runner-RunnerUITests framework...${NC}"
cd ios && xcodebuild -project Pods/Pods.xcodeproj \
    -target "Pods-Runner-RunnerUITests" \
    -configuration Debug \
    -sdk iphonesimulator \
    -quiet \
    BUILD_DIR="../build/ios_integ/Build" \
    CONFIGURATION_BUILD_DIR="../build/ios_integ/Build/Products/Debug-iphonesimulator" \
    2>&1 | tail -3
cd ..
echo -e "${GREEN}✅ Framework built${NC}"
echo ""

# ── Run tests ─────────────────────────────────────────────────────────────────
LOG_DIR="$PROJECT_ROOT/build/logs"
mkdir -p "$LOG_DIR"

TOTAL=${#TESTS[@]}
START_TIME=$(date +%s)

# Build --target flags, validating each file exists
TARGET_FLAGS=()
MISSING=0
for TEST in "${TESTS[@]}"; do
  TARGET="integration_test/$TEST"
  if [ ! -f "$TARGET" ]; then
    echo -e "${RED}❌ File not found: $TARGET${NC}"
    MISSING=$((MISSING + 1))
  else
    TARGET_FLAGS+=(--target "$TARGET")
  fi
done

if [ ${#TARGET_FLAGS[@]} -eq 0 ]; then
  echo -e "${RED}❌ No valid test files to run.${NC}"
  exit 1
fi

VALID_COUNT=$(( (${#TARGET_FLAGS[@]} / 2) ))
echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
echo -e "${BLUE}🧪 Running $VALID_COUNT test(s) in a single patrol invocation${NC}"
for TEST in "${TESTS[@]}"; do
  if [ -f "integration_test/$TEST" ]; then
    echo -e "   • $TEST"
  fi
done
echo -e "${BLUE}⏱️  $(date '+%H:%M:%S')${NC}"
echo ""

LOG_FILE="$LOG_DIR/patrol_run_all.log"

# ── Start video recording ──────────────────────────────────────────────────
VIDEO_FILE="$LOG_DIR/test_recording.mp4"
echo -e "${BLUE}🎬 Recording video → $VIDEO_FILE${NC}"
xcrun simctl io "$DEVICE_ID" recordVideo "$VIDEO_FILE" &
VIDEO_PID=$!

if patrol test "${TARGET_FLAGS[@]}" --device "$DEVICE_ID" --debug --verbose 2>&1 | tee "$LOG_FILE" | tail -40; then
  RESULT=0
else
  RESULT=1
fi

# ── Stop video recording ──────────────────────────────────────────────────
if kill -0 "$VIDEO_PID" 2>/dev/null; then
  kill -INT "$VIDEO_PID" 2>/dev/null
  wait "$VIDEO_PID" 2>/dev/null || true
  echo -e "${GREEN}🎬 Video saved → $VIDEO_FILE${NC}"
else
  echo -e "${YELLOW}⚠️  Video recording ended early${NC}"
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Results   ${MINUTES}m ${SECONDS}s${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "  Tests:   $VALID_COUNT target(s)"
if [ "$MISSING" -gt 0 ]; then
  echo -e "  ${RED}Missing: $MISSING file(s) not found${NC}"
fi
if [ "$RESULT" -eq 0 ]; then
  echo -e "  ${GREEN}Status:  ✅ ALL PASSED${NC}"
else
  echo -e "  ${RED}Status:  ❌ FAILURE (see log for details)${NC}"
  echo -e "${YELLOW}Log: $LOG_FILE${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

# ── Collect screenshots ──────────────────────────────────────────────────────
SCREENSHOT_DIR="$PROJECT_ROOT/build/screenshots"
rm -rf "$SCREENSHOT_DIR"
mkdir -p "$SCREENSHOT_DIR"
SCREENSHOT_COUNT=$(find /tmp/ash_trail_screenshots -name '*.png' 2>/dev/null | wc -l | tr -d ' ')
if [ "$SCREENSHOT_COUNT" -gt 0 ]; then
  cp /tmp/ash_trail_screenshots/*.png "$SCREENSHOT_DIR/" 2>/dev/null
  echo -e "  ${GREEN}📸 Screenshots: $SCREENSHOT_COUNT captured → build/screenshots/${NC}"
else
  echo -e "  ${YELLOW}📸 Screenshots: none captured${NC}"
fi

# ── Diagnostics log ──────────────────────────────────────────────────────────
# The test helper writes to <project_root>/logs/ (or /tmp/ as fallback).
DIAG_LOG="$PROJECT_ROOT/logs/ash_trail_test_diagnostics.log"
DIAG_LOG_TMP="/tmp/ash_trail_test_diagnostics.log"
if [ ! -f "$DIAG_LOG" ] && [ -f "$DIAG_LOG_TMP" ]; then
  DIAG_LOG="$DIAG_LOG_TMP"
fi
if [ -f "$DIAG_LOG" ]; then
  echo ""
  echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
  echo -e "${CYAN}  Test Diagnostics (dialog handler log)${NC}"
  echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
  cat "$DIAG_LOG"
  echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
  # Copy to build/logs for easy access
  cp "$DIAG_LOG" "$LOG_DIR/test_diagnostics.log"
  echo -e "  ${YELLOW}Also saved to: $LOG_DIR/test_diagnostics.log${NC}"
fi

exit $RESULT
