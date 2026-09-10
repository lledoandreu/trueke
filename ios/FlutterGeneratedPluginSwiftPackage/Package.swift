// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [],
    targets: [
        .target(name: "FlutterGeneratedPluginSwiftPackage", dependencies: [])
    ]
)
