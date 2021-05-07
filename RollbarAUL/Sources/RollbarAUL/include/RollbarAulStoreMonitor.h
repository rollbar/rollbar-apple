//
//  RollbarAulStoreMonitor.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

@import Foundation;
@import RollbarCommon;
@import RollbarNotifier;

@class RollbarAulStoreMonitorOptions;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Defines Rollbar AUL store monitor's protocol
@protocol RollbarAulStoreMonitoring

@required

- (id<RollbarAulStoreMonitoring>)configureWithOptions:(nullable RollbarAulStoreMonitorOptions *)options;
- (id<RollbarAulStoreMonitoring>)configureRollbarLogger:(nullable RollbarLogger *)logger;

- (void)start;
- (void)cancel;

@optional

// add optionals...

@end


API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Defines Rollbar AUL store monitor
@interface RollbarAulStoreMonitor : NSThread<RollbarAulStoreMonitoring, RollbarSingleInstancing>

@end

NS_ASSUME_NONNULL_END
