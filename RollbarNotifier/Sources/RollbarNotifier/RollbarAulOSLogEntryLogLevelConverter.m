//
//  RollbarAulOSLogEntryLogLevelConverter.m
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

#import "RollbarAulOSLogEntryLogLevelConverter.h"

API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos)
@implementation RollbarAulOSLogEntryLogLevelConverter

+ (OSLogEntryLogLevel) RollbarLevelToOSLogEntryLogLevel:(RollbarLevel)value
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos) {

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

+ (RollbarLevel) RollbarLevelFromOSLogEntryLogLevel:(OSLogEntryLogLevel)value
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos) {
    
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

+ (NSString *) OSLogEntryLogLevelToString:(OSLogEntryLogLevel)value 
API_AVAILABLE(macos(10.15))
API_UNAVAILABLE(ios, tvos, watchos) {

    switch (value) {
            
        case OSLogEntryLogLevelUndefined:
            return @"OSLogEntryLogLevelUndefined";
        case OSLogEntryLogLevelDebug:
            return @"OSLogEntryLogLevelDebug";
        case OSLogEntryLogLevelInfo:
            return @"OSLogEntryLogLevelInfo";
        case OSLogEntryLogLevelNotice:
            return @"OSLogEntryLogLevelNotice";
        case OSLogEntryLogLevelError:
            return @"OSLogEntryLogLevelError";
        case OSLogEntryLogLevelFault:
            return @"OSLogEntryLogLevelFault";
    }
}

@end
