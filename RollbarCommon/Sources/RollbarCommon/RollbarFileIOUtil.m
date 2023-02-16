//
//  RollbarFileIOUtil.m
//  
//
//  Created by Andrey Kornich on 2022-06-01.
//

#import "RollbarFileIOUtil.h"
#import "RollbarInternalLogging.h"

@implementation RollbarFileIOUtil

+ (nullable NSURL *)applicationSupportDirectory {
    
    return [RollbarFileIOUtil directory:NSApplicationSupportDirectory];
}

+ (nullable NSURL *)applicationCachesDirectory {
    
    return [RollbarFileIOUtil directory:NSCachesDirectory];
}

+ (nullable NSURL *)directory:(NSSearchPathDirectory)directory {
    
    NSError *error = nil;
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:directory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:YES
                                                           error:&error];
    if (!url && error) {
        
        RBCErr(@"Error while locating system directory %@: %@", directory, [error localizedDescription]);
    }
        
    return url;
}

@end
