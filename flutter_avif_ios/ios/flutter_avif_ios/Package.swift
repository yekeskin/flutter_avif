// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_avif_ios",
    platforms: [.iOS("13.0")],
    products: [
        .library(name: "flutter-avif-ios", targets: ["flutter_avif_ios"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "FlutterAvifBinary",
            // The same archive shipped with CocoaPods, pinned to upstream source.
            url: "https://raw.githubusercontent.com/yekeskin/flutter_avif/0ada6f0659b1144f9f7842b22f666ce637ac2785/flutter_avif_ios/ios/FlutterAvif.xcframework.zip",
            checksum: "777c0d4137bad8e8afba371238fe2a422d8bb7c041d72f4a5d196bc4cf763d4e"
        ),
        .target(
            name: "flutter_avif_linker",
            dependencies: ["FlutterAvifBinary"],
            publicHeadersPath: "include"
        ),
        .target(
            name: "flutter_avif_ios",
            dependencies: [
                "flutter_avif_linker",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
