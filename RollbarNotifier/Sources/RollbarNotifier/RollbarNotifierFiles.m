#import "RollbarNotifierFiles.h"

static NSString * const PAYLOADS_FILE_NAME = @"rollbar.payloads";

static NSString * const PAYLOADS_STORE_FILE_NAME = @"rollbar.db";

static NSString * const QUEUED_ITEMS_FILE_NAME = @"rollbar.items";
static NSString * const QUEUED_ITEMS_STATE_FILE_NAME = @"rollbar.state";

static NSString * const QUEUED_TELEMETRY_ITEMS_FILE_NAME = @"rollbar.telemetry";

static NSString * const SESSION_FILE_NAME = @"rollbar.session";
static NSString * const APP_QUIT_FILE_NAME = @"rollbar.appquit";

static NSString * const CONFIG_FILE_NAME = @"rollbar.config";

@implementation RollbarNotifierFiles

+ (nonnull NSString * const)payloadsStore {
    
    return PAYLOADS_STORE_FILE_NAME;
}

+ (nonnull NSString * const)itemsQueue {
    
    return QUEUED_ITEMS_FILE_NAME;
}

+ (nonnull NSString * const)itemsQueueState {
    
    return QUEUED_ITEMS_STATE_FILE_NAME;
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

+ (nonnull NSString * const)payloadsLog {
    
    return PAYLOADS_FILE_NAME;
}

+ (nonnull NSString * const)config {
    
    return CONFIG_FILE_NAME;
}


@end
