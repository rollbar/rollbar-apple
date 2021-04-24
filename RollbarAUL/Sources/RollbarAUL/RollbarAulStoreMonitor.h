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
- (void)configureWithOptions:(RollbarAulStoreMonitorOptions *)optiond;

@optional

@end


@interface RollbarAulStoreMonitor : NSObject<RollbarAulStoreMonitoring, RollbarSingleInstancing>

//#pragma mark - Singleton
//
//+ (instancetype)sharedInstance;
//
//+ (instancetype)alloc NS_UNAVAILABLE;
//
//+ (instancetype)new NS_UNAVAILABLE;
//
//+ (instancetype)allocWithZone:(NSZone *)zone NS_UNAVAILABLE;
//
//- (instancetype)copy NS_UNAVAILABLE;
//
//- (instancetype)copyWithZone:(NSZone *)zone NS_UNAVAILABLE;
//
//- (instancetype)mutableCopy NS_UNAVAILABLE;
//
//- (instancetype)mutableCopyWithZone:(NSZone *)zone NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
