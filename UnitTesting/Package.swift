// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnitTesting",
    platforms: [
        // Oldest targeted platform versions that are supported by this product.
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "UnitTesting",
            targets: ["UnitTesting"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../RollbarCommon"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "UnitTesting",
            dependencies: [
                "RollbarCommon",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/UnitTesting/**"),
                //                .headerSearchPath("Sources/RollbarNotifier"),
                //                .headerSearchPath("Sources/RollbarNotifier/include"),
                //                .headerSearchPath("Sources/RollbarNotifier/DTOs"),
                
                //                .define("DEFINES_MODULE"),
            ]
        ),
        .testTarget(
            name: "UnitTestingTests",
            dependencies: ["UnitTesting"]),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v4,
        SwiftVersion.v4_2,
        SwiftVersion.v5,
    ]
)
