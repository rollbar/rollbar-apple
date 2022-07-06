#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
#import "RollbarLogger.h"
#import "RollbarNotifierFiles.h"
#import "RollbarLoggerRegistry.h"

@implementation RollbarInfrastructure {
    @private
    RollbarConfig *_configuration;
    RollbarLogger *_logger;
    RollbarLoggerRegistry *_loggerRegistry;
}

#pragma mark - Sigleton pattern

+ (nonnull instancetype)sharedInstance {
    
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singleton = [RollbarInfrastructure new];

        RollbarSdkLog(@"%@ singleton created!",
                      [RollbarInfrastructure rollbar_objectClassName]
                      );
    });
    
    return singleton;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        self->_loggerRegistry = [RollbarLoggerRegistry new];
    }
    return self;
}

#pragma mark - instance methods

- (nonnull instancetype)configure:(nonnull RollbarConfig *)config {
    
    [self assertValidConfiguration:config];
    
    if (self->_configuration
        && (NSOrderedSame == [[config serializeToJSONString] compare:[self->_configuration serializeToJSONString]])
        ) {
        return self; // no need to reconfigure with an identical configuration...
    }
    
    self->_configuration = config;
    self->_logger = nil; //will be created as needed using the new config...
    
    RollbarSdkLog(@"%@ is configured with this RollbarConfig instance: \n%@",
                  [RollbarInfrastructure rollbar_objectClassName],
                  config
                  );
    
    return self;
}

- (nonnull RollbarLogger *)createLogger {

    return [self createLoggerWithConfig:self.configuration];
}

- (nonnull RollbarLogger *)createLoggerWithConfig:(nonnull RollbarConfig *)config {
    
    RollbarLogger *logger = [self->_loggerRegistry loggerWithConfiguration:config];
    return logger;
}

#pragma mark - class methods

+ (nonnull RollbarLogger *)sharedLogger {

    return [RollbarInfrastructure sharedInstance].logger;
}

+ (nonnull RollbarLogger *)logger {

    return [[RollbarInfrastructure sharedInstance] createLogger];
}

+ (nonnull RollbarLogger *)loggerWithConfig:(nonnull RollbarConfig *)config {

    return [[RollbarInfrastructure sharedInstance] createLoggerWithConfig:config];
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
        self->_logger = [self->_loggerRegistry loggerWithConfiguration:self.configuration];
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
