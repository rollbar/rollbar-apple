//
//  RollbarFileWriter.h
//  
//
//  Created by Andrey Kornich on 2022-05-23.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarFileWriter : NSObject

+ (BOOL)ensureFileExists: (nullable NSString *)fileFullPath;
+ (void)appendData:(nullable NSData *)data toFile:(nullable NSString *)fileFullPath;
+ (void)appendSafelyData:(nullable NSData *)data toFile:(nullable NSString *)fileFullPath;

/// Hides parameterless initializer.
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
