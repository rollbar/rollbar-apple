#ifndef RollbarDestination_h
#define RollbarDestination_h

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Models destination settings of a configuration
@interface RollbarDestination : RollbarDTO

#pragma mark - properties

/// Endpoint URI
@property (nonatomic, readonly, copy) NSString *endpoint;

/// Project access token
@property (nonatomic, readonly, copy) NSString *accessToken;

/// Environment name
@property (nonatomic, readonly, copy) NSString *environment;

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

@interface RollbarMutableDestination : RollbarDestination

#pragma mark - initializers

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

#pragma mark - properties

/// Endpoint URI
@property (nonatomic, readwrite, copy) NSString *endpoint;

/// Project access token
@property (nonatomic, readwrite, copy) NSString *accessToken;

/// Environment name
@property (nonatomic, readwrite, copy) NSString *environment;

//#pragma mark - initializers
//
///// Initializer
///// @param endpoint endpoint URI
///// @param accessToken Rollbar project access token
///// @param environment environment name
//- (instancetype)initWithEndpoint:(NSString *)endpoint
//                     accessToken:(NSString *)accessToken
//                     environment:(NSString *)environment;
//
///// Initializer
///// @param accessToken Rollbar project access token
///// @param environment environment name
//- (instancetype)initWithAccessToken:(NSString *)accessToken
//                        environment:(NSString *)environment;
//
///// Initializer
///// @param accessToken Rollbar project access token
//- (instancetype)initWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarDestination_h
