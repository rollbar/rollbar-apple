//
//  RollbarPredicateBuilder.h
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RollbarPredicateBuilder : NSObject

+ (nullable NSPredicate *)buildStringPredicateWithValue:(nullable NSString *)value
                                            forProperty:(nullable NSString *)property;

+ (nullable NSPredicate *)buildStringPredicateWithValueList:(nullable NSArray<NSString *> *)values
                                                forProperty:(nullable NSString *)property;

+ (nullable NSPredicate *)buildLessThanDatePredicateWithValue:(nullable NSDate *)value
                                                  forProperty:(nullable NSString *)property;

+ (nullable NSPredicate *)buildInclusiveTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                               endingAt:(nullable NSDate *)endTime
                                                            forProperty:(nullable NSString *)property;

+ (nullable NSPredicate *)buildTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                   inclusively:(BOOL)stratInclusively
                                                      endingAt:(nullable NSDate *)endTime
                                                   inclusively:(BOOL)endInclusively
                                                   forProperty:(nullable NSString *)property;

- (instancetype)init NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END
