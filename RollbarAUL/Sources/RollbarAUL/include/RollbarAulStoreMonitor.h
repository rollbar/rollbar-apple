#ifndef RollbarAulStoreMonitor_h
#define RollbarAulStoreMonitor_h

@import Foundation;

#if TARGET_OS_OSX

@import RollbarCommon;
@import RollbarNotifier;

@class RollbarAulStoreMonitorOptions;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Defines Rollbar AUL store monitor's protocol
@protocol RollbarAulStoreMonitoring

@required

/// Configures AUL stor monitoring with specified options
/// @param options monitoring options
- (id<RollbarAulStoreMonitoring>)configureWithOptions:(nullable RollbarAulStoreMonitorOptions *)options;

/// Configures store monitoring with specific Rollbar logger to use
/// @param logger a Rollbar logger
- (id<RollbarAulStoreMonitoring>)configureRollbarLogger:(nullable RollbarLogger *)logger;

/// Starts the monitoring
- (void)start;

/// Stops the monitoring
- (void)cancel;

@optional

// add optionals...

@end


API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Defines Rollbar AUL store monitor
@interface RollbarAulStoreMonitor
: NSThread<RollbarAulStoreMonitoring, RollbarSingleInstancing>

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulStoreMonitor_h

#endif //TARGET_OS_OSX
