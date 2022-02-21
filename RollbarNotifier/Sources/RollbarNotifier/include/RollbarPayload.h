@import RollbarCommon;

@class RollbarData;

NS_ASSUME_NONNULL_BEGIN

/// The payload root model
@interface RollbarPayload : RollbarDTO

#pragma mark - properties

/// Required: access_token
/// An access token with scope "post_server_item" or "post_client_item".
/// A post_client_item token must be used if the "platform" is "browser", "android", "ios", "flash", or "client"
/// A post_server_item token should be used for other platforms.
@property (nonatomic, copy, nonnull) NSString *accessToken;

/// Required: data
@property (nonatomic, nonnull) RollbarData *data;

#pragma mark - initializers

/// Initializer
/// @param token Rollbar project access token
/// @param data data element of the payload
-(instancetype)initWithAccessToken:(nonnull NSString *)token
                              data:(nonnull RollbarData *)data;

@end

NS_ASSUME_NONNULL_END
