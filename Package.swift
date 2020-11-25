// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RollbarSDK",
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
            name: "RollbarCommon",
            targets: ["RollbarCommon"]),
        .library(
            name: "RollbarDeploys",
            targets: ["RollbarDeploys"]),
        // .library(
        //     name: "RollbarNotifier",
        //     targets: ["RollbarNotifier"]),
    ],
//    dependencies: [
//        // Dependencies declare other packages that this package depends on.
//        // .package(url: /* package url */, from: "1.0.0"),
//        .package(path: "RollbarCommon"),
//    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.


        .target(
            name: "RollbarCommon",
            dependencies: [],
            path: "RollbarCommon/Sources/RollbarCommon",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarCommon/Sources/RollbarCommon/**"),
            ]
        ),
        .testTarget(
            name: "RollbarCommonTests",
            dependencies: ["RollbarCommon"],
            path: "RollbarCommon/Tests/RollbarCommonTests",
            cSettings: [
                .headerSearchPath("RollbarCommon/Tests/RollbarCommonTests/**"),
            ]
        ),
       .testTarget(
           name: "RollbarCommonTests-ObjC",
           dependencies: ["RollbarCommon"],
           path: "RollbarCommon/Tests/RollbarCommonTests-ObjC",
           cSettings: [
               .headerSearchPath("RollbarCommon/Tests/RollbarCommonTests-ObjC/**"),
           ]
       ),

        .target(
            name: "RollbarDeploys",
            dependencies: ["RollbarCommon",],
            path: "RollbarDeploys/Sources/RollbarDeploys",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarDeploys/Sources/RollbarDeploys/**"),
            ]
        ),
        .testTarget(
            name: "RollbarDeploysTests",
            dependencies: ["RollbarDeploys"],
            path: "RollbarDeploys/Tests/RollbarDeploysTests",
            cSettings: [
                .headerSearchPath("RollbarDeploys/Tests/RollbarDeploysTests/**"),
            ]
        ),
        .testTarget(
            name: "RollbarDeploysTests-ObjC",
            dependencies: ["RollbarDeploys"],
            path: "RollbarDeploys/Tests/RollbarDeploysTests-ObjC",
            cSettings: [
                .headerSearchPath("RollbarDeploys/Tests/RollbarDeploysTests-ObjC/**"),
            ]
        ),


        // .target(
        //     name: "RollbarNotifier",
        //     dependencies: ["RollbarCommon",],
        //     path: "RollbarNotifier/Sources/RollbarNotifier",
        //     publicHeadersPath: "include",
        //     cSettings: [
        //         .headerSearchPath("RollbarNotifier/Sources/RollbarNotifier/**"),
        //     ]
        // ),
        // .testTarget(
        //     name: "RollbarNotifierTests",
        //     dependencies: ["RollbarNotifier"],
        //     path: "RollbarNotifier/Sources/RollbarNotifierTests",
        //     cSettings: [
        //         .headerSearchPath("RollbarNotifier/Tests/RollbarNotifierTests/**"),
        //     ]
        // ),
        // .testTarget(
        //     name: "RollbarNotifierTests-ObjC",
        //     dependencies: ["RollbarNotifier"],
        //     path: "RollbarNotifier/Sources/RollbarNotifierTests-ObjC",
        //     cSettings: [
        //         .headerSearchPath("RollbarNotifier/Tests/RollbarNotifierTests-ObjC/**"),
        //     ]
        // ),

    ],
    swiftLanguageVersions: [
        SwiftVersion.v4,
        SwiftVersion.v4_2,
        SwiftVersion.v5,
    ]
)
