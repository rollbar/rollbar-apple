#ifndef RollbarTelemetryViewBody_h
#define RollbarTelemetryViewBody_h

#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

/// Telemetry view event body DTO
@interface RollbarTelemetryViewBody : RollbarTelemetryBody

#pragma mark - Properties

/// View element name
@property (nonatomic, copy) NSString *element;

#pragma mark - Initializers

/// Designated initializer
/// @param element view element name
/// @param extraData extra data
-(instancetype)initWithElement:(nonnull NSString *)element
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

/// Initializer
/// @param element view element name
-(instancetype)initWithElement:(nonnull NSString *)element;

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

#endif //RollbarTelemetryViewBody_h
