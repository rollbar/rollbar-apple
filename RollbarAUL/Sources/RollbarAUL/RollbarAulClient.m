//
//  RollbarAulClient.m
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import "RollbarAulClient.h"
#import "RollbarAulPredicateBuilder.h"

@implementation RollbarAulClient

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               staringAtTimestamp:(nullable NSDate *)startTimestamp
                                                endingAtTimestamp:(nullable NSDate *)endTimestamp
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category {
    
    
    if (nil == logStore) {
        
        return nil;
    }
    
    OSLogPosition *logPosition = [logStore positionWithDate:startTimestamp];
    
    NSPredicate *predicateSource = [RollbarAulPredicateBuilder buildRollbarAulPredicateForSubsystem:subsystem
                                                                                   andForCategory:category];
    NSPredicate *predicateTime = [RollbarAulPredicateBuilder buildAulTimeIntervalPredicateStartingAt:startTimestamp
                                                                                            endingAt:endTimestamp];
    NSPredicate *predicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateSource, predicateTime]];

    OSLogEnumerator *logEnumerator = [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                                                         staringAtPosition:logPosition
                                                                            usingPredicate:predicate];
    
    return logEnumerator;
}

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               withinTimeInterval:(nullable NSDateInterval *)timeInterval
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category {

    if (nil != timeInterval) {

        return [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                                  staringAtTimestamp:timeInterval.startDate
                                                   endingAtTimestamp:timeInterval.endDate
                                                        forSubsystem:subsystem
                                                      andForCategory:category];
    }
    else {
        
        return [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                                  staringAtTimestamp:nil
                                                   endingAtTimestamp:nil
                                                        forSubsystem:subsystem
                                                      andForCategory:category];
    }
}

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                               staringAtTimestamp:(nullable NSDate *)startTimestamp
                                            withDurationInSeconds:(NSTimeInterval)durationInSeconds
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category {
    
    if (nil == logStore) {
        
        return nil;
    }
    
    NSDateInterval *timeInterval = [[NSDateInterval alloc] initWithStartDate:startTimestamp
                                                                    duration:durationInSeconds];
    OSLogEnumerator *logEnumerator = [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                                                        withinTimeInterval:timeInterval
                                                                              forSubsystem:subsystem
                                                                            andForCategory:category];
    return logEnumerator;
}


+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                     forSubsystem:(nullable NSString *)subsystem
                                                   andForCategory:(nullable NSString *)category {
    
    if (nil == logStore) {
        
        return nil;
    }
    
    NSPredicate *predicate = [RollbarAulPredicateBuilder buildRollbarAulPredicateForSubsystem:subsystem
                                                                               andForCategory:category];

    return [RollbarAulClient buildAulLogEnumeratorWithinLogStore:logStore
                                               staringAtPosition:logPosition
                                                  usingPredicate:predicate];
}

+ (nullable OSLogEnumerator *)buildAulLogEnumeratorWithinLogStore:(nullable OSLogStore *)logStore
                                                staringAtPosition:(nullable OSLogPosition *)logPosition
                                                   usingPredicate:(nullable NSPredicate *)predicate {
    
    if (nil == logStore) {
        
        return nil;
    }
    
    NSError *error = nil;
    OSLogEnumerator *logEnumerator = [logStore entriesEnumeratorWithOptions:0
                                                                   position:logPosition
                                                                  predicate:predicate
                                                                      error:&error];
    if (nil != error) {
        
        //TODO: log into the SDK log
        return nil;
    }
    
    return logEnumerator;
}

@end
