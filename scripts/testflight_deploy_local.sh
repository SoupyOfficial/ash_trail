#!/bin/bash

# Local TestFlight deployment script
# This script mimics the GitHub Actions workflow for local testing

set -e  # Exit on error

echo "🚀 Starting local TestFlight deployment test..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUILD_NUMBER=${1:-$(date +%s)}  # Use provided build number or timestamp
BUNDLE_ID="com.soup.smokeLog"
TEAM_ID="DGQ5P34GS9"
SCHEME="Runner"
WORKSPACE="ios/Runner.xcworkspace"

echo -e "${YELLOW}Build number: ${BUILD_NUMBER}${NC}"

# Step 1: Check Flutter installation
echo -e "\n${YELLOW}Step 1: Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi
flutter --version

# Step 2: Install dependencies
echo -e "\n${YELLOW}Step 2: Installing Flutter dependencies...${NC}"
flutter pub get

# Step 3: Run tests (optional, can be skipped with SKIP_TESTS=1)
if [ -z "$SKIP_TESTS" ]; then
    echo -e "\n${YELLOW}Step 3: Running tests...${NC}"
    echo "Set SKIP_TESTS=1 to skip this step"
    flutter test || echo -e "${YELLOW}⚠️  Tests failed, continuing anyway...${NC}"
else
    echo -e "\n${YELLOW}Step 3: Skipping tests (SKIP_TESTS=1)${NC}"
fi

# Step 4: Install CocoaPods dependencies
echo -e "\n${YELLOW}Step 4: Installing CocoaPods dependencies...${NC}"
cd ios
if ! command -v pod &> /dev/null; then
    echo -e "${RED}❌ CocoaPods is not installed${NC}"
    echo "Install with: sudo gem install cocoapods"
    exit 1
fi
pod install --repo-update
cd ..

# Step 5: Build Flutter iOS app
echo -e "\n${YELLOW}Step 5: Building Flutter iOS app...${NC}"
echo "This may take several minutes..."
flutter build ios \
    --release \
    --build-number=$BUILD_NUMBER \
    --obfuscate \
    --split-debug-info=build/app/infos \
    --no-codesign

# Step 6: Create ExportOptions.plist (matching GitHub action)
echo -e "\n${YELLOW}Step 6: Creating ExportOptions.plist...${NC}"
cat > ios/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>signingCertificate</key>
  <string>Apple Distribution</string>
  <key>provisioningProfiles</key>
  <dict>
    <key>com.soup.smokeLog</key>
    <string>match AppStore com.soup.smokeLog</string>
  </dict>
  <key>teamID</key>
  <string>DGQ5P34GS9</string>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>thinning</key>
  <string>&lt;none&gt;</string>
</dict>
</plist>
EOF

echo "ExportOptions.plist created:"
cat ios/ExportOptions.plist

# Step 7: Archive with xcodebuild
echo -e "\n${YELLOW}Step 7: Archiving app with xcodebuild...${NC}"
cd ios
xcodebuild -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath ../build/ios/archive/Runner.xcarchive \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="Apple Distribution" \
    PROVISIONING_PROFILE_SPECIFIER="match AppStore com.soup.smokeLog" \
    DEVELOPMENT_TEAM=DGQ5P34GS9 \
    archive \
    2>&1 | tee ../build.log

# Step 8: Export archive to IPA
echo -e "\n${YELLOW}Step 8: Exporting archive to IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath ../build/ios/archive/Runner.xcarchive \
    -exportPath ../build/ios/ipa \
    -exportOptionsPlist ExportOptions.plist \
    -allowProvisioningUpdates \
    2>&1 | tee -a ../build.log

cd ..

# Step 9: Verify IPA was created
echo -e "\n${YELLOW}Step 9: Verifying IPA file...${NC}"
IPA_FILE=$(find build/ios/ipa -name "*.ipa" -type f | head -n 1)
if [ -n "$IPA_FILE" ]; then
    echo -e "${GREEN}✅ IPA file created successfully: $IPA_FILE${NC}"
    ls -lh "$IPA_FILE"
    # Rename to expected name if different
    if [ "$IPA_FILE" != "build/ios/ipa/ash_trail.ipa" ]; then
        mv "$IPA_FILE" build/ios/ipa/ash_trail.ipa
        echo "Renamed IPA to ash_trail.ipa"
    fi
else
    echo -e "${RED}❌ IPA file was not created${NC}"
    echo "Checking what files were created:"
    ls -R build/ios/ipa/ || echo "ipa directory not found"
    echo -e "\n${YELLOW}Last 50 lines of build.log:${NC}"
    tail -50 build.log
    exit 1
fi

# Step 10: Check for App Store Connect API credentials
echo -e "\n${YELLOW}Step 10: Checking for App Store Connect API credentials...${NC}"
if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_API_ISSUER_ID" ] || [ -z "$APP_STORE_CONNECT_API_KEY_BASE64" ]; then
    echo -e "${YELLOW}⚠️  App Store Connect API credentials not found in environment${NC}"
    echo "To upload, set these environment variables:"
    echo "  - APP_STORE_CONNECT_API_KEY_ID"
    echo "  - APP_STORE_CONNECT_API_ISSUER_ID"
    echo "  - APP_STORE_CONNECT_API_KEY_BASE64"
    echo ""
    echo "IPA file is ready at: build/ios/ipa/ash_trail.ipa"
    echo "You can upload it manually using Transporter app or xcrun altool"
    exit 0
fi

# Step 11: Upload to TestFlight
echo -e "\n${YELLOW}Step 11: Uploading to TestFlight...${NC}"

# Decode API key
mkdir -p ~/private_keys
API_KEY_FILE=~/private_keys/AuthKey_$APP_STORE_CONNECT_API_KEY_ID.p8
echo -n "$APP_STORE_CONNECT_API_KEY_BASE64" | base64 --decode > "$API_KEY_FILE"
chmod 600 "$API_KEY_FILE"

# Check if Fastlane is available
if ! command -v bundle &> /dev/null; then
    echo -e "${RED}❌ Bundler is not installed${NC}"
    echo "Install with: gem install bundler"
    exit 1
fi

# Install Fastlane if needed
cd ios
if [ ! -f "Gemfile.lock" ] || ! bundle check &> /dev/null; then
    echo "Installing Fastlane dependencies..."
    bundle install
fi

# Upload using Fastlane
echo "Uploading IPA to TestFlight using Fastlane..."
export APP_STORE_CONNECT_API_KEY_FILE="$API_KEY_FILE"
bundle exec fastlane upload_ipa ipa_path:"../build/ios/ipa/ash_trail.ipa"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Successfully uploaded to TestFlight!${NC}"
else
    echo -e "${RED}❌ Upload failed${NC}"
    cd ..
    rm -rf ~/private_keys
    exit 1
fi

cd ..

# Cleanup
echo -e "\n${YELLOW}Cleaning up...${NC}"
rm -rf ~/private_keys

echo -e "\n${GREEN}✅ Deployment test completed successfully!${NC}"
