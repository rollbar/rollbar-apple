//
//  RollbarAulOSLogEntryLogLevelConverter.m
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

#import "RollbarAulOSLogEntryLogLevelConverter.h"

@implementation RollbarAulOSLogEntryLogLevelConverter

+ (OSLogEntryLogLevel) RollbarLevelToOSLogEntryLogLevel:(RollbarLevel)value {
    
    switch (value) {
            
        case RollbarLevel_Debug:
            return OSLogEntryLogLevelDebug;
        case RollbarLevel_Info:
            return OSLogEntryLogLevelInfo;
        case RollbarLevel_Warning:
            return OSLogEntryLogLevelNotice;
        case RollbarLevel_Error:
            return OSLogEntryLogLevelError;
        case RollbarLevel_Critical:
            return OSLogEntryLogLevelFault;
    }
}

+ (RollbarLevel) RollbarLevelFromOSLogEntryLogLevel:(OSLogEntryLogLevel)value {
    
    switch (value) {
            
        case OSLogEntryLogLevelUndefined:
        case OSLogEntryLogLevelDebug:
            return RollbarLevel_Debug;
        case OSLogEntryLogLevelInfo:
            return RollbarLevel_Info;
        case OSLogEntryLogLevelNotice:
            return RollbarLevel_Warning;
        case OSLogEntryLogLevelError:
            return RollbarLevel_Error;
        case OSLogEntryLogLevelFault:
            return RollbarLevel_Critical;
    }
}

@end
