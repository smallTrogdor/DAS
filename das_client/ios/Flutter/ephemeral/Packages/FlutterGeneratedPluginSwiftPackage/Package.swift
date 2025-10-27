// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "battery_plus", path: "/Users/nicolasvidoni/.pub-cache/hosted/pub.dev/battery_plus-6.2.1/ios/battery_plus"),
        .package(name: "device_info_plus", path: "/Users/nicolasvidoni/.pub-cache/hosted/pub.dev/device_info_plus-11.2.0/ios/device_info_plus"),
        .package(name: "package_info_plus", path: "/Users/nicolasvidoni/.pub-cache/hosted/pub.dev/package_info_plus-8.1.2/ios/package_info_plus"),
        .package(name: "path_provider_foundation", path: "/Users/nicolasvidoni/.pub-cache/hosted/pub.dev/path_provider_foundation-2.4.1/darwin/path_provider_foundation"),
        .package(name: "volume_controller", path: "/Users/nicolasvidoni/.pub-cache/hosted/pub.dev/volume_controller-3.3.1/ios/volume_controller"),
        .package(name: "integration_test", path: "/Users/nicolasvidoni/fvm/versions/3.27.1/packages/integration_test/ios/integration_test")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "battery-plus", package: "battery_plus"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "volume-controller", package: "volume_controller"),
                .product(name: "integration-test", package: "integration_test")
            ]
        )
    ]
)
