// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RollbarPLCrashReporter",
    platforms: [
        // Oldest targeted platform versions that are supported by this product.
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RollbarPLCrashReporter",
            targets: ["RollbarPLCrashReporter"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name:"RollbarCommon",
                 path: "../RollbarCommon"
        ),
        .package(name:"PLCrashReporter",
                 url: "https://github.com/microsoft/plcrashreporter.git",
                 Package.Dependency.Requirement.branch("master")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RollbarPLCrashReporter",
            dependencies: ["RollbarCommon", "PLCrashReporter"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarPLCrashReporter/**"),
                //                .headerSearchPath("Sources/RollbarPLCrashReporter"),
                //                .headerSearchPath("Sources/RollbarPLCrashReporter/include"),
                //                .headerSearchPath("Sources/RollbarPLCrashReporter/DTOs"),
                
                //                .define("DEFINES_MODULE"),
            ]
        ),
        .testTarget(
            name: "RollbarPLCrashReporterTests",
            dependencies: ["RollbarPLCrashReporter"],
            cSettings: [
                .headerSearchPath("Tests/RollbarKSCrashTests/**"),
                //                .headerSearchPath("Sources/RollbarKSCrash"),
                //                .headerSearchPath("Sources/RollbarKSCrash/include"),
                //                .headerSearchPath("Sources/RollbarKSCrash/DTOs"),
                
                //                .define("DEFINES_MODULE"),
            ]
        ),
        .testTarget(
            name: "RollbarPLCrashReporterTests-ObjC",
            dependencies: ["RollbarPLCrashReporter"],
            cSettings: [
                .headerSearchPath("Tests/RollbarPLCrashReporterTests-ObjC/**"),
                //                .headerSearchPath("Sources/RollbarKSCrash"),
                //                .headerSearchPath("Sources/RollbarKSCrash/include"),
                //                .headerSearchPath("Sources/RollbarKSCrash/DTOs"),
                
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
