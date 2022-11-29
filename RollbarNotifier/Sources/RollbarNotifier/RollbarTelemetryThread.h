//
//  RollbarTelemetryThread.h
//  
//
//  Created by Andrey Kornich on 2022-04-11.
//

#import <Foundation/Foundation.h>

@class RollbarTelemetryOptions;

NS_ASSUME_NONNULL_BEGIN

@interface RollbarTelemetryThread : NSThread

/// Configures this instance with provided options
/// @param telemetryOptions desired Telemetry options
- (instancetype)configureWithOptions:(nonnull RollbarTelemetryOptions *)telemetryOptions;

@property (readonly, nonnull) RollbarTelemetryOptions *telemetryOptions;

/// Signifies that the thread is active or not.
@property(atomic) BOOL active;

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance;
+ (BOOL)sharedInstanceExists;

+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)alloc NS_UNAVAILABLE;
+ (id)copyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTarget:(id)target selector:(SEL)selector object:(nullable id)argument NS_UNAVAILABLE;
- (instancetype)initWithBlock:(void (^)(void))block NS_UNAVAILABLE;

- (void)dealloc NS_UNAVAILABLE;
- (id)copy NS_UNAVAILABLE;
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
