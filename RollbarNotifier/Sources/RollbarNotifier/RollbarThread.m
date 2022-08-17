@import RollbarCommon;

#import "RollbarThread.h"
#import "RollbarReachability.h"
#import "RollbarTelemetry.h"
#import "RollbarNotifierFiles.h"
#import "RollbarPayloadTruncator.h"
#import "RollbarData.h"
#import "RollbarModule.h"
#import "RollbarProxy.h"
#import "RollbarSender.h"
#import "RollbarPayloadPostReply.h"
#import "RollbarRegistry.h"
#import "RollbarPayloadRepository.h"

static NSUInteger MAX_RETRY_COUNT = 5;

@implementation RollbarThread {

@private
    NSUInteger _maxReportsPerMinute;
    NSTimer *_timer;
    NSString *_payloadsRepoFilePath;
    RollbarRegistry *_registry;
    RollbarPayloadRepository *_payloadsRepo;
    
//    NSDate *_nextSendTime;
//    NSString *_queuedItemsFilePath;
//    NSString *_stateFilePath;
//    NSMutableDictionary *_queueState;

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
        
        self->_maxReportsPerMinute = 240;//60;
        self->_registry = [RollbarRegistry new];
        
#if !TARGET_OS_WATCH
        self->_reachability = nil;
        self->_isNetworkReachable = YES;
#endif
        //self->_nextSendTime = [[NSDate alloc] init];

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
    
    [self start];
    
    return self;
}

- (void)setupDataStorage {
    
    // create working cache directory:
    [RollbarCachesDirectory ensureCachesDirectoryExists];
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    
    // setup persistent payloads store/repo:
    self->_payloadsRepoFilePath =
    [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles payloadsStore]];
    self->_payloadsRepo =
    [RollbarPayloadRepository persistentRepositoryWithPath:self->_payloadsRepoFilePath];
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:self->_payloadsRepoFilePath],
             @"Resistent payloads store was not created: %@!!!", self->_payloadsRepoFilePath
             );
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

#pragma mark - payload store

- (void)persist:(nonnull RollbarPayload *)payload {
    
}


#pragma mark - persisting payload items

- (void)persistPayload:(nonnull RollbarPayload *)payload
            withConfig:(nonnull RollbarConfig *)config {
    
    [self performSelector:@selector(queuePayload_OnlyCallOnThread:)
                 onThread:[RollbarThread sharedInstance]
               withObject:@[payload, config]
            waitUntilDone:NO
    ];
}

- (void)queuePayload_OnlyCallOnThread:(nonnull NSArray *)data {
    
    NSAssert(data, @"data can not be nil");
    NSAssert(2 == data.count, @"data expected to have 2 components");
        
    RollbarPayload *payload = (RollbarPayload *)data[0];
    NSAssert(payload, @"payload can not be nil in data: %@", data);
    RollbarConfig *config = (RollbarConfig *)data[1];
    NSAssert(config, @"config can not be nil");
    if (!(payload && config)) {
        
        RollbarSdkLog(@"Couldn't queue payload %@ with config %@", payload, config);
        return;
    }
    
    NSString *destinationID = [self->_payloadsRepo getIDofDestinationWithEndpoint:config.destination.endpoint
                                                                    andAccesToken:config.destination.accessToken];
    
    NSString *configJson = [config serializeToJSONString];
    NSAssert(configJson && configJson.length > 0, @"invalid configJson!");
    if (!configJson || (0 == configJson.length)) {
        RollbarSdkLog(@"invalid configJson!");
        return;
    }
    
    //TODO: consider moving payload modifications (scrubbing and truncation) here...
    
    [payload.data.notifier setData:@"configured_options" byKey:configJson];
    NSString *payloadJson = [payload serializeToJSONString];
    NSDictionary *payloadDataRow = [self->_payloadsRepo addPayload:payloadJson
                                                        withConfig:configJson
                                                  andDestinationID:destinationID];
    if (!payloadDataRow || !payloadDataRow[@"id"]) {
        RollbarSdkLog(@"*** Couldn't add a payload to the repo: %@", payloadJson);
        RollbarSdkLog(@"*** with config: %@", configJson);
        RollbarSdkLog(@"*** with destinationID: %@", destinationID);
        RollbarSdkLog(@"*** Resulting payloadDataRow: %@", payloadDataRow);
    }
    NSAssert(payloadDataRow && payloadDataRow[@"id"], @"Couldn't add a payload to the repo: %@", payloadJson);
    
    [[RollbarTelemetry sharedInstance] clearAllData];
}

#pragma mark - processing persisted payload items

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

- (void)processSavedPayload:(nonnull NSDictionary<NSString *, NSString *> *)payloadDataRow {
    
    NSString *destinationKey = payloadDataRow[@"destination_key"];
    NSAssert(destinationKey && destinationKey.length > 0, @"destination_key is expected to be defined!");
    NSDictionary<NSString *, NSString *> *destination = [self->_payloadsRepo getDestinationByID:destinationKey];
    RollbarDestinationRecord *destinationRecord = [self->_registry getRecordForEndpoint:destination[@"endpoint"]
                                                                         andAccessToken:destination[@"access_token"]];
    NSString *configJson = payloadDataRow[@"config_json"];
    NSAssert(configJson && configJson.length > 0, @"config_json is expected to be defined!");
    RollbarConfig *config = [[RollbarConfig alloc] initWithJSONString:configJson];
    NSAssert(config, @"config is expected to be defined!");
    
    if (![destinationRecord canPostWithConfig:config]) {
        return;
    }
    
    NSString *payloadJson = payloadDataRow[@"payload_json"];
    RollbarPayload *payload = [[RollbarPayload alloc] initWithJSONString:payloadJson];
    NSAssert(payload, @"payload is expected to be defined!");
    
    
    //TODO: the following payload truncation code should eventually move to the point right before payload persistence
    //      into the repo:
    NSMutableDictionary *newPayload =
    [NSMutableDictionary dictionaryWithDictionary:payload.jsonFriendlyData];
    [RollbarPayloadTruncator truncatePayload:newPayload];
    if (nil == newPayload) {
        
        RollbarSdkLog(
                      @"Couldn't send truncated payload that is nil"
                      );
        //let's use untruncated original:
        newPayload = [NSMutableDictionary dictionaryWithDictionary:payload.jsonFriendlyData];
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
        // there is nothing we can do with this payload - let's drop it:
        RollbarSdkLog(@"Dropping unprocessable payload: %@", payloadJson);
        if (![self->_payloadsRepo removePayloadByID:payloadDataRow[@"id"]]) {
            RollbarSdkLog(@"Couldn't remove payload data row with ID: %@", payloadDataRow[@"id"]);
        }
        return;
    }
    
    if (config.developerOptions.logPayload) {
        
        if (!config.developerOptions.suppressSdkInfoLogging) {
            
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
        [cachesDirectory stringByAppendingPathComponent:config.developerOptions.payloadLogFile];
        [RollbarFileWriter appendSafelyData:jsonPayload toFile:payloadsLogFilePath];
    }


    BOOL success = config ? [self sendPayload:jsonPayload usingConfig:config]
    : [self sendPayload:jsonPayload]; // backward compatibility with just upgraded very old SDKs...
    
    if (success) {
        // we a successful sending - can remove the repo data row:
        if (![self->_payloadsRepo removePayloadByID:payloadDataRow[@"id"]]) {
            RollbarSdkLog(@"Couldn't remove payload data row with ID: %@", payloadDataRow[@"id"]);
        }
        return;
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
    
    NSArray<NSDictionary<NSString *, NSString *> *> *payloads = [self->_payloadsRepo getPayloadsWithOffset:0 andLimit:5];
    for(NSDictionary<NSString *, NSString *> *payload in payloads) {
        [self processSavedPayload:payload];
    }
}

- (BOOL)sendPayload:(nonnull NSData *)payload
        usingConfig:(nonnull RollbarConfig  *)config {
    
    if (!payload || !config) {
        
        return NO;
    }
    
    RollbarDestinationRecord *record = [self->_registry getRecordForConfig:config];
    if (![record canPost]) {
        return NO;
    }
    
    RollbarPayloadPostReply *reply = [[RollbarSender new] sendPayload:payload
                                                          usingConfig:config
    ];
    [record recordPostReply:reply];
    if (reply && (200 == reply.statusCode)) {
        return YES;
    }
    
    return NO;
}

/// This is a DEPRECATED method left for some backward compatibility for very old clients eventually moving to this more recent implementation.
/// Use/maintain sendPayload:usingConfig: instead!
- (BOOL)sendPayload:(NSData *)payload {
    
    return YES;
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
