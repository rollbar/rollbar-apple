//
//  RollbarAulClient.h
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#ifndef RollbarAulClient_h
#define RollbarAulClient_h

@import Foundation;

#if TARGET_OS_OSX

//@import OSLog;
#if __has_include(<OSLog/OSLog.h>)
  #include <OSLog/OSLog.h>
#endif

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
/// Rollbar client for enumerating relevant entries within specified AUL store
@interface RollbarAulClient : NSObject

/// Builds an AUL enumerator
/// @param logStore a logStore of interest
/// @param logPosition the initial log position
/// @param predicate predicate to use while enumerating
+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                   usingPredicate:(nullable NSPredicate *)predicate;

/// Builds an AUL enumerator
/// @param logStore a logStore of interest
/// @param startTimestamp start time
/// @param endTimestamp end time
/// @param subsystem subsystem of interest
/// @param category category of interest
+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               staringAtTimestamp:(nullable NSDate *)startTimestamp
                                                endingAtTimestamp:(nullable NSDate *)endTimestamp
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

/// Builds an AUL enumerator
/// @param logStore a logStore of interest
/// @param timeInterval time interval of interest
/// @param subsystem subsystem of interest
/// @param category category of interest
+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               withinTimeInterval:(nullable NSDateInterval *)timeInterval
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

/// Builds an AUL enumerator
/// @param logStore a logStore of interest
/// @param startTimestamp start time
/// @param durationInSeconds duration since the start time
/// @param subsystem subsystem of interest
/// @param category category of interest
+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               staringAtTimestamp:(nullable NSDate *)startTimestamp
                                            withDurationInSeconds:(NSTimeInterval)durationInSeconds
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

/// Builds an AUL enumerator
/// @param logStore a logStore of interest
/// @param logPosition the initial log losition of interst
/// @param subsystem subsystem of interest
/// @param category category of interst
+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

/// Hides the initializer.
- (instancetype)init
NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END

#endif //RollbarAulClient_h

#endif //TARGET_OS_OSX
