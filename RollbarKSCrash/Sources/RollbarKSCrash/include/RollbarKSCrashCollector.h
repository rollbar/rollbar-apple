#ifndef RollbarKSCrashCollector_h
#define RollbarKSCrashCollector_h

@import Foundation;
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar KSCrash reports collector
@interface RollbarKSCrashCollector: NSObject

@property (nonatomic, readonly) NSUInteger totalProcessedReports;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarKSCrashCollector_h
