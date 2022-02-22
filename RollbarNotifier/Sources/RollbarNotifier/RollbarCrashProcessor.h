@import Foundation;
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// A crash report processor
@interface RollbarCrashProcessor : NSObject <RollbarCrashCollectorObserver>

@end

NS_ASSUME_NONNULL_END
