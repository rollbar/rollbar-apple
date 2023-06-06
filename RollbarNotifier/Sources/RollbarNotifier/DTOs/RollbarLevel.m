#import "RollbarLevel.h"

@implementation RollbarLevelUtil

+ (NSString *)rollbarLevelToString:(RollbarLevel)value {
    switch (value) {
        case RollbarLevel_Debug:
            return @"debug";
        case RollbarLevel_Info:
            return @"info";
        case RollbarLevel_Warning:
            return @"warning";
        case RollbarLevel_Error:
            return @"error";
        case RollbarLevel_Critical:
            return @"critical";
        default:
            return @"info";
    }
}

+ (RollbarLevel)rollbarLevelFromString:(nullable NSString *)value {
    if (value == nil) {
        return RollbarLevel_Info;
    } else if ([value caseInsensitiveCompare:@"debug"] == NSOrderedSame) {
        return RollbarLevel_Debug;
    } else if ([value caseInsensitiveCompare:@"info"] == NSOrderedSame) {
        return RollbarLevel_Info;
    } else if ([value caseInsensitiveCompare:@"warning"] == NSOrderedSame) {
        return RollbarLevel_Warning;
    } else if ([value caseInsensitiveCompare:@"error"] == NSOrderedSame) {
        return RollbarLevel_Error;
    } else if ([value caseInsensitiveCompare:@"critical"] == NSOrderedSame) {
        return RollbarLevel_Critical;
    } else {
        return RollbarLevel_Info;
    }
}

@end
