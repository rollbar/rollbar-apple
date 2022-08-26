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

static NSTimeInterval const DEFAULT_PAYLOAD_LIFETIME_SECONDS = 24 * 60 * 60;
// hours-per day * 60 min-per-hour * 60 sec-per-min = 1 day in sec

@implementation RollbarThread {

@private
    NSUInteger _maxReportsPerMinute;
    NSTimeInterval _payloadLifetimeInSeconds;
    NSTimer *_timer;
    NSString *_payloadsRepoFilePath;
    RollbarRegistry *_registry;
    RollbarPayloadRepository *_payloadsRepo;
    
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
        self->_payloadLifetimeInSeconds = DEFAULT_PAYLOAD_LIFETIME_SECONDS;
        self->_registry = [RollbarRegistry new];
        
#if !TARGET_OS_WATCH
        self->_reachability = nil;
        self->_isNetworkReachable = YES;
#endif

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

#pragma mark - persisting payload items

- (void)persistPayload:(nonnull RollbarPayload *)payload
            withConfig:(nonnull RollbarConfig *)config {
    
    [self performSelector:@selector(queuePayload_OnlyCallOnThisThread:)
                 onThread:self //[RollbarThread sharedInstance]
               withObject:@[payload, config]
            waitUntilDone:NO
    ];
}

+ (BOOL)shouldIgnorePayload:(nonnull RollbarPayload *)payload
                 withConfig:(nonnull RollbarConfig *)config {
    
    if (config.checkIgnoreRollbarData) {
        
        BOOL shouldIgnore = NO;
        @try {
            shouldIgnore = config.checkIgnoreRollbarData(payload.data);
        }
        @catch(NSException *e) {
            RollbarSdkLog(@"checkIgnore error: %@", e.reason);
            NSAssert(false, @"Provided checkIgnore implementation throws an exception!");
            shouldIgnore = NO;
        }
        
        if (shouldIgnore) {
            
            if (config.developerOptions.logDroppedPayloads
                && config.developerOptions.incomingPayloadsLogFile
                && (config.developerOptions.incomingPayloadsLogFile.length > 0)
                ) {
                NSString *cachesDirectory = [RollbarCachesDirectory directory];
                NSString *payloadsLogFilePath =
                [cachesDirectory stringByAppendingPathComponent:config.developerOptions.incomingPayloadsLogFile];
                [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:payloadsLogFilePath];
            }
            
            if (!config.developerOptions.suppressSdkInfoLogging) {
                RollbarSdkLog(@"Dropped payload (due to checkIgnore): %@",
                              [[NSString alloc] initWithData:[payload serializeToJSONData]
                                                    encoding:NSUTF8StringEncoding]
                              );
            }
            
            return YES; // ignore == nothing to queue...
        }
    }
    
    return NO;
}

+ (nullable RollbarPayload *)modifyPayload:(nonnull RollbarPayload *)payload
                                withConfig:(nonnull RollbarConfig *)config {
    
    if (config.modifyRollbarData) {
    
        @try {
            payload.data = config.modifyRollbarData(payload.data);
        }
        @catch(NSException *e) {
            RollbarSdkLog(@"modifyRollbarData error: %@", e.reason);
            NSAssert(false, @"Provided modifyRollbarData implementation throws an exception!");
            //return null;
        }
    }
    return payload;
}

+ (nullable RollbarPayload *)scrubPayload:(nonnull RollbarPayload *)payload
                               withConfig:(nonnull RollbarConfig *)config {

    NSSet *scrubFieldsSet = [RollbarThread getScrubFields:config.dataScrubber];
    if (scrubFieldsSet.count == 0) {
        return payload;
    }
    
    NSMutableDictionary *mutableJsonFriendlyData = payload.data.jsonFriendlyData.mutableCopy;
    for (NSString *key in scrubFieldsSet) {
        if ([mutableJsonFriendlyData valueForKeyPath:key]) {
            [RollbarThread createMutableDataWithData:mutableJsonFriendlyData
                                             forPath:key];
            [mutableJsonFriendlyData setValue:@"*****"
                                   forKeyPath:key];
        }
    }
    
    payload.data = [[RollbarData alloc] initWithDictionary:mutableJsonFriendlyData];
    
    return payload;
}

+ (nonnull NSSet *)getScrubFields:(nullable RollbarScrubbingOptions *)scrubbingOptions {
    
    if (!scrubbingOptions
        || scrubbingOptions.isEmpty
        || !scrubbingOptions.enabled
        || !scrubbingOptions.scrubFields
        || scrubbingOptions.scrubFields.count == 0) {
        
        return [NSSet set];
    }
    
    NSMutableSet *actualFieldsToScrub = scrubbingOptions.scrubFields.mutableCopy;
    if (scrubbingOptions.safeListFields.count > 0) {
        // actualFieldsToScrub =
        // config.dataScrubber.scrubFields - config.dataScrubber.whitelistFields
        // while using case insensitive field name comparison:
        actualFieldsToScrub = [NSMutableSet new];
        for(NSString *key in scrubbingOptions.scrubFields) {
            BOOL isWhitelisted = false;
            for (NSString *whiteKey in scrubbingOptions.safeListFields) {
                if (NSOrderedSame == [key caseInsensitiveCompare:whiteKey]) {
                    isWhitelisted = true;
                }
            }
            if (!isWhitelisted) {
                [actualFieldsToScrub addObject:key];
            }
        }
    }
    
    return actualFieldsToScrub;
}

+ (void)createMutableDataWithData:(NSMutableDictionary *)data
                           forPath:(NSString *)path {
    
    NSArray *pathComponents = [path componentsSeparatedByString:@"."];
    NSString *currentPath = @"";
    
    for (int i=0; i<pathComponents.count; i++) {
        NSString *part = pathComponents[i];
        currentPath = i == 0 ? part
        : [NSString stringWithFormat:@"%@.%@", currentPath, part];
        id val = [data valueForKeyPath:currentPath];
        if (!val) return;
        if ([val isKindOfClass:[NSArray class]]
            && ![val isKindOfClass:[NSMutableArray class]]) {
            
            NSMutableArray *newVal = [NSMutableArray arrayWithArray:val];
            [data setValue:newVal forKeyPath:currentPath];
        } else if ([val isKindOfClass:[NSDictionary class]]
                   && ![val isKindOfClass:[NSMutableDictionary class]]) {
            
            NSMutableDictionary *newVal =
            [NSMutableDictionary dictionaryWithDictionary:val];
            [data setValue:newVal forKeyPath:currentPath];
        }
    }
}

+ (nonnull RollbarPayload *)truncatePayload:(nonnull RollbarPayload *)payload {
    
    NSMutableDictionary *newPayloadData =
    [NSMutableDictionary dictionaryWithDictionary:payload.jsonFriendlyData];
    [RollbarPayloadTruncator truncatePayload:newPayloadData];
    
    RollbarPayload *newPayload = [[RollbarPayload alloc] initWithDictionary:newPayloadData];
    if (newPayload) {
        return newPayload;
    }
    else {
        
        return payload;
    }
}

- (void)queuePayload_OnlyCallOnThisThread:(nonnull NSArray *)data {
    
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
    
    @try {
        [self savePayload:payload withConfig:config];
    } @catch (NSException *exception) {
        RollbarSdkLog(@"Payload queuing EXCEPTION: %@", exception);
    } @finally {
        [[RollbarTelemetry sharedInstance] clearAllData];
    }
}

- (void)savePayload:(nonnull RollbarPayload *)payload withConfig:(nonnull RollbarConfig *)config {
    
    if ([RollbarThread shouldIgnorePayload:payload withConfig:config]) {
        
        return;
    }
    
    payload = [RollbarThread modifyPayload:payload withConfig:config];
    if (!payload) {
        return;
    }
    
    payload = [RollbarThread scrubPayload:payload withConfig:config];
    if (!payload) {
        return;
    }
    
    payload = [RollbarThread truncatePayload:payload];
    
    NSString *destinationID = [self->_payloadsRepo getIDofDestinationWithEndpoint:config.destination.endpoint
                                                                    andAccesToken:config.destination.accessToken];
    
    NSString *configJson = [config serializeToJSONString];
    NSAssert(configJson && configJson.length > 0, @"invalid configJson!");
    if (!configJson || (0 == configJson.length)) {
        RollbarSdkLog(@"invalid configJson!");
        return;
    }
    
    //[payload.data.notifier setData:config.jsonFriendlyData byKey:@"configured_options"];
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
    else if (config.developerOptions.logIncomingPayloads) {
        NSString *logFile = config.developerOptions.incomingPayloadsLogFile;
        NSString *cachesDirectory = [RollbarCachesDirectory directory];
        NSString *logFilePath = [cachesDirectory stringByAppendingPathComponent:logFile];
        
        
        NSError *error;
        NSData *jsonPayload = [NSJSONSerialization rollbar_dataWithJSONObject:payload.jsonFriendlyData
                                                                      options:0
                                                                        error:&error
                                                                         safe:true];
        if (nil == jsonPayload) {
            RollbarSdkLog(@"ERROR: Couldn't log an incoming payload locally!");
            if (nil != error) {
                RollbarSdkLog(@"   DETAILS: an error while generating JSON data: %@", error);
            }
        }
        else {
            [RollbarFileWriter appendSafelyData:jsonPayload toFile:logFilePath];
        }
    }

    NSAssert(payloadDataRow && payloadDataRow[@"id"], @"Couldn't add a payload to the repo: %@", payloadJson);
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

- (BOOL)checkProcessStalePayload:(nonnull NSDictionary<NSString *, NSString *> *)payloadDataRow {
    
    // let's make sure we are not dealng with a stale payload:
    NSString *timestampValue = payloadDataRow[@"created_at"];
    NSScanner *scanner = [NSScanner scannerWithString:timestampValue];
    double payloadTimestamp;
    BOOL timestampParsingSuccess = [scanner scanDouble:&payloadTimestamp];
    if (!timestampParsingSuccess
        || ((payloadTimestamp + self->_payloadLifetimeInSeconds) < [NSDate date].timeIntervalSince1970)
        ) {
        // we either have some sort of timestamp corruption or
        // we are processing a stale payload let's just drop it and call it done:
        [self->_payloadsRepo removePayloadByID:payloadDataRow[@"id"]];
        
        RollbarConfig *config = [[RollbarConfig alloc] initWithJSONString:payloadDataRow[@"config_json"]];
        
        if (config && config.developerOptions.logTransmittedPayloads) {
            NSString *payloadsLogFile = config.developerOptions.droppedPayloadsLogFile;
            if (payloadsLogFile && (payloadsLogFile.length > 0)) {
                NSString *cachesDirectory = [RollbarCachesDirectory directory];
                NSString *payloadsLogFilePath = [cachesDirectory stringByAppendingPathComponent:payloadsLogFile];
                RollbarPayload *payload = [[RollbarPayload alloc] initWithJSONString:payloadDataRow[@"payload_json"]];
                [RollbarFileWriter appendSafelyData: payload.serializeToJSONData toFile:payloadsLogFilePath];
            }
        }
        
        if (config && !config.developerOptions.suppressSdkInfoLogging) {
            RollbarSdkLog(@"Dropped a stale payload: %@", payloadDataRow[@"payload_json"]);
        }
        
        return YES;
    }
    
    return NO;
}

- (void)processSavedPayload:(nonnull NSDictionary<NSString *, NSString *> *)payloadDataRow {
    
    if ([self checkProcessStalePayload:payloadDataRow]) {
        return;
    }

    NSString *destinationKey = payloadDataRow[@"destination_key"];
    NSAssert(destinationKey && destinationKey.length > 0, @"destination_key is expected to be defined!");
    NSDictionary<NSString *, NSString *> *destination = [self->_payloadsRepo getDestinationByID:destinationKey];
    NSAssert(destination, @"destination can not be nil!");
    NSAssert(destination[@"endpoint"], @"destination endpoint can not be nil!");
    NSAssert(destination[@"access_token"], @"destination access_token can not be nil!");
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
        
    NSError *error;
    NSData *jsonPayload = [NSJSONSerialization rollbar_dataWithJSONObject:payload.jsonFriendlyData
                                                                  options:0
                                                                    error:&error
                                                                     safe:true];
    if (nil == jsonPayload) {
        RollbarSdkLog(@"Couldn't send jsonPayload that is nil");
        if (nil != error) {
            RollbarSdkLog(@"   DETAILS: an error while generating JSON data: %@", error);
        }
        // there is nothing we can do with this payload - let's drop it:
        RollbarSdkLog(@"Dropping unprocessable payload: %@", payloadJson);
        if (![self->_payloadsRepo removePayloadByID:payloadDataRow[@"id"]]) {
            RollbarSdkLog(@"Couldn't remove payload data row with ID: %@", payloadDataRow[@"id"]);
        }
        return;
    }
    
    RollbarTriStateFlag success = config ? [self sendPayload:jsonPayload usingConfig:config]
    : [self sendPayload:jsonPayload]; // backward compatibility with just upgraded very old SDKs...
    
    NSString *payloadsLogFile = nil;
    NSString *sdkLogTrace = (RollbarTriStateFlag_None == success) ? nil
    : [NSString stringWithFormat:@"%@ payload: %@",
       (RollbarTriStateFlag_On == success) ? @"Transmitted" : @"Dropped",
       [[NSString alloc] initWithData:jsonPayload encoding:NSUTF8StringEncoding]
    ];
    switch(success) {
        case RollbarTriStateFlag_On:
            // The payload is fully processed and transmitted.
            // It can be removed from the repo:
            if (![self->_payloadsRepo removePayloadByID:payloadDataRow[@"id"]]) {
                RollbarSdkLog(@"Couldn't remove payload data row with ID: %@", payloadDataRow[@"id"]);
            }
            if (config.developerOptions.logTransmittedPayloads) {
                payloadsLogFile = config.developerOptions.transmittedPayloadsLogFile;
            }
            break;
        case RollbarTriStateFlag_Off:
            // The payload is fully processed but not accepted by the server due to some invalid content.
            // It must be removed from the repo:
            if (![self->_payloadsRepo removePayloadByID:payloadDataRow[@"id"]]) {
                RollbarSdkLog(@"Couldn't remove payload data row with ID: %@", payloadDataRow[@"id"]);
            }
            if (config.developerOptions.logDroppedPayloads) {
                payloadsLogFile = config.developerOptions.droppedPayloadsLogFile;
            }
            break;
        case RollbarTriStateFlag_None:
        default:
            // Nothing obviously wrong with the payload but it was not actually tranmitted successfully.
            // Let's try again some other time. Keep it in the repo for now...
            break;
    }

    if (payloadsLogFile) {
        NSString *cachesDirectory = [RollbarCachesDirectory directory];
        NSString *payloadsLogFilePath = [cachesDirectory stringByAppendingPathComponent:payloadsLogFile];
        [RollbarFileWriter appendSafelyData:jsonPayload toFile:payloadsLogFilePath];
    }
    if (!config.developerOptions.suppressSdkInfoLogging) {
        NSString *sdkLogTrace = nil;
        switch(success) {
            case RollbarTriStateFlag_On:
                RollbarSdkLog(@"Transmitted payload: %@",
                              [[NSString alloc] initWithData:jsonPayload encoding:NSUTF8StringEncoding]);
                break;
            case RollbarTriStateFlag_Off:
                RollbarSdkLog(@"Dropped payload: %@",
                              [[NSString alloc] initWithData:jsonPayload encoding:NSUTF8StringEncoding]);
                break;
            case RollbarTriStateFlag_None:
                RollbarSdkLog(@"Couldn't transmit (and will try) payload: %@",
                              [[NSString alloc] initWithData:jsonPayload encoding:NSUTF8StringEncoding]);
                break;
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
    
    NSArray<NSDictionary<NSString *, NSString *> *> *payloads = [self->_payloadsRepo getPayloadsWithOffset:0 andLimit:5];
    for(NSDictionary<NSString *, NSString *> *payload in payloads) {
        @try {
            [self processSavedPayload:payload];
        } @catch (NSException *exception) {
            RollbarSdkLog(@"Payload processing EXCEPTION: %@", exception);
        } @finally {
        }
    }
}

- (RollbarTriStateFlag)sendPayload:(nonnull NSData *)payload
                       usingConfig:(nonnull RollbarConfig  *)config {
    
    if (!payload || !config) {
        
        return RollbarTriStateFlag_Off; //obviously invalid payload to sent or invalid destination...
    }
    
    RollbarDestinationRecord *record = [self->_registry getRecordForConfig:config];
    if (![record canPost]) {
        return RollbarTriStateFlag_None; // nothing obviously wrong with the payload - just can not send at the moment
    }
    
    RollbarPayloadPostReply *reply = [[RollbarSender new] sendPayload:payload
                                                          usingConfig:config
    ];
    [record recordPostReply:reply];
    
    if (!reply) {
        return RollbarTriStateFlag_None; // nothing obviously wrong with the payload - just there was no deterministic
                                         // reply from the destination server
    }
    
    switch(reply.statusCode) {
        case 200: // OK
            return RollbarTriStateFlag_On; // the payload was successfully transmitted
        case 400: // bad request
        case 413: // request entity too large
        case 422: // unprocessable entity
            return RollbarTriStateFlag_Off; // unecceptable request/payload - should be dropped
        case 403: // access denied
        case 404: // not found
        case 429: // too many requests
        default:
            return RollbarTriStateFlag_None; // worth retrying later
    }
}

/// This is a DEPRECATED method left for some backward compatibility for very old clients eventually moving to this more recent implementation.
/// Use/maintain sendPayload:usingConfig: instead!
- (RollbarTriStateFlag)sendPayload:(NSData *)payload {
    
    return RollbarTriStateFlag_Off;
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
