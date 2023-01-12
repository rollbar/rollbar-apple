#ifndef RollbarCrashInstallation_h
#define RollbarCrashInstallation_h

@import KSCrash_Installations;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar Crash installation helper
@interface RollbarCrashInstallation : KSCrashInstallation

/// The shared instance of this helper.
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashInstallation_h
