// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RollbarSwift",
    platforms: [
        // Oldest targeted platform versions that are supported by this product.
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RollbarSwift",
            targets: ["RollbarSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../RollbarCommon"),
        .package(path: "../RollbarNotifier"),
        .package(name: "UnitTesting",
                 path: "../UnitTesting"
                ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RollbarSwift",
            dependencies: ["RollbarCommon", "RollbarNotifier",],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarSwift/**"),
//                .headerSearchPath("Sources/RollbarSwift"),
//                .headerSearchPath("Sources/RollbarSwift/include"),
//                .headerSearchPath("Sources/RollbarSwift/DTOs"),
                
//                .define("DEFINES_MODULE"),
            ]
        ),
        .testTarget(
            name: "RollbarSwiftTests",
            dependencies: [
                "UnitTesting",
                "RollbarSwift",
            ]
        ),
        .testTarget(
            name: "RollbarSwiftTests-ObjC",
            dependencies: ["RollbarSwift"],
            cSettings: [
                .headerSearchPath("Tests/RollbarSwiftTests-ObjC/**"),
//                .headerSearchPath("Sources/RollbarNotifier"),
//                .headerSearchPath("Sources/RollbarNotifier/include"),
//                .headerSearchPath("Sources/RollbarNotifier/DTOs"),
                
//                .define("DEFINES_MODULE"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v4,
        SwiftVersion.v4_2,
        SwiftVersion.v5,
    ]
)
