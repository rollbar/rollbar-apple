#ifndef RollbarTelemetryConnectivityBody_h
#define RollbarTelemetryConnectivityBody_h

#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

/// Telemetry connectivity event's body
@interface RollbarTelemetryConnectivityBody : RollbarTelemetryBody

#pragma mark - Properties

/// Connectivity status
@property (nonatomic, copy) NSString *status;

#pragma mark - Initializers

/// Designated initializer
/// @param status connectivity status
/// @param extraData extra data
-(instancetype)initWithStatus:(nonnull NSString *)status
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

/// Initializer
/// @param status connectivity status
-(instancetype)initWithStatus:(nonnull NSString *)status;

/// Designated serializer
/// @param data seeding data dictionary
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

#endif //RollbarTelemetryConnectivityBody_h
