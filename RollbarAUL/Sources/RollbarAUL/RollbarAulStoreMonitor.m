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

static NSTimeInterval const DEFAULT_AUL_MONITORING_INTERVAL_IN_SECS = 3.0;

static RollbarAulStoreMonitor *theOnlyInstance;


@implementation RollbarAulStoreMonitor {
    @private
    // configurable data fields:
    RollbarLogger       *_logger;
    //NSString            *_aulSubsystem;
    //NSArray<NSString *> *_aulCategories;
    NSPredicate         *_aulSubsystemCategoryPredicate;
    // dynamically calculated data fields:
    NSDate *_aulStartTimestamp; //= [[NSDate date] dateByAddingTimeInterval:-1.0];
    NSDate *_aulEndTimestamp;
    // internal mechanics:
    NSTimer *_aulMonitoringTimer;
}

#pragma mark - AUL integrators

+ (void)setupMonitor:(nonnull RollbarAulStoreMonitor *)monitor
             options:(nonnull RollbarAulStoreMonitorOptions *)options {
    
    // snap the new options into the provided AUL monitor:
    //monitor->_aulSubsystem  = options.aulSubsystem.copy;
    //monitor->_aulCategories = options.aulCategories.copy;
    monitor->_aulSubsystemCategoryPredicate =
    [RollbarAulPredicateBuilder buildRollbarAulPredicateForSubsystem:options.aulSubsystem.copy
                                                      andForCategory:options.aulCategories.copy];
}

- (void)setupWithOptions:(nonnull RollbarAulStoreMonitorOptions *)options {
    
    [RollbarAulStoreMonitor setupMonitor:self
                                 options:options];
}

- (void)onTimerTick:(NSTimer *)timer {
    
    NSDate *currentMonitoringTimestamp = [NSDate date];
    
    //TODO: candidate for async processing!!!
    //START async processing block:
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

    NSPredicate *monitoringTimeframePredicate =
    [RollbarAulPredicateBuilder buildAulTimeIntervalPredicateStartingAt:self->_aulStartTimestamp
                                                               endingAt:currentMonitoringTimestamp];
    NSPredicate *logEnumeratorPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[self->_aulSubsystemCategoryPredicate, monitoringTimeframePredicate]];
    
    OSLogEnumerator *logEnumerator =
    [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                        staringAtPosition:logPosition
                                           usingPredicate:logEnumeratorPredicate];
    
    int count = [self processLogEntries:logEnumerator];
    RollbarLog(@"Total AUL entries: %d", count);
    //END async processing block:

    self->_aulStartTimestamp = currentMonitoringTimestamp;
}

- (int)processLogEntries:(OSLogEnumerator *)logEnumerator {
    
    int count = 0;
    for (OSLogEntryLog *entry in logEnumerator) {
        
        //TODO: reimplement to forward the log entries to Rollbar!!!

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
            
            theOnlyInstance = [[[self class] hiddenAlloc] init];

            // let's complete the only instance initialization:
            if (nil != theOnlyInstance) {

                [RollbarAulStoreMonitor setupMonitor:theOnlyInstance
                                             options:[RollbarAulStoreMonitorOptions new]];
                
                theOnlyInstance->_aulStartTimestamp =
                [[NSDate date] dateByAddingTimeInterval:-1.0];

                theOnlyInstance->_logger = Rollbar.currentLogger;
                
                theOnlyInstance->_aulMonitoringTimer =
                [NSTimer scheduledTimerWithTimeInterval:DEFAULT_AUL_MONITORING_INTERVAL_IN_SECS
                                                 target:theOnlyInstance//self
                                               selector:@selector(onTimerTick:)
                                               userInfo:nil
                                                repeats:YES];
            }
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
    
    // cleanup the monitoring timer:
    [self->_aulMonitoringTimer invalidate];
    self->_aulMonitoringTimer = nil;
    
    // do the basics (not needed with ARC):
    //[super dealloc];
}

@end
