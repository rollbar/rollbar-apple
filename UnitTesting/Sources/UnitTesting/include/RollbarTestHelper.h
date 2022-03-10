#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Utility class aiding in implementing SDK's unit tests
@interface RollbarTestHelper : NSObject

#pragma mark - class methods

/// returns Rollbar environment dedicated to the SDK's unit tests
+ (nonnull NSString *)getRollbarEnvironment;

/// returns Rollbar access token dedicated to the payloads sent by SDK's live unit tests
+ (nonnull NSString *)getRollbarPayloadsAccessToken;

/// returns Rollbar WRITE access token dedicated to the deploys registered by SDK's live unit tests
+ (nonnull NSString *)getRollbarDeploysWriteAccessToken;

/// returns Rollbar READ access token dedicated to iterating over the deploys registered by SDK's live unit tests
+ (nonnull NSString *)getRollbarDeploysReadAccessToken;

#pragma mark - instance initializers

/// Hides initializer
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
