#!/bin/bash
set -euo pipefail

# Build the Swift package in release mode
swift build -c release

# Paths
BUILD_DIR=".build/release"
APP_NAME="FloatingKeyboard"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"

# Clean previous bundle
rm -rf "${APP_BUNDLE}"

# Create .app bundle structure
mkdir -p "${MACOS}"

# Copy binary
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS}/${APP_NAME}"

# Copy Info.plist
cp "Sources/FloatingKeyboard/Info.plist" "${CONTENTS}/Info.plist"

echo "✅ App bundle created at: ${APP_BUNDLE}"
echo ""
echo "To run: open ${APP_BUNDLE}"
echo ""
echo "⚠️  Remember to grant Accessibility permission in:"
echo "   System Settings > Privacy & Security > Accessibility"
