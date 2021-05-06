//
//  RollbarHostingProcessUtil.m
//  
//
//  Created by Andrey Kornich on 2021-05-05.
//

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
