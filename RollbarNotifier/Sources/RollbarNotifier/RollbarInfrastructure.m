#import "RollbarInfrastructure.h"
#import "RollbarConfig.h"
#import "RollbarLogger.h"
#import "RollbarNotifierFiles.h"

@implementation RollbarInfrastructure {
    @private
    RollbarConfig *_configuration;
    RollbarLogger *_logger;
    NSString *_oomDetectionFilePath;
    NSString *_queuedItemsFilePath;
    NSString *_stateFilePath;
    NSString *_payloadsFilePath;
    NSMutableDictionary *_queueState;
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
    self->_logger = nil;
    
    [self setupInternalStorage];
    
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

- (void)setupInternalStorage {
    
    // create working cache directory:
    [RollbarCachesDirectory ensureCachesDirectoryExists];
    NSString *cachesDirectory = [RollbarCachesDirectory directory];
    
    // make sure we have all the data files set:
    self->_queuedItemsFilePath =
    [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles itemsQueue]];
    self->_stateFilePath =
    [cachesDirectory stringByAppendingPathComponent:[RollbarNotifierFiles itemsQueueState]];
    
    // create the queued items file if does not exist already:
    if (![[NSFileManager defaultManager] fileExistsAtPath:self->_queuedItemsFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:self->_queuedItemsFilePath
                                                contents:nil
                                              attributes:nil];
    }
    
    // create state tracking file if does not exist already:
    if ([[NSFileManager defaultManager] fileExistsAtPath:self->_stateFilePath]) {
        NSData *stateData = [NSData dataWithContentsOfFile:self->_stateFilePath];
        if (stateData) {
            NSDictionary *state = [NSJSONSerialization JSONObjectWithData:stateData
                                                                  options:0
                                                                    error:nil];
            self->_queueState = [state mutableCopy];
        } else {
            RollbarSdkLog(@"There was an error restoring saved queue state");
        }
    }
    
    // let's make sure we always recover into a good state if applicable:
    if (!self->_queueState) {
        self->_queueState = [@{
            @"offset": [NSNumber numberWithUnsignedInt:0],
            @"retry_count": [NSNumber numberWithUnsignedInt:0]
        } mutableCopy];
        [self saveQueueState];
    }
}

- (void)configureInfrastructure {
    
    //TODO: implement...
}

- (void)saveQueueState {
    NSError *error;
    NSData *data = [NSJSONSerialization rollbar_dataWithJSONObject:self->_queueState
                                                           options:0
                                                             error:&error
                                                              safe:true];
    if (error) {
        RollbarSdkLog(@"Error: %@", [error localizedDescription]);
    }
    [data writeToFile:self->_stateFilePath atomically:YES];
}

@end
