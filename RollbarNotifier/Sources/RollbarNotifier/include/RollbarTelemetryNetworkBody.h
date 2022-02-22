#import "RollbarTelemetryBody.h"
#import "RollbarHttpMethod.h"

NS_ASSUME_NONNULL_BEGIN

/// Telemetry network event body DTO
@interface RollbarTelemetryNetworkBody : RollbarTelemetryBody

#pragma mark - Properties

/// HTTP method
@property (nonatomic) RollbarHttpMethod method;

/// URL
@property (nonatomic, copy) NSString *url;

/// Status code
@property (nonatomic, copy) NSString *statusCode;

#pragma mark - Initializers

/// Designated initializer
/// @param method HTTP method
/// @param url URL
/// @param statusCode status code
/// @param extraData extra data
-(instancetype)initWithMethod:(RollbarHttpMethod)method
                          url:(nonnull NSString *)url
                   statusCode:(nonnull NSString *)statusCode
                    extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

/// Initializer
/// @param method HTTP method
/// @param url URL
/// @param statusCode status code
-(instancetype)initWithMethod:(RollbarHttpMethod)method
                          url:(nonnull NSString *)url
                   statusCode:(nonnull NSString *)statusCode;

/// Designated initializer
/// @param data seedind data dictionary
- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)data
NS_DESIGNATED_INITIALIZER;

/// Hides the initializer
/// @param data seeding data array
- (instancetype)initWithArray:(NSArray *)data
NS_UNAVAILABLE;

/// Hides the initializer
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
