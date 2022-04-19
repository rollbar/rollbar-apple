#import "RollbarDeveloperOptions.h"

#pragma mark - constants

static BOOL const DEFAULT_ENABLED_FLAG = YES;
static BOOL const DEFAULT_TRANSMIT_FLAG = YES;
static BOOL const DEFAULT_SUPPRESS_SDK_INFO_LOGGING_FLAG = NO;
static BOOL const DEFAULT_LOG_PAYLOADS_FLAG = NO;
static NSString * const DEFAULT_PAYLOAD_LOG_FILE = @"rollbar.payloads";

#pragma mark - data field keys

static NSString * const DFK_ENABLED = @"enabled";
static NSString * const DFK_TRANSMIT = @"transmit";
static NSString * const DFK_SUPPRESS_SDK_INFO_LOGGING = @"suppressSdkInfoLogging";
static NSString * const DFK_LOG_PAYLOAD = @"logPayload";
static NSString * const DFK_LOG_PAYLOAD_FILE = @"logPayloadFile";

#pragma mark - class implementation

@implementation RollbarDeveloperOptions

#pragma mark - initializers

- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
                     logPayload:(BOOL)logPayload
                 payloadLogFile:(NSString *)payloadLogFile {
    
    self = [super initWithDictionary:@{
        DFK_ENABLED:[NSNumber numberWithBool:enabled],
        DFK_TRANSMIT:[NSNumber numberWithBool:transmit],
        DFK_SUPPRESS_SDK_INFO_LOGGING:[NSNumber numberWithBool:DEFAULT_SUPPRESS_SDK_INFO_LOGGING_FLAG],
        DFK_LOG_PAYLOAD:[NSNumber numberWithBool:logPayload],
        DFK_LOG_PAYLOAD_FILE:payloadLogFile
    }];
    return self;
}

- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
                     logPayload:(BOOL)logPayload {
    
    return [self initWithEnabled:enabled
                        transmit:transmit
                      logPayload:logPayload
                  payloadLogFile:DEFAULT_PAYLOAD_LOG_FILE];
}

- (instancetype)initWithEnabled:(BOOL)enabled {
    
    return [self initWithEnabled:enabled
                        transmit:DEFAULT_TRANSMIT_FLAG
                      logPayload:DEFAULT_LOG_PAYLOADS_FLAG];
}

- (instancetype)init {
    return [self initWithEnabled:DEFAULT_ENABLED_FLAG];
}

#pragma mark - property accessors

- (BOOL)enabled {
    NSNumber *result = [self safelyGetNumberByKey:DFK_ENABLED];
    return [result boolValue];
}

- (void)setEnabled:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_ENABLED];
}

- (BOOL)transmit {
    NSNumber *result = [self safelyGetNumberByKey:DFK_TRANSMIT];
    return [result boolValue];
}

- (void)setTransmit:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_TRANSMIT];
}

- (BOOL)suppressSdkInfoLogging {
    NSNumber *result = [self safelyGetNumberByKey:DFK_SUPPRESS_SDK_INFO_LOGGING];
    return [result boolValue];
}

- (void)setSuppressSdkInfoLogging:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_SUPPRESS_SDK_INFO_LOGGING];
}

- (BOOL)logPayload {
    NSNumber *result = [self safelyGetNumberByKey:DFK_LOG_PAYLOAD];
    return [result boolValue];
}

- (void)setLogPayload:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_LOG_PAYLOAD];
}

- (NSString *)payloadLogFile {
    NSString *result = [self safelyGetStringByKey:DFK_LOG_PAYLOAD_FILE];
    return result;
}

- (void)setPayloadLogFile:(NSString *)value {
    [self setString:value forKey:DFK_LOG_PAYLOAD_FILE];
}

@end
