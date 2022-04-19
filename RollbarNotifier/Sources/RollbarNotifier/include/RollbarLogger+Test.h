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
+ (nonnull NSArray<NSMutableDictionary *> *)readLogItemsFromStore;

/// Reads all payloads from the default payloads log
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsFromSdkLog;

/// Reads all payloads from the provided file path
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsDataFromFile:(nonnull NSString *)filePath;

/// Clears all the payloads queued up in the persistent store
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (void)clearLogItemsStore;

/// Clears all the SDK persisted data
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (void)clearSdkDataStore;

/// Clears data from the specified file within the SDK data folder
/// @param sdkFileName fileName within the SDK data folder
///@note THIS METHOD IS TO BE USED FOR TESTING PURPOSES ONLY.
+ (void)clearSdkFile:(nonnull NSString *)sdkFileName;

@end

NS_ASSUME_NONNULL_END
