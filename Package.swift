// swift-tools-version:5.5
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
        .library(
             name: "RollbarNotifier",
             targets: ["RollbarNotifier"]),
        .library(
            name: "RollbarKSCrash",
            targets: ["RollbarKSCrash"]),
        .library(
            name: "RollbarPLCrashReporter",
            targets: ["RollbarPLCrashReporter"]),
        .library(
            name: "RollbarAUL",
            targets: ["RollbarAUL"]),
        .library(
            name: "RollbarSwift",
            targets: ["RollbarSwift"]),
        .library(
            name: "RollbarCocoaLumberjack",
            targets: ["RollbarCocoaLumberjack"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name:"KSCrash",
                 url: "https://github.com/kstenerud/KSCrash.git",
                 from: "1.15.25" //Package.Dependency.Requirement.branch("master")
        ),
        .package(name:"PLCrashReporter",
                 url: "https://github.com/microsoft/plcrashreporter.git",
                 from: "1.10.1" //Package.Dependency.Requirement.branch("master")
        ),
        .package(name:"CocoaLumberjack",
                 url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git",
                 from: "3.7.4" //Package.Dependency.Requirement.branch("master")
                ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RollbarCommon",
            dependencies: [
            ],
            path: "RollbarCommon/Sources/RollbarCommon",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarCommon/Sources/RollbarCommon/**"),
            ]
        ),

        .target(
            name: "RollbarDeploys",
            dependencies: [
                "RollbarCommon",
            ],
            path: "RollbarDeploys/Sources/RollbarDeploys",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarDeploys/Sources/RollbarDeploys/**"),
            ]
        ),

         .target(
             name: "RollbarNotifier",
             dependencies: [
                "RollbarCommon",
             ],
             path: "RollbarNotifier/Sources/RollbarNotifier",
             publicHeadersPath: "include",
             cSettings: [
                 .headerSearchPath("RollbarNotifier/Sources/RollbarNotifier/**"),
             ]
         ),

        .target(
            name: "RollbarKSCrash",
            dependencies: [
                "RollbarCommon",
                "KSCrash",
            ],
            path: "RollbarKSCrash/Sources/RollbarKSCrash",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarKSCrash/Sources/RollbarKSCrash/**"),
            ]
        ),

        .target(
            name: "RollbarPLCrashReporter",
            dependencies: [
                "RollbarCommon",
                .product(name: "CrashReporter", package: "PLCrashReporter"),
            ],
            path: "RollbarPLCrashReporter/Sources/RollbarPLCrashReporter",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarPLCrashReporter/Sources/RollbarPLCrashReporter/**"),
            ]
        ),

        .target(
            name: "RollbarAUL",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
            ],
            path: "RollbarAUL/Sources/RollbarAUL",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarAUL/Sources/RollbarAUL/**"),
            ]
        ),

        .target(
            name: "RollbarSwift",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
            ],
            path: "RollbarSwift/Sources/RollbarSwift",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarSwift/Sources/RollbarSwift/**"),
            ]
        ),

        .target(
            name: "RollbarCocoaLumberjack",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
                "CocoaLumberjack",
            ],
            path: "RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack/**"),
            ]
        ),
        
    ],
    swiftLanguageVersions: [
        SwiftVersion.v4,
        SwiftVersion.v4_2,
        SwiftVersion.v5,
    ]
)
