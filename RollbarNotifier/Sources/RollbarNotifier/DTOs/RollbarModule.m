#import "RollbarModule.h"

#pragma mark - constants

static NSString *const DEFAULT_VERSION = nil;

#pragma mark - data field keys

static NSString * const DFK_NAME = @"name";
static NSString * const DFK_VERSION = @"version";

#pragma mark - class implementation

@implementation RollbarModule

#pragma mark - initializers

- (instancetype)initWithName:(nullable NSString *)name
                     version:(nullable NSString *)version {
    
    if (self = [super initWithDictionary:@{
        DFK_NAME:name ? name : [NSNull null],
        DFK_VERSION:version ? version : [NSNull null]
    }]) {
        return self;
    }
    
    return nil;;
}

- (instancetype)initWithName:(nullable NSString *)name {
    
    return [self initWithName:name version:DEFAULT_VERSION];
}

#pragma mark - property accessors

- (nullable NSString *)name {
   return [self getDataByKey:DFK_NAME];
}

- (nullable NSString *)version {
    return [self getDataByKey:DFK_VERSION];
}

@end


@implementation RollbarMutableModule

#pragma mark - initializers

-(instancetype)init {
    
    if (self = [super initWithDictionary:@{}]) {
        return self;
    }
    return nil;
}

#pragma mark - property accessors

@dynamic name;
@dynamic version;

- (void)setName:(nullable NSString *)value {
    [self setData:value byKey:DFK_NAME];
}

- (void)setVersion:(nullable NSString *)value {
    [self setData:value byKey:DFK_VERSION];
}

@end
