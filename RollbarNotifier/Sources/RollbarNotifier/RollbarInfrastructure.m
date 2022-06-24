#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
#import "RollbarLogger.h"
#import "RollbarNotifierFiles.h"

@implementation RollbarInfrastructure {
    @private
    RollbarConfig *_configuration;
    RollbarLogger *_logger;
}

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance {
    
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singleton = [self new];

        RollbarSdkLog(@"%@ singleton created!",
                      [RollbarInfrastructure className]
                      );
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
    self->_logger = nil;
    
    RollbarSdkLog(@"%@ is configured with this RollbarConfig instance: \n%@",
                  [RollbarInfrastructure className],
                  rollbarConfig
                  );
    
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
    
    if (!self->_logger) {
        self->_logger = [RollbarLogger loggerWithConfiguration:self.configuration];
    }

    return self->_logger;
}

#pragma mark - internal methods

- (void)raiseNotConfiguredException {
    [NSException raise:@"RollbarInfrastructureNotConfiguredException"
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


- (void)configureInfrastructure {
    
    //TODO: implement...
}

@end
