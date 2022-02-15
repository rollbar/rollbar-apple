#ifndef RollbarPredicateBuilder_h
#define RollbarPredicateBuilder_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Builder of useful predicate objects
@interface RollbarPredicateBuilder : NSObject

+ (nullable NSPredicate *)buildIntegerPredicateWithValue:(NSInteger)value
                                             forProperty:(nullable NSString *)property;

+ (nullable NSPredicate *)buildNumberPredicateWithValue:(nullable NSNumber *)value
                                            forProperty:(nullable NSString *)property;

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

#endif //RollbarPredicateBuilder_h
