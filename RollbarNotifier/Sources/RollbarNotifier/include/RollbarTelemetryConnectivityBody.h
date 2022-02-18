#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarTelemetryConnectivityBody : RollbarTelemetryBody

#pragma mark - Properties

@property (nonatomic, copy) NSString *status;

#pragma mark - Initializers

-(instancetype)initWithStatus:(nonnull NSString *)status
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

-(instancetype)initWithStatus:(nonnull NSString *)status;

- (instancetype)initWithArray:(NSArray *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
