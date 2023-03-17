# CHANGELOG

## Release Notes

### 3.0.0

- The crash collection and reporting mechanism has been redone from scratch, this now allows us to:
  - Collect and report all types of crashes together with full stack trace information.
  - Provide useful error descriptions on all use cases that trigger crash reporting.
  - Produce Swift diagnostics for all types of crashes.
  - Format full crash reports with extra diagnostic information.
- Initialization has been simplified:
  - Crash collection is now fully automatic.
  - There's no need to investigate and select crash reporting libraries in order to make an informed decision, this is all now automatic and works much better than before.
- The Swift Demo has been greatly expanded and enhanced:
  - Demo: Expanded Swift Demo with more types of crashes.
  - Demo: Prevent optimizer from erasing crashing funcs that result in noops.
  - Demo: Allow users to change access token from the Demo UI.
- Fixed unsuppressed logging, and suppress it by default.
- Remove faulty Out of Memory detection.
- Remove RollbarPLCrashReporter library.
- Never symbolicate main executable frames.
- Don't send mach diagnostics as title, let the server figure it out.
- Add Rollbar branding to the Readme.
- Minimum Swift version is now 5.0 and minimum deployment is 14.0.
- Cleaned up podspecs, added publishing script.
- Remove old, non-working examples and low quality demos.

### 2.4.0

- New SDK Demos for iOS Swift and Objective-C.
- Fixed a rare crash during JSON serialization.
- More robust and more flexible SDK reconfigurability.
- Thread safety by design.
- Fully independent configurability of each individual instance of a logger.
- Flexible and standardized rate limiting control (both locally configured and server enforced).
- Structured payload storage based on Sqlite instead of a flat text file.
- Improved local payload logging based on developer options of a config object. Separately for all the incoming vs transmitted vs dropped payloads.
- Improved internal diagnostics of the SDK with reach debug build assertions.
- Ooptimized payload modification implementation.
- Improved performance of the RollbarThread.
- Improved internal SDK recovery from any unforeseen internal SDK exceptions/errors (including during processing of totally custom user-specified data within a payload).
- General codebase code quality and maintainability improvements.
- A higher level of code reuse.
- And more...

### 2.3.4

- fix: resolve #218 - Failsafe to ensure obj is not nil when creating dict literal

### 2.3.3

- fix: resolve #190 - Fix Cocoapods build warnings in RollbarNotifier
- fix: resolve #191 - Fix Cocoapods build warnings in RollbarCommon
- fix: resolve #192 - Fix SonarCloud detected bugs

### 2.3.2

- fix: resolve #186 - Fix RollbarCommon Cocopods warnings

### 2.3.1

- fix: resolve #183 - Fix broken Cocoapods build

### 2.3.0

- feat: Detection of possible Out-of-Memory issues
- fix: resolve #166 - v2.2.4 spams to log with NSLog on iOS
- fix: resolve #176 - Rollbar crashes when device runs out of memory
- fix: resolve #180 - SonarCloud: address current reliability issues

### 2.2.4

- fix:   resolve #161 - Fix type conversion within RollbarAulEntitySnapper.m
- chore: resolve #109 - ARM64 slice excluded from cocoapods spec?

### 2.2.3

- fix: resolve #154 - Fix Cocoapods builds.

### 2.2.2

- fix: resolve #154 - Fix Cocoapods builds.

### 2.2.1

- fix: resolve #154 - Fix Cocoapods builds.

### 2.2.0

- feat: resolve #148 - MemTel: Implement the memory usage Telemetry auto-collection based on the config options.
- feat: resolve #147 - MemTel: Implement necessary Telemetry auto-collection options config settings with the first available option being the memory usage collection.
- feat: resolve #146 - MemTel: Define custom data fields for a Manual Telemetry event to keep the collected data. Implement helpers to manage that data.
- test: resolve #148 - MemTel: Add unit tests.

### 2.1.0

- feat:  resolve #141 - Apply developer options of the persisted payload when sending the payload
- feat:  resolve #133 - Implement RollbarCocoaLumberjack module
- test:  resolve #134 - Implement unit tests for RollbarCocoaLumberjack
- fix:   resolve #136 - RollbarPLCrashReporter.init() no longer available
- test:  resolve #140 - Factor out common SDK unit testing API
- chore: resolve #112 - Upgrade to the latest PLCrashReporter 1.0.1
- docs:  resolve #138 - Move current SDK documentation from readme.io to the repo
- docs:  resolve #139 - Document new RollbarCocoaLumberjack module

### 2.0.3

- docs:  resolve #122 - Update RollbarCommon public API doc comments so they are properly rendered by Xcode Quick Help
- docs:  resolve #124 - Update RollbarDeploys public API doc comments so they are properly rendered by Xcode Quick Help
- docs:  resolve #126 - Update RollbarSwift, RollbarAUL, RollbarPLCrashReporter, and RollbarKSCrash public API doc comments so they are properly rendered by Xcode Quick Help
- docs:  resolve #127 - Update RollbarNotifier public API doc comments so they are properly rendered by Xcode Quick Help
- chore: resolve #114 - Consolidate destination parameters for samples
- chore: resolve #113 - Consolidate destination parameters for unit tests

### 2.0.2

- fix: resolve #110 - Xcode autocomplete for Swift expects person.id, but codebase expects person.ID
- chore: resolve #118 - Remove source file header comments from RollbarCommon

### 2.0.1

- moving from Beta to GA

### 2.0.0-beta.23

- refactor: upgraded KSCRash to v1.15.25
- refactor: upgraded PLCrashReporter to v1.10.0
- chore: updated macosAppObjC Xcode scheme
- chore: update SonarCloud build wrapper
- chore: update SonarCloud scanner

### 2.0.0-beta.22

### 2.0.0-beta.21

- feat: new RollbarAUL module is code complete

### 2.0.0-beta.15

- fix: resolve #81 - SPM - Resolving Package Graph Failed

### 2.0.0-beta.14

- feat: allocated new RollbarAUL module project
- fix: resolve #72 - Rollbar pods 2.0.0-beta.10 not all published

### 2.0.0-beta.13

### 2.0.0-beta.12

### 2.0.0-beta.11

- fix: resolve #72 - Rollbar pods 2.0.0-beta.10 not all published

### 2.0.0-beta.10

- fix: resolve #66 - App terminated due to signal 5 instantiating RollbarPLCrashCollector

### 2.0.0-beta8

- fix: point all the Cocoapods podspecs to proper documentation site.

### 2.0.0-beta7

### 2.0.0-beta6

### 2.0.0-beta5

### 2.0.0-beta4

- fix: RollbarSwift.podspec

### 2.0.0-beta3

- feat: added RollbarSwift

### 2.0.0-beta2

- feat: added new developer option: suppressSdkInfoLogging

### 2.0.0-beta1 - comparing to Rollbar-iOS

- feat: added RollbarPLCrashReporter module
- feat: added RollbarKSCrash module
- feat: added explicit reporting of NSErrors
- feat: defined default scrub fields
- refactor: split out RollbarCommon, RollbarNotifier, RollbarDeploys
- refactor: added use of lightweight generics
- refactor: added use of nullability attributes
- refactor: removed RollbarConfiguration and replaced it with RollbarConfig
- refactor: changed WhitelistFields into SafeListFields when it comes to the RollbarScrubbingOptions
- refactor: removed all the deprecated API
- refactor: replaced NSString-like log level parameters in RollbarLogger interface with RollbarLevel enum
- refactor: replaced sync-all log methods of Rollbar and RolbarLogger with ones dedicated to each type of payload: string-message, NSException, NSError, etc.
