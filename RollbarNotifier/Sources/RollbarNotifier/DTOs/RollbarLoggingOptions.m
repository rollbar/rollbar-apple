#import "RollbarLoggingOptions.h"

#pragma mark - constants

static RollbarLevel const DEFAULT_LOG_LEVEL = RollbarLevel_Info;
static RollbarLevel const DEFAULT_CRASH_LEVEL = RollbarLevel_Error;
static NSUInteger const DEFAULT_MAX_REPORTS_PER_MINUTE = 60;
static RollbarRateLimitBehavior const DEFAULT_RATE_LIMIT_BEHAVIOR = RollbarRateLimitBehavior_Drop;
static RollbarCaptureIpType const DEFAULT_IP_CAPTURE_TYPE = RollbarCaptureIpType_Full;

#if TARGET_OS_IPHONE
static NSString * const OPERATING_SYSTEM = @"ios";
#else
static NSString * const OPERATING_SYSTEM = @"macos";
#endif

#pragma mark - data field keys

static NSString * const DFK_LOG_LEVEL = @"logLevel";
static NSString * const DFK_CRASH_LEVEL = @"crashLevel";
static NSString * const DFK_MAX_REPORTS_PER_MINUTE = @"maximumReportsPerMinute";
static NSString * const DFK_RATE_LIMIT_BEHAVIOR = @"rateLimitBehavior";
static NSString * const DFK_IP_CAPTURE_TYPE = @"captureIp";
static NSString * const DFK_CODE_VERSION = @"codeVersion";
static NSString * const DFK_FRAMEWORK = @"framework";
static NSString * const DFK_REQUEST_ID = @"requestId";

#pragma mark - class implementation

@implementation RollbarLoggingOptions

#pragma mark - initializers

- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
         maximumReportsPerMinute:(NSUInteger)maximumReportsPerMinute
               rateLimitBehavior:(RollbarRateLimitBehavior)rateLimitBehavior
                       captureIp:(RollbarCaptureIpType)captureIp
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId
{
    self = [super initWithDictionary:@{
        DFK_LOG_LEVEL: [RollbarLevelUtil RollbarLevelToString:logLevel],
        DFK_CRASH_LEVEL: [RollbarLevelUtil RollbarLevelToString:crashLevel],
        DFK_MAX_REPORTS_PER_MINUTE: [NSNumber numberWithUnsignedInteger:maximumReportsPerMinute],
        DFK_RATE_LIMIT_BEHAVIOR: [NSNumber numberWithBool:rateLimitBehavior],
        DFK_IP_CAPTURE_TYPE: [RollbarCaptureIpTypeUtil CaptureIpTypeToString:DEFAULT_IP_CAPTURE_TYPE],
        DFK_CODE_VERSION: codeVersion ? codeVersion : [NSNull null],
        DFK_FRAMEWORK: framework ? framework : OPERATING_SYSTEM,
        DFK_REQUEST_ID: requestId ? requestId : [NSNull null],
    }];
    return self;
}

- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
         maximumReportsPerMinute:(NSUInteger)maximumReportsPerMinute
               rateLimitBehavior:(RollbarRateLimitBehavior)rateLimitBehavior
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId
{
    self = [self initWithLogLevel:logLevel
                       crashLevel:crashLevel
          maximumReportsPerMinute:maximumReportsPerMinute
           rateLimitBehavior:rateLimitBehavior
                        captureIp:DEFAULT_IP_CAPTURE_TYPE
                      codeVersion:codeVersion
                        framework:framework
                        requestId:requestId];
    return self;
}

- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
                       captureIp:(RollbarCaptureIpType)captureIp
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId
{
    self = [self initWithLogLevel:logLevel
                       crashLevel:crashLevel
          maximumReportsPerMinute:DEFAULT_MAX_REPORTS_PER_MINUTE
                rateLimitBehavior:DEFAULT_RATE_LIMIT_BEHAVIOR
                        captureIp:captureIp
                      codeVersion:codeVersion
                        framework:framework
                        requestId:requestId];
    return self;
}

- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
                     codeVersion:(nullable NSString *)codeVersion
                       framework:(nullable NSString *)framework
                       requestId:(nullable NSString *)requestId
{
    self = [self initWithLogLevel:logLevel
                       crashLevel:crashLevel
          maximumReportsPerMinute:DEFAULT_MAX_REPORTS_PER_MINUTE
                rateLimitBehavior:DEFAULT_RATE_LIMIT_BEHAVIOR
                        captureIp:DEFAULT_IP_CAPTURE_TYPE
                      codeVersion:codeVersion
                        framework:framework
                        requestId:requestId];
    return self;
}

- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel
         maximumReportsPerMinute:(NSUInteger)maximumReportsPerMinute
          rateLimitBehavior:(RollbarRateLimitBehavior)rateLimitBehavior
{
    self = [self initWithLogLevel:logLevel
                       crashLevel:crashLevel
          maximumReportsPerMinute:maximumReportsPerMinute
                rateLimitBehavior:rateLimitBehavior
                        captureIp:DEFAULT_IP_CAPTURE_TYPE
                      codeVersion:nil
                        framework:nil
                        requestId:nil];
    return self;
}

- (instancetype)initWithLogLevel:(RollbarLevel)logLevel
                      crashLevel:(RollbarLevel)crashLevel {
    
    return [self initWithLogLevel:logLevel
                       crashLevel:crashLevel
          maximumReportsPerMinute:DEFAULT_MAX_REPORTS_PER_MINUTE
                rateLimitBehavior:DEFAULT_RATE_LIMIT_BEHAVIOR];
}

- (instancetype)init {
    
    return [self initWithLogLevel:DEFAULT_LOG_LEVEL
                       crashLevel:DEFAULT_CRASH_LEVEL];
}

#pragma mark - property accessors

- (RollbarLevel)logLevel {
    NSString *logLevelString = [self safelyGetStringByKey:DFK_LOG_LEVEL];
    return [RollbarLevelUtil RollbarLevelFromString:logLevelString];
}

- (RollbarLevel)crashLevel {
    NSString *logLevelString = [self safelyGetStringByKey:DFK_CRASH_LEVEL];
    return [RollbarLevelUtil RollbarLevelFromString:logLevelString];
}

- (NSUInteger)maximumReportsPerMinute {
    return [self safelyGetUIntegerByKey:DFK_MAX_REPORTS_PER_MINUTE
                            withDefault:DEFAULT_MAX_REPORTS_PER_MINUTE];
}

- (RollbarRateLimitBehavior)rateLimitBehavior {
    return [self safelyGetBoolByKey:DFK_RATE_LIMIT_BEHAVIOR
                        withDefault:DEFAULT_RATE_LIMIT_BEHAVIOR];
}

- (RollbarCaptureIpType)captureIp {
    NSString *valueString = [self safelyGetStringByKey:DFK_IP_CAPTURE_TYPE];
    return [RollbarCaptureIpTypeUtil CaptureIpTypeFromString:valueString];
}

- (nullable NSString *)codeVersion {
    return [self getDataByKey:DFK_CODE_VERSION];
}

- (nullable NSString *)framework; {
    return [self getDataByKey:DFK_FRAMEWORK];
}

- (nullable NSString *)requestId {
    return [self getDataByKey:DFK_REQUEST_ID];
}

@end

@implementation RollbarMutableLoggingOptions

#pragma mark - initializers

- (instancetype)init {
    if (self = [super init]) {
        return self;
    }
    return nil;
}

#pragma mark - property accessors

@dynamic logLevel;
@dynamic crashLevel;
@dynamic maximumReportsPerMinute;
@dynamic rateLimitBehavior;
@dynamic captureIp;
@dynamic codeVersion;
@dynamic framework;
@dynamic requestId;

- (void)setLogLevel:(RollbarLevel)level {
    NSString *levelString = [RollbarLevelUtil RollbarLevelToString:level];
    [self setString:levelString forKey:DFK_LOG_LEVEL];
}

- (void)setCrashLevel:(RollbarLevel)level {
    NSString *levelString = [RollbarLevelUtil RollbarLevelToString:level];
    [self setString:levelString forKey:DFK_CRASH_LEVEL];
}

- (void)setMaximumReportsPerMinute:(NSUInteger)value {
    [self setUInteger:value forKey:DFK_MAX_REPORTS_PER_MINUTE];
}

- (void)setRateLimitBehavior:(RollbarRateLimitBehavior)behavior {
    [self setInteger:behavior forKey:DFK_RATE_LIMIT_BEHAVIOR];
}

- (void)setCaptureIp:(RollbarCaptureIpType)value {
    NSString *valueString = [RollbarCaptureIpTypeUtil CaptureIpTypeToString:value];
    [self setString:valueString forKey:DFK_IP_CAPTURE_TYPE];
}

- (void)setCodeVersion:(nullable NSString *)value {
    [self setData:value byKey:DFK_CODE_VERSION];
}

- (void)setFramework:(nullable NSString *)value {
    [self setData:value byKey:DFK_FRAMEWORK];
}

- (void)setRequestId:(nullable NSString *)value {
    [self setData:value byKey:DFK_REQUEST_ID];
}

@end
