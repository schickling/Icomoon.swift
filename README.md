# Icomoon.swift
Use your custom **Icomoon fonts with Swift** - auto-generates type safe enums for each icon

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
