#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
//#import "RollbarDestination.h"
#import "RollbarLoggerProtocol.h"
#import "RollbarLogger.h"
#import "RollbarNotifierFiles.h"
//#import "RollbarLoggerRegistry.h"

@implementation RollbarInfrastructure {
    @private
    RollbarConfig *_configuration;
    RollbarLogger *_logger;
//    RollbarLoggerRegistry *_loggerRegistry;
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

//- (instancetype)init {
//
//    if (self = [super init]) {
//
////        self->_loggerRegistry = [RollbarLoggerRegistry new];
//    }
//    return self;
//}

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

- (nonnull id<RollbarLogger>)createLogger {

    return [self createLoggerWithConfig:self.configuration];
}

- (nonnull id<RollbarLogger>)createLoggerWithConfig:(nonnull RollbarConfig *)config {
    
    RollbarLogger *logger = [RollbarLogger loggerWithConfiguration:config];
    //RollbarLogger *logger = [self->_loggerRegistry loggerWithConfiguration:config];
    return logger;
}

- (nonnull id<RollbarLogger>)createLoggerWithAccessToken:(nonnull NSString *)token
                                          andEnvironment:(nonnull NSString *)env {
    
    RollbarConfig *config = [self.configuration copy];
    config.destination.accessToken = token;
    config.destination.environment = env;
    id logger = [self createLoggerWithConfig:config];
    return logger;
}

- (nonnull id<RollbarLogger>)createLoggerWithAccessToken:(nonnull NSString *)token {
    
    RollbarConfig *config = [self.configuration copy];
    config.destination.accessToken = token;
    id logger = [self createLoggerWithConfig:config];
    return logger;
}

#pragma mark - class methods

//+ (nonnull id<RollbarLogger>)sharedLogger {
//
//    return [RollbarInfrastructure sharedInstance].logger;
//}
//
//+ (nonnull id<RollbarLogger>)newLogger {
//    
//    return [[RollbarInfrastructure sharedInstance] createLogger];
//}
//
//+ (nonnull id<RollbarLogger>)newLoggerWithConfig:(nonnull RollbarConfig *)config {
//
//    return [[RollbarInfrastructure sharedInstance] createLoggerWithConfig:config];
//}
//
//+ (nonnull id<RollbarLogger>)newLoggerWithAccessToken:(nonnull NSString *)token {
// 
//    return [[RollbarInfrastructure sharedInstance] createLoggerWithAccessToken:token];
//}
//
//+ (nonnull id<RollbarLogger>)newLoggerWithAccessToken:(nonnull NSString *)token
//                                  andEnvironment:(nonnull NSString *)env {
//    
//    return [[RollbarInfrastructure sharedInstance] createLoggerWithAccessToken:token
//                                                                andEnvironment:env];
//}

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

- (nonnull id<RollbarLogger>)logger {
    
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
