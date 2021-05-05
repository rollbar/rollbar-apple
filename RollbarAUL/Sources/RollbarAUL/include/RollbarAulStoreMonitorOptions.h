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

@property (nonatomic, copy) NSString *aulSubsystem;
@property (nonatomic, copy) NSArray<NSString *> *aulCategories;

#pragma mark - updaters

- (void)addAulCategory:(NSString *)field;

- (void)removeAulCategory:(NSString *)field;

#pragma mark - initializers

- (instancetype)initWithAulSubsystem:(nonnull NSString *)aulSubsystem;

- (instancetype)initWithAulSubsystem:(nonnull NSString *)aulSubsystem
                       aulCategories:(nullable NSArray<NSString *> *)aulCategories;

- (instancetype)initWithArray:(NSArray *)data
NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
