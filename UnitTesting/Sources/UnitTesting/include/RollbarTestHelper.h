#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarTestHelper : NSObject

#pragma mark - class methods

+ (nonnull NSString *)getRollbarEnvironment;
+ (nonnull NSString *)getRollbarPayloadsAccessToken;
+ (nonnull NSString *)getRollbarDeploysWriteAccessToken;
+ (nonnull NSString *)getRollbarDeploysReadAccessToken;

#pragma mark - instance initializers

/// Hides initializer
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
