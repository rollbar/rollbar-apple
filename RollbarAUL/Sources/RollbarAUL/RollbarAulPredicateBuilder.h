#ifndef RollbarAulPredicateBuilder_h
#define RollbarAulPredicateBuilder_h

@import Foundation;

#if TARGET_OS_OSX

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// AUL predicate builder utility
@interface RollbarAulPredicateBuilder : NSObject

/// Builds an AUL subsystem and category predicate
/// @param subsystem subsystem of interest
/// @param category category of interest
+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                                andForCategory:(nullable NSString *)category;

/// Builds an AUL subsystem and categories predicate
/// @param subsystem subsystem of interest
/// @param categories categories of interest
+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                              andForCategories:(nullable NSArray<NSString *> *)categories;

/// Builds an AUL subsystems and categories predicate
/// @param subsystems subsystems of interest
/// @param categories categories of interest
+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystems:(nullable NSArray<NSString *> *)subsystems
                                               andForCategories:(nullable NSArray<NSString *> *)categories;

/// Builds an AUL subsystem predicate
/// @param subsystem subsystem of interest
+ (nullable NSPredicate *)buildAulSubsystemPredicate:(nullable NSString *)subsystem;

/// Builds an AUL subsystems predicate
/// @param subsystems subsystems of interest
+ (nullable NSPredicate *)buildAulSubsystemsPredicate:(nullable NSArray<NSString *> *)subsystems;

/// Builds an AUL category predicate
/// @param category category of interest
+ (nullable NSPredicate *)buildAulCategoryPredicate:(nullable NSString *)category;

/// Builds an AUL categories predicate
/// @param categories categories of interest
+ (nullable NSPredicate *)buildAulCategoriesPredicate:(nullable NSArray<NSString *> *)categories;

/// Builds an AUL time interval predicate
/// @param startTime staring time
/// @param endTime ending time
+ (nullable NSPredicate *)buildAulTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                         endingAt:(nullable NSDate *)endTime;

/// Builds an AUL current process predicate
+ (nullable NSPredicate *)buildAulProcessPredicate;

/// Builds an AUL faults  predicate
+ (nullable NSPredicate *)buildAulFaultsPredicate
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
;

/// Hides the initializer.
- (instancetype)init
NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulPredicateBuilder_h

#endif //TARGET_OS_OSX
