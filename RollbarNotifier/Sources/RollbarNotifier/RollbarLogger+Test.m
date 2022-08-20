#import "RollbarLogger+Test.h"
#import "RollbarNotifierFiles.h"
#import "RollbarThread.h"

@import RollbarCommon;

@implementation RollbarLogger (Test)

+ (void)clearSdkDataStore {
    
    [RollbarLogger _clearFile:[RollbarLogger _logPayloadsStorePath]];
    [RollbarLogger _clearFile:[RollbarLogger _telemetryItemsStorePath]];
    
    [RollbarLogger _clearFile:[RollbarLogger _incomingPayloadsLogPath]];
    [RollbarLogger _clearFile:[RollbarLogger _transmittedPayloadsLogPath]];
    [RollbarLogger _clearFile:[RollbarLogger _droppedPayloadsLogPath]];
}


+ (void)clearSdkFile:(nonnull NSString *)sdkFileName {
    
    [RollbarLogger _clearFile:[RollbarLogger _getSDKDataFilePath:sdkFileName]];
}

+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsFromSdkIncomingLog {
    
    [RollbarLogger readPayloadsDataFromFile:[RollbarLogger _incomingPayloadsLogPath]];
}

+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsFromSdkTransmittedLog {
    
    [RollbarLogger readPayloadsDataFromFile:[RollbarLogger _transmittedPayloadsLogPath]];
}

+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsFromSdkDroppedLog {
    
    [RollbarLogger readPayloadsDataFromFile:[RollbarLogger _droppedPayloadsLogPath]];
}

//+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsFromSdkLog {
//
//    NSString *filePath = [RollbarLogger _payloadsLogPath];
//    return [RollbarLogger readPayloadsDataFromFile:filePath];
//}

+ (nonnull NSArray<NSMutableDictionary *> *)readPayloadsDataFromFile:(nonnull NSString *)filePath {
    
    RollbarFileReader *reader = [[RollbarFileReader alloc] initWithFilePath:filePath
                                                                  andOffset:0];
    
    NSMutableArray<NSMutableDictionary *> *items = [NSMutableArray array];
    [reader enumerateLinesUsingBlock:^(NSString *line, NSUInteger nextOffset, BOOL *stop) {
        NSError *error = nil;
        NSMutableDictionary *payload =
        [NSJSONSerialization JSONObjectWithData:[line dataUsingEncoding:NSUTF8StringEncoding]
                                        options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)
                                          error:&error
        ];
        if ((nil == payload) && (nil != error)) {
            RollbarSdkLog(@"Error serializing log item from the store: %@", [error localizedDescription]);
            return;
        }
        else if (nil == payload) {
            RollbarSdkLog(@"Error serializing log item from the store!");
            return;
        }
        
        NSMutableDictionary *data = payload[@"data"];
        [items addObject:data];
    }];
    
    return items;
}

+ (void)flushRollbarThread {
    
    [RollbarLogger performSelector:@selector(_test_doNothing)
                          onThread:[RollbarLogger _test_rollbarThread]
                        withObject:nil
                     waitUntilDone:YES
    ];
}

+ (void)_clearFile:(nonnull NSString *)filePath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    
    if (fileExists) {
        BOOL success = [fileManager removeItemAtPath:filePath
                                               error:&error];
        if (!success) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath
                                                contents:nil
                                              attributes:nil];
    }
}

+ (nonnull NSString *)_logPayloadsStorePath {
    
    return [RollbarLogger _getSDKDataFilePath:[RollbarNotifierFiles payloadsStore]];
}

//+ (nonnull NSString *)_logItemsStoreStatePath {
//
//    return [RollbarLogger _getSDKDataFilePath:[RollbarNotifierFiles itemsQueueState]];
//}

+ (nonnull NSString *)_telemetryItemsStorePath {
    
    return [RollbarLogger _getSDKDataFilePath:[RollbarNotifierFiles telemetryQueue]];
}

+ (nonnull NSString *)_incomingPayloadsLogPath {
    
    return [RollbarLogger _getSDKDataFilePath:[RollbarNotifierFiles incomingPayloadsLog]];
}

+ (nonnull NSString *)_transmittedPayloadsLogPath {
    
    return [RollbarLogger _getSDKDataFilePath:[RollbarNotifierFiles transmittedPayloadsLog]];
}

+ (nonnull NSString *)_droppedPayloadsLogPath {
    
    return [RollbarLogger _getSDKDataFilePath:[RollbarNotifierFiles droppedPayloadsLog]];
}

+ (nonnull NSString *)_getSDKDataFilePath:(nonnull NSString *)sdkFileName {
    
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    return [cachesDirectory stringByAppendingPathComponent:sdkFileName];
}

+ (NSThread *)_test_rollbarThread {
    
    return [RollbarThread sharedInstance];
}

+ (void)_test_doNothing {
    
    // no-Op simulation...
}

@end
