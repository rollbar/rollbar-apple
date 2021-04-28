//
//  RollbarAulStoreMonitor.m
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

@import RollbarCommon;

#import "RollbarAulStoreMonitor.h"

static RollbarAulStoreMonitor *theOnlyInstance;

@implementation RollbarAulStoreMonitor


#pragma mark - RollbarAulStoreMonitoring

- (void)configureWithOptions:(nonnull RollbarAulStoreMonitorOptions *)optiond {
    //TODO: implement
}

#pragma mark - Singleton Pattern

+ (RollbarAulStoreMonitor *)sharedInstance {
   
    //static RollbarAulStoreMonitor *theOnlyInstance = nil;

    @synchronized (theOnlyInstance) {
        
        if (theOnlyInstance == nil) {
            
            theOnlyInstance = [[[self class] hiddenAlloc] init];
            // any other special initialization as required here
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

//+ (instancetype)alloc {
//    NSLog(@"%@: use +sharedInstance instead of +alloc!", [self objectClassName]);
//    return nil;
//}
//
//+ (instancetype)new {
//    return [self alloc];
//}
//
//+ (instancetype)allocWithZone:(NSZone *)zone {
//    return [self alloc];
//}
//
//- (instancetype)copyWithZone:(NSZone *)zone {
//    // -copy inhereted from NSObject calls -copyWithZone:
//    NSLog(@"%@: -copy does not apply to a Singleton!", [self className]);
//}
//
//- (instancetype)mutableCopyWithZone:(NSZone *)zone {
//    // -mutableCopy inhereted from NSObject calls -mutableCopyWithZone:
//    return [self copyWithZone:zone];
//}

@end
