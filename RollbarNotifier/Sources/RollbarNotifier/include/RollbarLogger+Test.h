#import <Foundation/Foundation.h>
#import "RollbarLogger.h"

NS_ASSUME_NONNULL_BEGIN

/// Test category of RollbarLogger
///@note THIS CATEGORY IS TO BE USED FOR TESTING PURPOSES ONLY.
@interface RollbarLogger (Test)

/// Returns after all the queued up payloads are processed by the RollbarThread
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (void)flushRollbarThread;

/// Reads all the payloads queued up in the persistent store
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (NSArray *)readLogItemsFromStore;

/// Clears all the payloads queued up in the persistent store
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (void)clearLogItemsStore;

/// Clears all the SDK persisted data
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (void)clearSdkDataStore;

@end

NS_ASSUME_NONNULL_END
