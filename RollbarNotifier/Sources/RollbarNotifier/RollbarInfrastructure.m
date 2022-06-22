//
//  RollbarInfrastructure.m
//  
//
//  Created by Andrey Kornich on 2022-06-09.
//

#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
#import "RollbarLogger.h"

const NSExceptionName RollbarInfrastructureNotConfiguredException;

@implementation RollbarInfrastructure {
    @private
    RollbarConfig *_configuration;
    RollbarLogger *_logger;
    NSString *_oomDetectionFilePath;
    NSString *_queuedItemsFilePath;
    NSString *_stateFilePath;

    
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

#pragma mark - configuration

- (nonnull instancetype)configureWith:(nonnull RollbarConfig *)rollbarConfig {
    
    [self assertValidConfiguration:rollbarConfig];
    
    if (self->_configuration
        && (NSOrderedSame == [[rollbarConfig serializeToJSONString] compare:[self->_configuration serializeToJSONString]])
        ) {
        return self; // no need to reconfigure with an identical configuration...
    }
    
    self->_configuration = rollbarConfig;
    self->_logger = [RollbarLogger loggerWithConfiguration:rollbarConfig];
    return self;
}

#pragma mark - properties

- (nonnull RollbarConfig *)configuration {
    
    [self assertValidConfiguration:self->_configuration];
    if (YES == [self hasValidConfiguration]) {
        return self->_configuration;
    }
    else {
        [self raiseNotConfiguredException];
        return nil;
    }
}

- (nonnull RollbarLogger *)logger {
    
    if (self->_logger) {
        return self->_logger;
    }
    else {
        [self assertValidConfiguration:self->_configuration];
        [self raiseNotConfiguredException];
        return nil;
    }
}

#pragma mark - internal methods

- (void)raiseNotConfiguredException {
    [NSException raise:RollbarInfrastructureNotConfiguredException
                format:@"Make sure the [[RollbarInfrastructure sharedInstance] configureWith:...] is called "
     "providing a valid RollbarConfig instance!"
    ];
}

- (BOOL)hasValidConfiguration {
        
    if (!self->_configuration) {
        return NO;
    }

    //TODO: complete full validation implementation...

    return YES;
}

- (void)assertValidConfiguration:(nullable RollbarConfig *)config {
    
    NSAssert(config,
             @"Provide valid configuration via [[RollbarInfrastructure sharedInstance] configureWith:...]!");
    
    //TODO: complete full validation implementation...
}

- (void)setupInternalStorage {
    
    //TODO: implement...
}

- (void)setupConfigurableStorage {
    
    //TODO: implement...
}

- (void)configureInfrastructure {
    
    //TODO: implement...
}

@end
