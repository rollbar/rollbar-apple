#import "RollbarDeveloperOptions.h"
#import "../RollbarNotifierFiles.h"

#pragma mark - constants

static BOOL const DEFAULT_ENABLED_FLAG = YES;
static BOOL const DEFAULT_TRANSMIT_FLAG = YES;
static BOOL const DEFAULT_SUPPRESS_SDK_INFO_LOGGING_FLAG = NO;
static BOOL const DEFAULT_LOG_TRANSMITTED_PAYLOADS_FLAG = NO;
static BOOL const DEFAULT_LOG_DROPPED_PAYLOADS_FLAG = NO;

#pragma mark - data field keys

static NSString * const DFK_ENABLED = @"enabled";
static NSString * const DFK_TRANSMIT = @"transmit";
static NSString * const DFK_SUPPRESS_SDK_INFO_LOGGING = @"suppressSdkInfoLogging";
static NSString * const DFK_LOG_TRANSMITTED_PAYLOADS = @"logTransmittedsPayload";
static NSString * const DFK_LOG_TRANSMITTED_PAYLOADS_FILE = @"logTransmittedPayloadsFile";
static NSString * const DFK_LOG_DROPPED_PAYLOADS = @"logDroppedsPayload";
static NSString * const DFK_LOG_DROPPED_PAYLOADS_FILE = @"logDroppedPayloadsFile";

#pragma mark - class implementation

@implementation RollbarDeveloperOptions

#pragma mark - initializers

- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
         logTransmittedPayloads:(BOOL)logTransmittedPayloads
             logDroppedPayloads:(BOOL)logDroppedPayloads
     transmittedPayloadsLogFile:(NSString *)logTransmittedPayloadsFile
         droppedPayloadsLogFile:(NSString *)logDroppedPayloadsFile {
    
    self = [super initWithDictionary:@{
        DFK_ENABLED:[NSNumber numberWithBool:enabled],
        DFK_TRANSMIT:[NSNumber numberWithBool:transmit],
        DFK_SUPPRESS_SDK_INFO_LOGGING:[NSNumber numberWithBool:DEFAULT_SUPPRESS_SDK_INFO_LOGGING_FLAG],
        DFK_LOG_TRANSMITTED_PAYLOADS:[NSNumber numberWithBool:logTransmittedPayloads],
        DFK_LOG_DROPPED_PAYLOADS:[NSNumber numberWithBool:logDroppedPayloads],
        DFK_LOG_TRANSMITTED_PAYLOADS_FILE:logTransmittedPayloadsFile,
        DFK_LOG_DROPPED_PAYLOADS_FILE:logDroppedPayloadsFile
    }];
    return self;
}

- (instancetype)initWithEnabled:(BOOL)enabled
                       transmit:(BOOL)transmit
         logTransmittedPayloads:(BOOL)logTransmittedPayloads
             logDroppedPayloads:(BOOL)logDroppedPayloads {
    
    return [self initWithEnabled:enabled
                        transmit:transmit
          logTransmittedPayloads:logTransmittedPayloads
              logDroppedPayloads:logDroppedPayloads
      transmittedPayloadsLogFile:[RollbarNotifierFiles transmittedPayloadsLog]
          droppedPayloadsLogFile:[RollbarNotifierFiles droppedPayloadsLog]
    ];
}

- (instancetype)initWithEnabled:(BOOL)enabled {
    
    return [self initWithEnabled:enabled
                        transmit:DEFAULT_TRANSMIT_FLAG
          logTransmittedPayloads:DEFAULT_LOG_TRANSMITTED_PAYLOADS_FLAG
              logDroppedPayloads:DEFAULT_LOG_DROPPED_PAYLOADS_FLAG];
}

- (instancetype)init {
    return [self initWithEnabled:DEFAULT_ENABLED_FLAG];
}

#pragma mark - property accessors

- (BOOL)enabled {
    NSNumber *result = [self safelyGetNumberByKey:DFK_ENABLED];
    return [result boolValue];
}

- (BOOL)transmit {
    NSNumber *result = [self safelyGetNumberByKey:DFK_TRANSMIT];
    return [result boolValue];
}

- (BOOL)suppressSdkInfoLogging {
    NSNumber *result = [self safelyGetNumberByKey:DFK_SUPPRESS_SDK_INFO_LOGGING];
    return [result boolValue];
}

- (BOOL)logTransmittedPayloads {
    NSNumber *result = [self safelyGetNumberByKey:DFK_LOG_TRANSMITTED_PAYLOADS];
    return [result boolValue];
}

- (NSString *)transmittedPayloadsLogFile {
    NSString *result = [self safelyGetStringByKey:DFK_LOG_TRANSMITTED_PAYLOADS_FILE];
    return result;
}

- (BOOL)logDroppedPayloads {
    NSNumber *result = [self safelyGetNumberByKey:DFK_LOG_DROPPED_PAYLOADS];
    return [result boolValue];
}

- (NSString *)droppedPayloadsLogFile {
    NSString *result = [self safelyGetStringByKey:DFK_LOG_DROPPED_PAYLOADS_FILE];
    return result;
}

@end

@implementation RollbarMutableDeveloperOptions

@dynamic enabled;
@dynamic transmit;
@dynamic suppressSdkInfoLogging;
@dynamic logTransmittedPayloads;
@dynamic transmittedPayloadLogFile;
@dynamic logDroppedPayloads;
@dynamic droppedPayloadLogFile;

#pragma mark - property accessors

- (void)setEnabled:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_ENABLED];
}

- (void)setTransmit:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_TRANSMIT];
}

- (void)setSuppressSdkInfoLogging:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_SUPPRESS_SDK_INFO_LOGGING];
}

- (void)setLogTransmittedPayloads:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_LOG_TRANSMITTED_PAYLOADS];
}

- (void)setTransmittedPayloadsLogFile:(NSString *)value {
    [self setString:value forKey:DFK_LOG_TRANSMITTED_PAYLOADS_FILE];
}

- (void)setLogDroppedPayloads:(BOOL)value {
    [self setNumber:[[NSNumber alloc] initWithBool:value] forKey:DFK_LOG_DROPPED_PAYLOADS];
}

- (void)setDroppedPayloadsLogFile:(NSString *)value {
    [self setString:value forKey:DFK_LOG_DROPPED_PAYLOADS_FILE];
}

@end
