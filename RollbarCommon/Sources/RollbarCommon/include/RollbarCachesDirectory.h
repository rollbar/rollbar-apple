#ifndef RollbarCachesDirectory_h
#define RollbarCachesDirectory_h

@import Foundation;

/// Rollbar cache directory utility.
@interface RollbarCachesDirectory : NSObject

/// Path to the cache directory.
+ (NSString *)directory;

#pragma mark - Initializers

/// Hides parameterless initializer.
- (instancetype)init
NS_UNAVAILABLE;

@end

#endif // RollbarCachesDirectory_h
