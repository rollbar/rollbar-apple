#import "RollbarOsUtil.h"

@implementation RollbarOsUtil

+ (NSOperatingSystemVersion)detectOsVersion {

    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return version;
}

+ (nonnull NSString *)detectOsVersionString {
    
    NSString *result = [[NSProcessInfo processInfo] operatingSystemVersionString];
    return result;
}

+ (nonnull NSString *)stringFromOsVersion:(NSOperatingSystemVersion)version {
    
    NSString *versionString =
    [NSString stringWithFormat:@"%@.%@.%@", @(version.majorVersion), @(version.minorVersion), @(version.patchVersion)];
    return versionString;
}

+ (NSTimeInterval)detectOsUptimeInterval {
    
    NSTimeInterval result = [[NSProcessInfo processInfo] systemUptime];
    return result;
}

@end
