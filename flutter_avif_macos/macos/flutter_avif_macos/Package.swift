// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "flutter_avif_macos",
  platforms: [.macOS("10.15")],
  products: [
    .library(name: "flutter-avif-macos", targets: ["flutter_avif_macos"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "flutter_avif_macos",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        "flutter_avif_macos_linker",
      ]
    ),
    .target(
      name: "flutter_avif_macos_linker",
      dependencies: ["FlutterAvifMacosBinary"],
      publicHeadersPath: "include"
    ),
    .binaryTarget(
      name: "FlutterAvifMacosBinary",
      url: "https://raw.githubusercontent.com/yekeskin/flutter_avif/513c918e4f881a1c08600149a56ac2e604863f79/flutter_avif_macos/macos/FlutterAvif.xcframework.zip",
      checksum: "2ce64bb80b28bbbca779253a5ad88e9efac61c0d142b547b149fe6f2539c4e6c"
    ),
  ]
)
