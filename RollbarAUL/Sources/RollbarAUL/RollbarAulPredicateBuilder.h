//
//  RollbarAulPredicateBuilder.h
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#ifndef RollbarAulPredicateBuilder_h
#define RollbarAulPredicateBuilder_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@interface RollbarAulPredicateBuilder : NSObject

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                                andForCategory:(nullable NSString *)category;

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                              andForCategories:(nullable NSArray<NSString *> *)categories;

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystems:(nullable NSArray<NSString *> *)subsystems
                                               andForCategories:(nullable NSArray<NSString *> *)categories;

+ (nullable NSPredicate *)buildAulSubsystemPredicate:(nullable NSString *)subsystem;

+ (nullable NSPredicate *)buildAulSubsystemsPredicate:(nullable NSArray<NSString *> *)subsystems;

+ (nullable NSPredicate *)buildAulCategoryPredicate:(nullable NSString *)category;

+ (nullable NSPredicate *)buildAulCategoriesPredicate:(nullable NSArray<NSString *> *)categories;

+ (nullable NSPredicate *)buildAulTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                         endingAt:(nullable NSDate *)endTime;

+ (nullable NSPredicate *)buildAulProcessPredicate;

+ (nullable NSPredicate *)buildAulFaultsPredicate;

- (instancetype)init NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulPredicateBuilder_h
