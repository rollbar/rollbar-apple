#import "RollbarHostingProcessUtil.h"

@implementation RollbarHostingProcessUtil

+ (NSString *)getHostingProcessName {
    
    NSString *processName = [[NSProcessInfo processInfo] processName];
    return processName;
}

+ (int)getHostingProcessIdentifier {
    
    int processIdentifier = [[NSProcessInfo processInfo] processIdentifier];
    return processIdentifier;
}

@end
