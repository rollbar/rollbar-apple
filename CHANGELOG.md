# CHANGELOG

The change log has moved to this repo's [GitHub Releases Page](https://github.com/rollbar/rollbar-apple/releases).

## Release Notes Tagging Conventions

1. Every entry within the PackageReleaseNotes element is expected to be started with
    at least one of the tags listed:

    feat:     A new feature
    fix:      A bug fix
    docs:     Documentation only changes
    style:    Changes that do not affect the meaning of the code
    refactor: A code change that neither a bug fix nor a new feature
    perf:     A code change that improves performance
    test:     Adding or modifying unit test code
    chore:    Changes to the build process or auxiliary tools and libraries such as documentation generation, etc.

2. Every entry within the PackageReleaseNotes element is expected to be tagged with
    EITHER
    "resolve #GITHUB_ISSUE_NUMBER:" - meaning completely addresses the GitHub issue
    OR
    "ref #GITHUB_ISSUE_NUMBER:" - meaning relevant to the GitHub issue
    depending on what is more appropriate in each case.

## Release Notes

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
