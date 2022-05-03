//
//  RollbarSession.h
//  
//
//  Created by Andrey Kornich on 2022-04-21.
//

#import <Foundation/Foundation.h>

@class RollbarSessionState;

typedef BOOL (^RollbarCrashReportCheck)();

NS_ASSUME_NONNULL_BEGIN

@interface RollbarSession : NSObject {
}

@property(atomic, readonly) NSDate *lastKnownAppStartupTimestamp;
@property(atomic, readonly) NSString *lastKnownAppVersion;
@property(atomic, readonly) NSString *lastKnownOsVersion;

@property(atomic, readonly) BOOL anyLastKnownAppBackgroundState;
@property(atomic, readonly) BOOL anyLastKnownAppCrash;
@property(atomic, readonly) BOOL anyLastKnownAppTermination;
@property(atomic, readonly) BOOL anyLastKnownAppGracefulQuit;

- (RollbarSessionState *)getCurrentState;

- (void)enableOomMonitoringWithCrashCheck:(RollbarCrashReportCheck)crashCheck;
- (void)registerApplicationHooks; // probably can become a private method...


#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance;

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
