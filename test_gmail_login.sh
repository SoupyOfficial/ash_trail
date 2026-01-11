#!/bin/bash

# Gmail Login Testing Script for iOS Simulator
# This script helps test Gmail login functionality on the iOS simulator

set -e

PROJECT_DIR="/Volumes/Jacob-SSD/Projects/ash_trail"
DEVICE_ID="0A875592-129B-40B6-A072-A0C0CA94AED3"
LOG_FILE="$PROJECT_DIR/gmail_test_$(date +%Y%m%d_%H%M%S).log"

echo "======================================"
echo "Gmail Login Testing Script"
echo "======================================"
echo ""
echo "Device ID: $DEVICE_ID"
echo "Log File: $LOG_FILE"
echo ""

# Step 1: Verify simulator is running
echo "[1/5] Checking simulator status..."
SIMULATOR_STATUS=$(xcrun simctl list devices | grep "$DEVICE_ID")
if [[ $SIMULATOR_STATUS == *"Booted"* ]]; then
    echo "✅ Simulator is running"
else
    echo "⚠️  Simulator not booted, attempting to boot..."
    xcrun simctl boot "$DEVICE_ID" || echo "Simulator already booted or other issue"
fi
echo ""

# Step 2: Verify configurations
echo "[2/5] Verifying Firebase and Google Sign-In configurations..."
echo ""

echo "GoogleService-Info.plist:"
plutil -p "$PROJECT_DIR/ios/Runner/GoogleService-Info.plist" | grep -E "BUNDLE_ID|CLIENT_ID|REVERSED_CLIENT_ID" | head -3

echo ""
echo "Info.plist URL Scheme:"
plutil -p "$PROJECT_DIR/ios/Runner/Info.plist" | grep -A 5 "CFBundleURLSchemes" | head -4

echo ""

# Step 3: Clean build
echo "[3/5] Building Flutter app for simulator..."
cd "$PROJECT_DIR"
echo "Running flutter run..."
echo ""

# Step 4: Run with detailed logging
echo "[4/5] Deploying app and capturing logs..."
echo "Starting app deployment and log capture..."
echo ""

# Run flutter and capture logs in background
flutter run -d "$DEVICE_ID" -v > "$LOG_FILE" 2>&1 &
FLUTTER_PID=$!

echo "Flutter app is building and deploying (PID: $FLUTTER_PID)"
echo "Logs being saved to: $LOG_FILE"
echo ""
echo "======================================"
echo "TESTING INSTRUCTIONS FOR GMAIL LOGIN:"
echo "======================================"
echo ""
echo "1. Wait for the app to fully load on the simulator"
echo "2. Look for the Login screen with 'Continue with Google' button"
echo "3. Click 'Continue with Google'"
echo "4. If a web view opens:"
echo "   - You may see a Google Sign-In page"
echo "   - Or it might ask to use 'Google' app"
echo "   - Or a Safari browser window with Google login"
echo ""
echo "5. Enter your test Gmail credentials:"
echo "   - Email: <your-test-gmail-account>"
echo "   - Password: <your-test-password>"
echo ""
echo "6. Grant any requested permissions"
echo ""
echo "7. Observe what happens:"
echo "   ✅ Expected: Should navigate to home/dashboard screen"
echo "   ❌ Issue: Stays on login screen"
echo "   ❌ Issue: Shows error message"
echo "   ❌ Issue: Shows 'Access Denied' or 'Invalid Client' error"
echo ""
echo "In another terminal, you can watch logs with:"
echo "  flutter logs"
echo ""
echo "Or monitor the build log with:"
echo "  tail -f $LOG_FILE"
echo ""

# Wait for user to complete testing
sleep 5

echo ""
echo "[5/5] App should now be running on simulator"
echo ""
echo "Monitor these log messages:"
echo "  ✅ 'Starting Google sign-in' - flow initiated"
echo "  ✅ 'Google sign-in successful' - authentication succeeded"
echo "  ❌ 'Google sign-in failed' - authentication failed"
echo "  ❌ 'Failed to obtain Google access token' - token error"
echo ""
echo "Testing setup complete. Check simulator for the app!"
echo "Press Ctrl+C to stop monitoring when done."
echo ""
