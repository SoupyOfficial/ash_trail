# iOS Simulator Setup Guide

## Current Status

✅ **RESOLVED** - iOS simulators are now working with iOS 26.2

### Active Simulators:
- **iPhone 13 Pro** (ID: 84A035C2-4E2B-48D4-BF80-24262D549621) - iOS 26.2
- **iPhone 16 Pro Max** (ID: 0A875592-129B-40B6-A072-A0C0CA94AED3) - iOS 26.2

## Issue History

Previously had **memory allocation issues** with the iOS Simulator service. This was resolved by completely resetting the CoreSimulator framework.

## Quick Diagnostics

```bash
flutter doctor -v
```

This will show:
- ✅ Xcode installation status
- ✅ iOS deployment target
- ❌ iOS simulator availability (due to memory issue)

## Solutions

### Complete CoreSimulator Reset (Most Effective)

If simulators fail with memory errors (Error Code 12: "Cannot allocate memory"):

```bash
# 1. Free up system memory
sudo purge

# 2. Kill all simulator processes
killall -9 Simulator com.apple.CoreSimulator.CoreSimulatorService SimulatorTrampoline 2>/dev/null

# 3. Complete CoreSimulator reset
rm -rf ~/Library/Developer/CoreSimulator

# 4. Wait for rebuild (3-5 seconds)
sleep 3

# 5. Verify simulators are available
xcrun simctl list devices
```

### Creating Specific Simulators with iOS 26.2

After reset, create the required simulators:

```bash
# Create iPhone 13 Pro with iOS 26.2
xcrun simctl create "iPhone 13 Pro" com.apple.CoreSimulator.SimDeviceType.iPhone-13-Pro com.apple.CoreSimulator.SimRuntime.iOS-26-2

# Create iPhone 16 Pro Max with iOS 26.2
xcrun simctl create "iPhone 16 Pro Max" com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max com.apple.CoreSimulator.SimRuntime.iOS-26-2

# Boot both simulators
xcrun simctl boot 84A035C2-4E2B-48D4-BF80-24262D549621
xcrun simctl boot 0A875592-129B-40B6-A072-A0C0CA94AED3

# Open Simulator app
open -a Simulator

# Verify with Flutter
flutter devices
```

### Clean Up Unwanted Simulators

Remove all other simulators to keep only what you need:

```bash
# Delete all unavailable simulators
xcrun simctl delete unavailable

# Delete all shutdown simulators except specific ones
xcrun simctl list devices -j | jq -r '.devices | to_entries[] | .value[] | select(.state == "Shutdown") | .udid' | grep -v "84A035C2-4E2B-48D4-BF80-24262D549621\|0A875592-129B-40B6-A072-A0C0CA94AED3" | xargs -I {} xcrun simctl delete {} 2>/dev/null
```

### List Available Device Types and Runtimes

Before creating simulators:

```bash
# List available device types
xcrun simctl list devicetypes | grep "iPhone"

# List available runtimes
xcrun simctl list runtimes

# List all current devices
xcrun simctl list devices
```

### Memory Optimization (Quick Fix)

If experiencing memory issues:

```bash
# Check memory usage
vm_stat | head -n 3

# Free up memory
sudo purge

# Close browsers, IDEs, and heavy applications
# Then restart the simulator service
killall -9 com.apple.CoreSimulator.CoreSimulatorService
killall -9 com.apple.CoreSimulator.Logger

# Check devices
flutter devices
```

## Running Tests on iOS Simulator

With the active simulators:

```bash
# List all connected devices
flutter devices

# Run on iPhone 13 Pro (iOS 26.2)
flutter run -d 84A035C2-4E2B-48D4-BF80-24262D549621

# Run on iPhone 16 Pro Max (iOS 26.2)
flutter run -d 0A875592-129B-40B6-A072-A0C0CA94AED3

# Run unit tests on iOS simulator
flutter test test/ -d 84A035C2-4E2B-48D4-BF80-24262D549621

# Run integration tests
flutter test integration_test/database_integration_test.dart -d 84A035C2-4E2B-48D4-BF80-24262D549621

# Or use device names (if unique)
flutter run -d "iPhone 13 Pro"
flutter run -d "iPhone 16 Pro Max"
```

## Recommended System Requirements

For comfortable iOS development:
- **RAM**: 8GB minimum (16GB+ recommended)
- **Disk Space**: 20GB free for Xcode and simulators
- **CPU**: Multi-core processor

## Alternative: Physical iOS Device

If simulator issues persist, use a physical iPhone:

```bash
# Connect iOS device via USB
# Trust the device on the phone

# Check connection
flutter devices

# Run on device
flutter run -d <device-id>
```

## Troubleshooting Steps

1. **Check current simulator status**
   ```bash
   xcrun simctl list devices
   flutter devices
   ```

2. **Free up system memory**
   ```bash
   # Check memory usage
   vm_stat | head -n 3
   
   # Free memory
   sudo purge
   ```

3. **Restart simulator services**
   ```bash
   killall -9 Simulator com.apple.CoreSimulator.CoreSimulatorService
   sleep 3
   open -a Simulator
   ```

4. **Complete reset if needed**
   ```bash
   killall -9 Simulator com.apple.CoreSimulator.CoreSimulatorService
   rm -rf ~/Library/Developer/CoreSimulator
   sleep 3
   xcrun simctl list devices
   ```

5. **Check Flutter setup**
   ```bash
   flutter doctor -v
   flutter pub get
   ```

6. **Verify Podfile is current**
   ```bash
   cd ios
   pod deintegrate
   pod install --repo-update
   cd ..
   ```

## Common Error Solutions

### "Cannot allocate memory" (Error Code 12)
This indicates the CoreSimulator service can't initialize the device set:

```bash
# Solution: Complete CoreSimulator reset
sudo purge
killall -9 com.apple.CoreSimulator.CoreSimulatorService
rm -rf ~/Library/Developer/CoreSimulator
sleep 5
xcrun simctl list devices
```

### "Unable to determine SimDeviceSet"
The device set is corrupted:

```bash
# Remove and rebuild
rm -rf ~/Library/Developer/CoreSimulator/Devices
rm -rf ~/Library/Developer/CoreSimulator/Caches
killall -9 com.apple.CoreSimulator.CoreSimulatorService
xcrun simctl list devices
```

## Next Steps

With working iOS simulators (iPhone 13 Pro & iPhone 16 Pro Max on iOS 26.2):

1. **Run unit tests**: 
   ```bash
   flutter test test/
   ```

2. **Run integration tests**: 
   ```bash
   flutter test integration_test/ -d 84A035C2-4E2B-48D4-BF80-24262D549621
   ```

3. **Run the app**: 
   ```bash
   flutter run -d "iPhone 13 Pro"
   # or
   flutter run -d "iPhone 16 Pro Max"
   ```

4. **Use VS Code device selector** to switch between simulators

The integration tests require a simulator or physical device with platform plugins fully initialized. macOS desktop doesn't have iOS platform support.

## Quick Reference

```bash
# Boot both simulators
xcrun simctl boot 84A035C2-4E2B-48D4-BF80-24262D549621 && \
xcrun simctl boot 0A875592-129B-40B6-A072-A0C0CA94AED3

# Launch Simulator app
open -a Simulator && flutter emulators --launch apple_ios_simulator

# Check what's running
flutter devices

# Shutdown all simulators
xcrun simctl shutdown all

# Delete a specific simulator
xcrun simctl delete <UDID>

# Erase all content from a simulator (reset to factory)
xcrun simctl erase <UDID>
```
