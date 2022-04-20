#ifndef RollbarTelemetryEvent_h
#define RollbarTelemetryEvent_h

@import RollbarCommon;

#import "RollbarLevel.h"
#import "RollbarTelemetryType.h"
#import "RollbarSource.h"

@class RollbarTelemetryBody;

NS_ASSUME_NONNULL_BEGIN

/// Telemetry event DTO
/// @note:
/// Can contain any arbitrary keys.
@interface RollbarTelemetryEvent : RollbarDTO

#pragma mark - Properties

/// Required: level
/// The severity level of the telemetry data. One of: "critical", "error", "warning", "info", "debug".
@property (nonatomic, readonly) RollbarLevel level;

/// Required: type
/// The type of telemetry data. One of: "log", "network", "dom", "navigation", "error", "manual".
@property (nonatomic, readonly) RollbarTelemetryType type;

/// Required: source
/// The source of the telemetry data. Usually "client" or "server".
@property (nonatomic, readonly) RollbarSource source;

/// Required: timestamp_ms
/// When this occurred, as a unix timestamp in milliseconds.
@property (nonatomic, readonly) NSTimeInterval timestamp; //stored in JSON as long

/// Required: body
/// The key-value pairs for the telemetry data point. See "body" key below.
/// @note:
/// If type above is "log", body should contain "message" key.
/// If type above is "network", body should contain "method", "url", and "status_code" keys.
/// If type above is "dom", body should contain "element" key.
/// If type above is "navigation", body should contain "from" and "to" keys.
/// If type above is "error", body should contain "message" key.
@property (nonatomic, strong, readonly) RollbarTelemetryBody *body;

#pragma mark - Initializers

/// Initializer
/// @param level event level
/// @param type event type
/// @param source event source
- (instancetype)initWithLevel:(RollbarLevel)level
                telemetryType:(RollbarTelemetryType)type
                       source:(RollbarSource)source;

/// Initializer
/// @param level event level
/// @param source event source
/// @param body event body
- (instancetype)initWithLevel:(RollbarLevel)level
                       source:(RollbarSource)source
                         body:(nonnull RollbarTelemetryBody *)body;

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

#pragma mark - Class utility

/// Creates a telemetry body DTO by its type and seeding data dictionary
/// @param type telemetry body type
/// @param data seeding data dictionary
+ (RollbarTelemetryBody *)createTelemetryBodyWithType:(RollbarTelemetryType)type
                                                 data:(nullable NSDictionary<NSString *, id> *)data;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarTelemetryEvent_h
