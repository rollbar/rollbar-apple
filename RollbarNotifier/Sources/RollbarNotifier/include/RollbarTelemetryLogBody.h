#ifndef RollbarTelemetryLogBody_h
#define RollbarTelemetryLogBody_h

#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

/// Telemetry log event body DTO
@interface RollbarTelemetryLogBody : RollbarTelemetryBody

#pragma mark - Properties

/// Log message
@property (nonatomic, copy) NSString *message;

#pragma mark - Initializers

/// Designated initializer
/// @param message log message
/// @param extraData extra data
-(instancetype)initWithMessage:(nonnull NSString *)message
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

/// Initializer
/// @param message log message
-(instancetype)initWithMessage:(nonnull NSString *)message;

/// Designated initializer
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

#endif //RollbarTelemetryLogBody_h
