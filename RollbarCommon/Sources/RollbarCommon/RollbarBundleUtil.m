#import "RollbarBundleUtil.h"

@implementation RollbarBundleUtil

+ (nonnull NSString *)detectAppBundleVersion {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *major = infoDictionary[@"CFBundleShortVersionString"];
    NSString *minor = infoDictionary[@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"%@.%@", major, minor];
    return version;
}

@end
