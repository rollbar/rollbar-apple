//
//  NSObject+Rollbar.m
//  
//
//  Created by Andrey Kornich on 2021-04-23.
//

#import "NSObject+Rollbar.h"

@implementation NSObject (Rollbar)

- (nonnull NSString *)objectClassName {
    return NSStringFromClass(self.class);
}

@end
