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
@protocol RollbarAulStoreMonitoring

@required

- (id<RollbarAulStoreMonitoring>)configureWithOptions:(RollbarAulStoreMonitorOptions *)options;
- (id<RollbarAulStoreMonitoring>)configureRollbarLogger:(RollbarLogger *)logger;

- (void)start;
- (void)cancel;

@optional

// add optionals...

@end


API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@interface RollbarAulStoreMonitor : NSThread<RollbarAulStoreMonitoring, RollbarSingleInstancing>

@end

NS_ASSUME_NONNULL_END
