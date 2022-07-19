#import "RollbarDestination.h"

#pragma mark - constants

static NSString * const DEFAULT_ENDPOINT = @"https://api.rollbar.com/api/1/item/";
static NSString * const DEFAULT_ACCCESS_TOKEN = @"NONE";
#ifdef DEBUG
static NSString * const DEFAULT_ENVIRONMENT = @"development";
#else
static NSString * const DEFAULT_ENVIRONMENT = @"unspecified";
#endif

#pragma mark - data field keys

static NSString * const DFK_ENDPOINT = @"endpoint";
static NSString * const DFK_ACCESS_TOKEN = @"accessToken";
static NSString * const DFK_ENVIRONMENT = @"environment";

#pragma mark - class implementation

@implementation RollbarDestination

#pragma mark - initializers

- (instancetype)initWithEndpoint:(NSString *)endpoint
                     accessToken:(NSString *)accessToken
                     environment:(NSString *)environment {
    
    self = [super initWithDictionary:@{
        DFK_ENDPOINT:endpoint,
        DFK_ACCESS_TOKEN:accessToken,
        DFK_ENVIRONMENT:environment
    }];
    return self;
}

- (instancetype)initWithAccessToken:(NSString *)accessToken
                        environment:(NSString *)environment {
    
    return [self initWithEndpoint:DEFAULT_ENDPOINT
                      accessToken:accessToken
                      environment:environment];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken {
    
    return [self initWithAccessToken:accessToken
                         environment:DEFAULT_ENVIRONMENT];
}

- (instancetype)init {
    
    return [self initWithAccessToken:DEFAULT_ACCCESS_TOKEN];
}

#pragma mark - property accessors

- (NSString *)endpoint {
    NSString *result = [self safelyGetStringByKey:DFK_ENDPOINT];
    return result;
}

- (NSString *)accessToken {
    NSString *result = [self safelyGetStringByKey:DFK_ACCESS_TOKEN];
    return result;
}

- (NSString *)environment {
    NSString *result = [self safelyGetStringByKey:DFK_ENVIRONMENT];
    return result;
}

@end

@implementation RollbarMutableDestination

#pragma mark - initializers

-(instancetype)init {
    
    if (self = [super init]) {
        return self;
    }
    return nil;
}

#pragma mark - property accessors

@dynamic endpoint;
@dynamic accessToken;
@dynamic environment;

- (void)setEndpoint:(NSString *)value {
    [self setString:value forKey:DFK_ENDPOINT];
}

- (void)setAccessToken:(NSString *)value {
    [self setString:value forKey:DFK_ACCESS_TOKEN];
}

- (void)setEnvironment:(NSString *)value {
    [self setString:value forKey:DFK_ENVIRONMENT];
}

@end
