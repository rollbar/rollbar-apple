//
//  RollbarAulStoreMonitor.m
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import "RollbarAulStoreMonitor.h"
#import "RollbarAulStoreMonitorOptions.h"
#import "RollbarAulPredicateBuilder.h"
#import "RollbarAulClient.h"
#import "RollbarAulEntrySnapper.h"
#import "RollbarAulOSLogEntryLogLevelConverter.h"

@import RollbarNotifier;

static NSTimeInterval const DEFAULT_AUL_MONITORING_INTERVAL_IN_SECS = 3.0;

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
static RollbarAulStoreMonitor *theOnlyInstance;


API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@implementation RollbarAulStoreMonitor {
    @private
    // configurable data fields:
    RollbarLogger       *_logger;
    NSPredicate         *_aulSubsystemCategoryPredicate;
    NSPredicate         *_aulProcessPredicate;
    // dynamically calculated data fields:
    NSDate *_aulStartTimestamp;
    NSDate *_aulEndTimestamp;
    // internal mechanics:
    NSTimer *_aulMonitoringTimer;
}

- (instancetype)initWithLogger:(nullable RollbarLogger *)logger
                    andOptions:(nullable RollbarAulStoreMonitorOptions *)options {
    
    if ((self = [super initWithTarget:self
                             selector:@selector(run)
                               object:nil])) {

        self.name = @"RollbarAulStoreMonitor";
        
        self->_aulProcessPredicate = [RollbarAulPredicateBuilder buildAulProcessPredicate];
        
        self->_logger = logger;
        
        RollbarAulStoreMonitorOptions *validOptions = options;
        if (nil == validOptions) {
            [RollbarAulStoreMonitorOptions new];
        }
        [RollbarAulStoreMonitor setupMonitor:self
                                     options:validOptions];

        self->_aulStartTimestamp =
        [[NSDate date] dateByAddingTimeInterval:-1.0];
    }

    return self;
}

- (void)run {
    
    @autoreleasepool {
        
        self->_aulMonitoringTimer =
        [NSTimer timerWithTimeInterval:DEFAULT_AUL_MONITORING_INTERVAL_IN_SECS
                                target:self
                              selector:@selector(onTimerTick:)
                              userInfo:nil
                               repeats:YES];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self->_aulMonitoringTimer forMode:NSDefaultRunLoopMode];
        
        while (NO == self.cancelled) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

#pragma mark - AUL integrators

+ (void)setupMonitor:(nonnull RollbarAulStoreMonitor *)monitor
             options:(nonnull RollbarAulStoreMonitorOptions *)options {
    
    // snap the new options into the provided AUL monitor:
    monitor->_aulSubsystemCategoryPredicate =
    [RollbarAulPredicateBuilder buildRollbarAulPredicateForSubsystem:options.aulSubsystem.copy
                                                    andForCategories:options.aulCategories.copy];
}

- (void)setupWithOptions:(nonnull RollbarAulStoreMonitorOptions *)options {
    
    [RollbarAulStoreMonitor setupMonitor:self
                                 options:options];
}

- (void)onTimerTick:(NSTimer *)timer {
    
    if (YES == self.cancelled) {
        if (self->_aulMonitoringTimer) {
            [self->_aulMonitoringTimer invalidate];
            self->_aulMonitoringTimer = nil;
        }
        [NSThread exit];
    }

    NSDate *currentMonitoringTimestamp = [NSDate date];
    
    NSError *error = nil;
    OSLogStore *logStore = [OSLogStore localStoreAndReturnError:&error];
    if (nil == logStore) {
        RollbarLog(@"ERROR referencing the local AUL log store: %@", error);
        return;
    }

    OSLogPosition *logPosition = [logStore positionWithDate:self->_aulStartTimestamp];
    if (nil == logPosition) {
        RollbarLog(@"ERROR referencing the local AUL log store position.");
        return;
    }
    //RollbarSdkLog(@"Log position: %@", logPosition);
    
    NSPredicate *monitoringTimeframePredicate =
    [RollbarAulPredicateBuilder buildAulTimeIntervalPredicateStartingAt:self->_aulStartTimestamp
                                                               endingAt:currentMonitoringTimestamp];
    NSPredicate *logEnumeratorPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[
        self->_aulProcessPredicate,
        self->_aulSubsystemCategoryPredicate,
        monitoringTimeframePredicate]
     ];
    //RollbarSdkLog(@"Log predicate: %@", logEnumeratorPredicate);

    OSLogEnumerator *logEnumerator =
    [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                        staringAtPosition:logPosition
                                           usingPredicate:logEnumeratorPredicate];
    //RollbarSdkLog(@"Log enumerator: %@", logEnumerator);

    int count = [self processLogEntries:logEnumerator];
    //RollbarLog(@"Total AUL entries: %d", count);

//    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
//    [timestampFormatter setDateFormat:@"YYYY-MM-dd 'at' HH:mm:ss.SSSSSSXX"];
//    RollbarSdkLog(@"Total of %d AUL events at [%@, %@)",
//                  count,
//                  [timestampFormatter stringFromDate:self->_aulStartTimestamp],
//                  [timestampFormatter stringFromDate:currentMonitoringTimestamp]
//                  );

    self->_aulStartTimestamp = currentMonitoringTimestamp;
}

- (int)processLogEntries:(OSLogEnumerator *)logEnumerator {
    
    int count = 0;
    RollbarAulEntrySnapper *entrySnapper = [RollbarAulEntrySnapper new];

    for (OSLogEntryLog *entry in logEnumerator) {
        
        NSMutableDictionary<NSString *, id> *entrySnapshot =
        [NSMutableDictionary<NSString *, id> dictionaryWithCapacity:20];
        
        [entrySnapper captureOSLogEntry:entry
                           intoSnapshot:entrySnapshot];

//        NSLog(@"");
//        NSLog(@"=== START AUL ENTRY ===");
//        for (NSString *key in entrySnapshot) {
//            id value = entrySnapshot[key];
//            NSLog(@"   %@: %@", key, value);
//        }
//        NSLog(@"=== END AUL ENTRY ===");
//        NSLog(@"");
        
        // To start with, let's report as Telemetry events for now:
        if ((nil != self->_logger)
            && (nil != self->_logger.configuration)
            && (nil != self->_logger.configuration.telemetry)
            && (YES == self->_logger.configuration.telemetry.enabled)
            && (YES == self->_logger.configuration.telemetry.captureLog)
            ) {

            RollbarLevel rollbarLevel =
            [RollbarAulOSLogEntryLogLevelConverter RollbarLevelFromOSLogEntryLogLevel:entry.level];
            
            [RollbarTelemetry.sharedInstance recordLogEventForLevel:rollbarLevel
                                                            message:entry.composedMessage
                                                          extraData:entrySnapshot];
        }

        

        count++;
    }

    return count;
}

#pragma mark - RollbarAulStoreMonitoring

- (id<RollbarAulStoreMonitoring>)configureWithOptions:(nonnull RollbarAulStoreMonitorOptions *)options {

    @synchronized (theOnlyInstance) {

        if (nil != theOnlyInstance) {
            
            [self setupWithOptions:options];
        }
    }
}

- (id<RollbarAulStoreMonitoring>)configureRollbarLogger:(RollbarLogger *)logger {

    @synchronized (theOnlyInstance) {

        if (nil != theOnlyInstance) {
            
            theOnlyInstance->_logger = logger;
        }
    }
}

#pragma mark - Singleton Pattern

+ (RollbarAulStoreMonitor *)sharedInstance {
   
    @synchronized (theOnlyInstance) {
        
        if (nil == theOnlyInstance) {
            
            theOnlyInstance = [[[self class] hiddenAlloc] initWithLogger:nil
                                                              andOptions:nil];
        }
        
        return theOnlyInstance;
    }
}

+ (void)attemptDealloc {

    @synchronized (theOnlyInstance) {

        theOnlyInstance = nil;
    }
}

+ (BOOL)sharedInstanceExists {
    
    @synchronized (theOnlyInstance) {

        return (theOnlyInstance != nil);
    }
}

+ (instancetype)hiddenAlloc {
    
    return [super alloc];
}

#pragma mark - destructor

- (void)dealloc {
    
    [self cancel];
    // cleanup the monitoring timer:
    [self->_aulMonitoringTimer invalidate];
    self->_aulMonitoringTimer = nil;
    
    // do the basics (not needed with ARC):
    //[super dealloc];
}

@end
