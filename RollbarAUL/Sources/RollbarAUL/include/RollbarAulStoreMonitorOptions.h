//
//  RollbarAulStoreMonitorOptions.h
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

@import Foundation;
@import RollbarCommon;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@interface RollbarAulStoreMonitorOptions : RollbarDTO

#pragma mark - properties

@property (nonatomic, copy) NSArray<NSString *> *aulSubsystems;
@property (nonatomic, copy) NSArray<NSString *> *aulCategories;

#pragma mark - updaters

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
