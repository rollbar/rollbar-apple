#import "RollbarFileWriter.h"
#import "RollbarInternalLogging.h"

@implementation RollbarFileWriter

+ (BOOL)ensureFileExists: (nullable NSString *)fileFullPath {
    
    if (!(fileFullPath && (fileFullPath.length > 0))) {
        
        RBCErr(@"Can't ensure existance of this file: %@!", fileFullPath);
        return NO;
    }

    // make sure the file exists:
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileFullPath]) {
        
        if (![[NSFileManager defaultManager] createFileAtPath:fileFullPath
                                                     contents:nil
                                                   attributes:nil]) {
            RBCErr(@"    Error while creating file: %@", fileFullPath);
            return NO;
        }
    }
    
    return YES;
}

+ (void)appendData:(nullable NSData *)data toFile:(nullable NSString *)fileFullPath {
    
    if (!(data && fileFullPath && (fileFullPath.length > 0))) {
        
        RBCErr(@"Can't append data: %@ to file: %@!", data, fileFullPath);
        return;
    }
    
    // append-save the data into the file (assuming it exists):
    
    NSError *error;
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileFullPath];
    if (!fileHandle) {
        
        RBCErr(@"    Error while acquiring file handle for: %@", fileFullPath);
        return;
    }
    
    unsigned long long offset;
    if (![fileHandle seekToEndReturningOffset:&offset error:&error]) {
        
        RBCErr(@"    Error while seeking to file end of %@: %@", fileFullPath, [error localizedDescription]);
        return;
    }
    
    if (![fileHandle writeData:data error:&error]) {
        
        RBCErr(@"    Error while writing data to %@: %@", fileFullPath, [error localizedDescription]);
        return;
    }
    
    if (![fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] error:&error]) {
        
        RBCErr(@"    Error while writing data to %@: %@", fileFullPath, [error localizedDescription]);
        return;
    }
    
    if (![fileHandle closeAndReturnError:&error]) {
        
        RBCErr(@"    Error while closing %@: %@", fileFullPath, [error localizedDescription]);
        return;
    }
}

+ (void)appendSafelyData:(nullable NSData *)data toFile:(nullable NSString *)fileFullPath {

    if (!data) {
        
        RBCErr(@"No data to append!");
        return;
    }
    
    // make sure the file exists:
    if (NO == [RollbarFileWriter ensureFileExists:fileFullPath]) {
        
        return;
    }

    // append-save the data into the file:
    [RollbarFileWriter appendData:data toFile:fileFullPath];
}


@end
