#ifndef RollbarCrashCollector_h
#define RollbarCrashCollector_h

@import Foundation;
@import RollbarCommon;
@import RollbarCrash;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar crash report collector
@interface RollbarCrashCollector: RollbarCrashInstallation

- (void)sendAllReports;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashCollector_h
