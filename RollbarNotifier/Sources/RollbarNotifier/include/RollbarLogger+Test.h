//
//  RollbarLogger+Test.h
//  
//
//  Created by Andrey Kornich on 2022-03-09.
//

#import <Foundation/Foundation.h>
#import "RollbarLogger.h"

NS_ASSUME_NONNULL_BEGIN

/// Test category of RollbarLogger
///@note THIS CATEGORY IS TO BE USED FOR TESTING PURPOSES ONLY.
@interface RollbarLogger (Test)

+ (void)flushRollbarThread;
+ (NSArray *)readLogItemsFromStore;
+ (void)clearLogItemsStore;
+ (void)clearSdkDataStore;

//- (NSThread *)_test_rollbarThread;
//- (void)_test_doNothing;

@end

NS_ASSUME_NONNULL_END
