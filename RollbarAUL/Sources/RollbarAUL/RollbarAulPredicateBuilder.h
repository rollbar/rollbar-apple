//
//  RollbarAulPredicateBuilder.h
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@interface RollbarAulPredicateBuilder : NSObject

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                                andForCategory:(nullable NSString *)category;

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                              andForCategories:(nullable NSArray<NSString *> *)categories;

+ (nullable NSPredicate *)buildAulSubsystemPredicate:(nullable NSString *)subsystem;

+ (nullable NSPredicate *)buildAulCategoryPredicate:(nullable NSString *)category;

+ (nullable NSPredicate *)buildAulCategoriesPredicate:(nullable NSArray<NSString *> *)categories;

+ (nullable NSPredicate *)buildAulTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                         endingAt:(nullable NSDate *)endTime;

- (instancetype)init NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END
