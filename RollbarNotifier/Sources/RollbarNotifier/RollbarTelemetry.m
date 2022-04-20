@import RollbarCommon;

#import "RollbarTelemetry.h"
#import "RollbarCachesDirectory.h"

#import "RollbarTelemetryOptions.h"
#import "RollbarScrubbingOptions.h"
#import "RollbarTelemetryThread.h"
#import "RollbarTelemetryEvent.h"
#import "RollbarTelemetryBody.h"
#import "RollbarTelemetryLogBody.h"
#import "RollbarTelemetryViewBody.h"
#import "RollbarTelemetryErrorBody.h"
#import "RollbarTelemetryNavigationBody.h"
#import "RollbarTelemetryNetworkBody.h"
#import "RollbarTelemetryConnectivityBody.h"
#import "RollbarTelemetryManualBody.h"

static NSUInteger const DEFAULT_DATA_LIMIT = 10;
static NSString * const TELEMETRY_FILE_NAME = @"rollbar.telemetry";

static BOOL captureLog = false;

static  RollbarTelemetry * _Nullable singleton = nil;

// this queue is used for serializing state changes to the various
// state in this class: captureLog, limit, dataArray
static dispatch_queue_t queue = nil;
// this queue is used for dispatching file system writes, we don't
// want or need to block our state queue by file system writes
static dispatch_queue_t fileQueue = nil;

@implementation RollbarTelemetry {
    
    NSMutableArray *_dataArray;
    NSUInteger _limit;
    NSString *_dataFilePath;
}

#pragma mark - NSLog redirection

+ (void)NSLogReplacement:(NSString *)format, ... {
    
    va_list args, argsCopy;
    va_start(args, format);
    if (captureLog) {
        va_copy (argsCopy, args);
        NSString *message = [[NSString alloc] initWithFormat:format
                                                   arguments:args];
        [[RollbarTelemetry sharedInstance] recordLogEventForLevel:RollbarLevel_Debug
                                                          message:message
                                                        extraData:nil];
        NSLogv(format, argsCopy);
    } else {
        NSLogv(format, args);
    }
    va_end(args);
}

#pragma mark - Singleton pattern

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        singleton = [[RollbarTelemetry alloc] init];
        queue = dispatch_queue_create("com.rollbar.telemetryQueue", DISPATCH_QUEUE_SERIAL);
        fileQueue = dispatch_queue_create("com.rollbar.telemetryFileQueue", DISPATCH_QUEUE_SERIAL);
    });
    return singleton;
}

+ (BOOL)sharedInstanceExists {
    
    return (nil != singleton);
}

#pragma mark - Initializers

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _enabled = NO;
        _dataArray = [NSMutableArray array];
        _limit = DEFAULT_DATA_LIMIT;
        
        // Create cache file
        NSString *cachesDirectory = [RollbarCachesDirectory directory];
        _dataFilePath = [cachesDirectory stringByAppendingPathComponent:TELEMETRY_FILE_NAME];
        
        _viewInputsToScrub = [NSMutableSet new];
        
        [self loadTelemetryData];
    }
    return self;
}

#pragma mark - Config options

- (nonnull instancetype)configureWithOptions:(nonnull RollbarTelemetryOptions *)telemetryOptions {
    
    self.enabled = telemetryOptions.enabled;
    self.scrubViewInputs = telemetryOptions.viewInputsScrubber.enabled;
    self.viewInputsToScrub = [NSSet setWithArray:telemetryOptions.viewInputsScrubber.scrubFields].mutableCopy;
    
    [self setCaptureLog:telemetryOptions.captureLog];
    [self setDataLimit:telemetryOptions.maximumTelemetryData];
    
    [[RollbarTelemetryThread sharedInstance] configureWithOptions:telemetryOptions];
    if (![RollbarTelemetryThread sharedInstance].active) {
        
        [[RollbarTelemetryThread sharedInstance] start];
    }
    
    return self;
}

- (void)setCaptureLog:(BOOL)shouldCapture {
    
    dispatch_async(queue, ^{
        captureLog = shouldCapture;
    });
}

- (void)setDataLimit:(NSInteger)dataLimit {
    
    dispatch_async(queue, ^{
        self->_limit = dataLimit;
        [self trimDataArray];
    });
}

#pragma mark - Telemetry data/event recording methods

- (void)recordEvent:(nonnull RollbarTelemetryEvent *)event {

    if (!self->_enabled) {
        return;
    }
    
    if (RollbarTelemetryType_View == event.type) {
        RollbarTelemetryViewBody *viewbody = (RollbarTelemetryViewBody *)event.body;
        // check if the extradata needs some scrubbing based on the element name:
        __block BOOL needsScrubbing = false;
        [_viewInputsToScrub enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if( [viewbody.element caseInsensitiveCompare:obj] == NSOrderedSame ) {
                needsScrubbing = true;
                *stop = YES;
            }
        }];
        // scrub the extradata as needed:
        if (needsScrubbing) {
            for (NSString * key in event.body.jsonFriendlyData.allKeys)
            {
                if ([key caseInsensitiveCompare:@"element"] != NSOrderedSame) {
                    viewbody.jsonFriendlyData[key] = @"[scrubbed]";
                }
            }
        }
    }
    
    dispatch_async(queue, ^{
 
        [self->_dataArray addObject:event.jsonFriendlyData];
        [self trimDataArray];
        NSData *data = [self serializedDataArray];
        dispatch_async(fileQueue, ^{
            [self saveTelemetryData:data];
        });
    });
}


- (void)recordEventWithLevel:(RollbarLevel)level
                   eventBody:(nonnull RollbarTelemetryBody *)body {
    
    if (!self->_enabled) {
        return;
    }
    
    return [self recordEventWithLevel:level
                               source:RollbarSource_Client
                            eventBody:body];
}

- (void)recordEventWithLevel:(RollbarLevel)level
                      source:(RollbarSource)source
                   eventBody:(nonnull RollbarTelemetryBody *)body {

    if (!self->_enabled) {
        return;
    }
    
    RollbarTelemetryEvent *event = [[RollbarTelemetryEvent alloc]
                                    initWithLevel:level
                                    source:source
                                    body:body];
    [self recordEvent:event];
}

- (void)recordEventForLevel:(RollbarLevel)level
                       type:(RollbarTelemetryType)type
                       data:(NSDictionary<NSString *, id> *)data {
    
    if (!self->_enabled) {
        return;
    }
    
    NSTimeInterval timestamp = NSDate.date.timeIntervalSince1970 * 1000.0;
    NSString *telemetryLvl = [RollbarLevelUtil   RollbarLevelToString:level];
    NSString *telemetryType = [RollbarTelemetryTypeUtil RollbarTelemetryTypeToString:type];
    NSDictionary *info = @{@"level": telemetryLvl,
                           @"type": telemetryType,
                           @"source": @"client",
                           @"timestamp_ms": [NSString stringWithFormat:@"%.0f", round(timestamp)],
                           @"body": data ? data : [NSNull null]
                           };
    RollbarTelemetryEvent *event = [[RollbarTelemetryEvent alloc] initWithDictionary:info];
    [self recordEvent:event];
}

- (void)recordViewEventForLevel:(RollbarLevel)level
                        element:(NSString *)element
                      extraData:(NSDictionary<NSString *, id> *)extraData {
    
    RollbarTelemetryBody *body = [[RollbarTelemetryViewBody alloc] initWithElement:element
                                                                         extraData:extraData];
    [self recordEventWithLevel:level eventBody:body];
}

- (void)recordNetworkEventForLevel:(RollbarLevel)level
                            method:(NSString *)method
                               url:(NSString *)url
                        statusCode:(NSString *)statusCode
                         extraData:(NSDictionary<NSString *, id> *)extraData {

    RollbarHttpMethod httpMethod = [RollbarHttpMethodUtil HttpMethodFromString:method];
    RollbarTelemetryNetworkBody *body = [[RollbarTelemetryNetworkBody alloc] initWithMethod:httpMethod
                                                                                        url:url
                                                                                 statusCode:statusCode
                                                                                  extraData:extraData];
    if (!self->_enabled) {
        return;
    }
    
    [self recordEventWithLevel:level eventBody:body];
}

- (void)recordConnectivityEventForLevel:(RollbarLevel)level
                                 status:(NSString *)status
                              extraData:(NSDictionary<NSString *, id> *)extraData {
    
    if (!self->_enabled) {
        return;
    }
    
    RollbarTelemetryConnectivityBody *body = [[RollbarTelemetryConnectivityBody alloc] initWithStatus:status
                                                                                            extraData:extraData];
    [self recordEventWithLevel:level eventBody:body];
}

- (void)recordErrorEventForLevel:(RollbarLevel)level
                         message:(NSString *)message
                       extraData:(NSDictionary<NSString *, id> *)extraData {
    
    if (!self->_enabled) {
        return;
    }
    
    RollbarTelemetryErrorBody *body = [[RollbarTelemetryErrorBody alloc] initWithMessage:message
                                                                               extraData:extraData];
    [self recordEventWithLevel:level eventBody:body];
}

- (void)recordNavigationEventForLevel:(RollbarLevel)level
                                 from:(NSString *)from
                                   to:(NSString *)to
                            extraData:(NSDictionary<NSString *, id> *)extraData {
    
    if (!self->_enabled) {
        return;
    }
    
    RollbarTelemetryNavigationBody *body = [[RollbarTelemetryNavigationBody alloc] initWithFromLocation:from
                                                                                             toLocation:to
                                                                                              extraData:extraData];
    [self recordEventWithLevel:level eventBody:body];
}

- (void)recordManualEventForLevel:(RollbarLevel)level
                         withData:(NSDictionary<NSString *, id> *)extraData {
    
    if (!self->_enabled) {
        return;
    }
    
    RollbarTelemetryManualBody *body = [[RollbarTelemetryManualBody alloc] initWithDictionary:extraData];
    [self recordEventWithLevel:level eventBody:body];
}

- (void)recordLogEventForLevel:(RollbarLevel)level
                       message:(NSString *)message
                     extraData:(NSDictionary<NSString *, id> *)extraData {
    
    if (!self->_enabled) {
        return;
    }
    
    RollbarTelemetryLogBody *body = [[RollbarTelemetryLogBody alloc] initWithMessage:message
                                                                           extraData:extraData];
    [self recordEventWithLevel:level eventBody:body];
}

#pragma mark - Telemetry Data access methods

-(nonnull NSArray<RollbarTelemetryEvent*> *)getAllEvents {
    NSArray *telemetryData = [self getAllData];
    NSMutableArray<RollbarTelemetryEvent*> *events =
        [NSMutableArray arrayWithCapacity:telemetryData ? telemetryData.count : 0];
    if (nil == telemetryData) {
        
        return events;
    }
    
    for (NSDictionary *dataItem in telemetryData) {
        
        RollbarTelemetryType eventType =
            [RollbarTelemetryTypeUtil RollbarTelemetryTypeFromString:dataItem[@"type"]];
        RollbarTelemetryBody *eventBody =
            [RollbarTelemetryEvent createTelemetryBodyWithType:eventType data:dataItem[@"body"]];
        if (nil != eventBody) {
            
            RollbarLevel eventLevel = [RollbarLevelUtil RollbarLevelFromString:dataItem[@"level"]];
            RollbarSource eventSource = [RollbarSourceUtil RollbarSourceFromString:dataItem[@"source"]];
            RollbarTelemetryEvent *event = [[RollbarTelemetryEvent alloc] initWithLevel:eventLevel
                                                                                 source:eventSource
                                                                                   body:eventBody];
            [events addObject:event];
        }
    }
    return events;
}

- (NSArray *)getAllData {
    
    __block NSArray *dataCopy = nil;
    dispatch_sync(queue, ^{
        
        dataCopy = [self->_dataArray copy];
    });
    return dataCopy;
}

- (void)clearAllData {
    
    dispatch_async(queue, ^{
        
        [self->_dataArray removeAllObjects];
        NSData *data = [self serializedDataArray];
        dispatch_async(fileQueue, ^{
            [self saveTelemetryData:data];
        });
    });
}

#pragma mark - Telemetry Data manipulation

- (void)trimDataArray {
    
    if (@available(iOS 10.0, macOS 10.12, *)) {
        dispatch_assert_queue_debug(queue);
    }
    if (_limit > 0 && _dataArray.count > _limit) {
        [_dataArray removeObjectsInRange:NSMakeRange(0, _dataArray.count - _limit)];
    }
}

#pragma mark - Telemetry Data persistence

// This is used for getting a read-only copy of our shared dataArray
// which can later be written to a file. This method must be called
// on the internal queue to serialize the dataArray read, but the result
// is free to be used anywhere
- (NSData *)serializedDataArray {
    
    if (@available(iOS 10.0, macOS 10.12, *)) {
        dispatch_assert_queue_debug(queue);
    }
    NSData *data = [NSJSONSerialization rollbar_dataWithJSONObject:_dataArray
                                                   options:0
                                                     error:nil
                                                      safe:true];
    return data;
}

- (void)saveTelemetryData:(NSData *)data {
    if (@available(iOS 10.0, macOS 10.12, *)) {
        dispatch_assert_queue_debug(fileQueue);
    }
    [data writeToFile:_dataFilePath atomically:true];
}

// This must only be called in init, calls to this method at any other time
// would present a race condition because dataArray is modified without
// protecting which thread/queue we are being called from
- (void)loadTelemetryData {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_dataFilePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:_dataFilePath];
        if (data) {
            
            NSArray *telemetryDataList = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:nil];
            if (telemetryDataList) {
                _dataArray = [telemetryDataList mutableCopy];
            }
        }
    }
}

//#pragma mark - Memory stats collection
//
//- (void)collectMemoryStats {
//
//    NSObject *memoryStats = [RollbarMemoryUtil getMemoryStats];
//
//    [self recordManualEventForLevel:RollbarLevel_Info withData:@{
//        @"memory_stats" : memoryStats,
//    }];
//}

@end
