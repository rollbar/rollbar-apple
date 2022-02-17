#ifndef RollbarCrashCollectorBase_h
#define RollbarCrashCollectorBase_h

#import "RollbarCrashCollectorProtocol.h"

@import Foundation;

@protocol RollbarCrashCollectorObserver;

NS_ASSUME_NONNULL_BEGIN

/// Abstract implementation of the RollbarCrashCollector protocol.
@interface RollbarCrashCollectorBase : NSObject<RollbarCrashCollector> {
    @private
    id<RollbarCrashCollectorObserver> _observer;
}

/// Designated initializer.
/// @param observer a crash collector observer.
- (instancetype)initWithObserver:(nullable id<RollbarCrashCollectorObserver>)observer
NS_DESIGNATED_INITIALIZER;

/// Hides parametrless initializer.
- (instancetype)init
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif /* RollbarCrashCollectorBase_h */
