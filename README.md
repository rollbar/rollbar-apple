<p align="center">
  <img alt="rollbar-logo" src="https://user-images.githubusercontent.com/3300063/207964480-54eda665-d6fe-4527-ba51-b0ab3f41f10b.png" />
</p>

<h1 align="center">Rollbar Apple MonoRepo</h1>

<p align="center">
  <strong>Proactively discover, predict, and resolve errors in real-time with <a href="https://rollbar.com">Rollbar’s</a> error monitoring platform. <a href="https://rollbar.com/signup/">Start tracking errors today</a>!</strong>
</p>

---

Objective-C & Swift SDK for remote crash, exception, error reporting, and logging with [Rollbar](https://rollbar.com).

It works on all Apple *OS platforms (**macOS**, **iOS**, **tvOS**, **watchOS**, etc).

NOTE:
This SDK is essentially a reincarnation of our [Rollbar-iOS SDK](https://github.com/rollbar/rollbar-ios) that will be available for awhile in its current v1 version
and will only maintained with fixes to bug or security issues if any.
All the active development will be done within this SDK repository.

## Key benefits of using Rollbar for Apple software platforms are:

- **Platforms:** Rollbar supports all <a href="https://docs.rollbar.com/docs/apple">Apple OS platforms</a> such as IOS, macOS, tvOS, watchOS, etc.
- **Automatic error grouping:** Rollbar aggregates Occurrences caused by the same error into Items that represent application issues. <a href="https://docs.rollbar.com/docs/grouping-occurrences">Learn more about reducing log noise</a>.
- **Advanced search:** Filter items by many different properties. <a href="https://docs.rollbar.com/docs/search-items">Learn more about search</a>.
- **Customizable notifications:** Rollbar supports several messaging and incident management tools where your team can get notified about errors and important events by real-time alerts. <a href="https://docs.rollbar.com/docs/notifications">Learn more about Rollbar notifications</a>.



# The Apple SDK is GA. Learn more: https://docs.rollbar.com/docs/apple

## Codebase status (code quality and CI build)

![CI Build Status](https://github.com/rollbar/rollbar-apple/workflows/Swift/badge.svg)

![CI Build with Unit Tests](https://github.com/rollbar/rollbar-apple/workflows/CI%20Build%20with%20Unit%20Tests/badge.svg)

<!--
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=alert_status)](https://sonarcloud.io/dashboard?id=rollbar-apple)
-->
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=security_rating)](https://sonarcloud.io/dashboard?id=rollbar-apple)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=rollbar-apple)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=rollbar-apple)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=rollbar-apple)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=coverage)](https://sonarcloud.io/dashboard?id=rollbar-apple)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=ncloc)](https://sonarcloud.io/dashboard?id=rollbar-apple)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=rollbar-apple&metric=bugs)](https://sonarcloud.io/dashboard?id=rollbar-apple)


## Package Distribution Systems Status

[![GitHub all releases downloads total](https://img.shields.io/github/downloads/rollbar/rollbar-apple/total?logo=GitHub)]()

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-brightgreen.svg)](https://cocoapods.org/)

<!--
[//]: # [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Rollbar.svg)](https://img.shields.io/cocoapods/v/Rollbar.svg)
-->

[![Platform](https://img.shields.io/cocoapods/p/RollbarNotifier.svg?label=RollbarNotifier)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarDeploys.svg?label=RollbarDeploys)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarCommon.svg?label=RollbarCommon)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarAUL.svg?label=RollbarAUL)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarSwift.svg?label=RollbarSwift)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarCocoaLumberjack.svg?label=RollbarCocoaLumberjack)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarPLCrashReporter.svg?label=RollbarPLCrashReporter)](https://docs.rollbar.com/docs/apple)
[![Platform](https://img.shields.io/cocoapods/p/RollbarKSCrash.svg?label=RollbarKSCrash)](https://docs.rollbar.com/docs/apple)

[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarNotifier?label=RollbarNotifier)](https://cocoapods.org/pods/RollbarNotifier)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarDeploys?label=RollbarDeploys)](https://cocoapods.org/pods/RollbarDeploys)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarCommon?label=RollbarCommon)](https://cocoapods.org/pods/RollbarCommon)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarAUL?label=RollbarAUL)](https://cocoapods.org/pods/RollbarAUL)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarSwift?label=RollbarSwift)](https://cocoapods.org/pods/RollbarSwift)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarCocoaLumberjack?label=RollbarCocoaLumberjack)](https://cocoapods.org/pods/RollbarCocoaLumberjack)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarPLCrashReporter?label=RollbarPLCrashReporter)](https://cocoapods.org/pods/RollbarPLCrashReporter)
[![CocoaPods](https://img.shields.io/cocoapods/v/RollbarKSCrash?label=RollbarKSCrash)](https://cocoapods.org/pods/RollbarKSCrash)


## Setup Instructions

1. [Sign up for a Rollbar account](https://rollbar.com/signup)
2. Follow the [Installation](https://docs.rollbar.com/docs/apple#section-installation) instructions in our [Rollbar-Apple SDK docs](https://docs.rollbar.com/docs/apple) to install the SDK modules.

## Usage and Reference

For complete usage instructions and configuration reference, see our [Rollbar-Apple SDK docs](https://docs.rollbar.com/docs/apple).

## Release History & Changelog

See our [Releases](https://github.com/rollbar/rollbar-apple/releases) page for a list of all releases, including changes.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Help / Support

- [Gitter Community](https://gitter.im/rollbar/SDK-Apple)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/rollbar)
- [GitHub Issues](https://github.com/rollbar/rollbar-apple/issues)
- [GitHub Discussions](https://github.com/rollbar/rollbar-apple/discussions)
- [File a bug report](https://github.com/rollbar/rollbar-apple/issues/new)
- Rollbar Support: `support@rollbar.com`
