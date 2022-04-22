//
//  RollbarOomDetectionState.m
//  
//
//  Created by Andrey Kornich on 2022-04-21.
//

#import "RollbarOomDetectionState.h"

@implementation RollbarOomDetectionState

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance {
    
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singleton = [self new];
    });
    
    return singleton;
}

@end
