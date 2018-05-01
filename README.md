# Icomoon.swift
Use your **Icomoon fonts with Swift** - auto-generates type safe enums for each icon

## Installation

1. [Download](https://github.com/optonaut/Icomoon.swift/archive/master.zip) or clone this repo.
2. Run `make`. That's it. (You can run `make uninstall` to uninstall.)

## Usage

### Generate framework

![](https://raw.githubusercontent.com/optonaut/Icomoon.swift/master/resources/readme.png)

1. Download your font file from Icomoon (usally called `icomoon.zip`)
2. Run `icomoon-swift icomoon.zip`
3. Add the generated `Icomoon.framework` to your Xcode project and create a [copy-frameworks](https://github.com/Carthage/Carthage#if-youre-building-for-ios) step in your build phases

### API

The generated framework extends `UIFont`, `UIImage` and `String` and generates an `enum Icon`. Cases are automatically created based on the name on Icomoon. (Example: `my-search` becomes `.MySearch`)

```swift
import Icomoon

let searchIcon = UILabel()
searchIcon.text = String.iconWithName(.MySearch)
searchIcon.font = UIFont.iconOfSize(30)
```

### Strip Architectures

![](https://imgur.com/a/43bb3Dh.jpg)

In order to submit to App Store, you'll need to automatically strip unsupported Architectures. Add this Run Script to you Build Phases, AFTER *Embed Frameworks*:

```
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

EXTRACTED_ARCHS=()

for ARCH in $ARCHS
do
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done

echo "Merging extracted architectures: ${ARCHS}"
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"

echo "Replacing original executable with thinned version"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
```
