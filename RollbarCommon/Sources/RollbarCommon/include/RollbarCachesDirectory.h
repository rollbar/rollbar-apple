#ifndef RollbarCachesDirectory_h
#define RollbarCachesDirectory_h

@import Foundation;

@interface RollbarCachesDirectory : NSObject

+ (NSString *)directory;

#pragma mark - Initializers

- (instancetype)init
NS_UNAVAILABLE;

@end

#endif // RollbarCachesDirectory_h
