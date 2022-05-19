@import Foundation;
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// A crash report processor
@interface RollbarCrashProcessor : NSObject <RollbarCrashCollectorObserver>

@property (nonatomic, readonly) NSUInteger totalProcessedReports;

@end

NS_ASSUME_NONNULL_END
