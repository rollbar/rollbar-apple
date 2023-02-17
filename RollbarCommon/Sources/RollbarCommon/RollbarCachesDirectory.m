#import "RollbarCachesDirectory.h"
#import "RollbarInternalLogging.h"

@implementation RollbarCachesDirectory

+ (NSString *)directory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSCachesDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *cachesDirectory = paths.firstObject;
    
#if TARGET_OS_OSX
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if (nil != [processInfo.environment
                valueForKey:@"APP_SANDBOX_CONTAINER_ID"]) {
        // when the hosting process is sandboxed, the cachesDirectory is already
        // allocated per application:
        return cachesDirectory;
    }
    
    // when the hosting process is not sandboxed let's make sure we sandbox
    // our own cache based on the process' unique attributes:
    NSString *appBundleID = [NSBundle mainBundle].bundleIdentifier;
    if (appBundleID) {
        cachesDirectory =
        [cachesDirectory stringByAppendingPathComponent:appBundleID];
    }
    else {
        cachesDirectory =
        [cachesDirectory stringByAppendingPathComponent:processInfo.processName];
    }
    
#endif
    return cachesDirectory;
}

+ (BOOL)ensureCachesDirectoryExists {
    
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:cachesDirectory];
    if (YES == success) {
        
        return success;
    }

    NSError *error;
    success =
    [[NSFileManager defaultManager] createDirectoryAtPath:cachesDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error
    ];
    RBCLog(@"Created a new caches directory: %@", [NSNumber numberWithBool:success]);
    if (NO == success) {
        
        if (!error) {

            RBCErr(@"Error creating a new caches directory: %@", error);
        }
    }
    return success;
}

+ (BOOL)checkCacheFileExists:(nonnull NSString *)fileName {
    
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (nonnull NSString *)getCacheFilePath:(nonnull NSString *)fileName {
    
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
    return filePath;
}

@end
