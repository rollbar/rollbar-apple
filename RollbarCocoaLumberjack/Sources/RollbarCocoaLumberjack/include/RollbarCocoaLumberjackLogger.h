#import <Foundation/Foundation.h>
@import CocoaLumberjack;
@import RollbarNotifier;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarCocoaLumberjackLogger : DDAbstractLogger <DDLogger> {
    @private
    RollbarLogger *_rollbarLogger;
}

#pragma mark - factory methods

+ (NSObject<DDLogger> *)createWithRollbarLogger:(RollbarLogger *)rollbarLogger;

+ (NSObject<DDLogger> *)createWithRollbarConfig:(RollbarConfig *)rollbarConfig;

#pragma mark - instance initializers

- (instancetype)initWithRollbarLogger:(RollbarLogger *)rollbarLogger
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRollbarConfig:(RollbarConfig *)rollbarConfig;

- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
