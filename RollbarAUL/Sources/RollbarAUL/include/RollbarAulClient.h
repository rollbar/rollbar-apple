//
//  RollbarAulClient.h
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

@import Foundation;

//@import OSLog;
#if __has_include(<OSLog/OSLog.h>)
  #include <OSLog/OSLog.h>
#endif

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@interface RollbarAulClient : NSObject

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                   usingPredicate:(nullable NSPredicate *)predicate;

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               staringAtTimestamp:(nullable NSDate *)startTimestamp
                                                endingAtTimestamp:(nullable NSDate *)endTimestamp
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               withinTimeInterval:(nullable NSDateInterval *)timeInterval
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               staringAtTimestamp:(nullable NSDate *)startTimestamp
                                            withDurationInSeconds:(NSTimeInterval)durationInSeconds
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category;

- (instancetype)init NS_UNAVAILABLE; // This is static utility class. No instances needed...

@end

NS_ASSUME_NONNULL_END
