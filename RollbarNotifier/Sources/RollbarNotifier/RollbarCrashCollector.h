#ifndef RollbarCrashCollector_h
#define RollbarCrashCollector_h

#if __has_include("KSCrash-umbrella.h")
@import KSCrash;
#else
@import KSCrash_Installations;
#endif

@import Foundation;
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar crash report collector
@interface RollbarCrashCollector: KSCrashInstallation

- (void)sendAllReports;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashCollector_h
