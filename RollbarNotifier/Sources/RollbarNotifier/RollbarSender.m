#import "RollbarSender.h"
#import "RollbarConfig.h"
#import "RollbarDestination.h"
#import "RollbarProxy.h"
#import "RollbarDeveloperOptions.h"
#import "RollbarPayloadPostReply.h"
#import "RollbarNotifierFiles.h"
#import "RollbarInternalLogging.h"

@implementation RollbarSender

+ (void)trace:(nonnull NSString *)message
  withOptions:(nullable RollbarDeveloperOptions *)developerOptions {
    
    if (!developerOptions) {
        // then, let's use default developer options:
        developerOptions = [RollbarDeveloperOptions new];
    }
    
    if (NO == developerOptions.suppressSdkInfoLogging) {
        RBLog(message);
    }
}

+ (void)assertError:(nonnull NSString *)error
        withOptions:(nullable RollbarDeveloperOptions *)developerOptions {

    [RollbarSender trace:error withOptions:developerOptions];
    
    NSAssert(false, error);
}

- (nullable RollbarPayloadPostReply *)sendPayload:(nonnull NSData *)payload
                                      usingConfig:(nonnull RollbarConfig *)config
{
    RollbarPayloadPostReply *reply;
    
    if (config.developerOptions.transmit) {
        reply = [self transmitPayload:payload
                        toDestination:config.destination
                usingDeveloperOptions:config.developerOptions
                 andHttpProxySettings:config.httpProxy
                andHttpsProxySettings:config.httpsProxy];
    } else {
        reply = [RollbarPayloadPostReply greenReply]; // we just successfully short-circuit here...
    }
    
    NSString *payloadString = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];

    if (reply && reply.statusCode == 200) {
        NSUInteger truncateIndex = MIN(payloadString.length, 256);
        NSString *truncatedString = [payloadString substringToIndex:truncateIndex];
        [RollbarSender trace:[NSString stringWithFormat:@"Transmitted payload: %@...", truncatedString] withOptions:config.developerOptions];
    } else if (reply) {
        [RollbarSender trace:[NSString stringWithFormat:@"Failed to transmit payload (%li status code): %@", (long)reply.statusCode, payloadString] withOptions:config.developerOptions];
    } else {
        [RollbarSender trace:[NSString stringWithFormat:@"Failed to transmit payload (no reply): %@", payloadString] withOptions:config.developerOptions];
    }

    return reply;
}

- (nullable RollbarPayloadPostReply *)transmitPayload:(nonnull NSData *)payload
                                        toDestination:(nonnull RollbarDestination  *)destination
                                usingDeveloperOptions:(nullable RollbarDeveloperOptions *)developerOptions
                                 andHttpProxySettings:(nullable RollbarProxy *)httpProxySettings
                                andHttpsProxySettings:(nullable RollbarProxy *)httpsProxySettings {

    NSAssert(payload, @"The payload must be initialized!");
    
    NSAssert(destination, @"The destination must be initialized!");
    NSAssert(destination.endpoint, @"The destination endpoint must be initialized!");
    NSAssert(destination.accessToken, @"The destination access token must be initialized!");
    
    if (!developerOptions) {
        // then, let's use default developer options:
        developerOptions = [RollbarDeveloperOptions new];
    }
    
    if (!httpProxySettings) {
        // then, let's use default proxy settingd:
        httpProxySettings = [RollbarProxy new];
    }

    if (!httpsProxySettings) {
        // then, let's use default proxy settingd:
        httpsProxySettings = [RollbarProxy new];
    }
    
    NSHTTPURLResponse *response = [self postPayload:payload
                                      toDestination:destination
                              usingDeveloperOptions:developerOptions
                               andHttpProxySettings:httpProxySettings
                              andHttpsProxySettings:httpsProxySettings];
    
    RollbarPayloadPostReply *reply = [RollbarPayloadPostReply replyFromHttpResponse:response];

    return reply;
}

- (nullable NSHTTPURLResponse *)postPayload:(nonnull NSData *)payload
                              toDestination:(nonnull RollbarDestination  *)destination
                      usingDeveloperOptions:(nonnull RollbarDeveloperOptions *)developerOptions
                       andHttpProxySettings:(nonnull RollbarProxy *)httpProxySettings
                      andHttpsProxySettings:(nonnull RollbarProxy *)httpsProxySettings {


    NSURL *url = [NSURL URLWithString:destination.endpoint];
    if (nil == url) {
        NSString *message =
        [NSString stringWithFormat:@"The destination endpoint URL is malformed: %@", destination.endpoint];
        [RollbarSender assertError:message
                       withOptions:developerOptions];
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:destination.accessToken forHTTPHeaderField:@"X-Rollbar-Access-Token"];
    [request setHTTPBody:payload];
    
    //__block BOOL result = NO;
    __block NSHTTPURLResponse *httpResponse = nil;
    
    // This requires iOS 7.0+
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    if (httpProxySettings.enabled
        || httpsProxySettings.enabled) {
        
        NSDictionary *connectionProxyDictionary =
        @{
            @"HTTPEnable"   : [NSNumber numberWithBool:httpProxySettings.enabled],
            @"HTTPProxy"    : httpProxySettings.proxyUrl,
            @"HTTPPort"     : [NSNumber numberWithUnsignedInteger:httpProxySettings.proxyPort],
            @"HTTPSEnable"  : [NSNumber numberWithBool:httpsProxySettings.enabled],
            @"HTTPSProxy"   : httpsProxySettings.proxyUrl,
            @"HTTPSPort"    : [NSNumber numberWithUnsignedInteger:httpsProxySettings.proxyPort]
        };
        
        NSURLSessionConfiguration *sessionConfig =
        [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.connectionProxyDictionary = connectionProxyDictionary;
        session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(
                                   NSData * _Nullable data,
                                   NSURLResponse * _Nullable response,
                                   NSError * _Nullable error) {
                                       httpResponse = [self checkPayloadResponse:response
                                                                           error:error
                                                                            data:data
                                                           usingDeveloperOptions:developerOptions];
                                       dispatch_semaphore_signal(sem);
                                   }];
    [dataTask resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return httpResponse;
}

- (nullable NSHTTPURLResponse *)checkPayloadResponse:(NSURLResponse *)response
                                               error:(NSError *)error
                                                data:(NSData *)data
                               usingDeveloperOptions:(nonnull RollbarDeveloperOptions *)developerOptions
{
    if (error) {
        [RollbarSender trace:@"There was an error reporting to Rollbar:" withOptions:developerOptions];
        [RollbarSender trace:[NSString stringWithFormat:@"   Error: %@", [error localizedDescription]] withOptions:developerOptions];
        return nil;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse && [httpResponse statusCode] == 200) {
        [RollbarSender trace:[NSString stringWithFormat:@"OK response from Rollar: %ld", [httpResponse statusCode]] withOptions:developerOptions];
        return httpResponse;
    }

    [RollbarSender trace:@"There was a problem reporting to Rollbar:" withOptions:developerOptions];
    [RollbarSender trace:[NSString stringWithFormat:@"   Response: %@", response] withOptions:developerOptions];
    [RollbarSender trace:[NSString stringWithFormat:@"   Response data: %@", data] withOptions:developerOptions];

    return nil;
}

@end
