#ifndef RollbarCrashCollector_h
#define RollbarCrashCollector_h

@import Foundation;
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar KSCrash reports collector
@interface RollbarCrashCollector: NSObject

@property (nonatomic, readonly) NSUInteger totalProcessedReports;

- (void)collectCrashReports;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarCrashCollector_h
