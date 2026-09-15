# flutter_avif_macos

macOS implementation of flutter_avif.

## Native dependencies

Supports Swift Package Manager (Flutter 3.44 or later, macOS 10.15 or later)
and CocoaPods. Flutter generates the adjacent `FlutterFramework` package when
integrating the plugin into a macOS application.

Both integrations use the same Swift registration and C linking helper. The
helper retains all seven native functions used by Dart FFI, including when
optimization and dead-code stripping are enabled. The Dart API is unchanged.

SwiftPM downloads the existing universal arm64/x86_64 XCFramework from an
immutable commit in this repository and verifies its SHA-256 checksum. No
separate release asset or fork is required. When updating the binary, update
both the pinned URL and checksum in `macos/flutter_avif_macos/Package.swift`.
CocoaPods continues to use the archive included in this package.

## Regression checks

When validating a release in a macOS Flutter host:

- Check plugin registration and all seven FFI symbols with SwiftPM enabled.
- Decode a bundled AVIF image and advance/reset/dispose an animated decoder.
- Repeat with CocoaPods and with a release build to check dead-code stripping.
- Cover both Apple silicon and Intel hosts.
