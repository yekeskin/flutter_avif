// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_avif_macos",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        // Dynamic, so the Rust functions Dart looks up by name stay exported in archived builds:
        // linked statically into the app binary, they are stripped when archiving.
        .library(name: "flutter-avif-macos", type: .dynamic, targets: ["flutter_avif_macos"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "FlutterAvif",
            path: "FlutterAvif.xcframework.zip"
        ),
        .target(
            name: "flutter_avif_macos",
            dependencies: [
                "FlutterAvif",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [
                .headerSearchPath("include/flutter_avif_macos")
            ]
        )
    ]
)
