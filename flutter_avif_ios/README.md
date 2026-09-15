# flutter_avif_ios

The iOS implementation of flutter_avif supports Swift Package Manager and
CocoaPods. Flutter selects the installation method for the application.

## Native packaging

SwiftPM uses the `flutter-avif-ios` product in `ios/flutter_avif_ios/Package.swift`.
The binary target downloads the same XCFramework archive shipped with this
package, pinned to an upstream Git commit and verified with a SHA-256 checksum.
No fork-owned release or binary rebuild is required. When replacing the native
archive, update both the pinned URL and checksum in the manifest.

The Swift plugin and C linker helper are shared with CocoaPods. Registration
retains the FFI entry points used by Dart, including in optimized builds.
The SwiftPM package requires iOS 13 or later; CocoaPods retains its existing
platform declaration. The application's Flutter SDK can require a newer target.

## iOS integration validation

The existing example contains one integration test that checks native symbol
availability and loads a frame from its bundled AVIF fixture. Generate its iOS
host locally (the host does not need to be committed):

```sh
cd flutter_avif/example
flutter create --platforms=ios --no-pub .
flutter pub get
flutter test integration_test/ios_linking_test.dart -d <ios-simulator-id>
flutter build ios --release --no-codesign
```

The example overrides `flutter_avif_ios` to the repository package so these
commands exercise the checkout. To verify CocoaPods, add the following under
the example's existing `flutter:` section, regenerate the host in a clean
checkout, and run the same integration test and build with CocoaPods installed:

```yaml
  config:
    enable-swift-package-manager: false
```

This is an application-local test setting; do not commit it to the example.
