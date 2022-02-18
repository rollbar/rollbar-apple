#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarTelemetryLogBody : RollbarTelemetryBody

#pragma mark - Properties

@property (nonatomic, copy) NSString *message;

#pragma mark - Initializers

-(instancetype)initWithMessage:(nonnull NSString *)message
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

-(instancetype)initWithMessage:(nonnull NSString *)message;

- (instancetype)initWithArray:(NSArray *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
