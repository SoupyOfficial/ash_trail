#!/bin/bash

# Simplified TestFlight deployment script using flutter build ipa
# This is faster for testing the upload process

set -e

echo "🚀 Simplified TestFlight deployment test..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BUILD_NUMBER=${1:-$(date +%s)}

echo -e "${YELLOW}Build number: ${BUILD_NUMBER}${NC}"

# Step 1: Build IPA using Flutter (handles everything automatically)
echo -e "\n${YELLOW}Step 1: Building IPA with Flutter...${NC}"
flutter build ipa \
    --release \
    --build-number=$BUILD_NUMBER \
    --obfuscate \
    --split-debug-info=build/app/infos

# Step 2: Verify IPA was created
echo -e "\n${YELLOW}Step 2: Verifying IPA file...${NC}"
IPA_FILE="build/ios/ipa/ash_trail.ipa"
if [ -f "$IPA_FILE" ]; then
    echo -e "${GREEN}✅ IPA file created: $IPA_FILE${NC}"
    ls -lh "$IPA_FILE"
else
    echo -e "${RED}❌ IPA file not found at $IPA_FILE${NC}"
    echo "Checking build directory:"
    find build/ios -name "*.ipa" 2>/dev/null || echo "No IPA files found"
    exit 1
fi

# Step 3: Check for upload credentials
echo -e "\n${YELLOW}Step 3: Checking for App Store Connect API credentials...${NC}"
if [ -z "$APP_STORE_CONNECT_API_KEY_ID" ] || [ -z "$APP_STORE_CONNECT_API_ISSUER_ID" ] || [ -z "$APP_STORE_CONNECT_API_KEY_BASE64" ]; then
    echo -e "${YELLOW}⚠️  App Store Connect API credentials not found${NC}"
    echo "IPA file is ready at: $IPA_FILE"
    echo "Set these environment variables to upload:"
    echo "  - APP_STORE_CONNECT_API_KEY_ID"
    echo "  - APP_STORE_CONNECT_API_ISSUER_ID"
    echo "  - APP_STORE_CONNECT_API_KEY_BASE64"
    exit 0
fi

# Step 4: Upload using Fastlane
echo -e "\n${YELLOW}Step 4: Uploading to TestFlight using Fastlane...${NC}"

# Decode API key
mkdir -p ~/private_keys
API_KEY_FILE=~/private_keys/AuthKey_$APP_STORE_CONNECT_API_KEY_ID.p8
echo -n "$APP_STORE_CONNECT_API_KEY_BASE64" | base64 --decode > "$API_KEY_FILE"
chmod 600 "$API_KEY_FILE"

# Install Fastlane if needed
cd ios
if ! bundle check &> /dev/null; then
    echo "Installing Fastlane dependencies..."
    bundle install
fi

# Upload
export APP_STORE_CONNECT_API_KEY_FILE="$API_KEY_FILE"
bundle exec fastlane upload_ipa ipa_path:"../$IPA_FILE"

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
rm -rf ~/private_keys

echo -e "\n${GREEN}✅ Deployment completed successfully!${NC}"
