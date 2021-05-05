//
//  RollbarAulPredicateBuilder.m
//  
//
//  Created by Andrey Kornich on 2021-04-29.
//

#import "RollbarAulPredicateBuilder.h"

@import RollbarCommon;

@implementation RollbarAulPredicateBuilder

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                              andForCategories:(nullable NSArray<NSString *> *)categories {

    NSPredicate *subsystemPredicate = [self buildAulSubsystemPredicate:subsystem];
    NSPredicate *categoriesPredicate  = [self buildAulCategoriesPredicate:categories];

    if ((nil != subsystemPredicate) && (nil != categoriesPredicate)) {
        
        NSPredicate *predicate =
        [NSCompoundPredicate andPredicateWithSubpredicates:@[subsystemPredicate, categoriesPredicate]];
        return predicate;
    }
    else if (nil != subsystemPredicate) {
        
        return subsystemPredicate;
    }
    else if (nil != categoriesPredicate) {
        
        return categoriesPredicate;
    }
    else {
        return nil;
    }
}

+ (nullable NSPredicate *)buildRollbarAulPredicateForSubsystem:(nullable NSString *)subsystem
                                                andForCategory:(nullable NSString *)category {
    
    NSPredicate *subsystemPredicate = [self buildAulSubsystemPredicate:subsystem];
    NSPredicate *categoryPredicate  = [self buildAulCategoryPredicate:category];

    if ((nil != subsystemPredicate) && (nil != categoryPredicate)) {
        
        NSPredicate *predicate =
        [NSCompoundPredicate andPredicateWithSubpredicates:@[subsystemPredicate, categoryPredicate]];
        return predicate;
    }
    else if (nil != subsystemPredicate) {
        
        return subsystemPredicate;
    }
    else if (nil != categoryPredicate) {
        
        return categoryPredicate;
    }
    else {
        return nil;
    }
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

+ (nullable NSPredicate *)buildAulCategoriesPredicate:(nullable NSArray<NSString *> *)categories {
    
    //TODO: implement...
    NSPredicate *predicate = nil;
    
    if (nil != categories) {
        
        predicate = [RollbarPredicateBuilder buildStringPredicateWithValueList:categories
                                                                   forProperty:@"category"];
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

+ (nullable NSPredicate *)buildAulTimeIntervalPredicateStartingAt:(nullable NSDate *)startTime
                                                         endingAt:(nullable NSDate *)endTime {
    
    NSPredicate *predicate = [RollbarPredicateBuilder buildTimeIntervalPredicateStartingAt:startTime
                                                                               inclusively:YES
                                                                                  endingAt:endTime
                                                                               inclusively:NO
                                                                               forProperty:@"date"];
    return predicate;
}

@end
