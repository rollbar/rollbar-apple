@import Foundation;

#import "RollbarConfig.h"
#import "RollbarPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarThread : NSThread

/// Signifies that the thread is active or not.
@property(atomic) BOOL active;

//- (void)persist:(nonnull RollbarPayload *)payload;

- (void)persistPayload:(nonnull RollbarPayload *)payload
            withConfig:(nonnull RollbarConfig *)config;

- (BOOL)sendPayload:(nonnull NSData *)payload
        usingConfig:(nonnull RollbarConfig  *)config;

/// Hides the initializer.
- (instancetype)init NS_UNAVAILABLE;

/// Hides the initializer.
- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                        object:(nullable id)argument
NS_UNAVAILABLE;

- (instancetype)initWithBlock:(void (^)(void))block NS_UNAVAILABLE;


#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

- (void)dealloc NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
