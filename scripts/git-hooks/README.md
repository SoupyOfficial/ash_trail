# Git Hooks

This directory contains git hooks that align with the GitHub Actions workflow.

## Pre-commit Hook
- Runs `flutter pub get` to install dependencies
- Runs `flutter test` to execute all tests
- Runs `flutter analyze` to check for code issues

## Pre-push Hook (main/mvp branches only)
- Runs `flutter pub get`
- Runs `flutter test`  
- Runs `cd ios && pod install --repo-update` to install CocoaPods dependencies
- Runs `flutter build ios --release --no-codesign` to verify iOS build

These hooks help catch issues locally before they reach CI/CD.
