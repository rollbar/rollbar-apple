#import <Foundation/Foundation.h>
@import CocoaLumberjack;
@import RollbarNotifier;

NS_ASSUME_NONNULL_BEGIN

/// Rollbar logger for CocoaLumberjack
@interface RollbarCocoaLumberjackLogger : DDAbstractLogger <DDLogger> {
    @private
    RollbarLogger *_rollbarLogger;
}

#pragma mark - factory methods

/// Creates initialized instance of the Rollbar logger for CocoaLumberjack
/// @param rollbarLogger a RollbarLogger to use
+ (NSObject<DDLogger> *)createWithRollbarLogger:(RollbarLogger *)rollbarLogger;

/// Creates initialized instance of the Rollbar logger for CocoaLumberjack
/// @param rollbarConfig a RollbarConfig to use
+ (NSObject<DDLogger> *)createWithRollbarConfig:(RollbarConfig *)rollbarConfig;

#pragma mark - instance initializers

/// Initializer
/// @param rollbarLogger a RollbarLogger to use
- (instancetype)initWithRollbarLogger:(RollbarLogger *)rollbarLogger
NS_DESIGNATED_INITIALIZER;

/// Initializer
/// @param rollbarConfig a RollbarConfig to use
- (instancetype)initWithRollbarConfig:(RollbarConfig *)rollbarConfig;

/// Hides initializer
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
