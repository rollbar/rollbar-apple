//
//  RollbarPredicateBuilder.m
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import "RollbarPredicateBuilder.h"

@implementation RollbarPredicateBuilder

+ (nullable NSPredicate *)buildStringPredicateWithValue:(nullable NSString *)value
                                            forProperty:(nullable NSString *)property {
    
    NSPredicate *predicate = nil;
    
    if ((nil != property) && (nil != value)) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K == %@", property, value];
    }
    else if (nil != property) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K == nil", property, value];
    }

    return predicate;
}

+ (nullable NSPredicate *)buildStringPredicateWithValueList:(nullable NSArray<NSString *> *)values
                                                forProperty:(nullable NSString *)property {
    
    //TODO: implement...
}


+ (nullable NSPredicate *)buildLessThanDatePredicateWithValue:(nullable NSDate *)value
                                                  forProperty:(nullable NSString *)property {
    
    
    if (nil == property) {
        
        return nil;
    }
    
    NSPredicate *predicate = nil;
    
    if (nil != value) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K < %@", property, value];
    }
    
    return predicate;
}

+ (nullable NSPredicate *)buildInclusiveTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                               endingAt:(nullable NSDate *)endTime
                                                            forProperty:(nullable NSString *)property {
    
    if (nil == property) {
        
        return nil;
    }
    
    NSPredicate *predicate = nil;
    
    if ((nil != startTime) && (nil != endTime)) {
        
        predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", property, startTime, property, endTime];
    }
    else if (nil != startTime) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K >= %@", property, startTime];
    }
    else if (nil != endTime) {
        
        predicate = [NSPredicate predicateWithFormat:@"%K <= %@", property, endTime];
    }

    return predicate;
}

+ (nullable NSPredicate *)buildTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                   inclusively:(BOOL)stratInclusively
                                                      endingAt:(nullable NSDate *)endTime
                                                   inclusively:(BOOL)endInclusively
                                                   forProperty:(nullable NSString *)property {
    
    if (nil == property) {
        
        return nil;
    }
    
    NSPredicate *predicate = nil;
    
    NSString *startCondition = (YES == stratInclusively) ? @">=" : @">";
    NSString *endCondition = (YES == endInclusively) ? @"<=" : @"<";

    if ((nil != startTime) && (nil != endTime)) {
        
        if ((YES == stratInclusively) && (YES == endInclusively)) {
            predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", property, startTime, property, endTime];
        }
        else if ((NO == stratInclusively) && (YES == endInclusively)) {
            predicate = [NSPredicate predicateWithFormat:@"(%K > %@) AND (%K <= %@)", property, startTime, property, endTime];
        }
        else if ((YES == stratInclusively) && (NO == endInclusively)) {
            predicate = [NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K < %@)", property, startTime, property, endTime];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"(%K > %@) AND (%K < %@)", property, startTime, property, endTime];
        }
    }
    else if (nil != startTime) {
        
        if (YES == stratInclusively) {
            predicate = [NSPredicate predicateWithFormat:@"%K >= %@", property, startTime];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"%K > %@", property, startTime];
        }
    }
    else if (nil != endTime) {
        
        if (YES == endInclusively) {
            predicate = [NSPredicate predicateWithFormat:@"%K <= %@", property, endTime];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"%K < %@", property, endTime];
        }
    }

    return predicate;
}

@end
