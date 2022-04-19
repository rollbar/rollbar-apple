@import Foundation;

@class RollbarLogger;

@interface RollbarThread : NSThread

/// Hides the initializer.
- (instancetype)init
NS_UNAVAILABLE;

/// Initializer
/// @param logger a Rollbar logger to use.
/// @param reportsPerMinute maximum allowed reporting rate.
- (instancetype)initWithNotifier:(RollbarLogger*)logger
                   reportingRate:(NSUInteger)reportsPerMinute;

/// Signifies that the thread is active or not.
@property(atomic) BOOL active;

@end
