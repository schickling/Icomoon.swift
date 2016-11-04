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
SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/iphonesimulator/${FRAMEWORK_NAME}.framework"
DEVICE_LIBRARY_PATH="${BUILD_DIR}/iphoneos/${FRAMEWORK_NAME}.framework"
UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/iphoneuniversal"
FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"
RESULT_FRAMEWORK="$(pwd)/${FRAMEWORK_NAME}.framework"


######################
# Prepare
######################

rm -rf "${RESULT_FRAMEWORK}"
rm -rf "${BUILD_DIR}"

mkdir -p "${BUILD_DIR}"
mkdir "${UNIVERSAL_LIBRARY_DIR}"
mkdir "${FRAMEWORK}"

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

xcodebuild -sdk iphonesimulator -configuration "Release" clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/iphonesimulator

xcodebuild -sdk iphoneos -configuration "Release" clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/iphoneos


######################
# Copy files Framework
######################

cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"
cp -r "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/." "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule"


######################
# Make fat universal binary
######################

lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}"


######################
# Copy the result to current dir and open in finder
######################

cp -r "${FRAMEWORK}" "${RESULT_FRAMEWORK}"

open "${RESULT_FRAMEWORK}"
