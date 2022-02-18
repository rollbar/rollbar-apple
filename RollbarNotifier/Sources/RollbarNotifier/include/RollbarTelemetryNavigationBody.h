#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarTelemetryNavigationBody : RollbarTelemetryBody

#pragma mark - Properties

@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;

#pragma mark - Initializers

-(instancetype)initWithFromLocation:(nonnull NSString *)from
                         toLocation:(nonnull NSString *)to
                          extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

-(instancetype)initWithFromLocation:(nonnull NSString *)from
                         toLocation:(nonnull NSString *)to;

- (instancetype)initWithArray:(NSArray *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
