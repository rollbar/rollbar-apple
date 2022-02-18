#import "RollbarTelemetryBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarTelemetryViewBody : RollbarTelemetryBody

#pragma mark - Properties

@property (nonatomic, copy) NSString *element;

#pragma mark - Initializers

-(instancetype)initWithElement:(nonnull NSString *)element
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData
NS_DESIGNATED_INITIALIZER;

-(instancetype)initWithElement:(nonnull NSString *)element;

- (instancetype)initWithArray:(NSArray *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)data
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
