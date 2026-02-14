#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Preflight Gmail Check
# ─────────────────────────────────────────────────────────────────────────────
#
# Validates that the iOS simulator is ready for Gmail multi-account tests.
# Run this BEFORE `patrol test` to catch common issues early.
#
# Usage:
#   ./scripts/preflight_gmail_check.sh                # Auto-detect simulator
#   ./scripts/preflight_gmail_check.sh <device-uuid>  # Specific simulator
#
# Checks performed:
#   1. Simulator is booted
#   2. App is installed (com.soup.smokeLog)
#   3. Network connectivity
#   4. Patrol CLI is available
#
# Note: This script CANNOT verify Firebase Auth state from the host side.
# Auth state is checked at runtime by ensureGmailLoggedIn() in the test.
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
BUNDLE_ID="com.soup.smokeLog"

pass() { echo -e "  ${GREEN}✅ $1${NC}"; PASS_COUNT=$((PASS_COUNT + 1)); }
warn() { echo -e "  ${YELLOW}⚠️  $1${NC}"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { echo -e "  ${RED}❌ $1${NC}"; FAIL_COUNT=$((FAIL_COUNT + 1)); }

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  AshTrail — Gmail Preflight Check${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# ── 1. Find simulator ────────────────────────────────────────────────────────

echo -e "${CYAN}1. Simulator status${NC}"

DEVICE_ID="${1:-}"

if [ -z "$DEVICE_ID" ]; then
  # Auto-detect: prefer iPhone 16 Pro Max, then any booted iPhone
  DEVICE_ID=$(xcrun simctl list devices booted | grep "iPhone 16 Pro Max" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
  if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(xcrun simctl list devices booted | grep "iPhone" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
  fi
fi

if [ -z "$DEVICE_ID" ]; then
  fail "No booted iOS simulator found"
  echo ""
  echo -e "  ${YELLOW}Fix: Boot a simulator first:${NC}"
  echo -e "    xcrun simctl boot \"iPhone 16 Pro Max\""
  echo -e "    open -a Simulator"
  echo ""
else
  DEVICE_NAME=$(xcrun simctl list devices | grep "$DEVICE_ID" | sed 's/(.*//' | xargs || echo "Unknown")
  BOOTED=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c "Booted" || true)

  if [ "$BOOTED" -gt 0 ]; then
    pass "Simulator booted: ${DEVICE_NAME} (${DEVICE_ID})"
  else
    fail "Simulator exists but is NOT booted: ${DEVICE_NAME}"
    echo -e "    ${YELLOW}Fix: xcrun simctl boot $DEVICE_ID${NC}"
  fi
fi

# ── 2. App installation ──────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}2. App installation${NC}"

if [ -n "$DEVICE_ID" ]; then
  # Check if app is installed using get_app_container (more reliable than listapps)
  if xcrun simctl get_app_container "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null | grep -q "/"; then
    APP_PATH=$(xcrun simctl get_app_container "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null)
    pass "App installed: $BUNDLE_ID"
    echo -e "    Container: $APP_PATH"
  else
    warn "App NOT installed: $BUNDLE_ID"
    echo -e "    ${YELLOW}The app will be built and installed by 'patrol test'.${NC}"
    echo -e "    ${YELLOW}First run will take longer (~5-10 min for build).${NC}"
  fi
else
  warn "Skipped — no simulator found"
fi

# ── 3. Network connectivity ──────────────────────────────────────────────────

echo ""
echo -e "${CYAN}3. Network connectivity${NC}"

if curl -s --max-time 5 -o /dev/null -w "%{http_code}" https://www.googleapis.com 2>/dev/null | grep -q "200\|301\|302"; then
  pass "Network reachable (googleapis.com)"
else
  warn "Network may be unreachable — Firebase token refresh requires connectivity"
  echo -e "    ${YELLOW}Tests may still work with cached tokens on the simulator.${NC}"
fi

# ── 4. Patrol CLI ─────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}4. Patrol CLI${NC}"

export PATH="$HOME/.pub-cache/bin${PUB_CACHE:+:$PUB_CACHE/bin}:$PATH"

if command -v patrol &> /dev/null; then
  PATROL_VERSION=$(patrol --version 2>/dev/null || echo "unknown")
  pass "Patrol CLI available: $PATROL_VERSION"
else
  fail "Patrol CLI not found"
  echo -e "    ${YELLOW}Fix: dart pub global activate patrol_cli${NC}"
fi

# ── 5. Project dependencies ──────────────────────────────────────────────────

echo ""
echo -e "${CYAN}5. Project dependencies${NC}"

if [ -f "$PROJECT_ROOT/pubspec.lock" ]; then
  pass "pubspec.lock exists"
else
  warn "pubspec.lock missing — run 'flutter pub get' first"
fi

if [ -d "$PROJECT_ROOT/ios/Pods" ]; then
  pass "CocoaPods installed"
else
  warn "ios/Pods missing — run 'cd ios && pod install' first"
fi

# ── 6. Gmail auth persistence info ───────────────────────────────────────────

echo ""
echo -e "${CYAN}6. Gmail auth persistence${NC}"

if [ -n "$DEVICE_ID" ]; then
  echo -e "  ${BLUE}ℹ️  Auth state cannot be checked from the host.${NC}"
  echo -e "  ${BLUE}   ensureGmailLoggedIn() will detect it at runtime.${NC}"
  echo ""
  echo -e "  ${BOLD}First run on a fresh simulator:${NC}"
  echo -e "    Manual Google Sign-In required (one-time, ~15 seconds)."
  echo -e "    The session persists in the iOS Keychain across all future runs."
  echo ""
  echo -e "  ${BOLD}Subsequent runs:${NC}"
  echo -e "    Fully automatic — no manual interaction needed."
  echo ""
  echo -e "  ${BOLD}Re-seeding required after:${NC}"
  echo -e "    • ${RED}xcrun simctl erase${NC} (wipes entire simulator)"
  echo -e "    • ${RED}patrol test --full-isolation${NC} (uninstalls app + Keychain)"
  echo -e "    • ${RED}Xcode version upgrade${NC} (may reset simulators)"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
printf "  ${GREEN}Pass: %d${NC}  ${YELLOW}Warn: %d${NC}  ${RED}Fail: %d${NC}\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo -e "  ${RED}Preflight check FAILED — fix issues above before running tests.${NC}"
  exit 1
elif [ "$WARN_COUNT" -gt 0 ]; then
  echo -e "  ${YELLOW}Preflight check passed with warnings.${NC}"
  exit 0
else
  echo -e "  ${GREEN}All checks passed — ready to run Gmail tests!${NC}"
  echo ""
  echo -e "  ${BOLD}Run:${NC}"
  echo -e "    patrol test --target integration_test/gmail_multi_account_test.dart \\"
  if [ -n "$DEVICE_ID" ]; then
    echo -e "      --device \"$DEVICE_ID\""
  else
    echo -e "      --device \"iPhone 16 Pro Max\""
  fi
  exit 0
fi
