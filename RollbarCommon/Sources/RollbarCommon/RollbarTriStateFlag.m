#import "RollbarTriStateFlag.h"

@implementation RollbarTriStateFlagUtil

+ (NSString *) TriStateFlagToString:(RollbarTriStateFlag)value {
    
    switch (value) {
        case RollbarTriStateFlag_On:
            return @"ON";
        case RollbarTriStateFlag_Off:
            return @"OFF";
        case RollbarTriStateFlag_None:
        default:
            return @"NONE";
    }
}

+ (RollbarTriStateFlag) TriStateFlagFromString:(NSString *)value {
    
    if (nil == value) {
        return RollbarTriStateFlag_None;
    }
    else if (NSOrderedSame == [value caseInsensitiveCompare:@"ON"]) {
        return RollbarTriStateFlag_On;
    }
    else if (NSOrderedSame == [value caseInsensitiveCompare:@"OFF"]) {
        return RollbarTriStateFlag_Off;
    }
    else {
        return RollbarTriStateFlag_None; // default case...
    }
}

@end
