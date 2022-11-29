#import "RollbarBundleUtil.h"

@implementation RollbarBundleUtil

+ (nonnull NSString *)detectAppBundleVersion {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (!infoDictionary) {
        return @"n/a";
    }
    NSString *major = infoDictionary[@"CFBundleShortVersionString"];
    NSString *minor = infoDictionary[@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"%@.%@", major, minor];
    return version;
}

@end
