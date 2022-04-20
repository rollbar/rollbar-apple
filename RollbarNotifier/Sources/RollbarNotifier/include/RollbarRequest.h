#ifndef RollbarRequest_h
#define RollbarRequest_h

#import "RollbarHttpMethod.h"

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

/// Request element of a payload DTO
/// @note:
// Can contain any additional arbitrary keys.
@interface RollbarRequest : RollbarDTO

#pragma mark - Properties

/// url: full URL where this event occurred
@property (nonatomic, copy, nullable) NSString *url;

/// method: the request method
@property (nonatomic) RollbarHttpMethod method;

/// headers: object containing the request headers.
/// @note:
/// Header names should be formatted like they are in HTTP.
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *headers;

/// params: any routing parameters (i.e. for use with Rails Routes)
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *params;

/// GET: query string params
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *getParams;

/// query_string: the raw query string
@property (nonatomic, copy, nullable) NSString *queryString;

/// POST: POST params
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *postParams;

/// body: the raw POST body
@property (nonatomic, copy, nullable) NSString *postBody;

/// user_ip: the user's IP address as a string.
/// @note:
/// Can also be the special value "$remote_ip", which will be replaced with the source IP of the API request.
/// Will be indexed, as long as it is a valid IPv4 address.
@property (nonatomic, copy, nullable) NSString *userIP;

#pragma mark - Initializers

- (instancetype)initWithHttpMethod:(RollbarHttpMethod)httpMethod
                               url:(nullable NSString *)url
                           headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                            params:(nullable NSDictionary<NSString *, NSString *> *)params
                       queryString:(nullable NSString *)queryString
                         getParams:(nullable NSDictionary<NSString *, NSString *> *)getParams
                        postParams:(nullable NSDictionary<NSString *, NSString *> *)postParams
                          postBody:(nullable NSString *)postBody
                            userIP:(nullable NSString *)userIP;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarRequest_h
