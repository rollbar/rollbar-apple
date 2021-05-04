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

@protocol RollbarAulStoreMonitoring

@required
- (id<RollbarAulStoreMonitoring>)configureWithOptions:(RollbarAulStoreMonitorOptions *)options;

@optional
- (id<RollbarAulStoreMonitoring>)configureRollbarLogger:(RollbarLogger *)logger;

@end


@interface RollbarAulStoreMonitor : NSThread<RollbarAulStoreMonitoring, RollbarSingleInstancing>

@property(atomic) BOOL active;


@end

NS_ASSUME_NONNULL_END
