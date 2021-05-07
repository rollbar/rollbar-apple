//
//  RollbarAulPredicateBuilder.m
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import "RollbarAulPredicateBuilder.h"

@import RollbarCommon;

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@implementation RollbarAulPredicateBuilder

#pragma mark - public methods

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystems:(nullable NSArray<NSString *> *)subsystems
                                               andForCategories:(nullable NSArray<NSString *> *)categories {
    
    NSPredicate *subsystemsPredicate = [self buildAulSubsystemsPredicate:subsystems];
    NSPredicate *categoriesPredicate  = [self buildAulCategoriesPredicate:categories];
    
    NSPredicate *combinedPredicate = [RollbarAulPredicateBuilder safelyCombinePredicate:subsystemsPredicate
                                                                           andPredicate:categoriesPredicate];
    
    return combinedPredicate;
}

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                              andForCategories:(nullable NSArray<NSString *> *)categories {

    NSPredicate *subsystemPredicate = [self buildAulSubsystemPredicate:subsystem];
    NSPredicate *categoriesPredicate  = [self buildAulCategoriesPredicate:categories];

    NSPredicate *combinedPredicate = [RollbarAulPredicateBuilder safelyCombinePredicate:subsystemPredicate
                                                                           andPredicate:categoriesPredicate];
    
    return combinedPredicate;
}

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                                andForCategory:(nullable NSString *)category {
    
    NSPredicate *subsystemPredicate = [self buildAulSubsystemPredicate:subsystem];
    NSPredicate *categoryPredicate  = [self buildAulCategoryPredicate:category];

    NSPredicate *combinedPredicate = [RollbarAulPredicateBuilder safelyCombinePredicate:subsystemPredicate
                                                                           andPredicate:categoryPredicate];
    
    return combinedPredicate;
}

+ (nullable NSPredicate *)buildAulSubsystemPredicate:(nullable NSString *)subsystem {
    
    NSPredicate *predicate = nil;
    
    if (nil != subsystem) {
        
        //predicate = [NSPredicate predicateWithFormat:@"subsystem == %@", subsystem];
        
        predicate = [RollbarPredicateBuilder buildStringPredicateWithValue:subsystem
                                                               forProperty:@"subsystem"];
    }

    return predicate;
}

+ (nullable NSPredicate *)buildAulSubsystemsPredicate:(nullable NSArray<NSString *> *)subsystems {
    
    NSPredicate *predicate = nil;
    
    if (nil != subsystems) {
        
        predicate = [RollbarPredicateBuilder buildStringPredicateWithValueList:subsystems
                                                                   forProperty:@"subsystem"];
    }

    return predicate;

}

+ (nullable NSPredicate *)buildAulCategoryPredicate:(nullable NSString *)category {
    
    NSPredicate *predicate = nil;
    
    if (nil != category) {
        
        predicate = [RollbarPredicateBuilder buildStringPredicateWithValue:category
                                                               forProperty:@"category"];
    }

    return predicate;
}

+ (nullable NSPredicate *)buildAulCategoriesPredicate:(nullable NSArray<NSString *> *)categories {
    
    NSPredicate *predicate = nil;
    
    if (nil != categories) {
        
        predicate = [RollbarPredicateBuilder buildStringPredicateWithValueList:categories
                                                                   forProperty:@"category"];
    }

    return predicate;
}

+ (nullable NSPredicate *)buildAulTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                         endingAt:(nullable NSDate *)endTime {
    
    NSPredicate *predicate = [RollbarPredicateBuilder buildTimeIntervalPredicateStartingAt:startTime
                                                                               inclusively:YES
                                                                                  endingAt:endTime
                                                                               inclusively:NO
                                                                               forProperty:@"date"];
    return predicate;
}

+ (nullable NSPredicate *)buildAulProcessPredicate {
    
//    NSString *processName = [RollbarHostingProcessUtil getHostingProcessName];
//    NSPredicate *processNamePredicate = [RollbarPredicateBuilder buildStringPredicateWithValue:processName
//                                                                                   forProperty:@"process"];
//
//    int processIdentifier = [RollbarHostingProcessUtil getHostingProcessIdentifier];
//    NSPredicate *processIdentifirePredicate = [RollbarPredicateBuilder buildIntegerPredicateWithValue:processIdentifier
//                                                                                          forProperty:@"processIdentifier"];
//
//    NSPredicate *predicate = [RollbarAulPredicateBuilder safelyCombinePredicate:processName
//                                                                   andPredicate:processIdentifier];
//
//    return predicate;

    int processIdentifier = [RollbarHostingProcessUtil getHostingProcessIdentifier];
    NSPredicate *processIdentifirePredicate = [RollbarPredicateBuilder buildIntegerPredicateWithValue:processIdentifier
                                                                                          forProperty:@"processIdentifier"];
    return processIdentifirePredicate;
}

#pragma mark - private methods

+ (nullable NSPredicate *)safelyCombinePredicate:(nullable NSPredicate *)leftPredicate
                                     orPredicate:(nullable NSPredicate *)rightPredicate {
    
    if ((nil != leftPredicate) && (nil != rightPredicate)) {
        
        NSPredicate *predicate =
        [NSCompoundPredicate orPredicateWithSubpredicates:@[leftPredicate, rightPredicate]];
        return predicate;
    }
    else if (nil != leftPredicate) {
        
        return leftPredicate;
    }
    else if (nil != rightPredicate) {
        
        return rightPredicate;
    }
    else {
        return nil;
    }
}

+ (nullable NSPredicate *)safelyCombinePredicate:(nullable NSPredicate *)leftPredicate
                                    andPredicate:(nullable NSPredicate *)rightPredicate {
    
    if ((nil != leftPredicate) && (nil != rightPredicate)) {
        
        NSPredicate *predicate =
        [NSCompoundPredicate andPredicateWithSubpredicates:@[leftPredicate, rightPredicate]];
        return predicate;
    }
    else if (nil != leftPredicate) {
        
        return leftPredicate;
    }
    else if (nil != rightPredicate) {
        
        return rightPredicate;
    }
    else {
        return nil;
    }
}

@end
