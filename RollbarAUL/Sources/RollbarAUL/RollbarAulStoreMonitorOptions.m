//
//  RollbarAulStoreMonitorOptions.m
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import "RollbarAulStoreMonitorOptions.h"

#if TARGET_OS_OSX

#pragma mark - data field keys

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
static NSString * const DFK_AUL_SUBSYSTEMS = @"aul_subsystems";

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
static NSString * const DFK_AUL_CATEGORIES = @"aul_categories";

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@implementation RollbarAulStoreMonitorOptions

#pragma mark - initializers

- (instancetype)init {
 
    return [self initWithAulSubsystems:nil
                         aulCategories:nil];
}

- (instancetype)initWithAulSubsystems:(nullable NSArray<NSString *> *)aulSubsystems {
    
    return [self initWithAulSubsystems:aulSubsystems
                         aulCategories:nil];
}

- (instancetype)initWithAulSubsystems:(nullable NSArray<NSString *> *)aulSubsystems
                        aulCategories:(nullable NSArray<NSString *> *)aulCategories {
    
    self = [self initWithDictionary:@{
        DFK_AUL_SUBSYSTEMS:(nil != aulSubsystems) ? aulSubsystems : [NSNull null],
        DFK_AUL_CATEGORIES:(nil != aulCategories) ? aulCategories : [NSNull null],
    }];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)data {

    return [super initWithDictionary:data];
}

- (instancetype)initWithArray:(NSArray *)data {
    
    @throw nil;
}

#pragma mark - subsystems

- (NSArray<NSString *> *)aulSubsystems {
    
    NSArray *result = [self safelyGetArrayByKey:DFK_AUL_SUBSYSTEMS];
    return result;
}

- (void)setAulSubsystems:(NSArray<NSString *> *)subsystems {
    
    [self setArray:subsystems forKey:DFK_AUL_SUBSYSTEMS];
}

- (void)addAulSubsystem:(NSString *)subsystem {
    
    self.aulSubsystems =
    [self.aulSubsystems arrayByAddingObject:subsystem];
}

- (void)removeAulSubsystem:(NSString *)subsystem {
    
    NSMutableArray *mutableCopy = self.aulSubsystems.mutableCopy;
    [mutableCopy removeObject:subsystem];
    self.aulSubsystems = mutableCopy.copy;
}

#pragma mark - categories

- (NSArray<NSString *> *)aulCategories {
    
    NSArray *result = [self safelyGetArrayByKey:DFK_AUL_CATEGORIES];
    return result;
}

- (void)setAulCategories:(NSArray<NSString *> *)categories {
    
    [self setArray:categories forKey:DFK_AUL_CATEGORIES];
}

- (void)addAulCategory:(NSString *)category {
    
    self.aulCategories =
    [self.aulCategories arrayByAddingObject:category];
}

- (void)removeAulCategory:(NSString *)category {
    
    NSMutableArray *mutableCopy = self.aulCategories.mutableCopy;
    [mutableCopy removeObject:category];
    self.aulCategories = mutableCopy.copy;
}

@end

#endif //TARGET_OS_OSX
