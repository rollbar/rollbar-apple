# Rollbar-Apple SDK

**Rollbar SDK for any Apple \*OS (macOS, ipadOS, iOS, tvOS, watchOS, ...)**

**Written in Objective-C. Works with Swift**

---

[TOC]

## What is Rollbar-Apple SDK?

Objective-C & Swift SDK for remote crash, exception, error reporting, and logging with Rollbar.

It works on all Apple *OS platforms (macOS, ipadOS, iOS, tvOS, watchOS, etc).

It is the preferred SDK for sending log payloads to [Rollbar](http://rollbar.com).

## How is Rollbar-Apple SDK different from Rollbar-iOS SDK?

Look at Rollbar-Apple SDK as the next major reincarnation of Rollbar-iOS SDK.
It is v2 of Rollbar-iOS SDK under a new name that better describes its purpose.

Rollbar-iOS will be available for a while to allow our customers to make a move to Rollbar-Apple SDK when it most convenient to them.

All the new feature development will be happening here within Rollbar-Apple SDK.

## Where can I get the SDK from?

Rollbar-Apple SDK is an open-source project available on GitHub.
Its releases are published on GitHub as well.
The SDK can also be integrated into your codebase from the following package distribution systems:

- Swift Package Manager (also known as SwiftPM or SPM)
- Cocoapods
- Carthage

## Pay Attention

Depending on the specific package management system, the SDK is available either as the whole (under `Rollbar-Apple` name) or on a per-module basis (for example, `RollbarCommon`, `RollbarNotifier`, `RollbarDeploys`, etc).

Some package distribution systems also host packages associated with the older incarnation of this SDK, called Rollbar-iOS, that used to be published under Rollbar package name and versioned at either `v0.n.n` or `v1.n.n`.

All the Rollbar-Apple SDK releases (and packages) versioned starting from v2 (since, as we already explained above, Rollbar-Apple is the `v2` of Rollbar-iOS SDK renamed into Rollbar-Apple).


## Getting Help and Support

- [Gitter Community](https://gitter.im/rollbar/SDK-Apple)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/rollbar)
- [GitHub Issues](https://github.com/rollbar/rollbar-apple/issues)
- [GitHub Discussions](https://github.com/rollbar/rollbar-apple/discussions)
- [File a bug report](https://github.com/rollbar/rollbar-apple/issues/new)
- Rollbar Support: `support@rollbar.com`

## SDK Modules/Packages

*RollbarNotifier* is the package that implements the `RollbarLogger` (i.e. Notifier) - that is the thing that supports a lot of configurational options and allows to capture, package, and forward (to the preconfigured Rollbar Project on rollbar.com) exceptions, errors, log messages, telemetry, and custom data.

We offer a couple of optional crash reporting alternatives - one based on *KSCrash* and another one based on *PLCrashReporter*. Each package (*RollbarKSCrash*` or `*RollbarPLCrashReporter*) implements its own crash report collector adapter to a corresponding third-party crash reporter.
A collector is optional and can be supplied into a notifier (`RollbarLogger`) initializer along with the required `RollbarConfig` instance.

*RollbarAUL* module implements *RollbarNotifier* integration with Apple Unified Logging (AUL) and allows capture of the AUL entries as corresponding Rollbar Telemetry log events.

*RollbarDeploys* is the package that should be used, for example by your CI Release pipeline, to track/manage your application releases/deployments so they are reported to the Rollbar Project and Rollbar would correlate the incoming payloads with specific deployment instance.

*RollbarCommon* is just a shared package with types used by any of the other packages as well as some potentially useful public utility classes that you may find useful.

## Installation

Here are a few alternatives for installing the SDK into your software projects:

### Via [GitHub](https://github.com/rollbar/rollbar-apple)

Here are a few options:

- you can download or clone the SDK source code directly from the GitHub repo;
- you can download a source code snapshot of a specific release from the repo Release page;
- you can integrate the the GitHub repo as a git submodule of your project git repository.

### Via [Swift Package Manager](https://github.com/apple/swift-package-manager)

For example, in Xcode, by pointing your project's build target SPM settings to https://github.com/rollbar/rollbar-apple.git repository and specifying the desired release version, or branch, or commit.

### Via [Carthage](https://github.com/Carthage/Carthage)

In your *Cartfile*, specify:

```txt
github "rollbar/rollbar-apple" ~> n.n.n
```

where `n.n.n` is the desired pod version of the SDK to use.

### Via [Cocoapods](https://cocoapods.org/)

The SDK is configured for *Cocoapods* distribution on a pod-per-module basis, so you will have to separately specify each module pod dependency as needed. For example:

```txt
pod "RollbarNotifier", "~> n.n.n"
pod "RollbarDeploys", "~> n.n.n"
```

where `n.n.n` is the desired pod version of the SDK to use. As the general rule, for multiple modules try using the same version.

You do not have to worry about explicitly including other internal dependencies of the modules, like *RollbarCommon* module pod. The SDK modules' *podspec*s already specify these as needed.

## Using the SDK in Your Code

### Import Necessary SDK Modules

Before using any of the types provided by the SDK modules, you need to make sure you import the modules you need. For example:

#### Objective-C

```Obj-C
@import RollbarNotifier;
```

#### Swift

```Swift
import RollbarNotifier
```

### Define the Shared Notifier's Configuration Instance

When setting up a notifier configuration you must at least specify your Rollbar Project's access token:

#### Objective-C

```Obj-C
RollbarConfig *config = [RollbarConfig new];
config.destination.accessToken = @"YOUR_PROJECT_ACCESS_TOKEN";
config.destination.environment = @"YOUR_ENVIRONMENT";
```

#### Swift

```Swift
let config = RollbarConfig()
config.destination.accessToken = "YOUR_PROJECT_ACCESS_TOKEN"
config.destination.environment = "ENVIRONMENT"
```

### Initialize the Shared Notifier

#### Objective-C

```Obj-C
[Rollbar initWithConfiguration:config];
//OR [Rollbar initWithConfiguration:config crashCollector:crashCollector];
```

#### Swift

```Swift
Rollbar.initWithConfiguration(config)
//OR Rollbar.initWithConfiguration(config, crashCollector: crashCollector)
```

### Start Logging using the Shared Notifier

#### Objective-C

```Obj-C
[Rollbar infoMessage:@"See this message on your Rollbar Project Dashboard..."];
```

#### Swift

```Swift
Rollbar.infoMessage("See this message on your Rollbar Project Dashboard...")
```

There are other dedicated method overloads for logging `NSException`s, `NSError`s with different levels of log severity.
