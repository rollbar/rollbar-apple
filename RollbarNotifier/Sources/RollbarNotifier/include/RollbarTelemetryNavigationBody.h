#ifndef RollbarTelemetryNavigationBody_h
#define RollbarTelemetryNavigationBody_h

#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

/// Telemetry navigation event body DTO
@interface RollbarTelemetryNavigationBody : RollbarTelemetryBody

#pragma mark - Properties

/// Navigation from
@property (nonatomic, copy) NSString *from;

/// Navigation to.
@property (nonatomic, copy) NSString *to;

#pragma mark - Initializers

/// Designated initializer
/// @param from navigation from
/// @param to navigation to
/// @param extraData extra data
-(instancetype)initWithFromLocation:(nonnull NSString *)from
                         toLocation:(nonnull NSString *)to
                          extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

/// Initializer
/// @param from navigation from
/// @param to navigation to
-(instancetype)initWithFromLocation:(nonnull NSString *)from
                         toLocation:(nonnull NSString *)to;

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

#endif //RollbarTelemetryNavigationBody_h
