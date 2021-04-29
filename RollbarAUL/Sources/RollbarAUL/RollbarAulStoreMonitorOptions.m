//
//  RollbarAulStoreMonitorOptions.m
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import "RollbarAulStoreMonitorOptions.h"

#pragma mark - data field keys

static NSString * const DFK_AUL_SUBSYSTEM = @"aul_sysbsystem";
static NSString * const DFK_AUL_CATEGORIES = @"aul_categories";

@implementation RollbarAulStoreMonitorOptions

#pragma mark - initializers

- (instancetype)init {
 
    // by default, we only want to monitor AUL events/entries that are
    // relevant to the currently running application/main bundle:
    
    NSBundle *mainBundle =
    [NSBundle mainBundle];
    
    NSString *bundleIdentifier =
    [mainBundle objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    
    return [self initWithAulSubsystem:bundleIdentifier];
}

- (instancetype)initWithAulSubsystem:(nonnull NSString *)aulSubsystem {
    
    return [self initWithAulSubsystem:aulSubsystem
                        aulCategories:nil];
}

- (instancetype)initWithAulSubsystem:(nonnull NSString *)aulSubsystem
                       aulCategories:(nullable NSArray<NSString *> *)aulCategories {
    
    self = [self initWithDictionary:@{
        DFK_AUL_SUBSYSTEM:aulSubsystem,
        DFK_AUL_CATEGORIES:aulCategories,
    }];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)data {

    return [super initWithDictionary:data];
}

- (instancetype)initWithArray:(NSArray *)data {
    
    @throw nil;
}

#pragma mark - property accessors

- (NSString *)aulSubsystem {
    
    NSString *result = [self safelyGetStringByKey:DFK_AUL_SUBSYSTEM];
    return result;
}

- (void)setAulSubsystem:(NSString *)value {
    
    [self setString:value forKey:DFK_AUL_SUBSYSTEM];
}

- (NSArray<NSString *> *)aulCategories {
    
    NSArray *result = [self safelyGetArrayByKey:DFK_AUL_CATEGORIES];
    return result;
}

- (void)setAulCategories:(NSArray<NSString *> *)scrubFields {
    
    [self setArray:scrubFields forKey:DFK_AUL_CATEGORIES];
}

- (void)addAulCategory:(NSString *)field {
    
    self.aulCategories =
    [self.aulCategories arrayByAddingObject:field];
}

- (void)removeAulCategory:(NSString *)field {
    
    NSMutableArray *mutableCopy = self.aulCategories.mutableCopy;
    [mutableCopy removeObject:field];
    self.aulCategories = mutableCopy.copy;
}

@end
