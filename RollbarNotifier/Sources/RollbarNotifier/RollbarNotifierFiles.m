#import "RollbarNotifierFiles.h"

static NSString * const PAYLOADS_STORE_FILE_NAME = @"rollbar.db";

static NSString * const INCOMING_PAYLOADS_FILE_NAME = @"rollbar.incoming";
static NSString * const TRANSMITTED_PAYLOADS_FILE_NAME = @"rollbar.transmitted";
static NSString * const DROPPED_PAYLOADS_FILE_NAME = @"rollbar.dropped";

static NSString * const QUEUED_TELEMETRY_ITEMS_FILE_NAME = @"rollbar.telemetry";

static NSString * const SESSION_FILE_NAME = @"rollbar.session";
static NSString * const APP_QUIT_FILE_NAME = @"rollbar.appquit";

static NSString * const CONFIG_FILE_NAME = @"rollbar.config";

@implementation RollbarNotifierFiles

+ (nonnull NSString * const)payloadsStore {
    
    return PAYLOADS_STORE_FILE_NAME;
}

+ (nonnull NSString * const)telemetryQueue {
    
    return QUEUED_TELEMETRY_ITEMS_FILE_NAME;
}

+ (nonnull NSString * const)runtimeSession {
    
    return SESSION_FILE_NAME;
}

+ (nonnull NSString * const)appQuit {
    
    return APP_QUIT_FILE_NAME;
}

+ (nonnull NSString * const)incomingPayloadsLog  {
    
    return INCOMING_PAYLOADS_FILE_NAME;
}

+ (nonnull NSString * const)transmittedPayloadsLog {
    
    return TRANSMITTED_PAYLOADS_FILE_NAME;
}

+ (nonnull NSString * const)droppedPayloadsLog {
    
    return DROPPED_PAYLOADS_FILE_NAME;
}

+ (nonnull NSString * const)config {
    
    return CONFIG_FILE_NAME;
}


@end
