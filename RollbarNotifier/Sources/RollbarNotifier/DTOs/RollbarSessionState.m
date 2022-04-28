//
//  RollbarSessionState.m
//  
//
//  Created by Andrey Kornich on 2022-04-27.
//

#import "RollbarSessionState.h"

#pragma mark - constants

static NSString *const DEFAULT_USERNAME = nil;
static NSString *const DEFAULT_EMAIL = nil;



#pragma mark - data field keys

static NSString * const DFK_OS_VERSION = @"os_version";
static NSString * const DFK_APP_VERSION = @"app_version";
static NSString * const DFK_SESSION_TIMESTAMP = @"session_timestamp";
static NSString * const DFK_APP_MEMORY_WARNING_TIMESTAMP = @"app_memory_warning_timestamp";
static NSString * const DFK_APP_TERMINATION_TIMESTAMP = @"app_termination_timestamp";
static NSString * const DFK_APP_IN_BACKGROUND_FLAG = @"app_in_background";


@implementation RollbarSessionState

#pragma mark - property accessors

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


- (BOOL)appInBackgroundFlag {
    
    BOOL result = [self safelyGetBoolByKey:DFK_APP_IN_BACKGROUND_FLAG withDefault:NO];
    return result;
}

- (void)setAppInBackgroundFlag:(BOOL)value {
    
    [self setBool:value forKey:DFK_APP_IN_BACKGROUND_FLAG];
}

@end
