@import RollbarCommon;

#import "RollbarConfigUtil.h"
#import "RollbarConfig.h"
#import "RollbarNotifierFiles.h"
#import "RollbarInternalLogging.h"

#pragma mark - constants

static NSString *configurationDirectory = nil;
static NSString *configurationFilePath = nil;

#pragma mark - class implementation

@implementation RollbarConfigUtil

+ (void)initialize {
    
    if (self == [RollbarConfigUtil class]) {
        
        configurationDirectory = [RollbarCachesDirectory directory];
        configurationFilePath = [configurationDirectory stringByAppendingPathComponent:[RollbarNotifierFiles config]];
    }
}

+ (nonnull NSString *)getDefaultConfigFileName {
    
    return [RollbarNotifierFiles config];
}

+ (nonnull NSString *)getDefaultConfigDirectory {
    
    return configurationDirectory;
}

+ (nonnull NSString *)getDefaultConfigFilePath {
    
    return configurationFilePath;
}

+ (nullable RollbarConfig *)createRollbarConfigFromFile:(nonnull NSString *)filePath
                                                  error:(NSError * _Nullable *)error {
    
    if (!filePath) {
        
        *error = [NSError errorWithDomain:@"filePath is nil"
                                     code:0
                                 userInfo:nil];
        return nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        if (nil != error) {
            
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"filePath %@ does not exist.", filePath]
                                         code:0
                                     userInfo:nil];
        }
        return nil;
    }
    NSData *configData = [NSData dataWithContentsOfFile:filePath
                                                options:NSDataReadingMappedIfSafe
                                                  error:error];
    if (nil != configData) {
        
        RollbarConfig *config = [[RollbarConfig alloc] initWithJSONData:configData];
        return config;
    }
    else {
        
        if ((nil != error) && (nil != *error)) {
            
            RBErr(@"Error loading RollbarConfig from %@: %@", filePath, [*error localizedDescription]);
        }
        return nil;
    }
}

+ (nullable RollbarConfig *)createRollbarConfigFromDefaultFile:(NSError * _Nullable *)error {
    
    return [RollbarConfigUtil createRollbarConfigFromFile:configurationFilePath
                                                    error:error];
}

+ (BOOL)saveRollbarConfig:(RollbarConfig *)rollbarConfig
                   toFile:(nonnull NSString *)filePath
                    error:(NSError * _Nullable *)error {
    
    if (!rollbarConfig) {
        
        *error =
        [NSError errorWithDomain:@"Can't save uninitialized RollbarConfig"
                            code:0
                        userInfo:nil];
        return YES; // nothing bad happened
    }
    if ([filePath hasPrefix:@"~"]) {
        
        filePath = [filePath stringByExpandingTildeInPath];
    }
    NSData *configData = [rollbarConfig serializeToJSONData];
    BOOL success = [configData writeToFile:filePath atomically:YES];
    if ((NO == success) && (nil != error)) {
        
        *error =
        [NSError errorWithDomain:[NSString stringWithFormat:@"Can't write RollbarConfig to file: %@", filePath]
                            code:0
                        userInfo:nil];
    }
    return success;
}

+ (BOOL)saveRollbarConfig:(RollbarConfig *)rollbarConfig
                    error:(NSError * _Nullable *)error {
    
    return [RollbarConfigUtil saveRollbarConfig:rollbarConfig
                                         toFile:configurationFilePath
                                          error:error];
}

+ (BOOL)deleteFile:(nonnull NSString *)filePath
             error:(NSError * _Nullable *)error {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        
        BOOL success = [fileManager removeItemAtPath:filePath
                                               error:error];
        if (NO == success) {
            
            if ((nil != error) && (nil != *error)) {
                
                RBErr(@"Error while deleting file %@: %@", filePath, [*error localizedDescription]);
            }
            else {
                
                RBErr(@"Error while deleting file %@", filePath);
            }
        }
        
        return success;
    }
    return YES; // nothing bad happened
}

+ (BOOL)deleteDefaultRollbarConfigFile:(NSError * _Nullable *)error {
    
    return [RollbarConfigUtil deleteFile:configurationFilePath
                                   error:error];
}

@end
