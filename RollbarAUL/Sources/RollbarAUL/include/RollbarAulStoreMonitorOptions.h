//
//  RollbarAulStoreMonitorOptions.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#ifndef RollbarAulStoreMonitorOptions_h
#define RollbarAulStoreMonitorOptions_h

@import Foundation;

#if TARGET_OS_OSX

@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Defines Rollbar AUL stor monitor's configuration options
@interface RollbarAulStoreMonitorOptions : RollbarDTO

#pragma mark - properties

/// AUL subsystems of interest for monitoring
@property (nonatomic, copy) NSArray<NSString *> *aulSubsystems;

/// AUL categories of interest for monitoring
@property (nonatomic, copy) NSArray<NSString *> *aulCategories;

#pragma mark - options updaters

- (void)addAulSubsystem:(NSString *)subsystem;

- (void)removeAulSubsystem:(NSString *)subsystem;

- (void)addAulCategory:(NSString *)category;

- (void)removeAulCategory:(NSString *)category;

#pragma mark - initializers

- (instancetype)initWithAulSubsystems:(nullable NSArray<NSString *> *)aulSubsystems;

- (instancetype)initWithAulSubsystems:(nullable NSArray<NSString *> *)aulSubsystems
                        aulCategories:(nullable NSArray<NSString *> *)aulCategories;

- (instancetype)initWithArray:(NSArray *)data
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulStoreMonitorOptions_h

#endif //TARGET_OS_OSX
