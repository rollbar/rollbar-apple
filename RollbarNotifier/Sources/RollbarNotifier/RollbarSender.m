#import "RollbarSender.h"
#import "RollbarConfig.h"
#import "RollbarDestination.h"
#import "RollbarProxy.h"
#import "RollbarDeveloperOptions.h"
#import "RollbarPayloadPostReply.h"
#import "RollbarNotifierFiles.h"
#import "RollbarInternalLogging.h"

@implementation RollbarSender

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

    return reply;
}

- (nullable RollbarPayloadPostReply *)transmitPayload:(nonnull NSData *)payload
                                        toDestination:(nonnull RollbarDestination  *)destination
                                usingDeveloperOptions:(nullable RollbarDeveloperOptions *)developerOptions
                                 andHttpProxySettings:(nullable RollbarProxy *)httpProxySettings
                                andHttpsProxySettings:(nullable RollbarProxy *)httpsProxySettings
{
    NSAssert(payload, @"The payload must be initialized!");
    NSAssert(destination, @"The destination must be initialized!");
    NSAssert(destination.endpoint, @"The destination endpoint must be initialized!");
    NSAssert(destination.accessToken, @"The destination access token must be initialized!");

    developerOptions = developerOptions ?: [RollbarDeveloperOptions new];
    httpProxySettings = httpProxySettings ?: [RollbarProxy new];
    httpsProxySettings = httpsProxySettings ?: [RollbarProxy new];

    NSHTTPURLResponse *response = [self postPayload:payload
                                      toDestination:destination
                              usingDeveloperOptions:developerOptions
                               andHttpProxySettings:httpProxySettings
                              andHttpsProxySettings:httpsProxySettings];

    return [RollbarPayloadPostReply replyFromHttpResponse:response];
}

- (nullable NSHTTPURLResponse *)postPayload:(nonnull NSData *)payload
                              toDestination:(nonnull RollbarDestination  *)destination
                      usingDeveloperOptions:(nonnull RollbarDeveloperOptions *)developerOptions
                       andHttpProxySettings:(nonnull RollbarProxy *)httpProxySettings
                      andHttpsProxySettings:(nonnull RollbarProxy *)httpsProxySettings
{
    NSURL *url = [NSURL URLWithString:destination.endpoint];
    if (url == nil) {
        RBLog(@"The destination endpoint URL is malformed: %@", destination.endpoint);
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:destination.accessToken forHTTPHeaderField:@"X-Rollbar-Access-Token"];
    [request setHTTPBody:payload];

    __block NSHTTPURLResponse *httpResponse = nil;

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    NSURLSession *session = [NSURLSession sharedSession];

    if (httpProxySettings.enabled || httpsProxySettings.enabled) {
        NSDictionary *connectionProxyDictionary = @{
            @"HTTPEnable"   : [NSNumber numberWithBool:httpProxySettings.enabled],
            @"HTTPProxy"    : httpProxySettings.proxyUrl,
            @"HTTPPort"     : [NSNumber numberWithUnsignedInteger:httpProxySettings.proxyPort],
            @"HTTPSEnable"  : [NSNumber numberWithBool:httpsProxySettings.enabled],
            @"HTTPSProxy"   : httpsProxySettings.proxyUrl,
            @"HTTPSPort"    : [NSNumber numberWithUnsignedInteger:httpsProxySettings.proxyPort]
        };

        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.connectionProxyDictionary = connectionProxyDictionary;
        session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }

    RBLog(@"\tSending payload...");
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        httpResponse = [self checkPayloadResponse:response error:error];
        dispatch_semaphore_signal(sem);
    }];

    [dataTask resume];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return httpResponse;
}

- (nullable NSHTTPURLResponse *)checkPayloadResponse:(NSURLResponse *)response error:(NSError *)error {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    if (httpResponse.statusCode == 200) {
        RBLog(@"\tOK response from Rollbar");
    } else {
        RBLog(@"\tThere was a problem reporting to Rollbar:");
        RBLog(@"\t\tError: %@", [error localizedDescription]);
        RBLog(@"\t\tResponse: %d", httpResponse.statusCode);
    }

    return httpResponse;
}

@end
