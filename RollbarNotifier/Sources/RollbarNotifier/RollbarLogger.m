@import Foundation;

#if TARGET_OS_IOS | TARGET_OS_TV | TARGET_OS_MACCATALYST
@import UIKit;
#endif

@import RollbarCommon;

#import "RollbarLogger.h"
#import "RollbarLogger+Extension.h"
#import "RollbarThread.h"
#import "RollbarTelemetryThread.h"
#import "RollbarReachability.h"
#import "RollbarPayloadFactory.h"
#import "RollbarTelemetry.h"
#import "RollbarPayloadTruncator.h"
#import "RollbarConfig.h"
#import "RollbarNotifierFiles.h"
#import "RollbarLoggerRegistry.h"

#import "RollbarPayloadDTOs.h"

#define MAX_PAYLOAD_SIZE 128 // The maximum payload size in kb

static NSString *payloadsFilePath = nil;
static NSString *queuedItemsFilePath = nil;

@implementation RollbarLogger {
    
    @private
    NSDictionary *m_osData;
}

#pragma mark - //TODO: to be removed

+ (instancetype)loggerWithAccessToken:(nonnull NSString *)accessToken {
    return [[RollbarLogger alloc] initWithAccessToken:accessToken];
}
+ (instancetype)loggerWithAccessToken:(nonnull NSString *)accessToken
                       andEnvironment:(nonnull NSString *)environment {
    return [[RollbarLogger alloc] initWithAccessToken:accessToken andEnvironment:environment];
}
+ (instancetype)loggerWithConfiguration:(nonnull RollbarConfig *)configuration {
    return [[RollbarLogger alloc] initWithConfiguration:configuration];
}
- (instancetype)initWithAccessToken:(NSString *)accessToken {
    RollbarConfig *config = [RollbarConfig new];
    config.destination.accessToken = accessToken;
    return [self initWithConfiguration:config];
}
- (instancetype)initWithAccessToken:(nonnull NSString *)accessToken
                     andEnvironment:(nonnull NSString *)environment {
    RollbarConfig *config = [RollbarConfig new];
    config.destination.accessToken = accessToken;
    config.destination.environment = environment;
    return [self initWithConfiguration:config];
}
- (instancetype)initWithConfiguration:(nonnull RollbarConfig *)configuration {

    if ((self = [super init])) {

        [self updateConfiguration:configuration];

        NSString *cachesDirectory = [RollbarCachesDirectory directory];
        if (nil != self.configuration.developerOptions.payloadLogFile
            && self.configuration.developerOptions.payloadLogFile.length > 0) {

            payloadsFilePath =
            [cachesDirectory stringByAppendingPathComponent:self.configuration.developerOptions.payloadLogFile];
        }
        else {

            payloadsFilePath =
            [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles payloadsLog]];
        }
    }

    return self;
}









#pragma mark - initializers

- (instancetype)initWithConfiguration:(nonnull RollbarConfig *)config
                      andLoggerRecord:(nonnull RollbarLoggerRecord *)loggerRecord {
    
    NSAssert(config, @"Config must not be null!");
    NSAssert(loggerRecord, @"LoggerRecord must not be null!");

    if ((self = [super init])) {
        
        self->_loggerRecord = loggerRecord;
        
        [self updateConfiguration:config];
        
        NSString *cachesDirectory = [RollbarCachesDirectory directory];
        if (nil != self.configuration.developerOptions.payloadLogFile
            && self.configuration.developerOptions.payloadLogFile.length > 0) {
            
            payloadsFilePath =
            [cachesDirectory stringByAppendingPathComponent:self.configuration.developerOptions.payloadLogFile];
        }
        else {
            
            payloadsFilePath =
            [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles payloadsLog]];
        }
    }
    
    return self;
}

#pragma mark - logging methods

- (void)logCrashReport:(NSString *)crashReport {

    if (YES == [self shouldSkipReporting:self.configuration.loggingOptions.crashLevel]) {
        return;
    }
    
    RollbarPayloadFactory *payloadFactory = [RollbarPayloadFactory factoryWithConfig:self.configuration];
    
    RollbarPayload *payload = [payloadFactory payloadWithLevel:self.configuration.loggingOptions.crashLevel
                                                   crashReport:crashReport];
    [self report:payload];
}

- (void)log:(RollbarLevel)level
    message:(NSString *)message
       data:(NSDictionary<NSString *, id> *)data
    context:(NSString *)context {
    
    if (YES == [self shouldSkipReporting:level]) {
        return;
    }

    RollbarPayloadFactory *payloadFactory = [RollbarPayloadFactory factoryWithConfig:self.configuration];
    
    RollbarPayload *payload = [payloadFactory payloadWithLevel:level
                                                       message:message
                                                          data:data
                                                       context:context];
    [self report:payload];
}

- (void)log:(RollbarLevel)level
  exception:(NSException *)exception
       data:(NSDictionary<NSString *, id> *)data
    context:(NSString *)context {
    
    if (YES == [self shouldSkipReporting:level]) {
        return;
    }
    
    RollbarPayloadFactory *payloadFactory = [RollbarPayloadFactory factoryWithConfig:self.configuration];
    
    RollbarPayload *payload = [payloadFactory payloadWithLevel:level
                                                     exception:exception
                                                          data:data
                                                       context:context];
    [self report:payload];
}

- (void)log:(RollbarLevel)level
      error:(NSError *)error
       data:(NSDictionary<NSString *, id> *)data
    context:(NSString *)context {

    if (YES == [self shouldSkipReporting:level]) {
        return;
    }
    
    RollbarPayloadFactory *payloadFactory = [RollbarPayloadFactory factoryWithConfig:self.configuration];
    
    RollbarPayload *payload = [payloadFactory payloadWithLevel:level
                                                         error:error
                                                          data:data
                                                       context:context];
    [self report:payload];
}

- (BOOL)shouldSkipReporting:(RollbarLevel)level {
    
    RollbarConfig *config = self.configuration;
    
    if (!config.developerOptions.enabled) {
        return YES;
    }
    
    if (level < config.loggingOptions.logLevel) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Payload queueing/reporting

- (void)report:(RollbarPayload *)payload {

    if (payload) {
        NSDictionary *payloadJsonData = payload.jsonFriendlyData;
        if (payloadJsonData) {
            [[RollbarThread sharedInstance] persistPayload:payloadJsonData];
        }
    }
}

#pragma mark - Update configuration methods

- (void)updateConfiguration:(RollbarConfig *)configuration {

    self.configuration = configuration;
}

- (void)updateAccessToken:(NSString *)accessToken {
    self.configuration.destination.accessToken = accessToken;
}

- (void)updateReportingRate:(NSUInteger)maximumReportsPerMinute {
    if (nil != self.configuration) {
        self.configuration.loggingOptions.maximumReportsPerMinute = maximumReportsPerMinute;
    }

    //[[RollbarThread sharedInstance] cancel];
    //[[RollbarThread sharedInstance] setReportingRate:maximumReportsPerMinute];
    //[[RollbarThread sharedInstance] start];
}
    
@end
