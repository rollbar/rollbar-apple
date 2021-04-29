//
//  RollbarAulStoreMonitor.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

@import Foundation;
@import RollbarCommon;

@class RollbarAulStoreMonitorOptions;

NS_ASSUME_NONNULL_BEGIN

@protocol RollbarAulStoreMonitoring

@required
- (void)configureWithOptions:(RollbarAulStoreMonitorOptions *)options;

@optional

@end


@interface RollbarAulStoreMonitor : NSObject<RollbarAulStoreMonitoring, RollbarSingleInstancing>

@end

NS_ASSUME_NONNULL_END
