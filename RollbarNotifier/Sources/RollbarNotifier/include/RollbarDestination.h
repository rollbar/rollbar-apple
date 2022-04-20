#ifndef RollbarDestination_h
#define RollbarDestination_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Models destination settings of a configuration
@interface RollbarDestination : RollbarDTO

#pragma mark - properties

/// Endpoint URI
@property (nonatomic, copy) NSString *endpoint;

/// Project access token
@property (nonatomic, copy) NSString *accessToken;

/// Environment name
@property (nonatomic, copy) NSString *environment;

#pragma mark - initializers

/// Initializer
/// @param endpoint endpoint URI
/// @param accessToken Rollbar project access token
/// @param environment environment name
- (instancetype)initWithEndpoint:(NSString *)endpoint
                     accessToken:(NSString *)accessToken
                     environment:(NSString *)environment;

/// Initializer
/// @param accessToken Rollbar project access token
/// @param environment environment name
- (instancetype)initWithAccessToken:(NSString *)accessToken
                        environment:(NSString *)environment;

/// Initializer
/// @param accessToken Rollbar project access token
- (instancetype)initWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarDestination_h
