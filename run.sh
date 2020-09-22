#! /bin/bash

# This script is based on Jacob Van Order's answer on apple dev forums https://devforums.apple.com/message/971277
# See also http://spin.atomicobject.com/2011/12/13/building-a-universal-framework-for-ios/ for the start


# To get this to work with a Xcode 6 Cocoa Touch Framework, create Framework
# Then create a new Aggregate Target. Throw this script into a Build Script Phrase on the Aggregate

set -e

######################
# Options
######################
LIB_DIR="/usr/local/lib/icomoon-swift"
BUILD_DIR="/tmp/icomoon-build"
FRAMEWORK_NAME="Icomoon"
SIMULATOR_ARCHIVE="$BUILD_DIR/$FRAMEWORK_NAME.framework-iphoneos.xcarchive"
DEVICE_ARCHIVE="$BUILD_DIR/$FRAMEWORK_NAME.framework-iphonesimulator.xcarchive"
CATALYST_ARCHIVE="$BUILD_DIR/$FRAMEWORK_NAME.framework-catalyst.xcarchive"
MAIN_DIR="$(pwd)"
RESULT_FRAMEWORK="$(pwd)/${FRAMEWORK_NAME}.xcframework"


######################
# Prepare
######################

rm -rf "${RESULT_FRAMEWORK}"
rm -rf "${BUILD_DIR}"

mkdir -p "${BUILD_DIR}"

cp -r "${LIB_DIR}/." "${BUILD_DIR}"


######################
# Unpack font archive
######################

unzip "$1" -d "${BUILD_DIR}"


######################
# Parse svg
######################

cd "${BUILD_DIR}"

SVG_FONT=$(ls ./fonts/*.svg)
TTF_FONT=$(ls ./fonts/*.ttf)

python parse.py "$SVG_FONT" > "${FRAMEWORK_NAME}/Font.swift"
cp "$TTF_FONT" "${FRAMEWORK_NAME}/font.ttf"


######################
# Build Frameworks
######################

# Device slice.
xcodebuild archive -workspace "$FRAMEWORK_NAME.xcworkspace" -scheme "$FRAMEWORK_NAME" -configuration Release -destination 'generic/platform=iOS' -archivePath "$SIMULATOR_ARCHIVE" SKIP_INSTALL=NO

# Simulator slice.
xcodebuild archive -workspace "$FRAMEWORK_NAME.xcworkspace" -scheme "$FRAMEWORK_NAME" -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath "$DEVICE_ARCHIVE" SKIP_INSTALL=NO

# Mac Catalyst slice.
xcodebuild archive -workspace "$FRAMEWORK_NAME.xcworkspace" -scheme "$FRAMEWORK_NAME" -configuration Release -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' -archivePath "$CATALYST_ARCHIVE" SKIP_INSTALL=NO


######################
# Copy files Framework
#####################

#cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"
#cp -r "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/." "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule"


######################
# Make XCFramework
######################

xcodebuild -create-xcframework -framework "$SIMULATOR_ARCHIVE/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" -framework "$DEVICE_ARCHIVE/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" -framework "$CATALYST_ARCHIVE/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" -output "$RESULT_FRAMEWORK"

open "$MAIN_DIR"
