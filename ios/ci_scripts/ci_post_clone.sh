#!/bin/sh
# =============================================================================
# Xcode Cloud Post-Clone Script
#
# This script runs after Xcode Cloud clones the repo but before the build.
# It installs Flutter, runs `flutter pub get` to generate Generated.xcconfig,
# and runs `pod install` to generate the Pods workspace and xcfilelists.
# =============================================================================

set -e

echo "=== Xcode Cloud Post-Clone ==="
echo "PWD: $PWD"
echo "CI_WORKSPACE: $CI_WORKSPACE"

# Navigate to the project root (ci_scripts lives inside ios/)
cd "$CI_WORKSPACE"

# ── Install Flutter ──────────────────────────────────────────────────────────
# Clone Flutter SDK if not already available
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter SDK..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

echo "Flutter version: $(flutter --version)"

# ── Flutter pub get (generates Generated.xcconfig) ───────────────────────────
echo "Running flutter pub get..."
flutter pub get

# ── Install CocoaPods ────────────────────────────────────────────────────────
if ! command -v pod &> /dev/null; then
  echo "Installing CocoaPods..."
  gem install cocoapods
fi

echo "CocoaPods version: $(pod --version)"

# ── Pod install (generates Pods/ and xcfilelists) ─────────────────────────────
echo "Running pod install..."
cd ios
pod install

echo "=== Post-Clone Complete ==="
