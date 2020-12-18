# CHANGELOG

The change log has moved to this repo's [GitHub Releases Page](https://github.com/rollbar/rollbar-apple/releases).

## Release Notes Tagging Conventions

1.  Every entry within the PackageReleaseNotes element is expected to be started with
    at least one of the tags listed:

    feat:     A new feature
    fix:      A bug fix
    docs:     Documentation only changes
    style:    Changes that do not affect the meaning of the code
    refactor: A code change that neither a bug fix nor a new feature
    perf:     A code change that improves performance
    test:     Adding or modifying unit test code
    chore:    Changes to the build process or auxiliary tools and libraries such as documentation generation, etc.

2.  Every entry within the PackageReleaseNotes element is expected to be tagged with 
    EITHER 
    "resolve #GITHUB_ISSUE_NUMBER:" - meaning completely addresses the GitHub issue
    OR 
    "ref #GITHUB_ISSUE_NUMBER:" - meaning relevant to the GitHub issue
    depending on what is more appropriate in each case.

## Release Notes

**2.0.0** Preliminary Notes
- feat: added RollbarPLCrashReporter module
- feat: added RollbarKSCrash module
- feat: explicit reporting of NSErrors 
- feat: defined default scrub fields
- refactor: split out RollbarCommon, RollbarNotifier, RollbarDeploys
- refactor: added use of lightweight generics
- refactor: added use nullability attributes
- refactor: removed RollbarConfiguration and replaced it with RollbarConfig
- refactor: changed WhitelistFields into SafeListFields when it comes to the RollbarScrubbingOptions
- refactor: removed all the deprecated API 
- refactor: replace NSString-like log level parameters in RollbarLogger interface with RollbarLevel enum
- refactor: replace sync-all log methods of Rollbar and RolbarLogger with ones dedicated to each type of payload: string-message, NSException, NSError, etc.
