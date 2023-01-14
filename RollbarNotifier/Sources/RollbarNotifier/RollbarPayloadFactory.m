#import "RollbarPayloadFactory.h"

#import "RollbarConfig.h"
#import "RollbarLoggingOptions.h"
#import "RollbarScrubbingOptions.h"
#import "RollbarDestination.h"

#import "RollbarPayload.h"
#import "RollbarBody.h"
#import "RollbarMessage.h"
#import "RollbarData.h"
#import "RollbarPerson.h"
#import "RollbarServer.h"
#import "RollbarModule.h"

#import <sys/utsname.h>

#if TARGET_OS_IOS | TARGET_OS_TV | TARGET_OS_MACCATALYST
@import UIKit;
#endif

@implementation RollbarPayloadFactory {
    
    @private
    RollbarConfig *_config; // expected to be nonnull...
    NSMutableDictionary<NSString *, id> *_osData;
}

+ (instancetype)factoryWithConfig:(nonnull RollbarConfig *)config {
    
    RollbarPayloadFactory *factory = [[RollbarPayloadFactory alloc] initWithConfig:config];
    return factory;
}

- (instancetype)initWithConfig:(nonnull RollbarConfig *)config {
    
    NSAssert(config, @"The config must be initialized!");
    
    if (self = [super init]) {
        
        self->_config = config;
    }
    
    return self;
}

#pragma mark - Patload factory methods

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                  crashReport:(nonnull NSString *)crashReport {
    
    RollbarPayload *payload = [self buildRollbarPayloadWithLevel:level
                                                         message:nil
                                                       exception:nil
                                                           error:nil
                                                           extra:nil
                                                     crashReport:crashReport
                                                         context:nil];
    return payload;
}

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                      message:(nonnull NSString *)message
                                         data:(nullable NSDictionary<NSString *, id> *)data
                                      context:(nullable NSString *)context {
    
    RollbarPayload *payload = [self buildRollbarPayloadWithLevel:level
                                                         message:message
                                                       exception:nil
                                                           error:nil
                                                           extra:data
                                                     crashReport:nil
                                                         context:context];
    return payload;
}

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                    exception:(nonnull NSException *)exception
                                         data:(nullable NSDictionary<NSString *, id> *)data
                                      context:(nullable NSString *)context {
    
    RollbarPayload *payload = [self buildRollbarPayloadWithLevel:level
                                                         message:nil
                                                       exception:exception
                                                           error:nil
                                                           extra:data
                                                     crashReport:nil
                                                         context:context];
    return payload;
}

- (nullable RollbarPayload *)payloadWithLevel:(RollbarLevel)level
                                        error:(nonnull NSError *)error
                                         data:(nullable NSDictionary<NSString *, id> *)data
                                      context:(nullable NSString *)context {
    
    RollbarPayload *payload = [self buildRollbarPayloadWithLevel:level
                                                         message:nil
                                                       exception:nil
                                                           error:error
                                                           extra:data
                                                     crashReport:nil
                                                         context:context];
    return payload;
}

#pragma mark - Payload Composition

-(nullable RollbarPayload *)buildRollbarPayloadWithLevel:(RollbarLevel)level
                                        message:(NSString *)message
                                      exception:(NSException *)exception
                                          error:(NSError *)error
                                          extra:(NSDictionary *)extra
                                    crashReport:(NSString *)crashReport
                                        context:(NSString *)context {
    
    // check critical config settings:
    if (!self->_config.destination
        || !self->_config.destination.environment
        || self->_config.destination.environment.length == 0) {
        
        return nil;
    }
    
    // compile payload data proper body:
    RollbarBody *body = [RollbarBody alloc];
    if (crashReport) {
        body = [body initWithCrashReport:crashReport];
    }
    else if (error) {
        body = [body initWithError:error];
    }
    else if (exception) {
        body = [body initWithException:exception];
    }
    else if (message) {
        body = [body initWithMessage:message];
    }
    else {
        return nil;
    }
    
    if (!body) {
        return nil;
    }
    
    // this is done only for backward compatibility for customers that used to rely on this undocumented
    // extra data with a message:
    if (message && extra) {
        [body.message setData:extra.mutableCopy byKey:@"extra"];
    }
    
    // compile payload data:
    RollbarData *data = [[RollbarData alloc] initWithEnvironment:self->_config.destination.environment
                                                            body:body];
    if (!data) {
        return nil;
    }
    
    NSMutableDictionary *customData =
    [NSMutableDictionary dictionaryWithDictionary:self->_config.customData];
    if (crashReport || exception) {
        // neither crash report no exception payload objects have placeholders for any extra data
        // or an extra message, let's preserve them as the custom data:
        if (extra) {
            customData[@"error.extra"] = extra.mutableCopy;
        }
        if (message && message.length > 0) {
            customData[@"error.message"] = message;
        }
    }
    
    data.level = level;
    data.language = RollbarAppLanguage_ObjectiveC;
    data.platform = @"client";
    data.uuid = [NSUUID UUID];
    data.custom = [[RollbarDTO alloc] initWithDictionary:customData];
    data.notifier = [self buildRollbarNotifierModule];
    data.person = [self buildRollbarPerson];
    data.server = [self buildRollbarServer];
    data.client = [self buildRollbarClient];
    if (context && context.length > 0) {
        data.context = context;
    }
    if (self->_config.loggingOptions) {
        data.framework = self->_config.loggingOptions.framework;
        if (self->_config.loggingOptions.requestId
            && (self->_config.loggingOptions.requestId.length > 0)) {
            
            [data setData:self->_config.loggingOptions.requestId byKey:@"requestId"];
        }
    }
    
    RollbarPayload *payload = [[RollbarPayload alloc] initWithAccessToken:self->_config.destination.accessToken
                                                                     data:data];
    
    return payload;
}

-(RollbarModule *)buildRollbarNotifierModule {
    
    if (self->_config.notifier && !self->_config.notifier.isEmpty) {
        
        RollbarModule *notifierModule =
        [[RollbarModule alloc] initWithDictionary:self->_config.notifier.jsonFriendlyData.copy];
        [notifierModule setData:self->_config.jsonFriendlyData byKey:@"configured_options"];
        return notifierModule;
    }
    
    return nil;
}

-(RollbarDTO *)buildRollbarClient {
    
    NSNumber *timestamp = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]];
    
    if (self->_config.loggingOptions) {
        switch (self->_config.loggingOptions.captureIp) {
            case RollbarCaptureIpType_Full:
                return [[RollbarDTO alloc] initWithDictionary:@{
                    @"timestamp": timestamp,
                    @"ios": [self buildOSData],
                    @"user_ip": @"$remote_ip"
                }];
            case RollbarCaptureIpType_Anonymize:
                return [[RollbarDTO alloc] initWithDictionary:@{
                    @"timestamp": timestamp,
                    @"ios": [self buildOSData],
                    @"user_ip": @"$remote_ip_anonymize"
                }];
            case RollbarCaptureIpType_None:
                //no op
                break;
        }
    }
    
    return [[RollbarDTO alloc] initWithDictionary:@{
        @"timestamp": timestamp,
        @"ios": [self buildOSData],
    }];
}

-(RollbarPerson *)buildRollbarPerson {
    
    if (self->_config.person && self->_config.person.ID) {
        return self->_config.person;
    }
    else {
        return nil;
    }
}

-(RollbarServer *)buildRollbarServer {
    
    if (self->_config.server && !self->_config.server.isEmpty) {
        return [[RollbarServer alloc] initWithCpu:nil
                                     serverConfig:self->_config.server];
    }
    else {
        return nil;
    }
}

-(NSDictionary<NSString *, id> *)buildOSData {
    
    //TODO: redo this implementation based on the helper utils used by RollbarSession or on RollbarSession itself...
    
    if (self->_osData) {
        return self->_osData;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *version = nil;
    if (self->_config.loggingOptions
        && self->_config.loggingOptions.codeVersion
        && self->_config.loggingOptions.codeVersion.length > 0) {
        
        version = self->_config.loggingOptions.codeVersion;
    }
    else {
        version = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    }
    
    NSString *shortVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *bundleName = [mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    NSString *bundleIdentifier = [mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceCode = [NSString stringWithCString:systemInfo.machine
                                              encoding:NSUTF8StringEncoding];
    
#if TARGET_OS_IOS | TARGET_OS_TV | TARGET_OS_MACCATALYST
    self->_osData = @{
        @"os": @"iOS",
        @"os_version": [[UIDevice currentDevice] systemVersion],
        @"device_code": deviceCode,
        @"code_version": version ? version : @"",
        @"short_version": shortVersion ? shortVersion : @"",
        @"bundle_identifier": bundleIdentifier ? bundleIdentifier : @"",
        @"app_name": bundleName ? bundleName : @""
    }.mutableCopy;
#else
    NSOperatingSystemVersion osVer = [[NSProcessInfo processInfo] operatingSystemVersion];
    self->_osData = @{
        @"os": @"macOS",
        @"os_version": [NSString stringWithFormat:@" %tu.%tu.%tu",
                        osVer.majorVersion,
                        osVer.minorVersion,
                        osVer.patchVersion
        ],
        @"device_code": deviceCode,
        @"code_version": version ? version : @"",
        @"short_version": shortVersion ? shortVersion : @"",
        @"bundle_identifier": bundleIdentifier ? bundleIdentifier : @"",
        @"app_name": bundleName ? bundleName : [[NSProcessInfo processInfo] processName]
    }.mutableCopy;
#endif
    
    return self->_osData;
}

@end
