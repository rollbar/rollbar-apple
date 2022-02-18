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

/// Adds an AUL subsystem of interest
/// @param subsystem subsystem of interest
- (void)addAulSubsystem:(NSString *)subsystem;

/// Removes an AUL subsystem of interest
/// @param subsystem subsystem of interest
- (void)removeAulSubsystem:(NSString *)subsystem;

/// Adds an AUL category of interest
/// @param category category of interest
- (void)addAulCategory:(NSString *)category;

/// Removes an AUL category of interest
/// @param category category of interest
- (void)removeAulCategory:(NSString *)category;

#pragma mark - initializers

/// Initializer with AUL subsystems of interest.
/// @param aulSubsystems AUL subsystems of interest
- (instancetype)initWithAulSubsystems:(nullable NSArray<NSString *> *)aulSubsystems;

/// Initializer
/// @param aulSubsystems AUL subsystems of interest
/// @param aulCategories AUL categories of interest
- (instancetype)initWithAulSubsystems:(nullable NSArray<NSString *> *)aulSubsystems
                        aulCategories:(nullable NSArray<NSString *> *)aulCategories;

/// Hides the initializer.
/// @param data data array
- (instancetype)initWithArray:(NSArray *)data
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulStoreMonitorOptions_h

#endif //TARGET_OS_OSX
