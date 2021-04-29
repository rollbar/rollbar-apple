//
//  RollbarAulStoreMonitor.m
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import "RollbarAulStoreMonitor.h"
#import "RollbarAulStoreMonitorOptions.h"


static RollbarAulStoreMonitor *theOnlyInstance;


@implementation RollbarAulStoreMonitor {
    @private
    RollbarLogger *_logger;
    RollbarAulStoreMonitorOptions *_options;
}

#pragma mark - AUL integrators

- (void)setupMonitoringWithOptions:(nonnull RollbarAulStoreMonitorOptions *)options {
    
    NSString            *subSystem  = theOnlyInstance->_options.aulSubsystem.copy;
    NSArray<NSString *> *categories = theOnlyInstance->_options.aulCategories.copy;
    
    //TODO: implement
    
}

#pragma mark - RollbarAulStoreMonitoring

- (id<RollbarAulStoreMonitoring>)configureWithOptions:(nonnull RollbarAulStoreMonitorOptions *)options {

    @synchronized (theOnlyInstance) {

        if (nil != theOnlyInstance) {
            
            theOnlyInstance->_options = options;
            [self setupMonitoringWithOptions:options];
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
   
    //static RollbarAulStoreMonitor *theOnlyInstance = nil;

    @synchronized (theOnlyInstance) {
        
        if (nil == theOnlyInstance) {
            
            theOnlyInstance = [[[self class] hiddenAlloc] init];

            // let's complete the only instance initialization:
            if (nil != theOnlyInstance) {

                theOnlyInstance->_options = [RollbarAulStoreMonitorOptions new];
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
