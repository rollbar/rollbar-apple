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
        [self->_rollbarLogger log:[RollbarCocoaLumberjackLogger convertDDLogFlagToRollbarLevel:logMessage.flag]
                          message:logMsg
                             data:[RollbarCocoaLumberjackLogger dataWithDDLogMessage:logMessage]
                          context:@"RollbarCocoaLumberjackLogger"
        ];
    }
}

#pragma mark - utility methods

+ (NSDictionary<NSString *, id> *)dataWithDDLogMessage:(DDLogMessage *)logMessage {
    
    return @{
        @"DDLogMessage.message":
            logMessage.message,
        @"DDLogMessage.level":
            [RollbarCocoaLumberjackLogger convertDDLogLevelToString:logMessage.level],
        @"DDLogMessage.flag":
            [RollbarCocoaLumberjackLogger convertDDLogFlagToString:logMessage.flag],
        @"DDLogMessage.context":
            [NSNumber numberWithInteger:logMessage.context],
        @"DDLogMessage.file":
            logMessage.file,
        @"DDLogMessage.fileName":
            logMessage.fileName,
        @"DDLogMessage.function":
            (nil != logMessage.function) ? logMessage.function : @"<nil>",
        @"DDLogMessage.line":
            [NSNumber numberWithUnsignedInteger:logMessage.line],
        @"DDLogMessage.representedObject":
            (nil != logMessage.representedObject) ? [logMessage.representedObject description] : @"<nil>",
        @"DDLogMessage.options":
            [RollbarCocoaLumberjackLogger convertDDLogMessageOptionsToString:logMessage.options],
        @"DDLogMessage.timestamp":
            logMessage.timestamp.description, // !!!!!!!!!!!! *********
        @"DDLogMessage.threadID":
            logMessage.threadID,
        @"DDLogMessage.threadName":
            (nil != logMessage.threadName) ? logMessage.threadName : @"<nil>",
        @"DDLogMessage.queueLabel":
            logMessage.queueLabel,
        @"DDLogMessage.qos":
            [NSNumber numberWithUnsignedInteger:logMessage.qos],
//        @"DDLogMessage.tag":
//            (nil != logMessage.tag) ? [logMessage.tag description] : @"<nil>",
    };
}

+ (NSString *)convertDDLogMessageOptionsToString:(DDLogMessageOptions) options {
    
    NSString *stringValue = [NSString string];
    if (options & DDLogMessageCopyFile) {
        if (stringValue.length > 0) {
            stringValue = [stringValue stringByAppendingString:@" | "];
        }
        stringValue = [stringValue stringByAppendingString:@"DDLogMessageCopyFile"];
    }
    if (options & DDLogMessageCopyFunction) {
        if (stringValue.length > 0) {
            stringValue = [stringValue stringByAppendingString:@" | "];
        }
        stringValue = [stringValue stringByAppendingString:@"DDLogMessageCopyFunction"];
    }
    if (options & DDLogMessageDontCopyMessage) {
        if (stringValue.length > 0) {
            stringValue = [stringValue stringByAppendingString:@" | "];
        }
        stringValue = [stringValue stringByAppendingString:@"DDLogMessageDontCopyMessage"];
    }
    return stringValue;
}

+ (NSString *)convertDDLogLevelToString:(DDLogLevel) logLevel {
    
    switch(logLevel) {
        case DDLogLevelOff:
            return @"DDLogLevelOff";
        case DDLogLevelAll:
            return @"DDLogLevelAll";
        case DDLogLevelInfo:
            return @"DDLogLevelError";
        case DDLogLevelError:
            return @"DDLogLevelError";
        case DDLogLevelDebug:
            return @"DDLogLevelDebug";
        case DDLogLevelWarning:
            return @"DDLogLevelWarning";
        case DDLogLevelVerbose:
            return @"DDLogLevelVerbose";
        default:
            return @"Unexpected_DDLogLevel_value";
    }
}

+ (NSString *)convertDDLogFlagToString:(DDLogFlag) ddLogFlag {
    
    switch(ddLogFlag) {
        case DDLogFlagError:
            return @"DDLogFlagError";
        case DDLogFlagWarning:
            return @"DDLogFlagWarning";
        case DDLogFlagInfo:
            return @"DDLogFlagInfo";
        case DDLogFlagDebug:
            return @"DDLogFlagDebug";
        case DDLogFlagVerbose:
            return @"DDLogFlagVerbose";
        default:
            return @"Unexpected_DDLogFlag_value";
    }
}

+ (RollbarLevel) convertDDLogFlagToRollbarLevel:(DDLogFlag) ddLogFlag {
    
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
