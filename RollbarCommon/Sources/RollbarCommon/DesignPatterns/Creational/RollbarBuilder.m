#import "RollbarBuilder.h"

@implementation RollbarEntity

- (instancetype)initWithBuilder:(RollbarEntityBuilder *)builder {
    if (self = [super init]) {
        _ID = builder.ID;
    }
    return self;
}

@end

@implementation RollbarEntityBuilder

- (RollbarEntity *)build {
    return [[RollbarEntity alloc] initWithBuilder:self];
}

@end
