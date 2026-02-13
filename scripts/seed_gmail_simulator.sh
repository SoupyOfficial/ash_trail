#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Seed Gmail Simulator
# ─────────────────────────────────────────────────────────────────────────────
#
# One-time convenience script to seed a simulator with Gmail test accounts.
# After seeding, all subsequent `patrol test` runs will skip the native
# Google Sign-In flow automatically.
#
# Usage:
#   ./scripts/seed_gmail_simulator.sh                # Auto-detect simulator
#   ./scripts/seed_gmail_simulator.sh <device-uuid>  # Specific simulator
#
# What this does:
#   1. Boots the target simulator (if not already booted)
#   2. Opens Simulator.app so you can see the screen
#   3. Builds and runs the Gmail smoke test (G0)
#   4. Prompts you to complete manual Google Sign-In in the simulator
#   5. Verifies the session persisted
#
# After completion, the Firebase refresh token is stored in the iOS Keychain
# and will survive across all future test runs (until the simulator is erased
# or --full-isolation is used).
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
cd "$PROJECT_ROOT"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  AshTrail — Gmail Simulator Seeding${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# ── Find simulator ────────────────────────────────────────────────────────────

DEVICE_ID="${1:-}"

if [ -z "$DEVICE_ID" ]; then
  # Auto-detect: prefer iPhone 16 Pro Max, then any available iPhone
  DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 16 Pro Max" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
  if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
  fi
fi

if [ -z "$DEVICE_ID" ]; then
  echo -e "${RED}❌ No iOS simulator found.${NC}"
  echo -e "   Create one in Xcode → Window → Devices and Simulators"
  exit 1
fi

DEVICE_NAME=$(xcrun simctl list devices | grep "$DEVICE_ID" | sed 's/(.*//' | xargs || echo "Unknown")
echo -e "${GREEN}📱 Target: ${DEVICE_NAME} (${DEVICE_ID})${NC}"

# ── Boot simulator ────────────────────────────────────────────────────────────

BOOTED=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c "Booted" || true)
if [ "$BOOTED" -eq 0 ]; then
  echo -e "${BLUE}🚀 Booting simulator...${NC}"
  xcrun simctl boot "$DEVICE_ID" || true
fi

# Open Simulator.app so the device is visible — this is the key step that
# prevents xcodebuild from creating a cloned simulator for UI testing.
echo -e "${BLUE}📲 Opening Simulator.app (prevents xcodebuild clone)...${NC}"
open -a Simulator

echo -e "${BLUE}⏳ Waiting for simulator to finish booting...${NC}"
xcrun simctl bootstatus "$DEVICE_ID" -b 2>/dev/null || true
sleep 3
echo -e "${GREEN}✅ Simulator is ready${NC}"
echo ""

# ── Ensure dependencies ──────────────────────────────────────────────────────

export PATH="$HOME/.pub-cache/bin${PUB_CACHE:+:$PUB_CACHE/bin}:$PATH"

if ! command -v patrol &> /dev/null; then
  echo -e "${YELLOW}Installing patrol_cli...${NC}"
  dart pub global activate patrol_cli 3.6.0
fi

echo -e "${BLUE}📦 flutter pub get${NC}"
flutter pub get --suppress-analytics 2>/dev/null

# ── Instructions ──────────────────────────────────────────────────────────────

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Manual Sign-In Instructions${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  The Gmail multi-account test will now build and launch."
echo -e "  When the ASWebAuthenticationSession sheet appears:"
echo ""
echo -e "  ${BOLD}Account 4:${NC}"
echo -e "    1. Tap ${BOLD}Continue${NC} in the Safari sheet"
echo -e "    2. Enter: ${GREEN}ashtraildev3@gmail.com${NC}"
echo -e "    3. Password: ${GREEN}AshTestPass123!${NC}"
echo -e "    4. Complete any 2FA / permission prompts"
echo ""
echo -e "  ${BOLD}Account 5:${NC}"
echo -e "    1. When prompted again, tap ${BOLD}Continue${NC}"
echo -e "    2. Enter: ${GREEN}soupsterx@live.com${NC}"
echo -e "    3. Password: ${GREEN}Achieve23!${NC}"
echo -e "    4. Complete sign-in"
echo ""
echo -e "  The test polls every 2s and proceeds ${BOLD}immediately${NC} once"
echo -e "  sign-in completes (no fixed wait)."
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
echo ""

read -p "$(echo -e ${YELLOW}"Press Enter to start the test build..."${NC}) "

# ── Run Gmail test ────────────────────────────────────────────────────────────

echo ""
echo -e "${BLUE}🧪 Running Gmail multi-account test suite...${NC}"
echo -e "${BLUE}   (First build may take 5-10 minutes)${NC}"
echo ""

# Clear previous diagnostics
rm -f /tmp/ash_trail_test_diagnostics.log
mkdir -p /tmp/ash_trail_screenshots

LOG_FILE="$PROJECT_ROOT/build/logs/seed_gmail.log"
mkdir -p "$(dirname "$LOG_FILE")"

if patrol test \
  --target integration_test/gmail_multi_account_test.dart \
  --device "$DEVICE_ID" \
  --debug \
  --verbose 2>&1 | tee "$LOG_FILE" | tail -30; then
  RESULT=0
else
  RESULT=1
fi

# ── Verify seeding ────────────────────────────────────────────────────────────

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

DIAG_LOG="/tmp/ash_trail_test_diagnostics.log"
if [ -f "$DIAG_LOG" ]; then
  PERSISTED=$(grep -c "Persisted session found" "$DIAG_LOG" 2>/dev/null || true)
  SIGN_IN=$(grep -c "Sign-in completed" "$DIAG_LOG" 2>/dev/null || true)
  TOKEN_OK=$(grep -c "token refresh OK\|Firebase token refresh OK" "$DIAG_LOG" 2>/dev/null || true)

  echo -e "  ${CYAN}Diagnostics:${NC}"
  echo -e "    Persisted sessions detected: ${PERSISTED}"
  echo -e "    Manual sign-ins completed:   ${SIGN_IN}"
  echo -e "    Token refreshes OK:          ${TOKEN_OK}"
  echo ""

  if [ "$PERSISTED" -gt 0 ] || [ "$TOKEN_OK" -gt 0 ]; then
    echo -e "  ${GREEN}✅ Seeding SUCCEEDED${NC}"
    echo ""
    echo -e "  All subsequent runs will be fully automatic:"
    echo -e "    patrol test --target integration_test/gmail_multi_account_test.dart \\"
    echo -e "      --device \"$DEVICE_ID\""
  elif [ "$SIGN_IN" -gt 0 ]; then
    echo -e "  ${GREEN}✅ Sign-in completed — seeding likely succeeded${NC}"
    echo -e "  Run the test again to verify persistence."
  else
    echo -e "  ${YELLOW}⚠️  Could not confirm seeding from diagnostics.${NC}"
    echo -e "  Check: $DIAG_LOG"
  fi
else
  if [ "$RESULT" -eq 0 ]; then
    echo -e "  ${GREEN}✅ Test passed — seeding likely succeeded${NC}"
  else
    echo -e "  ${RED}❌ Test failed — check output above for errors${NC}"
    echo -e "  Full log: $LOG_FILE"
  fi
fi

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# ── Reminder ──────────────────────────────────────────────────────────────────

echo -e "${YELLOW}${BOLD}Remember:${NC}"
echo -e "  • Do NOT run 'xcrun simctl erase' on this simulator"
echo -e "  • Do NOT use '--full-isolation' for Gmail tests"
echo -e "  • The session persists across reboots and Xcode restarts"
echo ""

exit $RESULT
