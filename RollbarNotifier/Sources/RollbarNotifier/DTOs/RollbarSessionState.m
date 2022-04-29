#import "RollbarSessionState.h"

@import RollbarCommon;

#pragma mark - constants

// add...

#pragma mark - data field keys

static NSString * const DFK_OS_UPTIME = @"os_uptime_seconds";
static NSString * const DFK_OS_VERSION = @"os_version";
static NSString * const DFK_APP_VERSION = @"app_version";

static NSString * const DFK_APP_ID = @"app_id";
static NSString * const DFK_SESSION_ID = @"session_id";

static NSString * const DFK_SESSION_TIMESTAMP = @"session_timestamp";
static NSString * const DFK_APP_MEMORY_WARNING_TIMESTAMP = @"app_memory_warning_timestamp";
static NSString * const DFK_APP_TERMINATION_TIMESTAMP = @"app_termination_timestamp";
static NSString * const DFK_APP_IN_BACKGROUND_FLAG = @"app_in_background";

@implementation RollbarSessionState

#pragma mark - initializers

- (instancetype)init {
    
    self = [super initWithDictionary:@{
        
        DFK_SESSION_TIMESTAMP: [[NSDate date] rollbar_toString],
        DFK_OS_UPTIME: [NSNumber numberWithDouble: [RollbarOsUtil detectOsUptimeInterval]],
        DFK_OS_VERSION: [RollbarOsUtil detectOsVersionString],
        DFK_APP_VERSION: [RollbarBundleUtil detectAppBundleVersion],
        DFK_APP_ID: [NSUUID new].UUIDString,
        DFK_SESSION_ID: [NSUUID new].UUIDString,
    }];

    return self;
}

#pragma mark - property accessors

- (NSTimeInterval)osUptimeInterval {
    
    NSTimeInterval interval = [self safelyGetTimeIntervalByKey:DFK_OS_UPTIME
                                                   withDefault:0.0
    ];
    return interval;
}

- (void)setOsUptimeInterval:(NSTimeInterval)value {
    
    [self setTimeInterval:value forKey:DFK_OS_UPTIME];
}


- (NSString *)osVersion {
    
    NSString *result = [self getDataByKey:DFK_OS_VERSION];
    return (nil != result) ? result : @"";
}

- (void)setOsVersion:(NSString *)value {
    
    [self setData:value byKey:DFK_OS_VERSION];
}


- (NSString *)appVersion {
    
    NSString *result = [self getDataByKey:DFK_APP_VERSION];
    return (nil != result) ? result : @"";
}

- (void)setAppVersion:(NSString *)value {
    
    [self setData:value byKey:DFK_APP_VERSION];
}


-(nullable NSUUID *)appID {
    
    NSString *result = [self getDataByKey:DFK_APP_ID];
    if (result) {
        
        return [[NSUUID alloc] initWithUUIDString:result];
    }
    return nil;
}

-(void)setAppID:(nullable NSUUID *)value {
    [self setData:value.UUIDString byKey:DFK_APP_ID];
}


-(nullable NSUUID *)sessionID {
    
    NSString *result = [self getDataByKey:DFK_SESSION_ID];
    if (result) {
        
        return [[NSUUID alloc] initWithUUIDString:result];
    }
    return nil;
}

-(void)setSessionID:(nullable NSUUID *)value {
    [self setData:value.UUIDString byKey:DFK_SESSION_ID];
}


- (NSDate *)sessionStartTimestamp {
    
    NSDate *result = [self safelyGetDateByKey:DFK_SESSION_TIMESTAMP withDefault:nil];
    return result;
}

- (void)setSessionStartTimestamp:(NSDate *)value {
    
    [self setDate:value forKey:DFK_SESSION_TIMESTAMP];
}


- (NSDate *)appMemoryWarningTimestamp {
    
    NSDate *result = [self safelyGetDateByKey:DFK_APP_MEMORY_WARNING_TIMESTAMP withDefault:nil];
    return result;
}

- (void)setAppMemoryWarningTimestamp:(NSDate *)value {
    
    [self setDate:value forKey:DFK_APP_MEMORY_WARNING_TIMESTAMP];
}


- (NSDate *)appTerminationTimestamp {
    
    NSDate *result = [self safelyGetDateByKey:DFK_APP_TERMINATION_TIMESTAMP withDefault:nil];
    return result;
}

- (void)setAppTerminationTimestamp:(NSDate *)value {
    
    [self setDate:value forKey:DFK_APP_TERMINATION_TIMESTAMP];
}


- (RollbarTriStateFlag)appInBackgroundFlag {
    
    BOOL result = [self safelyGetTriStateFlagByKey:DFK_APP_IN_BACKGROUND_FLAG];
    return result;
}

- (void)setAppInBackgroundFlag:(RollbarTriStateFlag)value {
    
    [self setTriStateFlag:value forKey:DFK_APP_IN_BACKGROUND_FLAG];
}

@end
