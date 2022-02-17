#ifndef RollbarSingleInstancing_h
#define RollbarSingleInstancing_h

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/// Defines a protocol of a Singleton
@protocol RollbarSingleInstancing

@required

/// The singleton instance.
+ (instancetype)sharedInstance;

/// Hides the alloc method.
+ (instancetype)alloc NS_UNAVAILABLE;

/// Hides the new method.
+ (instancetype)new NS_UNAVAILABLE;

/// Hides the method
/// @param zone an allocation zone
+ (instancetype)allocWithZone:(NSZone *)zone NS_UNAVAILABLE;

/// Hides the method.
- (instancetype)copy NS_UNAVAILABLE;

/// Hides the method.
/// @param zone a zone
- (instancetype)copyWithZone:(NSZone *)zone NS_UNAVAILABLE;

/// Hides the method.
- (instancetype)mutableCopy NS_UNAVAILABLE;

/// Hides the method.
/// @param zone a zone
- (instancetype)mutableCopyWithZone:(NSZone *)zone NS_UNAVAILABLE;

@optional

/// Attempts to safely dealocate this object.
+ (void)attemptDealloc;

/// Flag signifying the single instance existance.
+ (BOOL)sharedInstanceExists;

@end



NS_ASSUME_NONNULL_END

#endif //RollbarSingleInstancing_h
