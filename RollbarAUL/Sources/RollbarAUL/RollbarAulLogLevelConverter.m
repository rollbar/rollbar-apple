//
//  RollbarAulLogLevelConverter.m
//  
//
//  Created by Andrey Kornich on 2021-03-24.
//

#import "RollbarAulLogLevelConverter.h"

API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0))
@implementation RollbarAulLogLevelConverter

+ (os_log_type_t) RollbarLevelToAulLevel:(RollbarLevel)value 
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0)) {

    switch (value) {
        case RollbarLevel_Debug:
            return OS_LOG_TYPE_DEBUG;
        case RollbarLevel_Info:
            return OS_LOG_TYPE_INFO;
        case RollbarLevel_Warning:
            return OS_LOG_TYPE_DEFAULT;
        case RollbarLevel_Error:
            return OS_LOG_TYPE_ERROR;
        case RollbarLevel_Critical:
            return OS_LOG_TYPE_FAULT;
    }
}

+ (RollbarLevel) RollbarLevelFromAulLevel:(os_log_type_t)value
API_AVAILABLE(macos(10.11), ios(9.0), tvos(9.0), watchos(2.0)) {

    switch (value) {
        case OS_LOG_TYPE_DEBUG:
            return RollbarLevel_Debug;
        case OS_LOG_TYPE_INFO:
            return RollbarLevel_Info;
        case OS_LOG_TYPE_ERROR:
            return RollbarLevel_Error;
        case OS_LOG_TYPE_FAULT:
            return RollbarLevel_Critical;
        case OS_LOG_TYPE_DEFAULT:
            return RollbarLevel_Warning;
    }
}

@end
