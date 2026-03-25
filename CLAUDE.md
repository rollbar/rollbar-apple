# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rollbar Apple SDK monorepo: Objective-C & Swift SDK for crash reporting, error logging, and deployment tracking across all Apple platforms (macOS 10.13+, iOS 11+, tvOS 11+, watchOS 4+).

## Build Commands

Each module has its own `Package.swift` for standalone builds, plus a root `Package.swift` for the full SDK.

```bash
# Build the entire SDK
swift build

# Build a single module (from its subdirectory)
cd RollbarCommon && swift build
cd RollbarNotifier && swift build
cd RollbarDeploys && swift build
cd RollbarAUL && swift build
```

## Testing

Tests run through the Xcode workspace, not `swift test`, because test targets are defined per-module and some require Xcode-specific infrastructure.

```bash
# Test a single module (e.g., RollbarCommon)
xcodebuild \
  -workspace RollbarSDK.xcworkspace \
  -scheme RollbarCommon \
  -derivedDataPath DerivedData \
  -enableCodeCoverage YES \
  build test \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO

# Test RollbarNotifier (includes RollbarCrash, RollbarReport)
xcodebuild \
  -workspace RollbarSDK.xcworkspace \
  -scheme RollbarNotifier \
  -derivedDataPath DerivedData \
  -enableCodeCoverage YES \
  build test \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO
```

Replace `-scheme RollbarCommon` with `RollbarNotifier`, `RollbarDeploys`, or `RollbarAUL` to test other modules.

For RollbarNotifier specifically, you can also run report-level tests via SPM:

```bash
cd RollbarNotifier && swift test --filter RollbarReportTests
```

## Module Architecture

```
RollbarCommon           (base module: DTOs, utilities, design patterns)
    |
    +-- RollbarNotifier (depends on RollbarCommon + RollbarCrash + RollbarReport)
    |     |
    |     +-- RollbarCrash   (C/C++/ObjC low-level crash monitors: signals, Mach, NSException, C++ exceptions, deadlock, zombie)
    |     +-- RollbarReport  (Swift crash report formatting/parsing)
    |
    +-- RollbarDeploys  (depends on RollbarCommon; deployment tracking)
    |
    +-- RollbarAUL      (depends on RollbarCommon + RollbarNotifier; Apple Unified Logging)
    |
    +-- RollbarCocoaLumberjack (depends on RollbarCommon + RollbarNotifier + CocoaLumberjack)

UnitTesting             (shared XCTest utilities, used by test targets)
```

## Key Conventions

- **Language mix:** Primarily Objective-C with Swift used in RollbarReport and newer code. RollbarCrash is C/C++.
- **DTO pattern:** Configuration and data structures use `RollbarDTO` base class hierarchy extensively. Internal access uses `RollbarDTO+Protected.h`.
- **Public headers:** Exposed via `include/` directories with `module.modulemap` files for clean module boundaries.
- **ObjC categories:** Follow `NS*+Rollbar` naming (e.g., `NSDate+Rollbar`, `NSDictionary+Rollbar`).
- **Test targets:** Each module has both Swift (`*Tests`) and Objective-C (`*Tests-ObjC`) test targets.
- **C++ standard:** C++17 with exception handling enabled (RollbarCrash).
- **Swift version:** 5 (tools-version 5.7.1).

## Distribution

The SDK ships via SwiftPM, CocoaPods (8 podspec files at repo root), and Carthage. Version is synchronized across all podspecs and `Package.swift`. Current version: 3.3.3.

## External Dependency

The only external dependency is CocoaLumberjack (>= 3.8.0), used only by the RollbarCocoaLumberjack module.
