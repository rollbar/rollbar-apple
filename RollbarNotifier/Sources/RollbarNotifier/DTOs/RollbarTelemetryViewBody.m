#import "RollbarTelemetryViewBody.h"

#pragma mark - constants

#pragma mark - data field keys

static NSString * const DFK_ELEMENT = @"element";

#pragma mark - class implementation

@implementation RollbarTelemetryViewBody

#pragma mark - initializers

-(instancetype)initWithElement:(nonnull NSString *)element
                     extraData:(nullable NSDictionary<NSString *, id> *)extraData {
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (extraData) {
        [data addEntriesFromDictionary:extraData];
    }
    [data setObject:element forKey:DFK_ELEMENT];
    self = [super initWithDictionary:data];
    return self;
}

-(instancetype)initWithElement:(nonnull NSString *)element {
    return [self initWithElement:element extraData:nil];
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)data {

    return [super initWithDictionary:data];
}

#pragma mark - property accessors

- (NSString *)element {
    NSString *result = [self safelyGetStringByKey:DFK_ELEMENT];
    return result;
}

- (void)setElement:(NSString *)value {
    [self setString:value forKey:DFK_ELEMENT];
}

@end
