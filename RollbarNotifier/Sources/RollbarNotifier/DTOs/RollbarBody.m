#import "RollbarBody.h"

#import "RollbarMessage.h"
#import "RollbarCrashReport.h"
#import "RollbarTrace.h"
#import "RollbarTelemetry.h"
#import "RollbarTelemetryEvent.h"

static NSString * const DFK_TELEMETRY = @"telemetry";
static NSString * const DFK_TRACE = @"trace";
static NSString * const DFK_TRACE_CHAIN = @"trace_chain";
static NSString * const DFK_MESSAGE = @"message";
static NSString * const DFK_CRASH_REPORT = @"crash_report";

@implementation RollbarBody

- (instancetype)initWithMessage:(nonnull NSString *)message {
    return [self initWithMessage:message extra:nil];
}

- (instancetype)initWithMessage:(nonnull NSString *)string
                          extra:(nullable NSDictionary *)extra
{
    RollbarMessage *message = [[RollbarMessage alloc] initWithBody:string];

    if (extra) {
        [message setData:extra.mutableCopy byKey:@"extra"];
    }

    self = [super initWithDictionary:@{
        DFK_MESSAGE: message.jsonFriendlyData,
        DFK_CRASH_REPORT: [NSNull null],
        DFK_TRACE: [NSNull null],
        DFK_TRACE_CHAIN: [NSNull null],
        DFK_TELEMETRY: [self snapTelemetryData],
    }];
    return self;
}

- (instancetype)initWithException:(nonnull NSException *)exception {
    
    RollbarTrace *trace = [[RollbarTrace alloc] initWithException:exception];
    self = [super initWithDictionary:@{
        DFK_MESSAGE: [NSNull null],
        DFK_CRASH_REPORT: [NSNull null],
        DFK_TRACE: trace.jsonFriendlyData,
        DFK_TRACE_CHAIN: [NSNull null],
        DFK_TELEMETRY: [self snapTelemetryData],
    }];
    return self;
}

- (instancetype)initWithError:(nonnull NSError *)error {
    
    self = [super initWithDictionary:@{
        DFK_MESSAGE: [[RollbarMessage alloc] initWithNSError:error].jsonFriendlyData,
        DFK_CRASH_REPORT: [NSNull null],
        DFK_TRACE: [NSNull null],
        DFK_TRACE_CHAIN: [NSNull null],
        DFK_TELEMETRY: [self snapTelemetryData],
    }];
    return self;
}

- (instancetype)initWithCrashReport:(nonnull NSString *)crashReport {
    RollbarCrashReport *report = [[RollbarCrashReport alloc] initWithRawCrashReport:crashReport];
    NSException *exception = [[NSException alloc] initWithName:report.title
                                                        reason:report.diagnostic
                                                      userInfo:report.jsonFriendlyData];
    RollbarTrace *trace = [[RollbarTrace alloc] initWithException:exception];

    self = [super initWithDictionary:@{
        DFK_MESSAGE: [NSNull null],
        DFK_CRASH_REPORT: report.jsonFriendlyData,
        DFK_TRACE: trace.jsonFriendlyData,
        DFK_TRACE_CHAIN: [NSNull null],
        DFK_TELEMETRY: [self snapTelemetryData],
    }];

    return self;
}

#pragma mark - Private methods

-(NSArray *)getJsonFriendlyDataFromTraceChain:(NSArray<RollbarTrace *> *)traces {
    if (traces) {
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:traces.count];
        for(RollbarTrace *trace in traces) {
            if (trace) {
                [data addObject:trace.jsonFriendlyData];
            }
        }
        return data;
    }
    else {
        return nil;
    }
}

-(NSArray *)getJsonFriendlyDataFromTelemetry:(NSArray<RollbarTelemetryEvent *> *)telemetry {
    if (telemetry) {
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:telemetry.count];
        for(RollbarTelemetryEvent *event in telemetry) {
            if (event) {
                [data addObject:event.jsonFriendlyData];
            }
        }
        return data;
    }
    else {
        return nil;
    }
}

-(id)snapTelemetryData {
    
    if (![RollbarTelemetry sharedInstance].enabled) {
        return [NSNull null];
    }
    
    NSArray *telemetryData = [[RollbarTelemetry sharedInstance] getAllData];
    if (telemetryData && telemetryData.count > 0) {
        return telemetryData;
    }
    else {
        return [NSNull null];
    }
}

@end
