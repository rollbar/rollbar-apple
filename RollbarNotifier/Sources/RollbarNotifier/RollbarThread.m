@import RollbarCommon;

#import "RollbarThread.h"
#import "RollbarLogger.h"
#import "RollbarConfig.h"
#import "RollbarDeveloperOptions.h"
#import "RollbarReachability.h"
#import "RollbarTelemetry.h"
#import "RollbarTelemetryOptions.h"
#import "RollbarNotifierFiles.h"
#import "RollbarPayload.h"
#import "RollbarPayloadTruncator.h"
#import "RollbarData.h"
#import "RollbarModule.h"
#import "RollbarDestination.h"
#import "RollbarProxy.h"

static NSUInteger MAX_RETRY_COUNT = 5;

/// Rollbar API Service enforced payload rate limit:
static NSString * const RESPONSE_HEADER_RATE_LIMIT = @"x-rate-limit-limit";
/// Rollbar API Service enforced remaining payload count until the limit is reached:
static NSString * const RESPONSE_HEADER_REMAINING_COUNT = @"x-rate-limit-remaining";
/// Rollbar API Service enforced rate limit reset time for the current limit window:
static NSString * const RESPONSE_HEADER_RESET_TIME = @"x-rate-limit-reset";
/// Rollbar API Service enforced rate limit remaining seconds of the current limit window:
static NSString * const RESPONSE_HEADER_REMAINING_SECONDS = @"x-rate-limit-remaining-seconds";

@implementation RollbarThread {

@private
    //RollbarLogger *_logger;
    NSUInteger _maxReportsPerMinute;
    NSTimer *_timer;
    
    NSString *_queuedItemsFilePath;
    NSString *_stateFilePath;
    NSMutableDictionary *_queueState;
    NSDate *_nextSendTime;

#if !TARGET_OS_WATCH
    RollbarReachability *_reachability;
    BOOL _isNetworkReachable;
#endif
    
}

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        object:(nullable id)argument {

    if ((self = [super initWithTarget:self
                             selector:@selector(run)
                               object:nil])) {
        
        [self setupDataStorage];
        
        self->_maxReportsPerMinute = 60;
        self->_reachability = nil;
        self->_isNetworkReachable = YES;
        self->_nextSendTime = [[NSDate alloc] init];

        self.name = [RollbarThread rollbar_objectClassName];//NSStringFromClass([RollbarThread class]);
        self.active = YES;
        
        
#if !TARGET_OS_WATCH
        // Listen for reachability status so that the items are only sent when the internet is available:
        self->_reachability = [RollbarReachability reachabilityForInternetConnection];
        self->_isNetworkReachable = [self->_reachability isReachable];
        
        __weak typeof(self) weakSelf = self;
        //OR __unsafe_unretained typeof(self) weakSelf = self;
        self->_reachability.reachableBlock = ^(RollbarReachability*reach) {
            [weakSelf captureTelemetryDataForNetwork:true];
            self->_isNetworkReachable = YES;
        };
        self->_reachability.unreachableBlock = ^(RollbarReachability*reach) {
            [weakSelf captureTelemetryDataForNetwork:false];
            self->_isNetworkReachable = NO;
        };
        
        [self->_reachability startNotifier];
#endif

    }
    
    return self;
}

- (void)setupDataStorage {
    
    // create working cache directory:
    [RollbarCachesDirectory ensureCachesDirectoryExists];
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    
    // make sure we have all the data files set:
    self->_queuedItemsFilePath =
    [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles itemsQueue]];
    self->_stateFilePath =
    [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles itemsQueueState]];
//    payloadsFilePath =
//    [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles payoadsLog]];
    
    // either create or overwrite the payloads log file:
//    [[NSFileManager defaultManager] createFileAtPath:payloadsFilePath
//                                            contents:nil
//                                          attributes:nil];
    
    // create the queued items file if does not exist already:
    if (![[NSFileManager defaultManager] fileExistsAtPath:self->_queuedItemsFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:self->_queuedItemsFilePath
                                                contents:nil
                                              attributes:nil];
    }
    
    // create state tracking file if does not exist already:
    if ([[NSFileManager defaultManager] fileExistsAtPath:self->_stateFilePath]) {
        NSData *stateData = [NSData dataWithContentsOfFile:self->_stateFilePath];
        if (stateData) {
            
            NSDictionary *state = [NSJSONSerialization JSONObjectWithData:stateData
                                                                  options:0
                                                                    error:nil];
            self->_queueState = [state mutableCopy];
        } else {
            
            RollbarSdkLog(@"There was an error restoring saved queue state");
        }
    }
    if (!self->_queueState) {
        
        self->_queueState = [@{
            @"offset": [NSNumber numberWithUnsignedInt:0],
            @"retry_count": [NSNumber numberWithUnsignedInt:0]
        } mutableCopy];
        
        [self saveQueueState];
    }
}

- (void)saveQueueState {

    NSError *error;
    NSData *data = [NSJSONSerialization rollbar_dataWithJSONObject:self->_queueState
                                                           options:0
                                                             error:&error
                                                              safe:true];
    if (error) {
        
        RollbarSdkLog(@"Error: %@", [error localizedDescription]);
    }
    [data writeToFile:self->_stateFilePath atomically:YES];
}

- (void)setReportingRate:(NSUInteger)reportsPerMinute {
 
//    NSAssert(reportsPerMinute > 0, @"reportsPerMinute must be greater than zero!");
//    
//    BOOL wasExecuting = self.isExecuting;
//    if (wasExecuting) {
//        
//        [self cancel];
//    }
//
//    if(reportsPerMinute > 0) {
//        _maxReportsPerMinute = reportsPerMinute;
//    } else {
//        _maxReportsPerMinute = 60;
//    }
//    
//    self.active = YES;
//    
//    if (wasExecuting) {
//        
//        [self start];
//    }
}

- (void)checkItems {
    
    if (self.cancelled) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        [NSThread exit];
    }
    
    @autoreleasepool {
        
//        if ((nil != _logger) && (NO == _logger.configuration.developerOptions.suppressSdkInfoLogging)) {
//        
//            RollbarSdkLog(@"Checking items...");
//        }
        
        [self processSavedItems];
    }
}

- (void)run {
    
    @autoreleasepool {
        
        NSTimeInterval timeIntervalInSeconds = 60.0 / _maxReportsPerMinute;
        
        _timer = [NSTimer timerWithTimeInterval:timeIntervalInSeconds
                                        target:self
                                      selector:@selector(checkItems)
                                      userInfo:nil
                                       repeats:YES
                 ];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
        
        while (self.active) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

- (void)processSavedItems {
    
#if !TARGET_OS_WATCH
    if (!self->_isNetworkReachable) {
        RollbarSdkLog(@"Processing saved items: no network!");
        // Don't attempt sending if the network is known to be not reachable
        return;
    }
#endif
    
    NSUInteger startOffset = [self->_queueState[@"offset"] unsignedIntegerValue];
    
    NSFileHandle *fileHandle =
    [NSFileHandle fileHandleForReadingAtPath:self->_queuedItemsFilePath];
    [fileHandle seekToEndOfFile];
    __block unsigned long long fileLength = [fileHandle offsetInFile];
    [fileHandle closeFile];
    
    if (!fileLength) {
        
//        if (NO == self.configuration.developerOptions.suppressSdkInfoLogging) {
//
//            RollbarSdkLog(@"Processing saved items: no queued items in the file!");
//        }
        return;
    }
    
    // Empty out the queued item file if all items have been processed already
    if (startOffset == fileLength) {
        [@"" writeToFile:self->_queuedItemsFilePath
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:nil];
        
        self->_queueState[@"offset"] = [NSNumber numberWithUnsignedInteger:0];
        self->_queueState[@"retry_count"] = [NSNumber numberWithUnsignedInteger:0];
        [self saveQueueState];
//        if (NO == self.configuration.developerOptions.suppressSdkInfoLogging) {
//
//            RollbarSdkLog(@"Processing saved items: emptied the queued items file.");
//        }
        
        return;
    }
    
    // Iterate through the items file and send the items in batches.
    RollbarFileReader *reader =
    [[RollbarFileReader alloc] initWithFilePath:self->_queuedItemsFilePath
                                      andOffset:startOffset];
    [reader enumerateLinesUsingBlock:^(NSString *line, NSUInteger nextOffset, BOOL *stop) {
        
        NSData *lineData = [line dataUsingEncoding:NSUTF8StringEncoding];
        if (!lineData) {
            // All we can do is ignore this line
            RollbarSdkLog(@"Error converting file line to NSData: %@", line);
            return;
        }
        NSError *error;
        NSJSONReadingOptions serializationOptions = (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves);
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:lineData
                                                                options:serializationOptions
                                                                  error:&error];
        
        if (!payload) {
            // Ignore this line if it isn't valid json and proceed to the next line
            RollbarSdkLog(@"Error restoring data from file to JSON: %@", error);
            RollbarSdkLog(@"Raw data from file failed conversion to JSON:");
            RollbarSdkLog(@"%@", lineData);
            //            RollbarSdkLog(@"   error code: %@", error.code);
            //            RollbarSdkLog(@"   error domain: %@", error.domain);
            //            RollbarSdkLog(@"   error description: %@", error.description);
            //            RollbarSdkLog(@"   error localized description: %@", error.localizedDescription);
            //            RollbarSdkLog(@"   error failure reason: %@", error.localizedFailureReason);
            //            RollbarSdkLog(@"   error recovery option: %@", error.localizedRecoveryOptions);
            //            RollbarSdkLog(@"   error recovery suggestion: %@", error.localizedRecoverySuggestion);
            return;
        }
        
        BOOL shouldContinue = [self sendItem:payload nextOffset:nextOffset];
        
        if (!shouldContinue) {
            // Stop processing the file so that the current file offset will be
            // retried next time the file is processed
            *stop = YES;
            return;
        }
        
        // The file has had items added since we started iterating through it,
        // update the known file length to equal the next offset
        if (nextOffset > fileLength) {
            fileLength = nextOffset;
        }
        
    }];
}

- (BOOL)sendItem:(NSDictionary *)payload
      nextOffset:(NSUInteger)nextOffset {
    
    RollbarPayload *rollbarPayload =
    [[RollbarPayload alloc] initWithDictionary:[payload copy]];
    if (nil == rollbarPayload) {
        
        RollbarSdkLog(
                      @"Couldn't init and send RollbarPayload with data: %@",
                      payload
                      );
        //        queueState[@"offset"] = [NSNumber numberWithUnsignedInteger:nextOffset];
        //        queueState[@"retry_count"] = [NSNumber numberWithUnsignedInteger:0];
        //        [RollbarLogger saveQueueState];
        return YES; // no retry needed
    }
    
    NSMutableDictionary *newPayload =
    [NSMutableDictionary dictionaryWithDictionary:payload];
    [RollbarPayloadTruncator truncatePayload:newPayload];
    if (nil == newPayload) {
        
        RollbarSdkLog(
                      @"Couldn't send truncated payload that is nil"
                      );
        //        queueState[@"offset"] = [NSNumber numberWithUnsignedInteger:nextOffset];
        //        queueState[@"retry_count"] = [NSNumber numberWithUnsignedInteger:0];
        //        [RollbarLogger saveQueueState];
        return YES; // no retry needed
    }
    
    NSError *error;
    NSData *jsonPayload = [NSJSONSerialization rollbar_dataWithJSONObject:newPayload
                                                                  options:0
                                                                    error:&error
                                                                     safe:true];
    if (nil == jsonPayload) {
        
        RollbarSdkLog(
                      @"Couldn't send jsonPayload that is nil"
                      );
        if (nil != error) {
            
            RollbarSdkLog(
                          @"   DETAILS: an error while generating JSON data: %@",
                          error
                          );
        }
        //        queueState[@"offset"] = [NSNumber numberWithUnsignedInteger:nextOffset];
        //        queueState[@"retry_count"] = [NSNumber numberWithUnsignedInteger:0];
        //        [RollbarLogger saveQueueState];
        return YES; // no retry needed
    }
    
    if (NSOrderedDescending != [self->_nextSendTime compare: [[NSDate alloc] init] ]) {
        
        NSUInteger retryCount =
        [self->_queueState[@"retry_count"] unsignedIntegerValue];
        
        RollbarConfig *rollbarConfig =
        [[RollbarConfig alloc] initWithDictionary:rollbarPayload.data.notifier.jsonFriendlyData[@"configured_options"]];
        
        if (0 == retryCount && YES == rollbarConfig.developerOptions.logPayload) {
            
            if (NO == rollbarConfig.developerOptions.suppressSdkInfoLogging) {
                
                RollbarSdkLog(@"About to send payload: %@",
                              [[NSString alloc] initWithData:jsonPayload
                                                    encoding:NSUTF8StringEncoding]
                              );
            }
            
            // - save this payload into a proper payloads log file:
            //*****************************************************
            
            // compose the payloads log file path:
            NSString *cachesDirectory = [RollbarCachesDirectory directory];
            NSString *payloadsLogFilePath =
            [cachesDirectory stringByAppendingPathComponent:rollbarConfig.developerOptions.payloadLogFile];
            
            [RollbarFileWriter appendSafelyData:jsonPayload toFile:payloadsLogFilePath];
        }
        
        BOOL success =
        rollbarConfig ? [self sendPayload:jsonPayload usingConfig:rollbarConfig]
        : [self sendPayload:jsonPayload]; // backward compatibility with just upgraded very old SDKs...
        
        if (!success) {
            
            if (retryCount < MAX_RETRY_COUNT) {
                
                self->_queueState[@"retry_count"] =
                [NSNumber numberWithUnsignedInteger:retryCount + 1];
                
                [self saveQueueState];
                
                // Return NO so that the current batch will be retried next time
                return NO;
            }
        }
    }
    else {
        
        RollbarSdkLog(
                      @"Omitting payload until nextSendTime is reached: %@",
                      [[NSString alloc] initWithData:jsonPayload encoding:NSUTF8StringEncoding]
                      );
    }
    
    self->_queueState[@"offset"] = [NSNumber numberWithUnsignedInteger:nextOffset];
    self->_queueState[@"retry_count"] = [NSNumber numberWithUnsignedInteger:0];
    [self saveQueueState];
    
    return YES;
}

- (BOOL)sendPayload:(nonnull NSData *)payload
        usingConfig:(nonnull RollbarConfig  *)config {
    
    if (!payload || !config) {
        
        return NO;
    }
    
    NSURL *url = [NSURL URLWithString:config.destination.endpoint];
    if (nil == url) {
        return NO;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:config.destination.accessToken forHTTPHeaderField:@"X-Rollbar-Access-Token"];
    [request setHTTPBody:payload];
    
    if (YES == config.developerOptions.logPayload) {
        NSString *payloadString = [[NSString alloc]initWithData:payload
                                                       encoding:NSUTF8StringEncoding
        ];
        NSLog(@"%@", payloadString);
        //TODO: if config.developerOptions.logPayloadFile is defined, save the payload into the file...
    }
    
    if (NO == config.developerOptions.transmit) {
        return YES; // we just successfully short-circuit here...
    }
    
    __block BOOL result = NO;
    
    // This requires iOS 7.0+
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    if (config.httpProxy.enabled
        || config.httpsProxy.enabled) {
        
        NSDictionary *connectionProxyDictionary =
        @{
            @"HTTPEnable"   : [NSNumber numberWithBool:config.httpProxy.enabled],
            @"HTTPProxy"    : config.httpProxy.proxyUrl,
            @"HTTPPort"     : [NSNumber numberWithUnsignedInteger:config.httpProxy.proxyPort],
            @"HTTPSEnable"  : [NSNumber numberWithBool:config.httpsProxy.enabled],
            @"HTTPSProxy"   : config.httpsProxy.proxyUrl,
            @"HTTPSPort"    : [NSNumber numberWithUnsignedInteger:config.httpsProxy.proxyPort]
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
                                       result = [self checkPayloadResponse:response
                                                                     error:error
                                                                      data:data];
                                       dispatch_semaphore_signal(sem);
                                   }];
    [dataTask resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    return result;
}

/// This is a DEPRECATED method left for some backward compatibility for very old clients eventually moving to this more recent implementation.
/// Use/maintain sendPayload:usingConfig: instead!
- (BOOL)sendPayload:(NSData *)payload {
    
    return NO;
//    if ((nil == payload)
//        || (nil == self.configuration)
//        || (nil == self.configuration.destination)
//        || (nil == self.configuration.destination.endpoint)
//        || (nil == self.configuration.destination.accessToken)
//        || (0 == self.configuration.destination.endpoint.length)
//        || (0 == self.configuration.destination.accessToken.length)
//        ) {
//
//        return NO;
//    }
//
//    NSURL *url = [NSURL URLWithString:self.configuration.destination.endpoint];
//    if (nil == url) {
//        return NO;
//    }
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:self.configuration.destination.accessToken forHTTPHeaderField:@"X-Rollbar-Access-Token"];
//    [request setHTTPBody:payload];
//
//    if (YES == self.configuration.developerOptions.logPayload) {
//        NSString *payloadString = [[NSString alloc]initWithData:payload
//                                                       encoding:NSUTF8StringEncoding
//        ];
//        NSLog(@"%@", payloadString);
//        //TODO: if self.configuration.logPayloadFile is defined, save the payload into the file...
//    }
//
//    if (NO == self.configuration.developerOptions.transmit) {
//        return YES; // we just successfully short-circuit here...
//    }
//
//    __block BOOL result = NO;
//
//    // This requires iOS 7.0+
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//
//    NSURLSession *session = [NSURLSession sharedSession];
//
//    if (self.configuration.httpProxy.enabled
//        || self.configuration.httpsProxy.enabled) {
//
//        NSDictionary *connectionProxyDictionary =
//        @{
//            @"HTTPEnable"   : [NSNumber numberWithInt:self.configuration.httpProxy.enabled],
//            @"HTTPProxy"    : self.configuration.httpProxy.proxyUrl,
//            @"HTTPPort"     : @(self.configuration.httpProxy.proxyPort),
//            @"HTTPSEnable"  : [NSNumber numberWithInt:self.configuration.httpsProxy.enabled],
//            @"HTTPSProxy"   : self.configuration.httpsProxy.proxyUrl,
//            @"HTTPSPort"    : @(self.configuration.httpsProxy.proxyPort)
//        };
//
//        NSURLSessionConfiguration *sessionConfig =
//        [NSURLSessionConfiguration ephemeralSessionConfiguration];
//        sessionConfig.connectionProxyDictionary = connectionProxyDictionary;
//        session = [NSURLSession sessionWithConfiguration:sessionConfig];
//    }
//
//    NSURLSessionDataTask *dataTask =
//    [session dataTaskWithRequest:request
//               completionHandler:^(
//                                   NSData * _Nullable data,
//                                   NSURLResponse * _Nullable response,
//                                   NSError * _Nullable error) {
//                                       result = [self checkPayloadResponse:response
//                                                                     error:error
//                                                                      data:data];
//                                       dispatch_semaphore_signal(sem);
//                                   }];
//    [dataTask resume];
//
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//
//    return result;
}

- (BOOL)checkPayloadResponse:(NSURLResponse *)response
                       error:(NSError *)error
                        data:(NSData *)data {
    
//    if (NO == self.configuration.developerOptions.suppressSdkInfoLogging) {
//        
//        RollbarSdkLog(@"HTTP response from Rollbar: %@", response);
//    }
    
    // Lookup rate limiting headers and adjust reporting rate accordingly:
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *httpHeaders = [httpResponse allHeaderFields];
    //int rateLimit = [[httpHeaders valueForKey:RESPONSE_HEADER_RATE_LIMIT] intValue];
    int rateLimitLeft =
    [[httpHeaders valueForKey:RESPONSE_HEADER_REMAINING_COUNT] intValue];
    int rateLimitSeconds =
    [[httpHeaders valueForKey:RESPONSE_HEADER_REMAINING_SECONDS] intValue];
    if (rateLimitLeft > 0) {
        
        self->_nextSendTime = [[NSDate alloc] init];
    }
    else {
        
        self->_nextSendTime =
        [[NSDate alloc] initWithTimeIntervalSinceNow:rateLimitSeconds];
    }
    
    if (error) {
        RollbarSdkLog(@"There was an error reporting to Rollbar");
        RollbarSdkLog(@"Error: %@", [error localizedDescription]);
    } else {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if ([httpResponse statusCode] == 200) {
            
//            if (NO == self.configuration.developerOptions.suppressSdkInfoLogging) {
//
//                RollbarSdkLog(@"Success");
//            }
            return YES;
        } else {

            RollbarSdkLog(@"There was a problem reporting to Rollbar");
            if (data) {
                RollbarSdkLog(
                              @"Response: %@",
                              [NSJSONSerialization JSONObjectWithData:data
                                                              options:0
                                                                error:nil]);
            }
        }
    }
    return NO;
}

#pragma mark - Network telemetry data

- (void)captureTelemetryDataForNetwork:(BOOL)reachable {

#if !TARGET_OS_WATCH
    if ([RollbarTelemetry sharedInstance].telemetryOptions.captureConnectivity
        && self->_isNetworkReachable != reachable) {
        
        NSString *status = reachable ? @"Connected" : @"Disconnected";
        NSString *networkType = @"Unknown";
        NetworkStatus networkStatus = [self->_reachability currentReachabilityStatus];
        switch(networkStatus) {
            case ReachableViaWiFi:
                networkType = @"WiFi";
                break;
            case ReachableViaWWAN:
                networkType = @"Cellular";
                break;
            default:
                // no-op...
                break;
        }
        [[RollbarTelemetry sharedInstance] recordConnectivityEventForLevel:RollbarLevel_Warning
                                                                    status:status
                                                                 extraData:@{@"network": networkType}
        ];
    }
#endif
}

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance {
    
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singleton = [[self alloc] initWithTarget:self
                                        selector:@selector(run)
                                          object:nil];
    });
    
    return singleton;
}

@end
