#ifndef RollbarCachesDirectory_h
#define RollbarCachesDirectory_h

@import Foundation;

/// Rollbar cache directory utility.
@interface RollbarCachesDirectory : NSObject

/// Path to the cache directory.
+ (nonnull NSString *)directory;

/// Ensures that the expected caches directory does exist, otherwise returns NO.
+ (BOOL)ensureCachesDirectoryExists;

/// Returns YES if the specified file exists in the cache directory, otherwise returns NO.
/// @param fileName file to check for.
+ (BOOL)checkCacheFileExists:(nonnull NSString *)fileName;

/// Returns full path + file name to the specified cache file
/// @param fileName file name of a cache
+ (nonnull NSString *)getCacheFilePath:(nonnull NSString *)fileName;

#pragma mark - Initializers

/// Hides parameterless initializer.
- (nonnull instancetype)init
NS_UNAVAILABLE;

@end

#endif // RollbarCachesDirectory_h
