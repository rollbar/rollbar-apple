//
//  RollbarInfrastructure.m
//  
//
//  Created by Andrey Kornich on 2022-06-09.
//

#import "RollbarInfrastructure.h"

@implementation RollbarInfrastructure

- (nonnull instancetype)configureWith:(RollbarConfig *)rollbarConfig {
    
    self->_config = rollbarConfig;
    
    return self;
}

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
