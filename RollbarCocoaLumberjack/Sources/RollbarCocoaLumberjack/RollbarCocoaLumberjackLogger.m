#import "RollbarCocoaLumberjackLogger.h"

@implementation RollbarCocoaLumberjackLogger

#pragma mark - factory methods

+ (NSObject<DDLogger> *)createWithRollbarConfig:(RollbarConfig *)rollbarConfig {

    return [[RollbarCocoaLumberjackLogger alloc] initWithRollbarConfig:rollbarConfig];
}

+ (NSObject<DDLogger> *)createWithRollbarLogger:(RollbarLogger *)rollbarLogger {
    
    return [[RollbarCocoaLumberjackLogger alloc] initWithRollbarLogger:rollbarLogger];
}

#pragma mark - instance initializers

- (instancetype)initWithRollbarLogger:(RollbarLogger *)rollbarLogger {
    
    if ((self = [super init])) {
        _rollbarLogger = rollbarLogger;
    }
    return self;
}

- (instancetype)initWithRollbarConfig:(RollbarConfig *)rollbarConfig {
    
    RollbarLogger *rollbarLogger = [[RollbarLogger alloc] initWithConfiguration:rollbarConfig];
    return [self initWithRollbarLogger:rollbarLogger];
}

#pragma mark - DDLogger protocol

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logMsg = logMessage.message;
    
    if (self->_logFormatter)
        logMsg = [self->_logFormatter formatLogMessage:logMessage];
    
    if (logMsg) {
        // let's send it to Rollbar:
        [self->_rollbarLogger log:[RollbarCocoaLumberjackLogger convert:logMessage]
                          message:logMsg
                             data:nil
                          context:@"RollbarCocoaLumberjackLogger"
        ];
    }
}

#pragma mark - utility methods

+ (NSDictionary<NSString *, id> *)dataWithDDLogMessage:(DDLogMessage *)logMessage {
    
    return @{
        //TODO: complete the data mapping...
    };
}

+ (RollbarLevel) convert:(DDLogFlag) ddLogFlag {
    
    switch(ddLogFlag) {
        case DDLogFlagError:
            return RollbarLevel_Error;
        case DDLogFlagWarning:
            return RollbarLevel_Warning;
        case DDLogFlagInfo:
            return RollbarLevel_Info;
        case DDLogFlagDebug:
        case DDLogFlagVerbose:
            return RollbarLevel_Debug;
        default:
            return RollbarLevel_Critical;
    }
}
@end
