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

@end
