// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_avif_ios",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // Dynamic, so the Rust functions Dart looks up by name stay exported in archived builds:
        // linked statically into the app binary, they are stripped when archiving.
        .library(name: "flutter-avif-ios", type: .dynamic, targets: ["flutter_avif_ios"])
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
            name: "flutter_avif_ios",
            dependencies: [
                "FlutterAvif",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [
                .headerSearchPath("include/flutter_avif_ios")
            ]
        )
    ]
)
