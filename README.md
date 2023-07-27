# Scan

![CI Status](https://github.com/BottleRocketStudios/iOS-Scan/actions/workflows/main.yml/badge.svg)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager)

**Scan** provides a simple lightweight abstraction around AVFoundation and the iOS camera APIs. There are a few main goals:

## Usage

### 1. Construct a `CaptureSession`

The `MetadataCaptureSession` is the main object that will be interfaced with when scanning for QR and various types of bar codes. Once started, the `MetadataCaptureSession` will report back any detected objects through it's `outputStream` property. This stream can be immediately iterated over after initialization using a `Task` in the simplest of cases. For example:


```swift
self.metadataCaptureSession = try .defaultVideo(capturing: metadataObjectTypes, previewVideoGravity: .resizeAspectFill)

Task {
    for await metadataObject in metadataCaptureSession.outputStream {
        if let readableObject = metadataObject as? MachineReadableMetadataObject {
            // Handle recognized object
        }
    }
}
```

There are various configuration options available on the `MetadataCaptureSession` and it's properties, intended to mirror the configuration available in the `AVFoundation` types they are based on. One key configuration option is the `rectOfInterest`. This can be updated using the below sample code. Note that the `CGRect` passed in here requires no manual transformations, it is given in the `view` coordinate space.

```swift
metadataCaptureSession.setViewRectOfInterest(newRectOfInterest)
```

## Example

Clone the repo:

```bash
git clone https://github.com/BottleRocketStudios/iOS-Scan.git
```

From here, you can open up `Scan.xcworkspace` and run the examples:

### Example Targets

* **Example**
    * `ExampleApp.swift`
        * A small SwiftUI example demonstrating potential use cases for QR and Barcode scanning

## Requirements

* iOS 14.0+
* tvOS 14.0+
* macOS 11+
* Swift 5.7

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/BottleRocketStudios/iOS-Scan.git", from: "1.0.0")
]
```

## Author

[Bottle Rocket Studios](https://www.bottlerocketstudios.com/)

## License

Scan is available under the Apache 2.0 license. See the LICENSE.txt file for more info.

## Contributing

See the [CONTRIBUTING] document. Thank you, [contributors]!

[CONTRIBUTING]: CONTRIBUTING.md
[contributors]: https://github.com/BottleRocketStudios/iOS-Scan/graphs/contributors
