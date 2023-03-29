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
#import "RollbarInternalLogging.h"
#import "RollbarInfrastructure.h"

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
                        object:(nullable id)argument
{
    self = [super initWithTarget:self
                        selector:@selector(run)
                          object:nil];
    if (self) {
        [self setupDataStorage];
        
        self->_maxReportsPerMinute = 240;
        self->_payloadLifetimeInSeconds = DEFAULT_PAYLOAD_LIFETIME_SECONDS;
        self->_registry = [RollbarRegistry new];

#if !TARGET_OS_WATCH
        self->_reachability = nil;
        self->_isNetworkReachable = YES;
#endif

        self.name = [RollbarThread rollbar_objectClassName];
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
             @"Persistent payloads store was not created: %@!!!", self->_payloadsRepoFilePath);
}

- (void)run {
    @autoreleasepool {
        _timer = [NSTimer timerWithTimeInterval:60.0 / _maxReportsPerMinute
                                         target:self
                                       selector:@selector(checkItems)
                                       userInfo:nil
                                        repeats:YES];
        
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
                 onThread:self
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
            RBErr(@"checkIgnore error: %@", e.reason);
            NSAssert(false, @"Provided checkIgnore implementation throws an exception!");
            shouldIgnore = NO;
        }
        @finally {
            return shouldIgnore;
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
            RBErr(@"modifyRollbarData error: %@", e.reason);
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
        RBErr(@"Couldn't queue payload %@ with config %@", payload, config);
        return;
    }
    
    @try {
        [self savePayload:payload withConfig:config];
    } @catch (NSException *exception) {
        RBErr(@"Payload queuing EXCEPTION: %@", exception);
    } @finally {
        [[RollbarTelemetry sharedInstance] clearAllData];
    }
}

- (void)savePayload:(nonnull RollbarPayload *)payload withConfig:(nonnull RollbarConfig *)config {
    if ([RollbarThread shouldIgnorePayload:payload withConfig:config]) {
        
        if (config.developerOptions.logIncomingPayloads) {
            NSString *logFilePath =
            [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.incomingPayloadsLogFile];
            [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
        }
        if (config.developerOptions.logDroppedPayloads) {
            NSString *logFilePath =
            [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.droppedPayloadsLogFile];
            [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
        }
        if (!config.developerOptions.suppressSdkInfoLogging) {
            RBErr(@"Dropped payload (due to checkIgnore): %@",
                  [[NSString alloc] initWithData:[payload serializeToJSONData]
                                        encoding:NSUTF8StringEncoding]);
        }
        return;
    }
    
    payload = [RollbarThread modifyPayload:payload withConfig:config];
    if (!payload) {

        if (config.developerOptions.logIncomingPayloads) {
            NSString *logFilePath =
            [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.incomingPayloadsLogFile];
            [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
        }
        if (config.developerOptions.logDroppedPayloads) {
            NSString *logFilePath =
            [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.droppedPayloadsLogFile];
            [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
        }
        if (!config.developerOptions.suppressSdkInfoLogging) {
            RBErr(@"Dropped payload (due to modifyPayload failure): %@",
                  [[NSString alloc] initWithData:[payload serializeToJSONData]
                                        encoding:NSUTF8StringEncoding]);
        }
        return;
    }
    
    payload = [RollbarThread scrubPayload:payload withConfig:config];
    if (!payload) {

        if (config.developerOptions.logIncomingPayloads) {
            NSString *logFilePath =
            [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.incomingPayloadsLogFile];
            [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
        }
        if (config.developerOptions.logDroppedPayloads) {
            NSString *logFilePath =
            [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.droppedPayloadsLogFile];
            [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
        }
        if (!config.developerOptions.suppressSdkInfoLogging) {
            RBErr(@"Dropped payload (due to scrubPayload failure): %@",
                  [[NSString alloc] initWithData:[payload serializeToJSONData]
                                        encoding:NSUTF8StringEncoding]);
        }
        return;
    }
    
    if (config.developerOptions.logIncomingPayloads) {
        NSString *logFilePath =
        [[RollbarCachesDirectory directory] stringByAppendingPathComponent:config.developerOptions.incomingPayloadsLogFile];
        [RollbarFileWriter appendSafelyData:[payload serializeToJSONData] toFile:logFilePath];
    }

    payload = [RollbarThread truncatePayload:payload];
    
    NSString *destinationID = [self->_payloadsRepo getIDofDestinationWithEndpoint:config.destination.endpoint
                                                                    andAccesToken:config.destination.accessToken];
    
    NSString *configJson = [config serializeToJSONString];
    NSAssert(configJson && configJson.length > 0, @"invalid configJson!");
    if (!configJson || (0 == configJson.length)) {
        RBErr(@"invalid configJson!");
        return;
    }

    RBLog(@"Queuing %@ (%d in queue)", payload.data.uuid, [self->_payloadsRepo getPayloadCount]);
    NSString *payloadJson = [payload serializeToJSONString];
    NSDictionary *payloadDataRow = [self->_payloadsRepo addPayload:payloadJson
                                                        withConfig:configJson
                                                  andDestinationID:destinationID];
    if (!payloadDataRow || !payloadDataRow[@"id"]) {
        RBErr(@"*** Couldn't add a payload to the repo: %@", payloadJson);
        RBErr(@"*** with config: %@", configJson);
        RBErr(@"*** with destinationID: %@", destinationID);
        RBErr(@"*** Resulting payloadDataRow: %@", payloadDataRow);
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
        [self processSavedItems];
    }
}

- (BOOL)checkProcessStalePayload:(nonnull NSDictionary<NSString *, NSString *> *)payloadDataRow {
    // let's make sure we are not dealing with a stale payload:
    NSString *timestampValue = payloadDataRow[@"created_at"];
    NSScanner *scanner = [NSScanner scannerWithString:timestampValue];
    double payloadTimestamp;
    BOOL timestampDidParse = [scanner scanDouble:&payloadTimestamp];
    BOOL isStale = (payloadTimestamp + self->_payloadLifetimeInSeconds) < [[NSDate date] timeIntervalSince1970];
    if (!timestampDidParse || isStale) {
        // we either have some sort of timestamp corruption or
        // we are processing a stale payload let's just drop it and call it done:
        [self removePayloadByID:payloadDataRow[@"id"]];

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
        
        RBLog(@"Dropped stale payload: %@", payloadDataRow[@"payload_json"]);

        return YES;
    }
    
    return NO;
}

- (void)processSavedPayload:(nonnull NSDictionary<NSString *, NSString *> *)payloadDataRow {
    if ([self checkProcessStalePayload:payloadDataRow]) {
        return;
    }

    NSDictionary<NSString *, NSString *> *destination = [self->_payloadsRepo getDestinationByID:payloadDataRow[@"destination_key"]];
    RollbarDestinationRecord *destinationRecord = [self->_registry getRecordForEndpoint:destination[@"endpoint"]
                                                                         andAccessToken:destination[@"access_token"]];
    RollbarPayload *payload = [[RollbarPayload alloc] initWithJSONString:payloadDataRow[@"payload_json"]];
    RollbarConfig *config = [[RollbarConfig alloc] initWithJSONString:payloadDataRow[@"config_json"]];

    if (![destinationRecord canPostWithConfig:config]) {
        if (self.rateLimitBehavior == RollbarRateLimitBehavior_Drop) {
            RBLog(@"Processing %@ (%d in queue)", payload.data.uuid, [self->_payloadsRepo getPayloadCount]);
            RBLog(@"\tRate limited");
            [self removePayloadByID:payloadDataRow[@"id"]];
            RBLog(@"Dropped %@", payload.data.uuid);
        }
        return;
    }

    RBLog(@"Processing %@ (%d in queue)", payload.data.uuid, [self->_payloadsRepo getPayloadCount]);

    NSError *error;
    NSData *jsonPayload = [NSJSONSerialization rollbar_dataWithJSONObject:payload.jsonFriendlyData
                                                                  options:0
                                                                    error:&error
                                                                     safe:true];
    if (jsonPayload == nil) {
        RBErr(@"Couldn't send jsonPayload that is nil");
        if (error != nil) {
            RBErr(@"\tError while generating JSON data: %@", error);
        }
        [self removePayloadByID:payloadDataRow[@"id"]];
        return;
    }

    RollbarTriStateFlag result = RollbarTriStateFlag_On;
    if (config.developerOptions.transmit) {
        result = [self sendPayload:jsonPayload toDestination:destinationRecord withConfig:config];
    }
    
    NSString *payloadsLogFile = nil;

    switch (result) {
        case RollbarTriStateFlag_On:
            // The payload is fully processed and transmitted.
            [self removePayloadByID:payloadDataRow[@"id"]];
            if (config.developerOptions.logTransmittedPayloads) {
                payloadsLogFile = config.developerOptions.transmittedPayloadsLogFile;
            }
            break;
        case RollbarTriStateFlag_Off:
            // The payload is fully processed but not accepted by the server due to some invalid content.
            [self removePayloadByID:payloadDataRow[@"id"]];
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

    RBLog([self loggableStringFromPayload:payload result:result]);
}

- (void)processSavedItems {
#if !TARGET_OS_WATCH
    if (!self->_isNetworkReachable) {
        RBLog(@"Processing saved items: no network!");
        // Don't attempt sending if the network is known to be not reachable
        return;
    }
#endif

    NSArray *payloads = [self->_payloadsRepo getPayloadsWithOffset:0 andLimit:5];
    for (NSDictionary<NSString *, NSString *> *payload in payloads) {
        @try {
            [self processSavedPayload:payload];
        } @catch (NSException *exception) {
            RBErr(@"Payload processing EXCEPTION: %@", exception);
        }
    }
}

- (RollbarTriStateFlag)sendPayload:(nonnull NSData *)payload
                        withConfig:(nonnull RollbarConfig *)config
{
    RollbarDestinationRecord *destination = [self->_registry getRecordForConfig:config];
    if ([destination canPostWithConfig:config]) {
        return [self sendPayload:payload toDestination:destination withConfig:config];
    }
    return RollbarTriStateFlag_None; // nothing obviously wrong with the payload - just can not send at the moment
}

- (RollbarTriStateFlag)sendPayload:(nonnull NSData *)payload
                     toDestination:(nullable RollbarDestinationRecord *)record
                        withConfig:(nonnull RollbarConfig *)config
{
    if (!payload || !config) {
        return RollbarTriStateFlag_Off; //obviously invalid payload to sent or invalid destination...
    }

    RollbarPayloadPostReply *reply = [[RollbarSender new] sendPayload:payload usingConfig:config];
    [record recordPostReply:reply withConfig:config];
    
    if (!reply) {
        return RollbarTriStateFlag_None; // nothing obviously wrong with the payload - just there was no deterministic
                                         // reply from the destination server
    }
    
    switch (reply.statusCode) {
        case 200: // OK
            return RollbarTriStateFlag_On; // the payload was successfully transmitted
        case 400: // bad request
        case 413: // request entity too large
        case 422: // unprocessable entity
            return RollbarTriStateFlag_Off; // unecceptable request/payload - should be dropped
        case 429: // too many requests
            switch (self.rateLimitBehavior) {
                case RollbarRateLimitBehavior_Queue:
                    return RollbarTriStateFlag_None;
                case RollbarRateLimitBehavior_Drop:
                default:
                    return RollbarTriStateFlag_Off;
            }
        case 403: // access denied
        case 404: // not found
        default:
            return RollbarTriStateFlag_None; // worth retrying later
    }
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

#pragma mark -

- (RollbarRateLimitBehavior)rateLimitBehavior {
    return RollbarInfrastructure.sharedInstance.configuration.loggingOptions.rateLimitBehavior;
}

- (void)removePayloadByID:(nonnull NSString *)payloadID {
    if (![self->_payloadsRepo removePayloadByID:payloadID]) {
        RBErr(@"\tCouldn't remove payload data row with ID: %@", payloadID);
    } else {
        RBLog(@"\tRecord dropped");
    }
}

- (NSString *)loggableStringFromPayload:(RollbarPayload *)payload result:(RollbarTriStateFlag)result {
    NSString *resultString =
        result == RollbarTriStateFlag_On ? @"Transmitted" :
        result == RollbarTriStateFlag_Off ? @"Dropped" : @"Queued";

    return [NSString stringWithFormat:@"%@ %@", resultString, payload.data.uuid];
}

#pragma mark - Singleton pattern

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
