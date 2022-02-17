#ifndef RollbarPredicateBuilder_h
#define RollbarPredicateBuilder_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Builder of useful predicate objects
@interface RollbarPredicateBuilder : NSObject

/// Integer property value predicate builder.
/// @param value a value
/// @param property a property
+ (nullable NSPredicate *)buildIntegerPredicateWithValue:(NSInteger)value
                                             forProperty:(nullable NSString *)property;

/// Number property value predicate builder.
/// @param value a value
/// @param property a property
+ (nullable NSPredicate *)buildNumberPredicateWithValue:(nullable NSNumber *)value
                                            forProperty:(nullable NSString *)property;

/// String property value predicate builder.
/// @param value a value
/// @param property a property
+ (nullable NSPredicate *)buildStringPredicateWithValue:(nullable NSString *)value
                                            forProperty:(nullable NSString *)property;

/// String property value list predicate builder.
/// @param values a value list
/// @param property a property
+ (nullable NSPredicate *)buildStringPredicateWithValueList:(nullable NSArray<NSString *> *)values
                                                forProperty:(nullable NSString *)property;

/// Less-than date-time property predicate
/// @param value a date to compare to
/// @param property a property
+ (nullable NSPredicate *)buildLessThanDatePredicateWithValue:(nullable NSDate *)value
                                                  forProperty:(nullable NSString *)property;

/// Inclusive date-time interval predicate
/// @param startTime a starting date-time
/// @param endTime an ending dat-time
/// @param property a property
+ (nullable NSPredicate *)buildInclusiveTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                               endingAt:(nullable NSDate *)endTime
                                                            forProperty:(nullable NSString *)property;

/// Date-time interval oredicate
/// @param startTime a starting date-time
/// @param stratInclusively should include the start date-time or not
/// @param endTime an ending date-time
/// @param endInclusively should include the end- date-time or not
/// @param property a property
+ (nullable NSPredicate *)buildTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                   inclusively:(BOOL)stratInclusively
                                                      endingAt:(nullable NSDate *)endTime
                                                   inclusively:(BOOL)endInclusively
                                                   forProperty:(nullable NSString *)property;

/// Hides parameterless initializer.
- (instancetype)init
NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END

#endif //RollbarPredicateBuilder_h
